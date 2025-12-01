# 新建 gameplay_session_data.gd
class_name GameplaySessionData extends Resource

# 战斗相关状态
var auto_battle: bool = false
var current_battle_mode: int = 0  # 使用BattleMode枚举
var last_combat_time: float = 0.0
var preferred_skills: Array[String] = []

# 地图探索状态
var discovered_areas: Array[String] = []
var current_quests: Array[String] = []

# 界面状态
var ui_layout_preferences: Dictionary = {}
var quick_slot_settings: Dictionary = {}

func serialize() -> Dictionary:
	return {
		"auto_battle": auto_battle,
		"current_battle_mode": current_battle_mode,
		"discovered_areas": discovered_areas
	}

func deserialize(data: Dictionary):
	auto_battle = data.get("auto_battle", false)
	current_battle_mode = data.get("current_battle_mode", 0)
	discovered_areas = data.get("discovered_areas", [])
