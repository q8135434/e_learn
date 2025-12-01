# res://core/ecs/data/combat/combat_attributes_base.gd
class_name CombatAttributesBase extends Resource

# 基础属性访问
func get_health() -> int:
	return 0

func get_mana() -> int:
	return 0

func get_min_attack() -> int:
	return 0

func get_max_attack() -> int:
	return 0

func get_min_magic_attack() -> int:
	return 0

func get_max_magic_attack() -> int:
	return 0
	
func get_min_defense() -> int:
	return 0

func get_max_defense() -> int:
	return 0

func get_min_magic_defense() -> int:
	return 0
	
func get_max_magic_defense() -> int:
	return 0

func get_accuracy() -> int:
	return 0

func get_agility() -> int:
	return 0

func get_luck() -> int:
	return 0

func get_curse() -> int:
	return 0

func get_magic_dodge() -> float:
	return 0

func get_critical_rate() -> float:
	return 0

func get_attack_speed() -> float:
	return 0

# 序列化
func serialize() -> Dictionary:
	return {
	}

# 反序列化
func deserialize(_data: Dictionary):
	pass

func get_class_name() -> String:
	return "CombatAttributesBase"
