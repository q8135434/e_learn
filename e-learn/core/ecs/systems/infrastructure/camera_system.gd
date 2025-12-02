class_name CameraSystem extends SystemBase

# 相机配置
var _camera: Camera2D
var _target_entity: GameEntity
var _smoothing_speed: float = 5.0

# 🎯 动态获取分辨率
var _viewport_size: Vector2 = Vector2.ZERO
var _base_zoom: float = 2.2
var _viewport_scale: float = 1.0  # 视口缩放比例
var _design_resolution: Vector2 = Vector2(1080, 2340)  # 设计分辨率（竖屏）

# 🎯 相机偏移配置（让玩家在屏幕中央偏下）
var _vertical_offset_ratio: float = 0.15  # 向下偏移屏幕高度的15%
var _vertical_offset: float = 0.0  # 计算后的实际偏移量

# 缓存相机矩形，避免每帧重复计算
var _cached_camera_rect: Rect2 = Rect2()
var _camera_rect_dirty: bool = true

func _initialize():
	system_name = "CameraSystem"
	system_type = "infrastructure"
	
	# 启用批处理优化
	use_batch_processing = true
	batch_size = 20
	batch_threshold = 30
	
	# 初始化视口大小
	_update_viewport_size()

# 🎯 动态更新视口大小
func _update_viewport_size():
	var viewport = get_viewport()
	if viewport:
		_viewport_size = viewport.size
		
		# 🎯 计算相对于设计分辨率的缩放比例
		# 保持宽高比，以较短边为基准
		var scale_x = _viewport_size.x / _design_resolution.x
		var scale_y = _viewport_size.y / _design_resolution.y
		_viewport_scale = min(scale_x, scale_y)
		
		# 限制缩放范围
		_viewport_scale = clamp(_viewport_scale, 0.5, 2.0)
		
		# 🎯 计算实际垂直偏移（像素）
		_vertical_offset = _viewport_size.y * _vertical_offset_ratio
		
		print("📐 视口更新: ", _viewport_size, " 缩放: ", _viewport_scale, " 偏移: ", _vertical_offset)
		_camera_rect_dirty = true  # 标记相机矩形需要重新计算
	else:
		# 回退到设计分辨率
		_viewport_size = _design_resolution
		_viewport_scale = 1.0
		_vertical_offset = _design_resolution.y * _vertical_offset_ratio
		_camera_rect_dirty = true

func _should_process_entity(entity: GameEntity) -> bool:
	# 🎯 你的判断条件是对的：
	# 1. 实体存在
	# 2. 实体激活状态
	# 3. 实体活着（如果有生命值概念）
	return entity != null and entity.is_entity_active()

# 🎯 处理单个实体：更新其视锥状态
func _process_entity(entity: GameEntity, _delta: float):
	if not entity or not entity.data:
		return
	
	# 更新相机矩形缓存
	if _camera_rect_dirty:
		_cached_camera_rect = _get_camera_rect()
		_camera_rect_dirty = false
	
	# 判断实体是否在相机视锥内
	var is_in_view = _is_point_in_camera_view(entity.global_position, _cached_camera_rect)
	
	# 设置视锥标志
	entity.data.runtime.is_in_camera_view = is_in_view

func _on_entity_registered(entity: GameEntity):
	var entity_type = entity.data.config.entity_type
	
	if entity_type == "player":
		print("📷 检测到玩家注册: ", entity.data.config.entity_name)
		_target_entity = entity
		_ensure_camera_exists()
		snap_to_target()
		print("✅ 相机开始跟随玩家")
	
	# 注册实体到系统（让父类管理）
	super.register_entity(entity)

func _on_entity_unregistered(entity: GameEntity):
	if entity == _target_entity:
		print("📷 目标实体注销，停止跟随: ", entity.data.config.entity_name)
		_target_entity = null
	
	# 从系统注销实体
	super.unregister_entity(entity)

func _ensure_camera_exists():
	if not _camera or not is_instance_valid(_camera):
		_create_camera()
	else:
		if not _camera.is_current():
			_camera.make_current()

func _create_camera():
	if _camera and is_instance_valid(_camera):
		_camera.queue_free()
	
	_camera = Camera2D.new()
	_camera.name = "MainCamera"
	
	# 🎯 动态计算缩放
	# 基础缩放 * (1/视口缩放) 保持内容大小一致
	var dynamic_zoom = _base_zoom * (1.0 / _viewport_scale)
	_camera.zoom = Vector2(dynamic_zoom, dynamic_zoom)
	
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = _smoothing_speed
	_camera.ignore_rotation = true
	_camera.anchor_mode = Camera2D.ANCHOR_MODE_DRAG_CENTER  # 居中锚点
	
	# 🎯 移除边界限制
	_camera.limit_left = -100000
	_camera.limit_top = -100000
	_camera.limit_right = 100000
	_camera.limit_bottom = 100000
	
	var scene_root = get_tree().current_scene
	if scene_root:
		scene_root.add_child(_camera)
		_camera.make_current()
		
		print("📷 自适应相机创建完成")
		print("   动态缩放: ", dynamic_zoom)
		print("   锚点模式: ", _camera.anchor_mode)
		
		_camera_rect_dirty = true  # 相机创建后需要更新矩形

# 🎯 立即跳转到目标位置（带垂直偏移）
func snap_to_target():
	if not _target_entity or not _camera or not is_instance_valid(_target_entity):
		return
	
	var target_pos = _target_entity.global_position
	
	# 🎯 关键：应用垂直偏移
	# 玩家位置向上移动，让玩家在屏幕中偏下
	var camera_target_pos = target_pos
	camera_target_pos.y -= _vertical_offset / _camera.zoom.y  # 需要考虑相机缩放
	
	_camera.global_position = camera_target_pos
	
	# 标记相机矩形需要更新
	_camera_rect_dirty = true
	
	print("🎯 相机定位调试:")
	print("   玩家位置: ", target_pos)
	print("   垂直偏移: ", _vertical_offset, "像素")
	print("   考虑缩放后的偏移: ", _vertical_offset / _camera.zoom.y)
	print("   相机目标位置: ", camera_target_pos)

# 🎯 系统更新：平滑跟随目标（带垂直偏移）
func process_system(delta: float):
	if not enabled:
		return
	
	# 1. 相机跟随目标
	_follow_target(delta)
	
	# 2. 🎯 使用父类的分帧处理机制更新实体视锥状态
	super.process_system(delta)

func _follow_target(delta: float):
	if not _target_entity or not _camera:
		return
	
	if not is_instance_valid(_target_entity):
		_target_entity = null
		return
	
	var target_pos = _target_entity.global_position
	
	# 🎯 应用垂直偏移
	var camera_target_pos = target_pos
	camera_target_pos.y -= _vertical_offset / _camera.zoom.y
	
	# 平滑插值
	var current_pos = _camera.global_position
	var new_pos = current_pos.lerp(camera_target_pos, delta * _smoothing_speed)
	
	# 只有位置变化时才更新
	if new_pos != current_pos:
		_camera.global_position = new_pos
		_camera_rect_dirty = true  # 位置变化需要更新相机矩形

# 🎯 获取相机实际覆盖的矩形区域（考虑垂直偏移）
func _get_camera_rect() -> Rect2:
	if not _camera:
		return Rect2()
	
	var camera_pos = _camera.global_position
	var scaled_viewport = _viewport_size / _camera.zoom
	
	# 🎯 对于居中锚点，考虑垂直偏移
	# 实际相机矩形应该向上偏移，因为相机位置已经向下调整了
	var actual_camera_pos = camera_pos
	actual_camera_pos.y += _vertical_offset / _camera.zoom.y  # 反向补偿偏移
	
	return Rect2(actual_camera_pos - scaled_viewport * 0.5, scaled_viewport)

# 🎯 判断点是否在相机视锥内
func _is_point_in_camera_view(point: Vector2, camera_rect: Rect2) -> bool:
	# 扩展判定区域（给物理系统一些缓冲）
	var extended_rect = camera_rect.grow(200.0)  # 200像素缓冲
	return extended_rect.has_point(point)

# 🎯 设置垂直偏移比例
func set_vertical_offset_ratio(ratio: float):
	_vertical_offset_ratio = clamp(ratio, 0.0, 0.4)  # 限制在0-40%之间
	_vertical_offset = _viewport_size.y * _vertical_offset_ratio
	_camera_rect_dirty = true  # 偏移变化需要更新相机矩形
	print("📏 垂直偏移比例设置为: ", _vertical_offset_ratio, " (", _vertical_offset, "像素)")

# 🎯 设置相机缩放
func set_zoom(zoom_level: float):
	if _camera:
		_camera.zoom = Vector2(zoom_level, zoom_level)
		_camera_rect_dirty = true  # 缩放变化需要更新相机矩形
		print("🔍 相机缩放设置为: ", zoom_level)

# 🎯 获取当前相机信息
func get_camera_info() -> Dictionary:
	if not _camera:
		return {}
	
	var target_pos = _target_entity.global_position if _target_entity and is_instance_valid(_target_entity) else Vector2.ZERO
	var scaled_viewport = _viewport_size / _camera.zoom
	
	# 确保相机矩形是最新的
	if _camera_rect_dirty:
		_cached_camera_rect = _get_camera_rect()
		_camera_rect_dirty = false
	
	return {
		"position": _camera.global_position,
		"zoom": _camera.zoom,
		"target": _target_entity.data.config.entity_name if _target_entity and is_instance_valid(_target_entity) else "无",
		"target_position": target_pos,
		"viewport_size": _viewport_size,
		"scaled_viewport": scaled_viewport,
		"design_resolution": _design_resolution,
		"viewport_scale": _viewport_scale,
		"vertical_offset": _vertical_offset,
		"vertical_offset_ratio": _vertical_offset_ratio,
		"camera_rect": _cached_camera_rect,
		"entities_in_system": entities.size(),
		"is_active": _camera.is_current()
	}

func force_update():
	if _target_entity and _camera:
		snap_to_target()
		_camera_rect_dirty = true
		print("🔄 强制更新相机位置")

func get_system_info() -> Dictionary:
	var info = super.get_system_info()
	var camera_info = get_camera_info()
	info["camera"] = camera_info
	return info
