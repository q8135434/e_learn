# 高频变化的运行时数据
class_name RuntimeData extends Resource

# 状态标志位定义（使用位运算，支持多个状态同时存在）
enum StateFlags {
	IN_BATTLE = 1,       # 战斗中 - 影响自动回血回蓝、某些技能效果
	POISONED = 2,        # 中毒 - 持续扣血，影响移动速度
	FROZEN = 4,          # 冰冻 - 无法移动和攻击，防御力提升
	PARALYZED = 8,       # 麻痹 - 无法移动，可以攻击但命中率下降
	INVISIBLE = 16,      # 隐身 - 怪物无法发现，攻击后显形
	HIDDEN = 32,         # 潜行 - 移动速度下降，怪物较难发现
	DEAD = 64,           # 死亡 - 无法进行任何操作，等待复活
	TRANSMITTING = 128,  # 传送中 - 无敌状态，无法被攻击
	SILENCED = 256,      # 沉默 - 无法使用技能，只能普通攻击
	STUNNED = 512        # 眩晕 - 无法移动和攻击，防御力下降
}
# 使用示例：
# 设置状态：state_flags |= StateFlags.POISONED | StateFlags.SILENCED
# 清除状态：state_flags &= ~StateFlags.POISONED
# 检查状态：(state_flags & StateFlags.POISONED) != 0

# 战斗属性容器（统一类型）
var combat: CombatAttributesBase = null

# 位置和移动相关
var position: Vector2 = Vector2.ZERO
var velocity: Vector2 = Vector2.ZERO
var rotation: float = 0.0
var move_direction: Vector2 = Vector2.ZERO
var is_active: bool = true

# 生命值和状态
var current_health: int = 100
var current_mana: int = 50

# 经验与等级
var experience: int = 0
var level: int = 1

# 状态标志
var state_flags: int = 0

# 玩家显示名称
var nickname: String = ""

func _init(initial_position: Vector2 = Vector2.ZERO):
	position = initial_position
	
# 伤害和治疗
func take_damage(damage: int):
	current_health -= damage
	current_health = max(0, current_health)
	if current_health == 0:
		set_state_flag(StateFlags.DEAD)

func heal(amount: int):
	current_health += amount
	current_health = min(current_health, get_max_health())
	if current_health > 0 and has_state_flag(StateFlags.DEAD):
		clear_state_flag(StateFlags.DEAD)
		
# 状态检查
func is_alive() -> bool:
	return current_health > 0 and not has_state_flag(StateFlags.DEAD)
	
# 状态标志方法
func set_state_flag(flag: int):
	state_flags |= flag

func clear_state_flag(flag: int):
	state_flags &= ~flag

func has_state_flag(flag: int) -> bool:
	return (state_flags & flag) != 0

func get_active_states() -> Array:
	var states = []
	for flag in StateFlags.values():
		if has_state_flag(flag):
			states.append(StateFlags.keys()[StateFlags.values().find(flag)])
	return states

# 基础属性访问
func get_health() -> int:
	return current_health

func get_max_health() -> int:
	return combat.get_max_health() if combat else 0
	
func get_mana() -> int:
	return current_mana

func get_max_mana() -> int:
	return combat.get_max_mana() if combat else 0
	
func get_min_attack() -> int:
	return combat.get_min_attack() if combat else 0

func get_max_attack() -> int:
	return combat.get_max_attack() if combat else 0

func get_min_magic_attack() -> int:
	return combat.get_min_magic_attack() if combat else 0

func get_max_magic_attack() -> int:
	return combat.get_max_magic_attack() if combat else 0
	
func get_min_defense() -> int:
	return combat.get_min_defense() if combat else 0

func get_max_defense() -> int:
	return combat.get_max_defense() if combat else 0

func get_min_magic_defense() -> int:
	return combat.get_min_magic_defense() if combat else 0
	
func get_max_magic_defense() -> int:
	return combat.get_max_magic_defense() if combat else 0

func get_accuracy() -> int:
	return combat.get_accuracy() if combat else 0

func get_agility() -> int:
	return combat.get_agility() if combat else 0

func get_luck() -> int:
	return combat.get_luck() if combat else 0

func get_curse() -> int:
	return combat.get_curse() if combat else 0

func get_magic_dodge() -> float:
	return combat.get_magic_dodge() if combat else 0.0

func get_critical_rate() -> float:
	return combat.get_critical_rate() if combat else 0.0

func get_attack_speed() -> float:
	return combat.get_attack_speed() if combat else 0.0
	
# 序列化
func serialize() -> Dictionary:
	var data = {
		"position": {"x": position.x, "y": position.y},
		"current_health": current_health,
		"current_mana": current_mana,
		"experience": experience,
		"level": level,
		"state_flags": state_flags,
		"nickname": nickname
	}
	
	# 序列化战斗属性
	if combat:
		data["combat_type"] = combat.get_class_name()  # 存储具体类型
		data["combat"] = combat.serialize()
	
	return data

# 反序列化
func deserialize(data: Dictionary):
	position = Vector2(data.get("position", {}).get("x", 0), data.get("position", {}).get("y", 0))
	current_health = data.get("current_health", 0)
	current_mana = data.get("current_mana", 0)
	experience = data.get("experience", 0)
	level = data.get("level", 1)
	state_flags = data.get("state_flags", 0)
	nickname = data.get("nickname", "")
	
	# 反序列化战斗属性
	var combat_type = data.get("combat_type", "")
	var combat_data = data.get("combat", {})
	
	match combat_type:
		"MonsterCombatAttributes":
			combat = MonsterCombatAttributes.new()
		"PlayerCombatAttributes":
			combat = PlayerCombatAttributes.new()
	
	if combat:
		combat.deserialize(combat_data)
