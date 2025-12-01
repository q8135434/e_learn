# res://global/system_manager.gd
extends Node
# 作用：ECS架构的核心调度器，管理和协调所有系统的执行
# 职责：
#   - 注册和管理所有系统实例
#   - 按优先级调度系统执行
#   - 提供系统间的通信桥梁
#   - 支持系统的动态启用/禁用

# Godot单例：不需要class_name，直接在AutoLoad中加载

# 系统注册表
var _systems: Dictionary = {}           # 系统名称 -> 系统实例
var _system_instances: Array = []       # 所有系统实例
var _update_order: Array = []           # 按优先级排序的系统名称列表

# 系统组别
var _system_groups: Dictionary = {
	"core": [],        # 核心系统：移动、战斗等
	"gameplay": [],    # 玩法系统：装备、技能等  
	"render": [],      # 渲染系统：动画、UI等
	"infrastructure": [] # 基础设施：网络、存档等
}

# 性能监控
var _performance_counter: int = 0       # 性能统计计数器（0-60循环）
var _system_performance: Dictionary = {} # 系统性能数据

var _check_frame:int = 300

# 就绪函数
func _ready():
	print("SystemManager 初始化完成")
	_setup_default_systems()
	
# 每帧更新
func _process(delta: float):
	_performance_counter += 1
	_update_systems(delta)
	
	# 每60帧输出一次性能报告并重置
	if _performance_counter >= _check_frame:
		_print_performance_report()
		_reset_performance_counters()
		_performance_counter = 0

# 设置默认系统
func _setup_default_systems():
	print("开始注册默认系统...")
	
	for registration in Game.system_registrations:
		_register_system_internal(registration)
	
	print("默认系统注册完成")

# 内部系统注册方法
func _register_system_internal(registration: Dictionary):
	var system_script = registration.get("script")
	var group = registration.get("group", "core")
	var needs_scene_tree = registration.get("needs_scene_tree", false)
	var priority = registration.get("priority", 50)  # 🎯 获取优先级
	
	if not system_script:
		push_error("系统注册缺少script")
		return
	
	var system_instance = system_script.new()
	
	# 🎯 设置系统优先级
	system_instance.update_priority = priority
	
	if needs_scene_tree:
		add_child(system_instance)
		system_instance.name = registration.get("name", "UnnamedSystem")
		
	if register_system(system_instance, group, needs_scene_tree):
		print("✅ 系统注册成功: ", system_instance.system_name, " 优先级: ", priority)
	else:
		push_error("❌ 系统注册失败")

# 注册系统
func register_system(system:SystemBase, group: String = "core", needs_scene_tree: bool = false) -> bool:
	# 简单的类型检查
	if system == null:
		push_error("注册失败：系统为 null")
		return false
	
	# 先初始化系统，让系统设置自己的名称
	if system.has_method("_initialize"):
		system._initialize()
	
	# 初始化后再获取系统名称
	var system_name = system.system_name
	print("正在注册系统: ", system_name)
	
	if _systems.has(system_name):
		push_error("系统已存在: " + system_name)
		return false
	
	# 注册系统
	_systems[system_name] = system
	_system_instances.append(system)
	
	# 添加到组别
	if _system_groups.has(group):
		_system_groups[group].append(system_name)
	else:
		_system_groups[group] = [system_name]
	
	# 更新执行顺序
	_update_execution_order()
		
	print("系统注册成功: ", system_name, " 组别: ", group)
	
	# 通知其他系统有新系统注册
	_notify_system_registered(system.system_name)
	
	return true

func _notify_system_registered(system_name: String):
	# 其他系统可以监听这个通知来更新依赖
	for system in _system_instances:
		if system.has_method("_on_system_registered"):
			system._on_system_registered(system_name)
	
# 注销系统
func unregister_system(system_name: String) -> bool:
	if not _systems.has(system_name):
		push_error("系统不存在: " + system_name)
		return false
	
	var system = _systems[system_name]
	
	# 执行系统清理
	if system.has_method("_shutdown"):
		system._shutdown()
	
	# 从所有组别中移除
	for group in _system_groups:
		_system_groups[group].erase(system_name)
	
	# 从注册表中移除
	_systems.erase(system_name)
	_system_instances.erase(system)
	_update_order.erase(system_name)
	
	print("系统注销成功: ", system_name)
	return true

# 获取系统
func get_system(system_name: String):
	return _systems.get(system_name)

# 检查系统是否存在
func has_system(system_name: String) -> bool:
	return _systems.has(system_name)

# 更新系统执行顺序
func _update_execution_order():
	# 按优先级排序
	_system_instances.sort_custom(_compare_system_priority)
	_update_order.clear()
	
	for system in _system_instances:
		_update_order.append(system.system_name)

# 系统优先级比较函数
func _compare_system_priority(a, b) -> bool:
	return a.update_priority < b.update_priority

# 系统更新循环
func _update_systems(delta: float):
	for system_name in _update_order:
		var system = _systems[system_name]
		if system and system.enabled:
			var system_start_time = Time.get_ticks_usec()
			
			# 执行系统更新
			system.process_system(delta)
			
			# 记录性能数据
			var system_time = Time.get_ticks_usec() - system_start_time
			_record_system_performance(system_name, system_time)

# 记录系统性能
func _record_system_performance(system_name: String, execution_time: int):
	if not _system_performance.has(system_name):
		_system_performance[system_name] = {
			"total_time": 0,
			"max_time": 0,
			"call_count": 0,
			"average_time": 0
		}
	
	var perf = _system_performance[system_name]
	perf.total_time += execution_time
	perf.call_count += 1
	perf.max_time = max(perf.max_time, execution_time)
	perf.average_time = perf.total_time / perf.call_count

# 重置性能计数器
func _reset_performance_counters():
	for system_name in _system_performance:
		_system_performance[system_name].call_count = 0
		_system_performance[system_name].total_time = 0

# 输出性能报告
func _print_performance_report():
	print("=== 系统性能报告 (采样%d帧) ===" % _check_frame)
	
	var total_system_time = 0
	var has_data = false
	
	for system_name in _system_performance:
		var perf = _system_performance[system_name]
		if perf.call_count > 0:
			has_data = true
			total_system_time += perf.average_time
			print("  %s: 平均%.2fμs, 最大%dμs, 调用%d次" % [
				system_name, perf.average_time, perf.max_time, perf.call_count
			])
	
	if has_data:
		print("  总系统时间: %.2fμs" % total_system_time)
		print("  活跃系统数量: ", _get_active_system_count())
	else:
		print("  暂无性能数据")

# 获取活跃系统数量
func _get_active_system_count() -> int:
	var count = 0
	for system in _system_instances:
		if system.enabled and system.is_system_processing():
			count += 1
	return count

# 按组别启用/禁用系统
func set_group_enabled(group: String, enabled: bool):
	if not _system_groups.has(group):
		push_error("系统组别不存在: " + group)
		return
	
	for system_name in _system_groups[group]:
		var system = _systems[system_name]
		if system:
			if enabled:
				system.enable()
			else:
				system.disable()

# 获取系统信息
func get_system_info() -> Dictionary:
	var info = {
		"total_systems": _system_instances.size(),
		"active_systems": _get_active_system_count(),
		"system_groups": {},
		"performance_data": _system_performance.duplicate()
	}
	
	for group in _system_groups:
		info["system_groups"][group] = _system_groups[group].size()
	
	return info

# 调试功能
func print_debug_info():
	var info = get_system_info()
	print("=== SystemManager 调试信息 ===")
	print("总系统数量: ", info.total_systems)
	print("活跃系统数量: ", info.active_systems)
	print("系统组别分布:")
	for group in info.system_groups:
		print("  ", group, ": ", info.system_groups[group])
	
	print("系统执行顺序:")
	for i in range(_update_order.size()):
		var system = _systems[_update_order[i]]
		print("  %d. %s (优先级: %d)" % [i + 1, system.system_name, system.update_priority])

# 实体注册到所有相关系统
func register_entity_to_systems(entity):
	for system in _system_instances:
		system.register_entity(entity)

# 实体从所有系统注销
func unregister_entity_from_systems(entity):
	for system in _system_instances:
		system.unregister_entity(entity)
