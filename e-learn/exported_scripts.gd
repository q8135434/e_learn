@tool
extends EditorScript

const EXPORT_FILE := "exported_scripts.txt"

func _init() -> void:
	# 1) 导出所有 .gd 文件
	_export_all_scripts()
	

# ---------- 1. 导出脚本 ----------
func _export_all_scripts() -> void:
	var files := _list_all_gd_files("res://")
	var content := ""
	for path in files:
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			content += "\n\n==== %s ====\n" % path
			content += file.get_as_text()
			file.close()
	var out := FileAccess.open(EXPORT_FILE, FileAccess.WRITE)
	out.store_string(content)
	out.close()
	print("📁 已导出 %d 个脚本 -> %s" % [files.size(), EXPORT_FILE])

# 递归收集 .gd
func _list_all_gd_files(dir: String) -> PackedStringArray:
	var list := PackedStringArray()
	var dir_access := DirAccess.open(dir)
	if dir_access:
		dir_access.list_dir_begin()
		var name := dir_access.get_next()
		while name != "":
			var full := dir + "/" + name
			if dir_access.current_is_dir() and not name.begins_with("."):
				list.append_array(_list_all_gd_files(full))
			elif name.ends_with(".gd"):
				list.append(full)
			name = dir_access.get_next()
	return list
