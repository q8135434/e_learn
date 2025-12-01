extends Node

const SHARED_CIRCLE_44 = preload("uid://ljqm0hcpijnt")
const SHARED_CIRCLE_72 = preload("uid://dlwg14a8t4brl")
const SHARED_CIRCLE_108 = preload("uid://cgqk4mwv7hg0i")

# 默认系统注册配置
var system_registrations: Array = [
	# 核心系统
	#{
		#"script": load("res://core/ecs/systems/infrastructure/touch_input_system.gd"),
		#"group": "infrastructure",
		#"name": "TouchInputSystem ",
		#"needs_scene_tree": true,  # 🎯 需要场景树来处理输入事件
		#"priority": 1  # 🎯 最高优先级
	#},
]
