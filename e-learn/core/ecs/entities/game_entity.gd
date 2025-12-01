# game_entity.gd
extends CharacterBody2D
class_name GameEntity

## 共享的 CircleShape2D 资源
var data: EntityData
var shared_shape: Shape2D

var collision_shape: CollisionShape2D

# 初始化函数
func setup(entity_data: EntityData) -> void:
	#"""初始化实体，绑定数据并连接信号"""
	data = entity_data
	
	# 连接基础表现相关的信号
	_connect_signals()
	
	_initial_sync()
	print("GameEntity 初始化完成: ", data.config.entity_name)

# 初始同步：用当前数据初始化基础表现
func _initial_sync() -> void:
   # """将初始数据同步到节点表现"""
	position = data.get_position()
	visible = data.runtime.is_active
	
	# 创建碰撞盒
	_create_collision_shape()
	
	print("实体初始化: %s 位置: %s" % [data.config.entity_name, position])
	
# 连接数据变化的信号
func _connect_signals() -> void:
	pass
	
# 统一移动接口，子类直接调
func move(direction: Vector2, speed: float) -> void:
	velocity = direction * speed
	move_and_slide()

# 创建碰撞盒
func _create_collision_shape() -> void:
	collision_layer = 2
	collision_mask = 2
	
	collision_shape = CollisionShape2D.new()
	collision_shape.shape = Game.SHARED_CIRCLE_44
	
	add_child(collision_shape)
