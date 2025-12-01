# 统一数据管理容器，支持响应式数据变更
class_name EntityData extends Resource

# 数据组件引用
var runtime: RuntimeData = null
var config: ConfigData = null

# === 数据变更信号 ===
signal data_changed(property_name: String, old_value, new_value)
signal position_changed(old_pos: Vector2, new_pos: Vector2)
signal health_changed(old_health: int, new_health: int)
signal mana_changed(old_mana: int, new_mana: int)

# 构造函数
func _init(
	runtime_data: RuntimeData = null, 
	config_data: ConfigData = null
):
	runtime = runtime_data if runtime_data else RuntimeData.new()
	config = config_data if config_data else ConfigData.new()

# 转发运行时组件变更信号
func _on_runtime_data_changed(property: String, old_value, new_value):
	data_changed.emit("runtime", property, old_value, new_value)

# === 基础数据访问 ===
func set_position(new_position: Vector2) -> void:
	if runtime.position != new_position:
		var old_position = runtime.position
		runtime.position = new_position
		position_changed.emit(old_position, new_position)

# === 状态检查 ===
func is_alive() -> bool:
	return runtime.is_alive()
	
func has_state_flag(state_flag: int) -> bool:
	return runtime.has_state_flag(state_flag)

func set_state_flag(state_flag: int) -> void:
	var old_flags = runtime.state_flags
	runtime.set_state_flag(state_flag)
	if runtime.state_flags != old_flags:
		data_changed.emit("state_flags", old_flags, runtime.state_flags)

func clear_state_flag(state_flag: int) -> void:
	var old_flags = runtime.state_flags
	runtime.clear_state_flag(state_flag)
	if runtime.state_flags != old_flags:
		data_changed.emit("state_flags", old_flags, runtime.state_flags)

func get_active_states() -> Array:
	return runtime.get_active_states()

# === 伤害和治疗 ===
func take_damage(damage: int) -> void:
	var old_health = runtime.current_health
	runtime.take_damage(damage)
	health_changed.emit(old_health, runtime.current_health)

func heal(amount: int) -> void:
	var old_health = runtime.current_health
	runtime.heal(amount)
	health_changed.emit(old_health, runtime.current_health)

# === 工具方法 ===
func get_display_name() -> String:
	# 优先使用运行时昵称，没有则使用配置名称
	if runtime.nickname != "":
		return runtime.nickname
	return config.get_display_name()

func get_character_class() -> String:
	return config.character_class

# === 战斗属性访问（委托给RuntimeData）===
func get_position() -> Vector2: return runtime.position
	
func get_level() -> int: return runtime.level

func get_experience() -> int: return runtime.experience
	
func get_health() -> float: return runtime.get_health()

func get_max_health() -> float: return runtime.get_max_health()

func get_mana() -> float: return runtime.get_mana()

func get_max_mana() -> float: return runtime.get_max_mana()

func get_min_attack() -> int:return runtime.get_min_attack()

func get_max_attack() -> int:return runtime.get_max_attack()

func get_min_magic_attack() -> int:return runtime.get_min_()

func get_max_magic_attack() -> int:return runtime.get_max_magic_attack()

func get_min_defense() -> int:return runtime.get_min_defense()

func get_max_defense() -> int:return runtime.get_max_defense()

func get_min_magic_defense() -> int:return runtime.get_min_magic_defense()
	
func get_max_magic_defense() -> int:return runtime.get_max_magic_defense()

func get_accuracy() -> int:return runtime.get_accuracy()

func get_agility() -> int:return runtime.get_agility()

func get_luck() -> int:return runtime.get_luck()

func get_curse() -> int:return runtime.get_curse()

func get_critical_rate() -> float:return runtime.get_critical_rate()

func get_magic_dodge() -> float:return runtime.get_magic_dodge()

func get_attack_speed() -> float:return runtime.get_attack_speed()

# 序列化数据（用于存档）
func serialize() -> Dictionary:
	return {
		"runtime": runtime.serialize(),
		"config": config.serialize()
	}

# 反序列化数据
func deserialize(data: Dictionary):
	if data.has("runtime"):
		runtime.deserialize(data["runtime"])
	if data.has("config"):
		config.deserialize(data["config"])
