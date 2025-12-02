extends Node

const SHARED_CIRCLE_44 = preload("uid://ljqm0hcpijnt")
const SHARED_CIRCLE_72 = preload("uid://dlwg14a8t4brl")
const SHARED_CIRCLE_108 = preload("uid://cgqk4mwv7hg0i")

# 默认系统注册配置
var system_registrations: Array = [
	 {
		"script": load("res://core/ecs/systems/infrastructure/touch_input_system.gd"),
		"group": "infrastructure",
		"name": "TouchInputSystem",
		"needs_scene_tree": true, 
		"priority": 1  # 输入系统优先级最高
	},
	{
		"script": load("res://core/ecs/systems/core/battle_mode_manager.gd"),
		"group": "core",
		"name": "BattleModeManager", 
		"needs_scene_tree": false,
		"priority": 5
	},
	{
		"script": load("res://core/ecs/systems/core/manual_battle_system.gd"),
		"group": "core",
		"name": "ManualBattleSystem",
		"needs_scene_tree": false, 
		"priority": 25  
	},
	{
		"script": load("res://core/ecs/systems/core/assist_battle_system.gd"),
		"group": "core", 
		"name": "AssistBattleSystem",
		"needs_scene_tree": false,
		"priority": 26
	},
	{
		"script": load("res://core/ecs/systems/core/full_auto_battle_system.gd"),
		"group": "core",
		"name": "ManualBattleSystem",
		"needs_scene_tree": false, 
		"priority": 27
	},
	{
		"script": load("res://core/ecs/systems/core/movement_system.gd"),
		"group": "core",
		"name": "MovementSystem",
		"needs_scene_tree": false, 
		"priority": 30  
	},
	{
		"script": load("res://core/ecs/systems/infrastructure/camera_system.gd"),
		"group": "infrastructure",
		"name": "CameraSystem",
		"needs_scene_tree": true, 
		"priority": 90  
	},
	{
		"script": load("res://core/ecs/systems/render/health_bar_system.gd"),
		"group": "infrastructure",
		"name": "HealthBarSystem",
		"needs_scene_tree": true, 
		"priority": 95  
	},
	{
		"script": load("res://core/ecs/systems/render/name_label_system.gd"),
		"group": "infrastructure",
		"name": "NameLabelSystem",
		"needs_scene_tree": true, 
		"priority": 96 
	},
	{
		"script": load("res://core/ecs/systems/render/damage_text_system.gd"),
		"group": "infrastructure",
		"name": "DamageTextSystem",
		"needs_scene_tree": true, 
		"priority": 97 
	},
]

## 单例 Game
enum GameMode {
	OFFLINE = 1,
	ONLINE = 2
}

var game_mode: GameMode = GameMode.OFFLINE

var _save_load_manager:SaveLoadManager = SaveLoadManager.new()
var has_valid_save: bool = false

var config_manager:ConfigManager
var data:DataManager

@onready var color_rect: ColorRect = $TransitionCanvas/ColorRect

func _init() -> void:
	data = DataManager.new()
	config_manager = ConfigManager.new()
	
	
func _ready():
	print("🎮 游戏初始化完成 - 模式: %s" % ("联机" if game_mode == GameMode.ONLINE else "单机"))
	load_data()

func save_data() -> bool:
	# 从System同步到data
	
	var game_data := get_save_data()
	var success = _save_load_manager.save_game(game_data)
	has_valid_save = success
	return success
	
func load_data() -> bool:
	var getted_data = _save_load_manager.load_game()
	has_valid_save = not getted_data.is_empty()

	if has_valid_save:
		apply_loaded_data(getted_data)
	
	return has_valid_save

func get_save_data() -> Dictionary:
	return {
		"data":data.to_dict(),
		"timestamp": Time.get_unix_time_from_system()
	}

func apply_loaded_data(getted_data:Dictionary) -> void:
	print(getted_data)
	data.from_dict(getted_data["data"])
		
# ==================== 公开接口 ====================

# UI场景切换（简单版）
func change_ui_scene(scene_path: String, transition_params: Dictionary = {}) -> void:
	print("🖥️ UI场景切换: ", scene_path)
	
	var duration = transition_params.get("duration", 0.3)
	
	# 1. 暂停 + 淡入
	get_tree().paused = true
	await _fade_in(duration)
	
	# 2. 直接切换场景（UI场景没有ECS实体）
	get_tree().change_scene_to_file(scene_path)
	await get_tree().tree_changed
	
	# 3. 恢复 + 淡出
	get_tree().paused = false
	await _fade_out(duration)
	
	print("✅ UI场景切换完成")

# 游戏场景切换（完整版）
func change_game_scene(scene_path: String, game_params: Dictionary = {}) -> void:
	var duration = game_params.get("transition_duration", 0.2)
	
	# 1. 暂停 + 淡入
	get_tree().paused = true
	await _fade_in(duration)
	
	# 4. 切换场景
	get_tree().change_scene_to_file(scene_path)
	await get_tree().tree_changed
	
	# 8. 恢复 + 淡出
	get_tree().paused = false
	await _fade_out(duration)
	
	print("✅ 游戏场景切换完成")

# ==================== 内部方法 ====================
# 淡入过渡
func _fade_in(duration: float) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color:a", 1.0, duration)
	await tween.finished

# 淡出过渡
func _fade_out(duration: float) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(color_rect, "color:a", 0.0, duration)
	await tween.finished
