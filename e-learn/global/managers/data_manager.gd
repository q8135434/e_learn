# data_manager.gd
class_name DataManager extends RefCounted

# 所有数据类在这里统一管理
#var user: UserData
var profile: UserProfileData
#var zone: ZoneData  
#var chat: ChatData
#var mail_list: MailListData  # 改为邮件列表
#var vip: VipData
#var session: SessionData
#var settings: GameSettings
#var wallet:WalletData
#var task_list:TaskListData
#var inventory:NetInventoryData
var player_skills: PlayerSkillData  # 🆕 纯数据容器

# 🎯 场景导航数据
var scene_navigation: SceneNavigationData
var gameplay_session_data: GameplaySessionData
# 🎯 游戏设置
#var settings: GameSettings

# 聊天室
var chat_messages: Dictionary = {}  # channel_type -> Array[ChatMessageData]
var current_channel: int = 1  # 当前选中的频道

func _init():
	#user = UserData.new()
	profile = UserProfileData.new()
	#zone = ZoneData.new()
	#chat = ChatData.new()
	#mail_list = MailListData.new()
	#vip = VipData.new()
	#session = SessionData.new()
	#settings = GameSettings.new()
	#wallet = WalletData.new()
	#task_list = TaskListData.new()
	#inventory = NetInventoryData.new()
	scene_navigation = SceneNavigationData.new()
	gameplay_session_data = GameplaySessionData.new()
	player_skills = PlayerSkillData.new()

func to_dict() -> Dictionary:
	return {
		#"user":user.to_dict(),
		"profile":profile.serialize(),
		"scene_navigation":scene_navigation.serialize(),
		"gameplay_session_data":gameplay_session_data.serialize(),
		"player_skills": player_skills.serialize()
	}

func from_dict(save_data:Dictionary) -> void:
	if save_data.is_empty(): return
	#if save_data.has("user"): user.update_from_dict(save_data["user"])
	if save_data.has("profile"): profile.deserialize(save_data["profile"])
	if save_data.has("scene_navigation"): scene_navigation.deserialize(save_data["scene_navigation"])
	if save_data.has("gameplay_session_data"): gameplay_session_data.deserialize(save_data["gameplay_session_data"])
	if save_data.has("player_skills"): player_skills.deserialize(save_data["player_skills"])

## 🆕 初始化新游戏数据
func initialize_new_game():
	profile.level = 1
	profile.experience = 0
	profile.nickname = "新手玩家"
	profile.gender = 0
	profile.job = 0
	profile.created_at = Time.get_unix_time_from_system()
	
	# 初始化场景导航数据
	scene_navigation.persistent_scene_id = "map_001"
	scene_navigation.persistent_position = Vector2(300, 300)
	
	print("DataManager: 新游戏数据初始化完成")
