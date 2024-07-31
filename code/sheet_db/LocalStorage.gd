extends Node

const SAVE_FILE_PATH = "user://data.dat"
var config = ConfigFile.new()

func save(content):
	if content == null:
		push_warning("Failed to save data")
		return {'status': ERR_INVALID_DATA}
		
	print(typeof(content), TYPE_DICTIONARY)
	assert(typeof(content) == TYPE_DICTIONARY)

	# save data
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_var(content)
	
	print("%s Saved" % content['version'])
	
	return {
		'status': OK, 
		'version': content.version
	}


func load_save():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		var data = file.get_var(true)
		if data:
			print("%s Loaded" % data.version)
			return {
				'status': OK,
				'data': data,
				'version': data.version
			}

	return {
		'status': ERR_FILE_NOT_FOUND,
		'error': 'No local file'
	}

#
func delete():
	print("Deleting local save...")
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
		return OK
	
	return ERR_DOES_NOT_EXIST
	
