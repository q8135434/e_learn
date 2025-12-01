# res://core/ecs/entities/entity_factory.gd
class_name EntityFactory

# 创建怪物实体
static func create_monster(monster_id: String, position: Vector2 = Vector2.ZERO, parent_node: Node = null) -> GameEntity:
	# 验证怪物配置是否存在
	if not Game.config_manager.monster_templates.has(monster_id):
		push_error("怪物配置不存在: " + monster_id)
		return null
	
	# 获取怪物配置数据
	var monster_data = Game.config_manager.monster_templates[monster_id]
	var monster_skills = monster_data.get("skills", [])
	
	# 生成唯一实体ID
	var entity_id = "monster_%s_%s" % [monster_id, _generate_unique_id()]
	
	# 创建ConfigData - 只设置最基础的身份信息
	var config = ConfigData.new(
		entity_id,
		monster_data.monster_name,
		"monster",
		"monster"
	)
	config.ai_behavior = monster_data.get("ai_behavior", "passive")
	config.monster_rank = monster_data.get("monster_rank", "normal")
	for skill_id in monster_skills:
		# 怪物技能不需要存到player_skills，直接在ConfigData中设置
		if not config.skills.has(skill_id):
			config.skills.append(skill_id)
	
	# 创建RuntimeData - 使用MonsterCombatAttributes
	var runtime := RuntimeData.new(position)
	runtime.combat = MonsterCombatAttributes.new()
	
	# 设置怪物基础属性（base层）
	runtime.combat.base.deserialize(monster_data)
	
	# 初始化当前值
	runtime.current_health = runtime.combat.get_health()
	runtime.current_mana = runtime.combat.get_mana()
	runtime.level = monster_data.level
	
	# 创建EntityData
	var entity_data = EntityData.new(runtime, config)
	
	# 创建GameEntity
	var game_entity = GameEntity.new()
	game_entity.setup(entity_data)
	
	# 挂载到父节点
	if parent_node and parent_node is Node:
		parent_node.add_child(game_entity)
		print("✅ 怪物挂载完成: ", monster_data.monster_name)
	else:
		push_warning("⚠️ 怪物创建但未挂载: " + monster_data.monster_name)
	
	# 自动注册到ECS系统
	EntityRegistry.register_entity(game_entity)
	
	print("✅ 怪物创建成功: %s (%s) 位置: %s" % [monster_data.monster_name, monster_id, position])
	return game_entity

# 创建玩家实体
static func create_player_from_profile(position: Vector2 = Vector2.ZERO, parent_node: Node = null) -> GameEntity:
	var profile = Game.data.profile
	
	# 根据职业选择玩家配置ID
	var config_id = _get_player_config_id(profile.job)
	
	# 生成唯一实体ID
	var entity_id = "player_%d_%s" % [profile.user_id, _generate_unique_id()]
	
	# 创建ConfigData - 只设置最基础的身份信息
	var config = ConfigData.new(
		entity_id,
		"",  # 名称留空，使用昵称
		"player",
		_get_class_string(profile.job)
	)
	
	# 创建RuntimeData - 使用PlayerCombatAttributes
	var runtime = RuntimeData.new(position)
	runtime.combat = PlayerCombatAttributes.new()
	
	# 设置玩家个性化数据
	runtime.nickname = profile.nickname
	runtime.level = profile.level
	runtime.experience = profile.experience
	
	# 从职业模板初始化基础属性
	var job_template = Game.config_manager.player_templates.get(config_id, {})
	runtime.combat.job.deserialize(job_template)
	
	# 初始化当前值
	runtime.current_health = runtime.combat.get_health()
	runtime.current_mana = runtime.combat.get_mana()
	
	# 设置玩法状态
	var session = Game.data.gameplay_session_data
	#runtime.auto_battle = session.auto_battle
	#runtime.current_battle_mode = session.current_battle_mode
	
	# 🎯 初始化玩家技能
	_initialize_player_skills(profile, config)
	
	# 创建EntityData
	var entity_data = EntityData.new(runtime, config)
	
	# 创建GameEntity
	var game_entity = GameEntity.new()
	game_entity.setup(entity_data)
	
	# 挂载到父节点
	if parent_node and parent_node is Node:
		parent_node.add_child(game_entity)
		print("✅ 玩家挂载完成: ", profile.nickname)
	else:
		push_warning("⚠️ 玩家创建但未挂载: " + profile.nickname)
	
	# 自动注册到ECS系统
	EntityRegistry.register_entity(game_entity)
	
	print("✅ 玩家创建成功: %s Lv.%d 位置: %s" % [profile.nickname, profile.level, position])
	return game_entity

# 创建NPC实体
static func create_npc(npc_id: String, position: Vector2 = Vector2.ZERO, parent_node: Node = null) -> GameEntity:
	# 这里需要你有npc_templates配置
	if not Game.config_manager.has("npc_templates") or not Game.config_manager.npc_templates.has(npc_id):
		push_error("NPC配置不存在: " + npc_id)
		return null
	
	var npc_data = Game.config_manager.npc_templates[npc_id]
	
	# 生成唯一实体ID
	var entity_id = "npc_%s_%s" % [npc_id, _generate_unique_id()]
	
	# 创建ConfigData
	var config = ConfigData.new(
		entity_id,
		npc_data.npc_name,
		"npc",
		"npc"
	)
	
	# 创建RuntimeData - NPC可能不需要战斗属性，或者使用基础版本
	var runtime = RuntimeData.new(position)
	# runtime.combat = NPCCombatAttributes.new()  # 如果需要的话
	
	# 创建EntityData
	var entity_data = EntityData.new(runtime, config)
	
	# 创建GameEntity
	var game_entity = GameEntity.new()
	game_entity.setup(entity_data)
	
	# 挂载到父节点
	if parent_node and parent_node is Node:
		parent_node.add_child(game_entity)
		print("✅ NPC挂载完成: ", npc_data.npc_name)
	
	# 自动注册到ECS系统
	EntityRegistry.register_entity(game_entity)
	
	print("✅ NPC创建成功: %s (%s) 位置: %s" % [npc_data.npc_name, npc_id, position])
	return game_entity

static func _initialize_player_skills(profile: UserProfileData, config: ConfigData):
	# 2. 清空ConfigData中的技能列表（准备重新构建）
	config.skills.clear()
	
	# 5. 添加额外学习的技能（不在职业基础中的）
	for skill_id in Game.data.player_skills.skills:
		if not config.skills.has(skill_id):
			config.skills.append(skill_id)
	
	print("✅ 玩家技能初始化: %s - 职业: %s, 技能数: %d" % [
		profile.nickname, 
		_get_class_string(profile.job),
		config.skills.size()
	])

	
# 🛠️ 工具方法

# 获取所有可用的怪物ID
static func get_available_monsters() -> Array[String]:
	return Game.config_manager.monster_templates.keys()

# 检查怪物配置是否存在
static func monster_exists(monster_id: String) -> bool:
	return Game.config_manager.monster_templates.has(monster_id)

# 获取所有可用的玩家职业配置ID
static func get_available_player_classes() -> Array[String]:
	if Game.config_manager.has("player_templates"):
		return Game.config_manager.player_templates.keys()
	return ["player_warrior", "player_mage", "player_taoist"]

# 🎯 内部工具方法

static func _generate_unique_id() -> String:
	return str(Time.get_ticks_msec()) + "_" + str(randi() % 10000)

static func _get_player_config_id(job: int) -> String:
	match job:
		1: return "player_warrior"
		2: return "player_mage" 
		3: return "player_taoist"
		_: return "player_warrior"

static func _get_class_string(job: int) -> String:
	match job:
		1: return "warrior"
		2: return "mage"
		3: return "taoist"
		_: return "warrior"
