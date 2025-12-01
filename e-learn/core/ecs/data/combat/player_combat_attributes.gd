# res://core/ecs/data/combat/player_combat_attributes.gd
class_name PlayerCombatAttributes extends CombatAttributesBase

@export var job: AttributeLayer = AttributeLayer.new()       # 职业基础数据
@export var level: AttributeLayer = AttributeLayer.new()     # 等级加成
@export var equipment: AttributeLayer = AttributeLayer.new() # 装备加成  
@export var buff: AttributeLayer = AttributeLayer.new()      # Buff加成
@export var passive: AttributeLayer = AttributeLayer.new()   # 🆕 被动技能加成

# 计算方法（职业基础 + 等级 + 装备 + Buff + 被动技能）
func get_health() -> int:
	return job.health + level.health + equipment.health + buff.health + passive.health

func get_mana() -> int:
	return job.mana + level.mana + equipment.mana + buff.mana + passive.mana

func get_min_attack() -> int:
	return job.min_attack + level.min_attack + equipment.min_attack + buff.min_attack + passive.min_attack

func get_max_attack() -> int:
	return job.max_attack + level.max_attack + equipment.max_attack + buff.max_attack + passive.max_attack

func get_min_magic_attack() -> int:
	return job.min_magic_attack + level.min_magic_attack + equipment.min_magic_attack + buff.min_magic_attack + passive.min_magic_attack

func get_max_magic_attack() -> int:
	return job.max_magic_attack + level.max_magic_attack + equipment.max_magic_attack + buff.max_magic_attack + passive.max_magic_attack
	
func get_min_defense() -> int:
	return job.min_defense + level.min_defense + equipment.min_defense + buff.min_defense + passive.min_defense

func get_max_defense() -> int:
	return job.max_defense + level.max_defense + equipment.max_defense + buff.max_defense + passive.max_defense

func get_min_magic_defense() -> int:
	return job.min_magic_defense + level.min_magic_defense + equipment.min_magic_defense + buff.min_magic_defense + passive.min_magic_defense
	
func get_max_magic_defense() -> int:
	return job.max_magic_defense + level.max_magic_defense + equipment.max_magic_defense + buff.max_magic_defense + passive.max_magic_defense
	
func get_accuracy() -> int:
	return job.accuracy + level.accuracy + equipment.accuracy + buff.accuracy + passive.accuracy

func get_agility() -> int:
	return job.agility + level.agility + equipment.agility + buff.agility + passive.agility

func get_luck() -> int:
	return job.luck + level.luck + equipment.luck + buff.luck + passive.luck

func get_curse() -> int:
	return job.curse + level.curse + equipment.curse + buff.curse + passive.curse

func get_magic_dodge() -> float:
	return job.magic_dodge + level.magic_dodge + equipment.magic_dodge + buff.magic_dodge + passive.magic_dodge

func get_critical_rate() -> float:
	return job.critical_rate + level.critical_rate + equipment.critical_rate + buff.critical_rate + passive.critical_rate

func get_attack_speed() -> float:
	return job.attack_speed + level.attack_speed + equipment.attack_speed + buff.attack_speed + passive.attack_speed

# 序列化
func serialize() -> Dictionary:
	return {
		"job": job.serialize(),
		"level": level.serialize(),
		"equipment": equipment.serialize(),
		"buff": buff.serialize(),
		"passive": passive.serialize()  # 🆕 序列化被动技能加成
	}

# 反序列化
func deserialize(data: Dictionary):
	if data.has("job"): job.deserialize(data["job"])
	if data.has("level"): level.deserialize(data["level"])
	if data.has("equipment"): equipment.deserialize(data["equipment"])
	if data.has("buff"): buff.deserialize(data["buff"])
	if data.has("passive"): passive.deserialize(data["passive"])  # 🆕 反序列化被动技能加成

func get_class_name() -> String:
	return "PlayerCombatAttributes"
