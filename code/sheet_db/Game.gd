extends CanvasLayer

@onready var db = $DB
@onready var label = $Control/Label
@onready var version_label = $Control/VersionLabel
@onready var version_update_btn = $Control/VersionLabel/UpdateButton
@onready var error = $Control/Error
@onready var error_label = $Control/Error/Label
@onready var event_label = $Control/EventLabel
@onready var loading_label = $Control/LoadingLabel


func _ready():
	db.on_event.connect(_on_event)
	db.check_or_download_latest()


func _on_event(payload):
	print('on event: ', payload.event)
	loading_label.stop()
	version_update_btn.visible = false
	event_label.visible = true
	event_label.text = payload.event
	delayed_hide(event_label)

	if payload.version:
		version_label.text = payload.version
	
	if payload.clear:
		label.text = ""

	match payload.event:
		'loading':
			loading_label.start()
		'check_version':
			version_label.text = 'checking'
		'update_available':
			version_update_btn.visible = true
		'clear':
			version_update_btn.visible = true
		'error':
			error.visible = true
			error_label.text = '[%s] %s' % [str(payload.code), str(payload.error)]
			delayed_hide(error_label)
		'data':
			label.text = JSON.stringify(payload.data, '\t')
		'local':
			label.text = JSON.stringify(payload.data, '\t')



func delayed_hide(target, duration = 3.0):
	await get_tree().create_timer(duration)
	target.hide()


func _on_update_button_pressed():
	db.download_latest()


func _on_clear_data_pressed():
	db.clear_data()
