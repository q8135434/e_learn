# res://core/ecs/systems/core/battle_mode_manager.gd
class_name BattleModeManager extends SystemBase

# 🎯 战斗模式枚举（和RuntimeData中保持一致）
enum BattleMode {
	MANUAL = 0,      # 手动模式
	ASSIST = 1,      # 点击辅助模式  
	FULL_AUTO = 2    # 全自动模式
}

func _initialize():
	system_name = "BattleModeManager"
	system_type = "core"
	update_priority = 5  # 较早执行，确保模式切换及时
	print("✅ BattleModeManager 初始化完成")

func _should_process_entity(entity: GameEntity) -> bool:
	return entity.data.config.entity_type == "player"

func _process_entity(entity: GameEntity, _delta: float):
	# 每帧同步状态，确保一致性
	# 可以在这里添加模式切换的动画效果等
	pass

# 🎯 公共API：切换战斗模式
static func switch_to_manual(entity: GameEntity) -> void:
	_switch_mode(entity, BattleMode.MANUAL)

static func switch_to_assist(entity: GameEntity) -> void:
	_switch_mode(entity, BattleMode.ASSIST)

static func switch_to_full_auto(entity: GameEntity) -> void:
	_switch_mode(entity, BattleMode.FULL_AUTO)

# 🎯 核心切换函数
static func _switch_mode(entity: GameEntity, new_mode: int) -> void:
	if not entity or not entity.data:
		return
	
	var entity_data = entity.data
	var runtime = entity_data.runtime
	var old_mode = runtime.battle_mode
	
	if old_mode == new_mode:
		return  # 模式相同，不需要切换
	
	print("🔄 战斗模式切换: %s [%s] → [%s]" % [
		entity_data.get_display_name(),
		_get_mode_name(old_mode),
		_get_mode_name(new_mode)
	])
	
	# 1. 清理旧模式状态
	_cleanup_old_mode(entity, old_mode)
	
	# 2. 设置新模式
	runtime.battle_mode = new_mode
	
	# 3. 初始化新模式
	_initialize_new_mode(entity, new_mode)

# 🎯 清理旧模式状态
static func _cleanup_old_mode(entity: GameEntity, old_mode: int):
	var runtime = entity.data.runtime
	
	# 通用清理
	runtime.velocity = Vector2.ZERO
	runtime.click_target = {
		"type": "none",
		"position": Vector2.INF,
		"entity_id": ""
	}
	runtime.current_target_id = ""
	runtime.clear_state_flag(RuntimeData.StateFlags.IN_BATTLE)
	
	# 模式特定清理
	match old_mode:
		BattleMode.ASSIST, BattleMode.FULL_AUTO:
			# 清理自动战斗数据
			runtime.auto_battle_state = 0  # IDLE
			runtime.auto_battle_data = {
				"search_timer": 0.0,
				"target_refresh_timer": 0.0,
				"current_target_id": "",
				"last_target_position": Vector2.ZERO
			}

# 🎯 初始化新模式
static func _initialize_new_mode(entity: GameEntity, new_mode: int):
	var runtime = entity.data.runtime
	
	match new_mode:
		BattleMode.MANUAL:
			runtime.auto_battle = false
			print("🎮 切换到手动模式：完全玩家控制")
			
		BattleMode.ASSIST:
			runtime.auto_battle = true
			runtime.auto_battle_state = 0  # IDLE
			print("🤖 切换到辅助模式：点击干预 + 自动挂机")
			
		BattleMode.FULL_AUTO:
			runtime.auto_battle = true
			runtime.auto_battle_state = 0  # IDLE
			print("🚀 切换到全自动模式：纯挂机体验")

# 🎯 获取当前模式名称
static func get_current_mode_name(entity: GameEntity) -> String:
	if not entity or not entity.data:
		return "未知"
	return _get_mode_name(entity.data.runtime.battle_mode)

static func _get_mode_name(mode: int) -> String:
	match mode:
		BattleMode.MANUAL: return "手动模式"
		BattleMode.ASSIST: return "辅助模式"
		BattleMode.FULL_AUTO: return "全自动模式"
		_: return "未知模式"

# 🎯 检查是否在某个模式
static func is_in_manual_mode(entity: GameEntity) -> bool:
	return entity.data.runtime.battle_mode == BattleMode.MANUAL

static func is_in_assist_mode(entity: GameEntity) -> bool:
	return entity.data.runtime.battle_mode == BattleMode.ASSIST

static func is_in_full_auto_mode(entity: GameEntity) -> bool:
	return entity.data.runtime.battle_mode == BattleMode.FULL_AUTO

# 🎯 工具函数：获取所有玩家
static func get_all_players() -> Array[GameEntity]:
	return EntityRegistry.get_entities_by_type("player")

# 🎯 切换所有玩家的模式（如果是多玩家游戏）
static func switch_all_players_to(mode: int) -> void:
	var players = get_all_players()
	for player in players:
		_switch_mode(player, mode)

# 🎯 调试信息
func get_system_info() -> Dictionary:
	var info = super.get_system_info()
	
	var mode_stats = {
		"manual": 0,
		"assist": 0,
		"full_auto": 0
	}
	
	for entity in entities:
		var mode = entity.data.runtime.battle_mode
		match mode:
			BattleMode.MANUAL: mode_stats.manual += 1
			BattleMode.ASSIST: mode_stats.assist += 1
			BattleMode.FULL_AUTO: mode_stats.full_auto += 1
	
	info["mode_distribution"] = mode_stats
	info["total_players"] = entities.size()
	
	return info
