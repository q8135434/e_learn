# res://core/ecs/systems/render/health_bar_system.gd
class_name HealthBarSystem
extends SystemBase

# 血条数据类
class HealthBarData:
	var entity: GameEntity
	var world_position: Vector2
	var health_ratio: float
	var is_visible: bool
	var entity_type: String
	
	func _init(entity_ref: GameEntity):
		entity = entity_ref
		update_data()
	
	func update_data():
		if is_instance_valid(entity) and entity.data:
			world_position = entity.data.get_position()
			health_ratio = entity.data.get_health() / entity.data.get_max_health()
			is_visible = entity.data.is_alive() and entity.data.runtime.is_active
			entity_type = entity.data.config.entity_type

var _health_bars: Array[HealthBarData] = []

func _initialize():
	system_name = "HealthBarSystem"
	system_type = "render"
	#update_priority = 95  # 在精灵之后，UI之前
	
	# 🎯 修复：使用Y Sort而不是CanvasLayer
	z_index = 90  # 设置较高的Z Index
	z_as_relative = false
	
	print("HealthBarSystem 初始化完成")

# 只处理需要血条的实体
func _should_process_entity(entity: GameEntity) -> bool:
	return entity.data.config.entity_type in ["player", "monster", "boss"]

func _process_entity(_entity: GameEntity, _delta: float):
	# 这个系统不按实体处理，而是批量绘制
	pass

func _on_entity_registered(entity: GameEntity):
	if _should_process_entity(entity):
		var health_bar = HealthBarData.new(entity)
		_health_bars.append(health_bar)
		print("✅ 血条系统注册实体: ", entity.data.get_display_name())

func _on_entity_unregistered(entity: GameEntity):
	for i in range(_health_bars.size() - 1, -1, -1):
		if _health_bars[i].entity == entity:
			_health_bars.remove_at(i)
			print("🗑️ 血条系统移除实体: ", entity.data.get_display_name())
			break

# 每帧更新血条数据并重绘
func process_system(_delta: float):
	if not enabled:
		return
	
	# 更新所有血条数据
	for health_bar in _health_bars:
		health_bar.update_data()
	
	# 请求重绘
	queue_redraw()

# 批量绘制所有血条
func _draw():
	for health_bar in _health_bars:
		if health_bar.is_visible:
			_draw_single_health_bar(health_bar)

func _draw_single_health_bar(health_bar: HealthBarData):
	var screen_pos = health_bar.world_position
		
	# 血条在头顶偏移
	var y_offset = -50
	if health_bar.entity_type == "player":
		y_offset = -60
	elif health_bar.entity_type == "monster":
		y_offset = -40
	
	screen_pos.y += y_offset
	
	# 血条尺寸
	var width = 50
	var height = 6
	var border = 1
	
	# 背景（黑色边框）
	draw_rect(Rect2(
		screen_pos.x - width/2.0 - border, 
		screen_pos.y - border, 
		width + border*2, 
		height + border*2
	), Color.BLACK)
	
	# 背景（灰色底）
	draw_rect(Rect2(
		screen_pos.x - width/2.0, 
		screen_pos.y, 
		width, 
		height
	), Color.DARK_GRAY)
	
	# 血量（颜色渐变）
	var health_width = width * health_bar.health_ratio
	var health_color = _get_health_color(health_bar.health_ratio, health_bar.entity_type)
	
	if health_width > 0:
		draw_rect(Rect2(
			screen_pos.x - width/2.0, 
			screen_pos.y, 
			health_width, 
			height
		), health_color)

func _get_health_color(ratio: float, entity_type: String) -> Color:
	# 传奇风格颜色渐变
	if entity_type == "player":
		# 玩家血条：绿→黄→红
		if ratio > 0.6:
			return Color.GREEN
		elif ratio > 0.3:
			return Color.YELLOW
		else:
			return Color.RED
	else:
		# 怪物血条：红→橙→黄
		if ratio > 0.6:
			return Color.RED
		elif ratio > 0.3:
			return Color.ORANGE
		else:
			return Color.YELLOW

# 调试信息
func get_system_info() -> Dictionary:
	var info = super.get_system_info()
	info["health_bar_count"] = _health_bars.size()
	return info
