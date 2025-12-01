# 高频变化的运行时数据
class_name RuntimeData extends Resource

# 位置和移动相关
var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var rotation: float = 0.0
var move_direction: Vector2 = Vector2.ZERO

# 生命值和状态
var current_health: float = 100.0
var current_mana: float = 50.0

# 战斗属性（统一类型）
@export var combat: CombatAttributesBase = null

# 状态标志
var state_flags: int = 0
var is_moving: bool = false
var is_attacking: bool = false
var is_dead: bool = false

# 冷却时间
var skill_cooldowns: Dictionary = {}
var global_cooldown: float = 0.0

# 响应式数据变更信号
signal data_changed(property: String, old_value, new_value)

# 安全的属性设置，触发变更信号
func set_property(property: String, value) -> bool:
	if get(property) != value:
		var old_value = get(property)
		set(property, value)
		data_changed.emit(property, old_value, value)
		return true
	return false

# 设置位置
func set_position(value: Vector2) -> void:
	if position != value:
		var old_value = position
		position = value
		data_changed.emit("position", old_value, value)

# 设置速度
func set_velocity(value: Vector2) -> void:
	if velocity != value:
		var old_value = velocity
		velocity = value
		data_changed.emit("velocity", old_value, value)

# 设置死亡状态
func set_is_dead(value: bool) -> void:
	if is_dead != value:
		var old_value = is_dead
		is_dead = value
		data_changed.emit("is_dead", old_value, value)

# 序列化
func serialize() -> Dictionary:
	return {
		"position": {"x": position.x, "y": position.y},
		"velocity": {"x": velocity.x, "y": velocity.y},
		"rotation": rotation,
		"move_direction": {"x": move_direction.x, "y": move_direction.y},
		"current_health": current_health,
		"current_mana": current_mana,
		"state_flags": state_flags,
		"is_moving": is_moving,
		"is_attacking": is_attacking,
		"is_dead": is_dead,
		"skill_cooldowns": skill_cooldowns.duplicate(),
		"global_cooldown": global_cooldown
	}

# 反序列化
func deserialize(data: Dictionary):
	if data.has("position"):
		position = Vector2(data["position"]["x"], data["position"]["y"])
	if data.has("velocity"):
		velocity = Vector2(data["velocity"]["x"], data["velocity"]["y"])
	if data.has("rotation"):
		rotation = data["rotation"]
	if data.has("move_direction"):
		move_direction = Vector2(data["move_direction"]["x"], data["move_direction"]["y"])
	if data.has("current_health"):
		current_health = data["current_health"]
	if data.has("current_mana"):
		current_mana = data["current_mana"]
	if data.has("state_flags"):
		state_flags = data["state_flags"]
	if data.has("is_moving"):
		is_moving = data["is_moving"]
	if data.has("is_attacking"):
		is_attacking = data["is_attacking"]
	if data.has("is_dead"):
		is_dead = data["is_dead"]
	if data.has("skill_cooldowns"):
		skill_cooldowns = data["skill_cooldowns"]
	if data.has("global_cooldown"):
		global_cooldown = data["global_cooldown"]
