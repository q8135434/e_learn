# res://core/ecs/world/entity_registry.gd
# 单例
# 类名：EntityRegistry
# 作用：实体注册表，管理所有活跃实体
# 职责：
#   - 注册和注销实体到ECS系统
#   - 提供实体查询功能
#   - 管理实体生命周期
extends Node


# 实体存储
var _entities: Dictionary = {}  # entity_id -> GameEntity
var _entities_by_type: Dictionary = {}  # entity_type -> Array[GameEntity]

# 注册实体到ECS系统
func register_entity(entity: GameEntity) -> bool:
	var entity_data = entity.get_entity_data()
	var entity_id = entity_data.config.entity_id
	var entity_type = entity_data.config.entity_type
	
	if _entities.has(entity_id):
		push_error("实体已存在: " + entity_id)
		return false
	
	# 存储实体
	_entities[entity_id] = entity
	
	# 按类型分类
	if not _entities_by_type.has(entity_type):
		_entities_by_type[entity_type] = []
	_entities_by_type[entity_type].append(entity)
	
	# 注册到所有系统
	SystemManager.register_entity_to_systems(entity)
	
	print("✅ 实体注册成功: %s (%s)" % [entity_data.config.entity_name, entity_id])
	return true

# 注销实体
func unregister_entity(entity: GameEntity) -> bool:
	var entity_data = entity.get_entity_data()
	var entity_id = entity_data.config.entity_id
	var entity_type = entity_data.config.entity_type
	
	if not _entities.has(entity_id):
		push_error("实体不存在: " + entity_id)
		return false
	
	# 从所有系统注销
	SystemManager.unregister_entity_from_systems(entity)
	
	# 从存储中移除
	_entities.erase(entity_id)
	if _entities_by_type.has(entity_type):
		_entities_by_type[entity_type].erase(entity)
	
	print("🗑️ 实体注销: %s (%s)" % [entity_data.config.entity_name, entity_id])
	return true

# 实体查询
func get_entity(entity_id: String) -> GameEntity:
	return _entities.get(entity_id)

func get_entities_by_type(entity_type: String) -> Array:
	return _entities_by_type.get(entity_type, []).duplicate()

func get_all_entities() -> Array:
	return _entities.values()

# 获取实体数量统计
func get_entity_stats() -> Dictionary:
	var stats = {"total": _entities.size()}
	for entity_type in _entities_by_type:
		stats[entity_type] = _entities_by_type[entity_type].size()
	return stats

# 调试功能
func print_entity_stats():
	var stats = get_entity_stats()
	print("=== 实体统计 ===")
	print("总实体数: ", stats.total)
	for entity_type in _entities_by_type:
		print("  %s: %d" % [entity_type, _entities_by_type[entity_type].size()])
