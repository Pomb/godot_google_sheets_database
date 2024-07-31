extends Node

@onready var http_request = $HTTPRequest
@onready var local_storage = $LocalStorage
@onready var transformer = $Transformer

var google_sheets_url
var sheet_id
var database_tab_id
var version_tab_id
var api_key
var tab

var _data
var _current_version = "0.0.0"

signal on_event

func _ready():
	http_request.request_completed.connect(_on_request_completed)
	_load_api_key()


func _load_api_key():
	var config = ConfigFile.new()
	var err = config.load("res://code/sheet_db/SecretConfig.cfg")
	if err == OK:
		err = _extract_config(config)
		if err != OK:
			_throw('error', {'error': 'Failed to load config', 'code': err})
	else:
		_throw('error', {'error': 'Failed to load API key from config file', 'code': ERR_CANT_ACQUIRE_RESOURCE})


func _extract_config(config):
	google_sheets_url = config.get_value("urls", "google_sheets")
	api_key = config.get_value("secrets", "sheets_api_key")
	sheet_id = config.get_value("sheet", "id")
	database_tab_id = config.get_value("tab", "db")
	version_tab_id = config.get_value("tab", "version")
	
	if(google_sheets_url && api_key && sheet_id && database_tab_id && version_tab_id):
		return OK

	return ERR_FILE_CORRUPT


func initialize():
	var err = _try_load_from_disk()
	if err != OK:
		push_warning('Failed to load from disk %s' % str(err))

	# Check for updates
	_fetch(version_tab_id)


func download_latest():
	print("downloading latest data...")
	_fetch(database_tab_id)


func clear_data():
	print("Clearing data...")
	var res = local_storage.delete()
	if res == OK:
		_data = null
		_current_version = '0.0.0'
		_event('clear', {'version': _current_version, "clear": true})

# Fetches data from a a specific sheet tab
func _fetch(target_tab):
	tab = target_tab
	var e = 'loading'

	if tab == version_tab_id:
		e = 'check_version'
	_event(e)

	var url = google_sheets_url % [sheet_id, target_tab, api_key]
	var error = http_request.request(url)

	if error != OK:
		_throw('Fetch request failed %d', error)


# The response from the request
func _on_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		_event('error', {'error': 'Failed to fetch data', 'code': response_code})
		return

	var response = JSON.parse_string(body.get_string_from_utf8())
	if response == null or response.size() == 0:
		_throw('Response failure', ERR_UNAVAILABLE)
		return
	var latest_version = response.values[0][0]

	match tab:
		version_tab_id:
			print("Version update check: ", " ".join([str(_current_version), '->', str(latest_version)]))
			
			# No data ever downloaded
			if(_current_version == '0.0.0'):
				download_latest()
				return

			if (_current_version == latest_version && _data != null): 
				_event("up_to_date", {'version': _current_version})
				return

			# Check local disk
			var err = _try_load_from_disk()
			if err != OK:
				print("No local data on disk...")
				download_latest()
				return

			# New data on the server that isn't on local disk
			if(_current_version != latest_version):
				_event('update_available', {'version': _current_version, 'update': latest_version})
				return
			
		database_tab_id:
			print("Downloaded database")
			_data = transformer.transform(response.values)
			_event('data', {'data': _data, 'version': latest_version})
			var res = local_storage.save(_data)
			if res.status == OK:
				_event('saved', {'version': res.version})
		_:
			_event('error', {'error': 'unknown tab %s' % tab, 'code': 0})


func _try_load_from_disk():
	print("Load local data...")
	var res = local_storage.load_save()
	if res.status == OK:
		_current_version = res.version
		_data = res.data
		_event('local', {'version': res.version, 'data': res.data})
	return res.status


func _throw(err, code):
	_event('error', {'error': err, 'code': code})


func _event(e, payload = {}):
	on_event.emit(DBResult.new(e, payload))
