# scene_navigation_data.gd
class_name SceneNavigationData extends Resource

# 🎯 玩家真实位置（持久化）
var persistent_position: Vector2 = Vector2.ZERO 	# 真实游戏位置
var persistent_scene_id: String = "map_001"     	# 真实所在场景id

# 🎯 场景传送数据（临时）
var transition_data: Dictionary = {
	"from_scene_id": "",           # 来源场景
	"from_exit_id": "",            # 来源出口ID  
	"to_scene_id": "",             # 目标场景
	"to_spawn_id": "",             # 目标出生点ID
	"transition_type": "normal"    # 传送类型
}

# 🎯 序列化（只存真实位置）
func serialize() -> Dictionary:
	return {
		"persistent_scene_id": persistent_scene_id,
		"persistent_position": {"x": persistent_position.x, "y": persistent_position.y}
	}

# 🎯 反序列化
func deserialize(data: Dictionary):
	persistent_scene_id = data.get("persistent_scene_id", "")
	var pos_data = data.get("persistent_position", {})
	persistent_position = Vector2(pos_data.get("x", 0), pos_data.get("y", 0))

# 🎯 设置传送信息
func set_transition(from_scene: String, from_exit: String, to_scene: String, to_spawn: String, type: String = "normal"):
	transition_data = {
		"from_scene_id": from_scene,
		"from_exit_id": from_exit,
		"to_scene_id": to_scene, 
		"to_spawn_id": to_spawn,
		"transition_type": type
	}

# 🎯 获取目标出生点（从地图配置读取）
func get_target_spawn_position() -> Vector2:
	var spawn_id = transition_data.get("to_spawn_id", "")
	var scene_id = transition_data.get("to_scene_id", "")
	
	# 🎯 从地图配置获取出生点
	var map_config = Game.config_manager.map_templates.get(scene_id, {})
	var spawn_points = map_config.get("spawn_points", {})
	
	return spawn_points.get(spawn_id, Vector2(300, 300))

# 🎯 更新真实位置（退出游戏时调用）
func update_persistent_position(scene_id: String, position: Vector2):
	persistent_scene_id = scene_id
	persistent_position = position
