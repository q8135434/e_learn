# res://core/ecs/systems/infrastructure/touch_input_system.gd
class_name TouchInputSystem extends SystemBase

# 玩家实体引用
var _player_entity: GameEntity = null

func _initialize():
	system_name = "TouchInputSystem"
	system_type = "infrastructure"
	update_priority = 1
	
	set_process_unhandled_input(true)
	print("✅ TouchInputSystem 初始化完成")

# 只绑定玩家
func _on_entity_registered(entity: GameEntity):
	super._on_entity_registered(entity)
	if entity.data.config.entity_type == "player":
		_player_entity = entity
		print("🎮 点击系统绑定玩家: ", entity.data.config.entity_name)

func _on_entity_unregistered(entity: GameEntity):
	super._on_entity_unregistered(entity)
	if entity == _player_entity:
		_player_entity = null
		print("🗑️ 点击系统解绑玩家")

# 输入处理
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		_handle_click(event)

func _handle_click(event: InputEventMouseButton):
	if not _player_entity or not _player_entity.data:
		return
	
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	# 获取点击的世界坐标
	var click_pos = camera.get_global_mouse_position()
	
	# 🎯 关键：射线检测点击的是什么
	var clicked_entity = _raycast_for_entity(click_pos)
	
	if clicked_entity and clicked_entity.data.config.entity_type in ["monster", "boss"]:
		# 🎯 点击了怪物 → 设置攻击目标
		_set_attack_target(clicked_entity, click_pos)
	else:
		# 🎯 点击了空地 → 设置移动目标
		_set_move_target(click_pos)

# 射线检测
func _raycast_for_entity(click_pos: Vector2) -> GameEntity:
	# 直接找离点击位置最近的怪物
	var nearest_entity = null
	var nearest_distance = 50.0  # 最大点击距离
	
	# 检查所有怪物
	for monster_type in ["monster", "boss"]:
		for entity in EntityRegistry.get_entities_by_type(monster_type):
			var distance = click_pos.distance_to(entity.global_position)
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_entity = entity
	
	print("🔍 手动检测: 距离=", nearest_distance, " 实体=", 
		  nearest_entity.data.config.entity_name if nearest_entity else "无")
	
	return nearest_entity

# 🎯 设置移动目标（使用你的click_target字段）
func _set_move_target(click_pos: Vector2):
	var runtime = _player_entity.data.runtime
	
	runtime.click_target = {
		"type": "move",
		"position": click_pos,
		"entity_id": ""
	}
	
	print("🎯 设置移动目标 -> ", click_pos)

# 🎯 设置攻击目标（使用你的click_target字段）
func _set_attack_target(target_entity: GameEntity, click_pos: Vector2):
	var runtime = _player_entity.data.runtime
	
	print("🎯 开始设置攻击目标:")
	print("   点击位置: ", click_pos)
	print("   目标实体: ", target_entity.data.config.entity_name)
	print("   目标ID: ", target_entity.data.config.entity_id)
	print("   目标类型: ", target_entity.data.config.entity_type)
	
	runtime.click_target = {
		"type": "attack",
		"position": click_pos,
		"entity_id": target_entity.data.config.entity_id
	}
	
	print("✅ 设置完成: ", runtime.click_target)

# 这个系统不需要每帧处理实体
func _process_entity(_entity: GameEntity, _delta: float):
	pass

func _should_process_entity(_entity: GameEntity) -> bool:
	return false

# 调试信息
func get_system_info() -> Dictionary:
	var info = super.get_system_info()
	info["player_bound"] = _player_entity != null
	
	if _player_entity:
		var click = _player_entity.data.runtime.click_target
		info["current_click_target"] = click.type
		if click.type == "attack":
			info["target_entity_id"] = click.entity_id
	
	return info
