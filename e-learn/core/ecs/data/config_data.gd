# 低频变化的配置数据（启动时设定，很少变动）
class_name ConfigData extends Resource

# 基础属性
var entity_id: String = ""				# 实体唯一ID
var entity_name: String = ""				# 显示名称（怪物/NPC用）
var entity_type: String = ""				# player, monster, npc, item
var prefab_path: String = ""				# 对应的场景文件路径

# 技能和装备配置
var skills: Array[String] = []
var equipment_slots: Array[String] = []

# 视觉和表现
var sprite_path: String = ""
var collision_shape: String = ""
var scale: Vector2 = Vector2.ONE

# === 玩家特有配置 ===
var character_class: String = "warrior" # warrior, mage, taoist
var gender: String = "male"             # male, female

# === 怪物特有配置 ===
var ai_behavior: String = "passive"     # passive, aggressive, neutral
var monster_rank: String = "normal"     # normal, elite, boss, lord

# === 装备槽位配置 ===
var equip_slots: Array[String] = [
	"weapon", "helmet", "necklace", "armor", 
	"bracelet", "ring", "boots"
]

# 构造函数
func _init(
	id: String = "", 
	name: String = "", 
	type: String = "player", 
	char_class: String = "warrior"
):
	entity_id = id
	entity_name = name
	entity_type = type
	character_class = char_class
	
# === 工具方法 ===
func get_class_display_name() -> String:
	match character_class:
		"warrior": return "战士"
		"mage": return "法师"
		"taoist": return "道士"
		_: return "未知职业"
		
# 怪物相关方法
func is_monster() -> bool:
	return entity_type == "monster"

func is_player() -> bool:
	return entity_type == "player"

func is_npc() -> bool:
	return entity_type == "npc"

# 获取行为模式显示名称
func get_behavior_display_name() -> String:
	match ai_behavior:
		"passive": return "被动"
		"aggressive": return "主动"
		"neutral": return "中立"
		"fleeing": return "逃跑"
		_: return "未知"

# 获取怪物等级显示名称
func get_rank_display_name() -> String:
	match monster_rank:
		"normal": return "普通"
		"elite": return "精英"
		"boss": return "首领"
		"lord": return "领主"
		_: return "未知"
		
func get_display_name() -> String:
	return "%s Lv.1 %s" % [entity_name, get_class_display_name()]

func has_skill(skill_id: String) -> bool:
	return skill_id in skills

func add_skill(skill_id: String) -> void:
	if not has_skill(skill_id):
		skills.append(skill_id)
	
