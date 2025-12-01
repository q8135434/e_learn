# 统一数据管理容器，支持响应式数据变更
class_name EntityData extends Resource

# 数据组件引用
var runtime: RuntimeData = null
var config: ConfigData = null

# 响应式数据变更信号（仅监控运行时数据）
signal data_changed(component_type: String, property: String, old_value, new_value)

func _init():
	# 初始化数据组件
	runtime = RuntimeData.new()
	config = ConfigData.new()
	
	# 只连接运行时组件的变更信号（配置数据很少变动）
	runtime.data_changed.connect(_on_runtime_data_changed)

# 转发运行时组件变更信号
func _on_runtime_data_changed(property: String, old_value, new_value):
	data_changed.emit("runtime", property, old_value, new_value)

# 序列化数据（用于存档）
func serialize() -> Dictionary:
	return {
		"runtime": runtime.serialize(),
		"config": config.serialize()
	}

# 反序列化数据
func deserialize(data: Dictionary):
	if data.has("runtime"):
		runtime.deserialize(data["runtime"])
	if data.has("config"):
		config.deserialize(data["config"])

# 便捷方法：获取完整属性
func get_final_property(property_name: String):
	# 计算最终属性 = 基础属性 + 装备加成 + 技能加成等
	match property_name:
		"health":
			return config.base_health  # 后续会加上装备加成
		"max_health":
			return config.base_health
		"speed":
			return config.base_speed
		"attack":
			return config.base_attack
		"defense":
			return config.base_defense
		_:
			return null
