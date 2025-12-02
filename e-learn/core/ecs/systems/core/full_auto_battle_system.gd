# res://core/ecs/systems/core/full_auto_battle_system.gd
class_name FullAutoBattleSystem extends SystemBase

var _attack_timers: Dictionary = {}  # entity_id -> 上次攻击时间

func _initialize():
	system_name = "FullAutoBattleSystem"
	system_type = "core"
	update_priority = 26  # 在手动模式之后
	print("✅ FullAutoBattleSystem 初始化完成")

# 只处理全自动模式的玩家
func _should_process_entity(entity: GameEntity) -> bool:
	return (entity.data.config.entity_type == "player" and 
			entity.data.runtime.battle_mode == 2)  # FULL_AUTO模式

func _process_entity(entity: GameEntity, delta: float):
	# 🎯 全自动模式：自动找怪、攻击
	_process_full_auto(entity)

func _process_full_auto(entity: GameEntity):
	var runtime = entity.data.runtime
	
	# 1. 如果有当前目标，先处理
	if runtime.current_target_id != "":
		_process_existing_target(entity, runtime.current_target_id)
		return
	
	# 2. 没有目标，寻找新目标
	_find_and_attack_target(entity)

# 处理现有目标
func _process_existing_target(entity: GameEntity, target_id: String):
	var target = EntityRegistry.get_entity(target_id)
	if not target or not target.data.is_alive():
		# 目标无效，清除
		entity.data.runtime.current_target_id = ""
		return
	
	var distance = entity.data.get_position().distance_to(target.data.get_position())
	
	if distance <= 100.0:  # 攻击范围
		entity.data.runtime.velocity = Vector2.ZERO
		_auto_attack(entity, target)
	else:
		# 移动到攻击范围
		var direction = (target.data.get_position() - entity.data.get_position()).normalized()
		entity.data.runtime.velocity = direction * entity.data.config.move_speed

# 寻找并攻击目标
func _find_and_attack_target(entity: GameEntity):
	# 寻找最近的怪物
	var nearest_monster = _find_nearest_monster(entity)
	
	if nearest_monster:
		# 设置为目标
		entity.data.runtime.current_target_id = nearest_monster.data.config.entity_id
		print("🎯 全自动模式锁定目标: ", nearest_monster.data.config.entity_name)
	else:
		# 没有怪物，停止移动
		entity.data.runtime.velocity = Vector2.ZERO

# 寻找最近的怪物
func _find_nearest_monster(entity: GameEntity) -> GameEntity:
	var entity_pos = entity.data.get_position()
	var nearest = null
	var min_distance = 500.0  # 最大搜索范围
	
	# 搜索怪物和BOSS
	for monster_type in ["monster", "boss"]:
		for target in EntityRegistry.get_entities_by_type(monster_type):
			if target.data.is_alive():
				var distance = entity_pos.distance_to(target.data.get_position())
				if distance < min_distance:
					min_distance = distance
					nearest = target
	
	return nearest

# 自动攻击
func _auto_attack(attacker: GameEntity, target: GameEntity):
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
	
	print("🤖 全自动攻击: %s → %s (-%d HP)" % [
		attacker.data.config.entity_name,
		target.data.config.entity_name,
		damage_value
	])
	
	# 显示伤害飘字
	var health_system = SystemManager.get_system("DamageTextSystem")
	if health_system:
		health_system.show_damage(target.global_position, damage_value)
	
	# 检查目标死亡
	if not target.data.is_alive():
		print("☠️ 全自动击杀: ", target.data.config.entity_name)
		attacker.data.runtime.current_target_id = ""

# 实体注册/注销
func _on_entity_registered(entity: GameEntity):
	super._on_entity_registered(entity)
	_attack_timers[entity.data.config.entity_id] = 0

func _on_entity_unregistered(entity: GameEntity):
	super._on_entity_unregistered(entity)
	_attack_timers.erase(entity.data.config.entity_id)

# 调试信息
func get_system_info() -> Dictionary:
	var info = super.get_system_info()
	info["auto_attack_count"] = _attack_timers.size()
	return info
