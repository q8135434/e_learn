extends RefCounted
class_name ConfigManager

const PATH :String = "res://database/"
const LOADKEY:String = "E3967DFBABC33E7A945DD46E2816E5"

var file_list:Array = [
		"item_templates",
		"monster_templates",
		"skill_templates",
		"map_templates",
		"player_templates",
		"skill_levels_templates",
	]
	
var item_templates:Dictionary = {}
var monster_templates:Dictionary = {}
var skill_templates:Dictionary = {}
var map_templates:Dictionary = {}
var player_templates:Dictionary = {}
var skill_levels_templates:Dictionary = {}

func _init() -> void:
	for file_name in file_list:
		_load_data(file_name)
	
func _load_data(file_name:String) -> void:
	var _path:String = PATH + file_name + ".json"
	var file := FileAccess.open_encrypted_with_pass(_path,FileAccess.READ,LOADKEY)
	if file:
		var content := file.get_as_text()
		file.close()
		self[file_name] = _array_data_to_json(JSON.parse_string(content))
		
func _array_data_to_json(array:Array) -> Dictionary:
	var json_data:Dictionary = {}
	for data in array:
		json_data[data.id] = data
	return json_data
