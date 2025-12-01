# 低频变化的配置数据（启动时设定，很少变动）
class_name ConfigData extends Resource

# 基础属性
var entity_id: String = ""
var entity_type: String = ""
var display_name: String = ""

# 技能和装备配置
var skill_list: Array[String] = []
var equipment_slots: Array[String] = []

# 视觉和表现
var sprite_path: String = ""
var collision_shape: String = ""
var scale: Vector2 = Vector2.ONE

# ⚡ 移除数据变更信号，因为配置数据启动时设定后很少变动
# 如果需要动态修改配置，可以后面再加

# 序列化
func serialize() -> Dictionary:
	return {
		"entity_id": entity_id,
		"entity_type": entity_type,
		"display_name": display_name,
		"skill_list": skill_list.duplicate(),
		"equipment_slots": equipment_slots.duplicate(),
		"sprite_path": sprite_path,
		"collision_shape": collision_shape,
		"scale": {"x": scale.x, "y": scale.y}
	}

# 反序列化
func deserialize(data: Dictionary):
	if data.has("entity_id"):
		entity_id = data["entity_id"]
	if data.has("entity_type"):
		entity_type = data["entity_type"]
	if data.has("display_name"):
		display_name = data["display_name"]
	if data.has("skill_list"):
		skill_list = data["skill_list"].duplicate()
	if data.has("equipment_slots"):
		equipment_slots = data["equipment_slots"].duplicate()
	if data.has("sprite_path"):
		sprite_path = data["sprite_path"]
	if data.has("collision_shape"):
		collision_shape = data["collision_shape"]
	if data.has("scale"):
		scale = Vector2(data["scale"]["x"], data["scale"]["y"])
