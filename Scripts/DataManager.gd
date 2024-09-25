extends Node

@onready var app_path : String = str(OS.get_executable_path().get_base_dir())
@onready var main : Control = get_node("/root/Main")
@onready var decryption_popup_container : Control = get_node("/root/Main/Camera/ScreenContainer/DecryptionScreen")
@export var passwords_data : Array[Dictionary] = []
@export var tag_data : Array[Dictionary] = []
@export var user_data : Dictionary = {}
@export var can_read_encrypted_data : bool = false
@export var decryption_key : String
@export var succesfully_read_data : bool = false
@export var remaining_read_attempts : int = 3
const default_user_data : Dictionary = {"alphabet": {"special": "!?@#£$%&(){}[]<>^|':;", "uppercase": "ABCDEFGHIJKLMNOPQRSTUVWXYZ", "lowercase": "abcdefghijklmnopqrstuvwxyz", "number": "0123456789"}, "autosave": false, "autosave_interval": 1, "autobackup": false, "autobackup_interval": 1, "lastopened": 0, "encryption": false, "case_sensative_search": true, "strict_search": true, "fpscapped": true, "frame_efficiency": false}
signal finished_read

func pause_app(state : bool) -> void:
	get_tree().set_deferred("paused", state)
	return

func read_data() -> void:
	pause_app(true)
	passwords_data = []
	tag_data = []
	user_data = {}
	#
	if DirAccess.dir_exists_absolute(app_path + "/NPS_Data") and FileAccess.file_exists(app_path + "/NPS_Data/UserData.ini"):
		var opened_user_data : ConfigFile = ConfigFile.new()
		opened_user_data.load(app_path + "/NPS_Data/UserData.ini")
		for item in opened_user_data.get_section_keys("data"):
			user_data[item] = opened_user_data.get_value("data", item)
	if user_data == {}:
		user_data = default_user_data.duplicate(true)
	#
	var data_exists : bool = DirAccess.dir_exists_absolute(app_path + "/NPS_Data")
	var passwords_path : String = str(app_path + "/NPS_Data/Passwords.ini")
	var tag_path : String = str(app_path + "/NPS_Data/Tags.ini")
	var passwords_data_exists : bool = (data_exists == true and FileAccess.file_exists(passwords_path))
	var tags_data_exists : bool = (data_exists == true and FileAccess.file_exists(tag_path))
	var run_decryption_process : bool = user_data["encryption"] == true and (passwords_data_exists and tags_data_exists)
	var empty_files : Array[bool]
	if data_exists:
		empty_files = [len(FileAccess.open(passwords_path, FileAccess.READ).get_as_text()) < 1, len(FileAccess.open(tag_path, FileAccess.READ).get_as_text()) < 1]
	main.callv("set_decryption_screen", [run_decryption_process])
	if run_decryption_process:
		while succesfully_read_data == false:
			await decryption_popup_container.get_child(0).set_decryption_key
			await get_tree().process_frame
			passwords_data = read_data_file(passwords_path, "password")
			tag_data = read_data_file(tag_path, "tag")
			if (passwords_data.is_empty() == empty_files[0]) and (tag_data.is_empty() == empty_files[1]):
				succesfully_read_data = true
			else:
				remaining_read_attempts -= 1
				decryption_popup_container.get_child(0).call_deferred("update_chances", remaining_read_attempts)
	else:
		default_data_read(passwords_data_exists, tags_data_exists)
	#
	pause_app(false)
	decryption_popup_container.set_deferred("visible", false)
	emit_signal("finished_read")
	return

func default_data_read(passwords_data_exists : bool, tags_data_exists : bool) -> void:
	passwords_data = []
	tag_data = []
	if passwords_data_exists:
		passwords_data = read_data_file(app_path + "/NPS_Data/Passwords.ini", "password")
	if tags_data_exists:
		tag_data = read_data_file(app_path + "/NPS_Data/Tags.ini", "tag")
	return

func read_data_file(path : String, data_type : String) -> Array[Dictionary]:
	var to_return : Array[Dictionary] = []
	var opened_file : ConfigFile = ConfigFile.new()
	var opened_file_text : String
	var file_is_empty : bool = len(FileAccess.open(path, FileAccess.READ).get_as_text()) < 1
	opened_file_text = open_file_contents(path)
	if (len(opened_file_text) < 1) and (file_is_empty):
		return to_return
	elif not opened_file_text.begins_with("["):
		return to_return
	opened_file.parse(opened_file_text)
	if data_type == "password":
		for item in opened_file.get_sections():
			to_return.append({"name": item, "login": opened_file.get_value(item, "login"), "password": opened_file.get_value(item, "password"), "tags": opened_file.get_value(item, "tags")})
	else:
		for item in opened_file.get_sections():
			to_return.append({"name": item, "used_by": opened_file.get_value(item, "used_by")})
	return to_return

func save_data(save_folder : String = "NPS_Data") -> void:
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_BUSY)
	pause_app(true)
	var passwords_file : ConfigFile = ConfigFile.new()
	var tag_file : ConfigFile = ConfigFile.new()
	var user_file : ConfigFile = ConfigFile.new()
	#
	for item in passwords_data:
		passwords_file.set_value(item["name"], "login", item["login"])
		passwords_file.set_value(item["name"], "password", item["password"])
		passwords_file.set_value(item["name"], "tags", item["tags"])
	#
	for item in tag_data:
		tag_file.set_value(item["name"], "used_by", item["used_by"])
	#
	for item in user_data:
		user_file.set_value("data", item, user_data[item])
	#
	if not DirAccess.dir_exists_absolute(app_path + "/" + save_folder):
		DirAccess.make_dir_absolute(app_path + "/" + save_folder)
	var password_path : String = app_path + "/" + save_folder + "/Passwords.ini"
	var tag_path : String = app_path + "/" + save_folder + "/Tags.ini"
	var user_path : String = app_path + "/" + save_folder + "/UserData.ini"
	if user_data["encryption"] == true:
		save_to_file(password_path, EncryptionManager.call("encrypt", passwords_file.encode_to_text(), decryption_key))
		save_to_file(tag_path, EncryptionManager.call("encrypt", tag_file.encode_to_text(), decryption_key))
	else:
		passwords_file.save(password_path)
		tag_file.save(tag_path)
	user_file.save(user_path)
	pause_app(false)
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	return

func delete_data(types : Array[String]) -> void:
	pause_app(true)
	for item in types:
		if FileAccess.file_exists(app_path + "/NPS_Data/" + item + ".ini"):
			DirAccess.remove_absolute(app_path + "/NPS_Data/" + item + ".ini")
	pause_app(false)
	return

func open_file_contents(path : String) -> String:
	var file : FileAccess = FileAccess.open(path, FileAccess.READ)
	var file_text : String
	if ((user_data["encryption"] == true) and (len(file.get_as_text()) > 0)):
		file_text = EncryptionManager.call("decrypt", file.get_as_text(), decryption_key)
	else:
		file_text = file.get_as_text()
	file.close()
	return file_text

func save_to_file(path : String, contents : String) -> void:
	var file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.resize(0)
	file.store_string(contents)
	file.close()
	return
