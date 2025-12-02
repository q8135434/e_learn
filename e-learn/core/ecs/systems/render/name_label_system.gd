# res://core/ecs/systems/render/name_label_system.gd
class_name NameLabelSystem
extends SystemBase

# 名字数据类
class NameLabelData:
	var entity: GameEntity
	var world_position: Vector2
	var is_visible: bool
	var entity_name: String
	var entity_type: String
	var should_show_name: bool  # 🆕 是否应该显示名字
	
	func _init(entity_ref: GameEntity):
		entity = entity_ref
		update_data()
	
	func update_data():
		if is_instance_valid(entity) and entity.data:
			var runtime = entity.data.runtime
			var config = entity.data.config
			var base_name = runtime.nickname if runtime.nickname != "" else config.entity_name

			world_position = entity.data.get_position()
			is_visible = entity.data.is_alive() and entity.data.runtime.is_active
			entity_name = base_name
			entity_type = entity.data.config.entity_type
			
			# 🆕 判断是否显示名字：BOSS始终显示，其他实体受伤才显示
			# BOSS和玩家始终显示，其他实体受伤才显示
			if entity_type == "boss" or entity_type == "player":
				should_show_name = true  # BOSS和玩家始终显示
			else:
				# 其他实体：受伤（当前血量 < 最大血量）才显示
				var current_health = entity.data.get_health()
				var max_health = entity.data.get_max_health()
				should_show_name = current_health < max_health
				

var _name_labels: Array[NameLabelData] = []
var _font: Font

func _initialize():
	system_name = "NameLabelSystem"
	system_type = "render"
	#update_priority = 96
	
	# 创建字体
	_font = _create_font()
	
	# 🎯 修复：使用Y Sort而不是CanvasLayer
	z_index = 90  # 设置较高的Z Index
	z_as_relative = false
	
	print("NameLabelSystem 初始化完成")

func _create_font() -> Font:
	# Godot 4.x 最简单的方法
	return ThemeDB.fallback_font

func _should_process_entity(entity: GameEntity) -> bool:
	return entity.data.config.entity_type in ["player", "monster", "npc", "boss"]

func _on_entity_registered(entity: GameEntity):
	if _should_process_entity(entity):
		var name_label = NameLabelData.new(entity)
		_name_labels.append(name_label)
		print("✅ 名字系统注册实体: ", entity.data.get_display_name())

func _on_entity_unregistered(entity: GameEntity):
	for i in range(_name_labels.size() - 1, -1, -1):
		if _name_labels[i].entity == entity:
			_name_labels.remove_at(i)
			print("🗑️ 名字系统移除实体: ", entity.data.get_display_name())
			break

func process_system(_delta: float):
	if not enabled:
		return
	
	# 更新所有名字数据
	for name_label in _name_labels:
		name_label.update_data()
	
	queue_redraw()

func _draw():
	for name_label in _name_labels:
		if name_label.is_visible and name_label.should_show_name:
			_draw_single_name_label(name_label)

func _draw_single_name_label(name_label: NameLabelData):
	var screen_pos = name_label.world_position
	
	var health_bar_y_offset = -60 if name_label.entity_type == "player" else -40
	
	# 🎯 名字在血条下方（血条高度6 + 间距）
	screen_pos.y += health_bar_y_offset + 30  # 血条下方10像素
	
	var font_size = 12
	var text = name_label.entity_name
	var health_bar_width = 50
	
	# 使用血条宽度居中
	var text_pos = Vector2(
		screen_pos.x - health_bar_width / 2.0,
		screen_pos.y
	)
	
	var name_color = Color.RED if name_label.entity_type == "boss" else Color.WHITE
	
	# 黑色描边
	draw_string(_font, text_pos + Vector2(-1, 0), text, HORIZONTAL_ALIGNMENT_CENTER, health_bar_width, font_size, Color.BLACK)
	draw_string(_font, text_pos + Vector2(1, 0), text, HORIZONTAL_ALIGNMENT_CENTER, health_bar_width, font_size, Color.BLACK)
	draw_string(_font, text_pos + Vector2(0, -1), text, HORIZONTAL_ALIGNMENT_CENTER, health_bar_width, font_size, Color.BLACK)
	draw_string(_font, text_pos + Vector2(0, 1), text, HORIZONTAL_ALIGNMENT_CENTER, health_bar_width, font_size, Color.BLACK)
	
	# 主体文字
	draw_string(_font, text_pos, text, HORIZONTAL_ALIGNMENT_CENTER, health_bar_width, font_size, name_color)

func _draw_name_with_outline(txt_name: String, pos: Vector2, text_color: Color, font_size: int):
	var outline_offset = 1
	
	# 黑色描边
	draw_string(_font, pos + Vector2(-outline_offset, 0), txt_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
	draw_string(_font, pos + Vector2(outline_offset, 0), txt_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
	draw_string(_font, pos + Vector2(0, -outline_offset), txt_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
	draw_string(_font, pos + Vector2(0, outline_offset), txt_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.BLACK)
	
	# 主体文字
	draw_string(_font, pos, txt_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

# 🆕 强制显示某个实体的名字（用于特殊情况下）
func force_show_name(entity: GameEntity, show_name: bool = true):
	for name_label in _name_labels:
		if name_label.entity == entity:
			name_label.should_show_name = show_name
			break

# 调试信息
func get_system_info() -> Dictionary:
	var info = super.get_system_info()
	info["name_label_count"] = _name_labels.size()
	
	# 统计显示中的名字数量
	var showing_count = 0
	for name_label in _name_labels:
		if name_label.should_show_name:
			showing_count += 1
	info["showing_name_count"] = showing_count
	
	return info
