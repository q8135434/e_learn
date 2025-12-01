# user_profile_data.gd
class_name UserProfileData extends Resource

var user_id: int = 0
var zone_id: int = 0

var level: int = 1
var experience: int = 0
var nickname: String = "未知玩家"
var last_activity: float = 0
var total_play_time: float = 0

# 新增字段
var gender: int = 0  # 0=未选择 1=男 2=女
var job: int = 0     # 0=未选择 1=战士 2=法师 3=道士  
var created_at: float = 0  # 角色创建时间

func deserialize(data: Dictionary) -> void:
	if data.has("user_id"): user_id = data["user_id"]
	if data.has("zone_id"): zone_id = data["zone_id"]
	if data.has("level"): level = data["level"]
	if data.has("experience"): experience = data["experience"]
	if data.has("nickname"): nickname = data["nickname"]
	if data.has("last_activity"): last_activity = data["last_activity"]
	if data.has("total_play_time"): total_play_time = data["total_play_time"]
	
	# 新增字段
	if data.has("gender"): gender = data["gender"]
	if data.has("job"): job = data["job"]
	if data.has("created_at"): created_at = data["created_at"]

func serialize() -> Dictionary:
	return {
		"user_id": user_id,
		"zone_id": zone_id,
		"level": level,
		"experience": experience,
		"nickname": nickname,
		"last_activity": last_activity,
		"total_play_time": total_play_time,
		"gender": gender,
		"job": job,
		"created_at": created_at
	}

# 新增工具方法
func get_job_name() -> String:
	match job:
		1: return "战士"
		2: return "法师"
		3: return "道士"
		_: return "未选择"

func get_gender_name() -> String:
	match gender:
		1: return "男"
		2: return "女"
		_: return "未选择"

func is_new_character() -> bool:
	# 3天内创建的角色算新角色
	var three_days_ago = Time.get_unix_time_from_system() - (3 * 24 * 60 * 60)
	return created_at > three_days_ago

func get_character_age_days() -> int:
	# 角色创建了多少天
	return int((Time.get_unix_time_from_system() - created_at) / (24 * 60 * 60))

func set_job(new_job: int) -> void:
	job = new_job

func set_gender(new_gender: int) -> void:
	gender = new_gender
