# res://core/ecs/systems/core/assist_battle_system.gd
class_name AssistBattleSystem extends SystemBase

var _attack_timers: Dictionary = {}  # entity_id -> 上次攻击时间
var _user_command_time: Dictionary = {}  # entity_id -> 上次用户指令时间

func _initialize():
	system_name = "AssistBattleSystem"
	system_type = "core"
	update_priority = 25  # 在手动和全自动之间
	print("✅ AssistBattleSystem 初始化完成")

# 只处理辅助模式的玩家
func _should_process_entity(entity: GameEntity) -> bool:
	return (entity.data.config.entity_type == "player" and 
			entity.data.runtime.battle_mode == 1)  # ASSIST模式

func _process_entity(entity: GameEntity, delta: float):
	var runtime = entity.data.runtime
	
	# 🎯 核心逻辑：用户指令优先，自动模式兜底
	
	# 1. 检查是否有用户点击指令（最高优先级）
	if runtime.click_target.type != "none":
		_process_user_command(entity)
		_user_command_time[entity.data.config.entity_id] = Time.get_unix_time_from_system()
		return
	
	# 2. 用户指令完成后，延迟一会再恢复自动（避免频繁切换）
	var entity_id = entity.data.config.entity_id
	var last_command_time = _user_command_time.get(entity_id, 0)
	var time_since_command = Time.get_unix_time_from_system() - last_command_time
	
	# 用户指令完成后等待1秒再恢复自动
	if time_since_command < 1.0:
		return
	
	# 3. 没有用户指令时，执行自动挂机
	_process_auto_battle(entity)

# 处理用户指令（移动或攻击）
func _process_user_command(entity: GameEntity):
	var runtime = entity.data.runtime
	var click = runtime.click_target
	
	print("🎮 辅助模式处理用户指令: ", click.type)
	
	match click.type:
		"move":
			_process_user_move(entity, click.position)
		"attack":
			_process_user_attack(entity, click.entity_id)
		_:
			runtime.velocity = Vector2.ZERO

# 用户点击移动
func _process_user_move(entity: GameEntity, target_pos: Vector2):
	var current_pos = entity.data.get_position()
	var distance = current_pos.distance_to(target_pos)
	
	if distance < 5.0:  # 到达目标
		entity.data.runtime.velocity = Vector2.ZERO
		print("✅ 用户移动完成")
	else:
		var direction = (target_pos - current_pos).normalized()
		entity.data.runtime.velocity = direction * entity.data.config.move_speed

# 用户点击攻击
func _process_user_attack(entity: GameEntity, target_id: String):
	var target = EntityRegistry.get_entity(target_id)
	if not target or not target.data.is_alive():
		entity.data.runtime.click_target.type = "none"
		return
	
	var distance = entity.data.get_position().distance_to(target.data.get_position())
	
	if distance <= 100.0:  # 攻击范围
		entity.data.runtime.velocity = Vector2.ZERO
		_perform_attack(entity, target)
	else:
		# 移动到攻击范围
		var direction = (target.data.get_position() - entity.data.get_position()).normalized()
		entity.data.runtime.velocity = direction * entity.data.config.move_speed

# 自动挂机逻辑（和全自动模式类似）
func _process_auto_battle(entity: GameEntity):
	var runtime = entity.data.runtime
	
	# 1. 如果有当前目标，先处理
	if runtime.current_target_id != "":
		_process_existing_target(entity, runtime.current_target_id)
		return
	
	# 2. 没有目标，寻找新目标
	_find_and_attack_target(entity)

# 处理现有目标（复制全自动的逻辑）
func _process_existing_target(entity: GameEntity, target_id: String):
	var target = EntityRegistry.get_entity(target_id)
	if not target or not target.data.is_alive():
		entity.data.runtime.current_target_id = ""
		return
	
	var distance = entity.data.get_position().distance_to(target.data.get_position())
	
	if distance <= 100.0:
		entity.data.runtime.velocity = Vector2.ZERO
		_perform_attack(entity, target)
	else:
		var direction = (target.data.get_position() - entity.data.get_position()).normalized()
		entity.data.runtime.velocity = direction * entity.data.config.move_speed

# 寻找并攻击目标（复制全自动的逻辑）
func _find_and_attack_target(entity: GameEntity):
	var nearest_monster = _find_nearest_monster(entity)
	
	if nearest_monster:
		entity.data.runtime.current_target_id = nearest_monster.data.config.entity_id
		print("🤖 辅助模式锁定目标: ", nearest_monster.data.config.entity_name)
	else:
		entity.data.runtime.velocity = Vector2.ZERO

# 寻找最近的怪物（复制全自动的逻辑）
func _find_nearest_monster(entity: GameEntity) -> GameEntity:
	var entity_pos = entity.data.get_position()
	var nearest = null
	var min_distance = 500.0
	
	for monster_type in ["monster", "boss"]:
		for target in EntityRegistry.get_entities_by_type(monster_type):
			if target.data.is_alive():
				var distance = entity_pos.distance_to(target.data.get_position())
				if distance < min_distance:
					min_distance = distance
					nearest = target
	
	return nearest

# 执行攻击（复用你的伤害计算逻辑）
func _perform_attack(attacker: GameEntity, target: GameEntity):
	var entity_id = attacker.data.config.entity_id
	var current_time = Time.get_unix_time_from_system()
	
	# 攻击冷却检查
	if current_time - _attack_timers.get(entity_id, 0) < 1.0:
		return
	
	# 伤害计算（复制你的逻辑）
	var atk = randi_range(attacker.data.get_min_attack(), attacker.data.get_max_attack())
	var def = randi_range(target.data.get_min_defense(), target.data.get_max_defense())
	var damage_value = atk - def
	
	# 保底伤害
	if damage_value <= 0:
		damage_value = 1
	
	target.data.take_damage(damage_value)
	
	# 更新攻击时间
	_attack_timers[entity_id] = current_time
	
	# 显示伤害飘字
	var health_system = SystemManager.get_system("DamageTextSystem")
	if health_system:
		health_system.show_damage(target.global_position, damage_value)
	
	# 检查目标死亡
	if not target.data.is_alive():
		attacker.data.runtime.current_target_id = ""

# 实体注册/注销
func _on_entity_registered(entity: GameEntity):
	super._on_entity_registered(entity)
	var entity_id = entity.data.config.entity_id
	_attack_timers[entity_id] = 0
	_user_command_time[entity_id] = 0

func _on_entity_unregistered(entity: GameEntity):
	super._on_entity_unregistered(entity)
	var entity_id = entity.data.config.entity_id
	_attack_timers.erase(entity_id)
	_user_command_time.erase(entity_id)

# 调试信息
func get_system_info() -> Dictionary:
	var info = super.get_system_info()
	info["attack_timers"] = _attack_timers.size()
	info["user_command_times"] = _user_command_time.size()
	return info
