# res://core/ecs/systems/infrastructure/touch_input_system.gd
class_name TouchInputSystem extends SystemBase

# 存储玩家实体引用（应该只有一个）
var _player_entity: GameEntity = null

func _initialize():
	system_name = "TouchInputSystem"
	system_type = "infrastructure"
	update_priority = 1  # 输入系统优先级最高
	
	# 启用输入处理
	set_process_unhandled_input(true)
	
	print("TouchInputSystem 初始化完成")

# 实体注册时检查是否是玩家
func _on_entity_registered(entity: GameEntity):
	super._on_entity_registered(entity)
	
	# 只保留玩家实体引用
	if entity.data.config.entity_type == "player":
		_player_entity = entity
		print("✅ 点击系统注册玩家: ", entity.data.config.entity_name)

# 实体注销时清理
func _on_entity_unregistered(entity: GameEntity):
	super._on_entity_unregistered(entity)
	
	if entity == _player_entity:
		_player_entity = null
		print("🗑️ 点击系统移除玩家: ", entity.data.config.entity_name)

# 处理输入
func _unhandled_input(event):
	# 只处理鼠标左键按下
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		_handle_click(event)

# 处理点击
func _handle_click(event: InputEventMouseButton):
	if not _player_entity or not _player_entity.data:
		return
	
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	# 获取点击的世界坐标
	var click_pos = camera.get_global_mouse_position()
	
	# 设置玩家移动目标
	_set_move_target(_player_entity, click_pos)

# 设置移动目标
func _set_move_target(entity: GameEntity, target_pos: Vector2):
	var runtime = entity.data.runtime
	
	# 设置移动目标
	runtime.click_target.type = "move"
	runtime.click_target.position = target_pos
	runtime.click_target.entity_id = ""
	
	print("🎯 玩家 %s 点击移动到: %s" % [entity.data.config.entity_name, target_pos])

# TouchInputSystem不需要每帧处理实体，所以这个方法空实现
func _process_entity(_entity: GameEntity, _delta: float):
	pass

# 这个系统不需要过滤实体，所有实体都可以注册
func _should_process_entity(_entity: GameEntity) -> bool:
	return false  # 不需要每帧处理实体
