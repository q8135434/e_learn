# res://core/ecs/data/attribute_layer.gd
class_name AttributeLayer extends Resource

# 基础属性
@export var health: int = 0
@export var mana: int = 0

# 攻击属性
@export var min_attack: int = 0
@export var max_attack: int = 0
@export var min_magic_attack: int = 0    # 最小魔法攻击
@export var max_magic_attack: int = 0    # 最大魔法攻击

# 防御属性
@export var min_defense: int = 0
@export var max_defense: int = 0
@export var min_magic_defense: int = 0
@export var max_magic_defense: int = 0

# 特殊属性
@export var accuracy: int = 0      # 准确
@export var agility: int = 0       # 敏捷
@export var luck: int = 0          # 幸运
@export var curse: int = 0         # 诅咒

# 隐藏属性
@export var magic_dodge: float = 0.0    # 魔法躲避
@export var critical_rate: float = 0.0  # 暴击率
@export var attack_speed: float = 1.0   # 攻击速度

# 序列化
func serialize() -> Dictionary:
	return {
		"health": health,
		"mana": mana,
		"min_attack": min_attack,
		"max_attack": max_attack,
		"min_magic_attack": min_magic_attack,
		"max_magic_attack": max_magic_attack,
		
		"min_defense": min_defense,
		"max_defense": max_defense,
		"min_magic_defense": min_magic_defense,
		"max_magic_defense": max_magic_defense,
		
		"accuracy": accuracy,
		"agility": agility,
		"luck": luck,
		"curse": curse,
		"magic_dodge": magic_dodge,
		"critical_rate": critical_rate,
		"attack_speed": attack_speed
	}

# 反序列化
func deserialize(data: Dictionary):
	health = data.get("health", 0)
	mana = data.get("mana", 0)
	min_attack = data.get("min_attack", 0)
	max_attack = data.get("max_attack", 0)
	min_magic_attack = data.get("min_magic_attack", 0)
	max_magic_attack = data.get("max_magic_attack", 0)
	
	min_defense = data.get("min_defense", 0)
	max_defense = data.get("max_defense", 0)
	min_magic_defense = data.get("min_magic_defense", 0)
	max_magic_defense = data.get("max_magic_defense", 0)
	
	accuracy = data.get("accuracy", 0)
	agility = data.get("agility", 0)
	luck = data.get("luck", 0)
	curse = data.get("curse", 0)
	magic_dodge = data.get("magic_dodge", 0.0)
	critical_rate = data.get("critical_rate", 0.0)
	attack_speed = data.get("attack_speed", 1.0)
