# game_entity.gd
extends CharacterBody2D
class_name GameEntity

## 共享的 CircleShape2D 资源
var data: EntityData
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
	 # 位置变化同步
	data.position_changed.connect(_on_position_changed)
	# 生命值变化同步
	data.health_changed.connect(_on_health_changed)
	# 通用数据变化
	data.data_changed.connect(_on_data_changed)
	
func _on_position_changed(old_pos: Vector2, new_pos: Vector2):
	position = new_pos
	print("实体 %s 位置更新: %s -> %s" % [data.config.entity_name, old_pos, new_pos])

func _on_health_changed(old_health: int, new_health: int):
	print("实体 %s 生命值变化: %d -> %d" % [data.config.entity_name, old_health, new_health])
	# 这里可以添加血条更新、受伤动画等

func _on_data_changed(property_name: String, old_value, new_value):
	print("实体 %s 数据变化: %s = %s -> %s" % [
		data.config.entity_name, property_name, old_value, new_value
	])
	

func get_entity_data() -> EntityData:
	#"""获取实体数据（供System使用）"""
	return data
	
# 统一移动接口，子类直接调
func move(direction: Vector2, speed: float) -> void:
	velocity = direction * speed
	move_and_slide()

# 创建碰撞盒
func _create_collision_shape() -> void:
	collision_shape = CollisionShape2D.new()
	collision_shape.shape = Game.SHARED_CIRCLE_44
	add_child(collision_shape)
	
	# 1-terrain 2-entity 3-bullet 4-trigger
	var layer := 0
	var mask  := 0
	match data.config.entity_type:
		"player":
			layer = 1<<1          # 只在第 2 层（entity）
			mask  = (1<<0) | (1<<1) | (1<<3)   # 撞 terrain+entity+trigger
		"monster":
			layer = 1<<1
			mask  = (1<<0) | (1<<1) | (1<<2)   # 撞 terrain+entity+bullet
		"npc":
			layer = 1<<1
			mask  = 1<<0                       # 只撞 terrain
		"item":
			layer = 1<<3                       # 放在 trigger 层
			mask  = 0                          # 不主动撞任何层

	set_collision_layer(layer)
	set_collision_mask(mask)
	
func is_entity_active() -> bool:
	return data != null and data.runtime.is_alive()
