class_name TemplateSaver
extends Resource


var save_data_file_name: String = "templates" # Name of save file
var save_data_file_path: String = "user://" + save_data_file_name + ".json" # Path to save file in user data folder

var saved_templates_dictionary: Dictionary = {} # Dictionary with saved data
var is_save_file_exists: bool = false

func _init() -> void:
	#save_data_file_path = "user://" + save_data_file_name + ".json" # You can see user data folder by -> Project -> Open User Data Folder
	if FileAccess.file_exists(save_data_file_path):
		saved_templates_dictionary = load_data()
		is_save_file_exists = true

func save_data(key_name: String, key_value: Array) -> void:
	var save_file: = FileAccess.open(save_data_file_path, FileAccess.WRITE)
	
	saved_templates_dictionary[key_name] = key_value
	
	var json: String = JSON.stringify(saved_templates_dictionary)
	save_file.store_string(json)
	save_file.close()

func load_data() -> Dictionary:
	var load_file: = FileAccess.open(save_data_file_path, FileAccess.READ)
	var json: String = load_file.get_as_text()
	var saved_data: Dictionary = JSON.parse_string(json)
	load_file.close()
	return saved_data
