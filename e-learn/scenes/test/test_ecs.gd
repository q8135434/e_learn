# test_ecs_scene.gd
extends Node2D

func _ready():
	print("=== GECS 框架集成测试 ===")
	_test_entity_creation()
	_test_systems()

func _test_entity_creation():
	print("\n1. 测试实体工厂...")
	
	# 创建玩家实体
	var player = EntityFactory.create_player_from_profile(Vector2(100, 200), self)
	if player:
		print("✅ 玩家创建成功:", player.data.config.get_display_name())
		print("   位置:", player.position)
		print("   生命值:", player.data.get_health(), "/", player.data.get_max_health())
	
	# 创建怪物实体
	var monster = EntityFactory.create_monster("1001", Vector2(300, 200), self)
	if monster:
		print("✅ 怪物创建成功:", monster.data.config.entity_name)

func _test_systems():
	print("\n2. 测试System集成...")
	
	# 检查SystemManager状态
	var system_manager = SystemManager
	print("   活跃系统:", system_manager._get_active_system_count())
	
	# 测试EntityRegistry
	print("\n3. 测试EntityRegistry...")
	var registry = EntityRegistry
	registry.print_entity_stats()
