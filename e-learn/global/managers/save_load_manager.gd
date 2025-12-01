class_name SaveLoadManager extends RefCounted

const SAVE_DIR = "user://saves/"
const POINTER_FILE = "user://save_pointer.dat"
const MAX_SAVES = 5
const SECRET_KEY :String = "Gdot"

var current_pointer :int = 0
var pointer_hash

func _init() -> void:
	# 确保存档目录存在
	verify_save_directoty(SAVE_DIR)
	# 加载当前指针
	load_pointer()

#验证目录是否合法
func verify_save_directoty(path:String) -> void:
	DirAccess.make_dir_absolute(path)
	
func save_game(data: Dictionary) -> bool:
	# 创建新的存档文件
	var new_save_id = (current_pointer + 1) % MAX_SAVES
	var save_path = SAVE_DIR + "save_" + str(new_save_id) + ".dat"
	
	# 密钥
	var _s_key :String = OS.get_unique_id() + SECRET_KEY
	# 写入新的存档文件
	var file := FileAccess.open_encrypted_with_pass(save_path,FileAccess.WRITE,_s_key)
	if file:
		# Todo
		var json_string := JSON.stringify(data)
		file.store_string(json_string)
		file.close()
		
		# 更新指针
		# 使用Crypto类计算SHA256哈希值
		pointer_hash = json_string.hash()
		current_pointer = new_save_id
		save_pointer()
		return true
	else:
		print("Error saving game: ")
		return false

func load_game() -> Dictionary:
	var data = {}
	
	# 从最新的存档开始尝试加载
	for i in range(MAX_SAVES):
		var save_id = (current_pointer - i + MAX_SAVES) % MAX_SAVES
		var save_path = SAVE_DIR + "save_" + str(save_id) + ".dat"
		
		# 密钥
		var _s_key :String = OS.get_unique_id() + SECRET_KEY
		
		if FileAccess.file_exists(save_path):
			var file :FileAccess = FileAccess.open_encrypted_with_pass(save_path,FileAccess.READ,_s_key)
			if file:
				var content := file.get_as_text()
				file.close()
				if content.hash() == pointer_hash:
					data = JSON.parse_string(content)
					return data
	
	print("No valid save file found")
	return data

func save_pointer():
	# 写入新的存档文件
	var file := FileAccess.open_encrypted_with_pass(POINTER_FILE,FileAccess.WRITE,OS.get_unique_id())
	if file:
		# Todo
		var json_string := JSON.stringify({"current_pointer":current_pointer,"pointer_hash":pointer_hash})
		file.store_string(json_string)
		file.close()
	else:
		print("Error saving pointer")

func load_pointer():
	if FileAccess.file_exists(POINTER_FILE):
		var file :FileAccess = FileAccess.open_encrypted_with_pass(POINTER_FILE,FileAccess.READ,OS.get_unique_id())
		if file:
			var content := file.get_as_text()
			file.close()
			var data :Dictionary = JSON.parse_string(content)
			if data.has("current_pointer"):
				current_pointer = data.current_pointer
			if data.has("pointer_hash"):
				pointer_hash = data.pointer_hash
		
func clear_all_saves():
	var dir = DirAccess.open(SAVE_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("发现目录：" + file_name)
			else:
				print("发现文件：" + file_name)
				dir.remove(SAVE_DIR + file_name)
			file_name = dir.get_next()
	else:
		print("尝试访问路径时出错。")
	
	# 重置指针
	current_pointer = 0
	save_pointer()
