# res://core/ecs/data/combat/monster_combat_attributes.gd
class_name MonsterCombatAttributes extends CombatAttributesBase

@export var base: AttributeLayer = AttributeLayer.new()  # 配表数据
@export var buff: AttributeLayer = AttributeLayer.new()  # Buff加成

# 重写计算方法（基础 + Buff）
func get_health() -> int:
	return base.health + buff.health

func get_mana() -> int:
	return base.mana + buff.mana

func get_min_attack() -> int:
	return base.min_attack + buff.min_attack

func get_max_attack() -> int:
	return base.max_attack + buff.max_attack

func get_min_magic_attack() -> int:
	return base.min_magic_attack + buff.min_magic_attack

func get_max_magic_attack() -> int:
	return base.max_magic_attack + buff.max_magic_attack
	
func get_min_defense() -> int:
	return base.min_defense + buff.min_defense

func get_max_defense() -> int:
	return base.max_defense + buff.max_defense

func get_min_magic_defense() -> int:
	return base.min_magic_defense + buff.min_magic_defense
	
func get_max_magic_defense() -> int:
	return base.max_magic_defense + buff.max_magic_defense
	
func get_accuracy() -> int:
	return base.accuracy + buff.accuracy

func get_agility() -> int:
	return base.agility + buff.agility

func get_luck() -> int:
	return base.luck + buff.luck

func get_curse() -> int:
	return base.curse + buff.curse

func get_magic_dodge() -> float:
	return base.magic_dodge + buff.magic_dodge

func get_critical_rate() -> float:
	return base.critical_rate + buff.critical_rate

func get_attack_speed() -> float:
	return base.attack_speed + buff.attack_speed

# 序列化
func serialize() -> Dictionary:
	#var data = super.serialize()
	#data["buff"] = buff.serialize()
	return base.serialize()

# 反序列化
func deserialize(data: Dictionary):
	#super.deserialize(data)
	#if data.has("buff"):
		#buff.deserialize(data["buff"])
		#
	base.deserialize(data)
