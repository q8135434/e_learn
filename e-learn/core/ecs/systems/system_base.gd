# res://core/ecs/systems/system_base.gd
# 设计原则：
#   - 无状态：系统本身不存储业务数据，只处理EntityData
#   - 单一职责：每个系统只负责一个特定的功能领域
#   - 批量处理：支持按批处理实体，优化性能
class_name SystemBase extends Node2D

# 系统关注的实体列表
var entities: Array[GameEntity] = []

# 系统配置
var update_priority: int = 0          # 更新优先级（数值越小越先执行）
var enabled: bool = true              # 系统是否启用

# 批处理配置
var use_batch_processing: bool = true # 是否启用分批处理
var batch_size: int = 20              # 每批处理的实体数量
var batch_threshold: int = 50         # 启用分批的实体数量阈值
var _current_batch_index: int = 0     # 当前批处理位置

# 系统标识
var system_name: String = "UnnamedSystem"
var system_type: String = "Generic"    # Core, Gameplay, Render, Infrastructure

# 虚函数：系统初始化
func _initialize() -> void:
	# 系统初始化，在添加到SystemManager时调用
	print("系统初始化: ", system_name)
	pass

# 虚函数：系统清理
func _shutdown() -> void:
	# 系统清理，在从SystemManager移除时调用
	print("系统关闭: ", system_name)
	entities.clear()
	_current_batch_index = 0

# 主更新函数 - 由SystemManager每帧调用
func process_system(delta: float) -> void:
	# 系统主更新函数
	if not enabled or entities.is_empty():
		return
	
	# 根据阈值决定是否启用分批处理
	if use_batch_processing and entities.size() > batch_threshold:
		_process_with_batching(delta)
	else:
		_process_all_entities(delta)

# 分批处理模式
func _process_with_batching(delta: float) -> void:
	# 分批处理实体
	var start_idx = _current_batch_index
	var end_idx = min(start_idx + batch_size, entities.size())
	
	# 处理当前批次
	for i in range(start_idx, end_idx):
		var entity = entities[i]
		if entity and entity.is_entity_active():
			# ⛔ 不符合条件直接走人
			if not _should_process_entity(entity):
				continue
			_process_entity(entity, delta)
	
	# 更新批处理位置（循环）
	_current_batch_index = end_idx
	if _current_batch_index >= entities.size():
		_current_batch_index = 0

# 全量处理模式
func _process_all_entities(delta: float) -> void:
	# 全量处理所有实体
	for entity in entities:
		if entity and entity.is_entity_active():
			# ⛔ 不符合条件直接走人
			if not _should_process_entity(entity):
				continue
			_process_entity(entity, delta)

# 子类重写此函数即可，默认全通过
func _should_process_entity(_entity: GameEntity) -> bool:
	return true
	
# 虚函数：处理单个实体
func _process_entity(_entity: GameEntity, _delta: float) -> void:
	# 处理单个实体（子类必须重写此方法）
	push_error("SystemBase._process_entity() 必须被子类重写: ", system_name)

# 实体管理
func register_entity(entity: GameEntity) -> void:
	# 向系统注册实体
	if entity and not entities.has(entity):
		entities.append(entity)
		_on_entity_registered(entity)

func unregister_entity(entity: GameEntity) -> void:
	# 从系统注销实体
	if entities.has(entity):
		entities.erase(entity)
		_on_entity_unregistered(entity)
		# 如果删除的实体在_current_batch_index之前，需要调整索引
		if entities.size() > 0 and _current_batch_index >= entities.size():
			_current_batch_index = 0

func clear_entities() -> void:
	# 清空所有实体
	for entity in entities:
		_on_entity_unregistered(entity)
	entities.clear()
	_current_batch_index = 0

# 实体事件回调
func _on_entity_registered(entity: GameEntity) -> void:
	# 实体注册时的回调
	print("实体注册到系统: ", system_name, " - ", entity.data.config.entity_name)

func _on_entity_unregistered(entity: GameEntity) -> void:
	# 实体注销时的回调
	print("实体从系统注销: ", system_name, " - ", entity.data.config.entity_name)

# 系统状态控制
func enable() -> void:
	# 启用系统
	if not enabled:
		enabled = true
		print("系统启用: ", system_name)

func disable() -> void:
	# 禁用系统
	if enabled:
		enabled = false
		print("系统禁用: ", system_name)

func toggle_enabled() -> bool:
	# 切换系统启用状态
	enabled = not enabled
	print("系统状态切换: ", system_name, " -> ", enabled)
	return enabled

# 批处理配置方法
func set_batch_settings(use_batch: bool, threshold: int, size: int) -> void:
	# 设置批处理参数
	use_batch_processing = use_batch
	batch_threshold = max(1, threshold)
	batch_size = max(1, size)
	print("批处理设置更新: ", system_name, " 阈值=", threshold, " 批大小=", size)

func disable_batching() -> void:
	# 禁用批处理
	use_batch_processing = false
	print("批处理已禁用: ", system_name)

# 工具函数
func get_entity_count() -> int:
	# 获取当前管理的实体数量
	return entities.size()

func is_system_processing() -> bool:
	# 检查系统是否正在处理（启用且有实体）
	return enabled and not entities.is_empty()

func get_batch_info() -> Dictionary:
	# 获取批处理信息
	return {
		"use_batch_processing": use_batch_processing,
		"batch_threshold": batch_threshold,
		"batch_size": batch_size,
		"current_batch_index": _current_batch_index,
		"is_using_batch": use_batch_processing and entities.size() > batch_threshold
	}

func get_system_info() -> Dictionary:
	# 获取系统信息（用于调试）
	return {
		"name": system_name,
		"type": system_type,
		"enabled": enabled,
		"entity_count": entities.size(),
		"priority": update_priority,
		"batch_info": get_batch_info()
	}

# 调试功能
func print_debug_info() -> void:
	# 打印系统调试信息
	var info = get_system_info()
	print("=== 系统调试信息 ===")
	for key in info:
		if key != "batch_info":
			print("  ", key, ": ", info[key])
	
	var batch_info = info["batch_info"]
	print("  批处理信息:")
	for key in batch_info:
		print("    ", key, ": ", batch_info[key])
	
	print("  实体列表:")
	for entity in entities:
		if entity and entity.data:
			print("    - ", entity.data.config.entity_name)
