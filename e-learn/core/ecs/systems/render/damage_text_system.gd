# damage_text_system.gd
class_name DamageTextSystem extends SystemBase

# 飘字数据类
class DamageTextData:
	var world_position: Vector2
	var text: String
	var color: Color
	var lifetime: float
	var velocity: Vector2
	var scale: float
	var creation_time: float
	var is_critical: bool
	
	func _init(pos: Vector2, txt: String, col: Color, life: float, vel: Vector2, critical: bool = false):
		world_position = pos
		text = txt
		color = col
		lifetime = life
		velocity = vel
		scale = 1.0
		creation_time = Time.get_ticks_msec()
		is_critical = critical

var _active_texts: Array[DamageTextData] = []
var _font: Font

func _initialize():
	system_name = "DamageTextSystem"
	system_type = "render"
	#update_priority = 97
	
	# 🎯 修复：使用Y Sort而不是CanvasLayer
	z_index = 10  # 设置较高的Z Index
	z_as_relative = false
	
	# 创建字体
	_font = _create_font()
	print("✅ DamageTextSystem 初始化完成")

func _create_font() -> Font:
	return ThemeDB.fallback_font

func _should_process_entity(_entity: GameEntity) -> bool:
	return false

# 显示伤害飘字
func show_damage(world_position: Vector2, damage: int, is_critical: bool = false, is_heal: bool = false):
	# 🎯 严格按传奇风格：伤害负号，治疗正号
	var text = ""
	if is_heal:
		text = "+" + str(damage)  # 治疗：+999
	else:
		text = "-" + str(damage)  # 伤害：-999
	
	# 🎯 严格按传奇风格颜色：
	var color = Color.WHITE  # 普通伤害：白字
	if is_critical:
		color = Color.RED    # 暴击伤害：红字
	elif is_heal:
		color = Color.GREEN  # 治疗：绿字
	
	var lifetime = 1.2
	
	# 🎯 严格按传奇风格动画：往右上方30度斜着上去
	# 传奇飘字特点：先快速弹出，然后缓慢右上方移动
	var base_velocity = Vector2(40, -60)  # 右上方30度方向
	var velocity = base_velocity
	
	var text_data = DamageTextData.new(world_position, text, color, lifetime, velocity, is_critical)
	_active_texts.append(text_data)
	
	# 🎯 暴击特效：稍微大一点，颜色更鲜艳
	if is_critical:
		text_data.scale = 1.3
		text_data.color = Color(1.0, 0.2, 0.2)  # 更鲜艳的红色
		text_data.velocity = Vector2(50, -70)   # 暴击飘得更远
	
	print("💥 显示伤害飘字: ", text, " 暴击: ", is_critical, " 治疗: ", is_heal)

# 显示治疗飘字
func show_heal(world_position: Vector2, heal_amount: int):
	var text = "+" + str(heal_amount)
	var color = Color(0.2, 1.0, 0.2)  # 鲜艳的绿色
	var lifetime = 1.5
	
	# 治疗飘字：右上方飘动，比伤害慢一些
	var velocity = Vector2(30, -50)
	
	var text_data = DamageTextData.new(world_position, text, color, lifetime, velocity)
	_active_texts.append(text_data)

# 显示经验值飘字
func show_experience(world_position: Vector2, exp_amount: int):
	var text_data = DamageTextData.new(
		world_position,
		"经验+" + str(exp_amount),
		Color(0.4, 0.8, 1.0),  # 亮蓝色
		1.8,
		Vector2(35, -55)  # 右上方飘动
	)
	_active_texts.append(text_data)

# 显示金币飘字
func show_gold(world_position: Vector2, gold_amount: int):
	var text_data = DamageTextData.new(
		world_position,
		"金币+" + str(gold_amount),
		Color(1.0, 0.8, 0.2),  # 金色
		1.8,
		Vector2(35, -55)  # 右上方飘动
	)
	_active_texts.append(text_data)

# 显示Miss飘字
func show_miss(world_position: Vector2):
	var text_data = DamageTextData.new(
		world_position,
		"Miss",
		Color(0.7, 0.7, 0.7),  # 灰色
		1.0,
		Vector2(25, -45)  # 右上方飘动
	)
	_active_texts.append(text_data)

# 系统更新：更新飘字状态
func process_system(delta: float):
	if not enabled:
		return
	
	# 更新所有活跃飘字
	_update_active_texts(delta)
	
	# 请求重绘
	queue_redraw()

func _update_active_texts(delta: float):
	var current_time = Time.get_ticks_msec()
	
	# 从后往前遍历，便于删除
	for i in range(_active_texts.size() - 1, -1, -1):
		var text_data = _active_texts[i]
		
		# 🎯 传奇风格：持续往右上方移动，速度基本不变
		text_data.world_position += text_data.velocity * delta
		
		# 🎯 轻微的速度衰减（很慢）
		text_data.velocity = text_data.velocity.lerp(Vector2(10, -15), delta * 0.5)
		
		# 🎯 传奇风格：没有缩放动画，只有位置移动和透明度变化
		
		# 检查生命周期结束
		var elapsed = (current_time - text_data.creation_time) / 1000.0
		if elapsed >= text_data.lifetime:
			_active_texts.remove_at(i)

# 批量绘制所有飘字
func _draw():
	for text_data in _active_texts:
		_draw_single_damage_text(text_data)

func _draw_single_damage_text(text_data: DamageTextData):
	var screen_pos = text_data.world_position
	var base_font_size = 42
	
	# 🎯 计算透明度（传奇风格：快速出现，缓慢消失）
	var elapsed = (Time.get_ticks_msec() - text_data.creation_time) / 1000.0
	var life_ratio = elapsed / text_data.lifetime
	var alpha = 1.0
	
	if life_ratio < 0.1:  # 前10%：快速出现
		alpha = life_ratio / 0.1
	elif life_ratio > 0.5:  # 后50%：缓慢消失
		alpha = 1.0 - ((life_ratio - 0.5) / 0.5)
	
	var font_size = int(base_font_size * text_data.scale)
	var text_color = text_data.color
	text_color.a = alpha
	
	# 🎯 传奇风格：黑色粗描边
	var outline_color = Color(0, 0, 0, alpha * 0.8)
	
	# 计算文本位置（居中）
	var text_size = _font.get_string_size(text_data.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var text_pos = screen_pos - Vector2(text_size.x * 0.5, text_size.y * 0.5)
	
	# 🎯 传奇风格：粗黑色描边（八个方向）
	var offsets = [
		Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
		Vector2(-1, 0),                 Vector2(1, 0),
		Vector2(-1, 1),  Vector2(0, 1),  Vector2(1, 1)
	]
	
	for offset in offsets:
		draw_string(_font, text_pos + offset, text_data.text, 
				   HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, outline_color)
	
	# 主体文字
	draw_string(_font, text_pos, text_data.text, 
			   HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

# 清空所有飘字
func clear_all_texts():
	_active_texts.clear()
	queue_redraw()

# 调试信息
func get_system_info() -> Dictionary:
	var info = super.get_system_info()
	info["active_damage_texts"] = _active_texts.size()
	return info
