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

# 工具方法：从职业模板初始化
func initialize_from_job_template(job_template: Dictionary):
	# 只初始化数值属性
	job.health = job_template.get("base_health", 0)
	job.mana = job_template.get("base_mana", 0)
	
	job.min_attack = job_template.get("base_min_attack", 0)
	job.max_attack = job_template.get("base_max_attack", 0)
	job.min_magic_attack = job_template.get("min_magic_attack", 0)
	job.max_magic_attack = job_template.get("max_magic_attack", 0)
	
	job.min_defense = job_template.get("base_min_defense", 0)
	job.max_defense = job_template.get("base_max_defense", 0)
	job.min_magic_defense = job_template.get("base_min_magic_defense", 0)
	job.max_magic_defense = job_template.get("base_max_magic_defense", 0)
	
	job.accuracy = job_template.get("base_accuracy", 0)
	job.agility = job_template.get("base_agility", 0)
	job.luck = job_template.get("base_luck", 0)
	job.curse = job_template.get("base_curse", 0)
	job.magic_dodge = job_template.get("base_magic_dodge", 0.0)
	job.critical_rate = job_template.get("base_critical_rate", 0.0)
	job.attack_speed = job_template.get("base_attack_speed", 1.0)

# 🆕 清空被动技能加成（在重新计算前调用）
func clear_passive_bonuses():
	passive = AttributeLayer.new()

# 🆕 添加被动技能加成
func add_passive_bonus(bonus_data: Dictionary):
	for property in bonus_data:
		var value = bonus_data[property]
		match property:
			"health": passive.health += value
			"mana": passive.mana += value
			"min_attack": passive.min_attack += value
			"max_attack": passive.max_attack += value
			"min_magic_attack": passive.min_magic_attack += value
			"max_magic_attack": passive.max_magic_attack += value
			"min_defense": passive.min_defense += value
			"max_defense": passive.max_defense += value
			"min_magic_defense": passive.min_magic_defense += value
			"max_magic_defense": passive.max_magic_defense += value
			"accuracy": passive.accuracy += value
			"agility": passive.agility += value
			"luck": passive.luck += value
			"curse": passive.curse += value
			"magic_dodge": passive.magic_dodge += value
			"critical_rate": passive.critical_rate += value
			"attack_speed": passive.attack_speed += value
