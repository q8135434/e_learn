# res://core/ecs/systems/core/movement_system.gd
class_name MovementSystem extends SystemBase

func _initialize():
	system_name = "MovementSystem"
	system_type = "core"
	update_priority = 20  # 在输入系统之后，其他系统之前
	
	print("MovementSystem 初始化完成")

# 只处理在摄像机视野内且需要移动的实体
func _should_process_entity(entity: GameEntity) -> bool:
	if not entity or not entity.data:
		return false
	
	var data = entity.data
	var runtime = data.runtime
	
	# 1. 实体必须活跃
	if not runtime.is_active:
		return false
	
	# 2. 实体必须活着
	if not data.is_alive():
		return false
	
	# 被控制状态不移动（冰冻、麻痹、眩晕等）
	if runtime.has_state_flag(RuntimeData.StateFlags.FROZEN) or \
	   runtime.has_state_flag(RuntimeData.StateFlags.PARALYZED) or \
	   runtime.has_state_flag(RuntimeData.StateFlags.STUNNED):
		return false

	return runtime.is_in_camera_view

# 处理单个实体的移动
func _process_entity(entity: GameEntity, _delta: float):
	if not entity or not entity.data:
		return
	
	# 简化为：有速度就移动
	if entity.data.runtime.velocity != Vector2.ZERO:
		entity.move()
		
	#var data = entity.data
	#var runtime = data.runtime
	#
	#
	## 检查是否有移动指令
	#if runtime.click_target.type == "move" and runtime.click_target.position != Vector2.INF:
		#_process_movement(entity)

# 处理移动逻辑
#func _process_movement(entity: GameEntity):
	#var data = entity.data
	#var runtime = data.runtime
	#var target_position = runtime.click_target.position
	#var current_position = entity.global_position
	#
	## 计算到目标的距离和方向
	#var distance = current_position.distance_to(target_position)
	#var direction = (target_position - current_position).normalized()
	#
	## 如果已经到达目标（5像素范围内）
	#if distance < 5.0:
		## 停止移动
		#runtime.click_target.type = "none"
		#runtime.click_target.position = Vector2.INF
		#runtime.velocity = Vector2.ZERO
		#runtime.is_moving = false
		#entity.velocity = runtime.velocity
		#return
	#
	## 设置速度
	#runtime.velocity = direction * data.config.move_speed
	#runtime.is_moving = true
	#entity.velocity = runtime.velocity
	#
	## 调用GameEntity的move方法
	#entity.move()
