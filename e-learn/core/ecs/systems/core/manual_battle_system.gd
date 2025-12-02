# manual_battle_system.gd
class_name ManualBattleSystem extends SystemBase

func _initialize():
	system_name = "ManualBattleSystem"
	system_type = "core"
	#update_priority = 25  # 在移动系统之前
	print("✅ ManualBattleSystem 初始化完成")

func _should_process_entity(entity: GameEntity) -> bool:
	return entity.data.config.entity_type == "player"

func _process_entity(entity: GameEntity, delta: float):
	var runtime = entity.data.runtime
	var click = runtime.click_target
	
	# 处理点击目标
	match click.type:
		"move":
			_process_move_target(entity, click.position)
		"attack":
			_process_attack_target(entity, click.entity_id)
		_:
			# "none" 或其他：什么都不做
			runtime.velocity = Vector2.ZERO

func _process_move_target(entity: GameEntity, target_pos: Vector2):
	var current_pos = entity.data.get_position()
	var distance = current_pos.distance_to(target_pos)
	
	if distance < 5.0:  # 到达目标
		entity.data.runtime.click_target.type = "none"
		entity.data.runtime.velocity = Vector2.ZERO
		print("✅ 到达移动目标")
	else:
		# 设置速度，让MovementSystem移动
		var direction = (target_pos - current_pos).normalized()
		entity.data.runtime.velocity = direction * entity.data.config.move_speed

func _process_attack_target(entity: GameEntity, target_id: String):
	print("🎯 开始处理攻击目标: ", target_id)
	
	var target = EntityRegistry.get_entity(target_id)
	if not target:
		print("❌ 目标不存在")
		return
	if not target.data.is_alive():
		print("❌ 目标已死亡")
		return
	
	var current_pos = entity.data.get_position()
	var target_pos = target.data.get_position()
	var distance = current_pos.distance_to(target_pos)
	
	print("📏 攻击距离检查:")
	print("   玩家位置: ", current_pos)
	print("   怪物位置: ", target_pos)
	print("   实际距离: ", distance)
	print("   攻击范围: 50.0")
	
	if distance <= 100.0:
		entity.data.runtime.velocity = Vector2.ZERO
		print("🎯 进入攻击范围，可以开始攻击")
		# TODO: 这里添加攻击逻辑
		_test_attack(entity,target)
	else:
		# 移动到攻击范围
		var direction = (target_pos - current_pos).normalized()
		entity.data.runtime.velocity = direction * entity.data.config.move_speed
		print("➡️ 正在接近目标，速度: ", entity.data.runtime.velocity)

# 测试真实战斗
var last_attack_tick:float = 0
func _test_attack(entity: GameEntity, target: GameEntity) -> void:
	if Time.get_unix_time_from_system() - last_attack_tick < 1:
		return
	last_attack_tick = Time.get_unix_time_from_system()
	var atk = randi_range(entity.data.get_min_attack(), entity.data.get_max_attack())
	var def = randi_range(target.data.get_min_defense(),target.data.get_max_defense())
	var damage_value = atk - def
	target.data.take_damage(damage_value)
	# 正常应该是信号通知，暂时先抽取下下飘字
	var health_system  :DamageTextSystem= SystemManager.get_system("DamageTextSystem")
	health_system.show_damage(target.global_position,damage_value)
