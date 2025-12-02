extends Control


func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_button_pressed() -> void:
	_goto_game_scene()
	

func _goto_game_scene() -> void:
	# 这里是id存的；
	var _scene_id:String = Game.data.scene_navigation.persistent_scene_id
	var _scene_path:String = "res://scenes/maps/%s.tscn" % _scene_id
	_scene_path = "res://scenes/test/test_ecs.tscn"
	Game.change_game_scene(_scene_path,{})
