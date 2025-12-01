extends Control


func _on_button_2_pressed() -> void:
	get_tree().quit()


func _on_button_pressed() -> void:
	var player = EntityFactory.create_player_from_profile(Vector2(300,300),self)
	
