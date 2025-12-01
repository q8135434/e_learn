# res://autoload/data/player_skill_data.gd
class_name PlayerSkillData extends Resource

# 🎯 纯数据容器，没有任何逻辑方法
var skills: Dictionary = {}  # skill_id -> {"current_level": int, "experience": int, "last_used_time": float}

# 🎯 只有序列化方法（数据转换，不算业务逻辑）
func serialize() -> Dictionary:
	return skills.duplicate(true)

func deserialize(data: Dictionary):
	skills = data.duplicate(true)
