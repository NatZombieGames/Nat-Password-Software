extends PanelContainer

@onready var add_entry_scene : Resource = preload("res://Scenes/AddEntryBtn.tscn")
@onready var popup_scene : Resource = preload("res://Scenes/PopupScene.tscn")
@onready var notification_scene : Resource = preload("res://Scenes/NotificationScene.tscn")
@onready var popup_searchbox_scene : Resource = preload("res://Scenes/PopupSearchbox.tscn")
@onready var main : Control = get_node("/root/Main")
@onready var main_popup_container : Control = get_node("/root/Main/Camera/ScreenContainer/PopupContainer")
@onready var main_notification_container : Control = get_node("/root/Main/Camera/ScreenContainer/NotificationContainer")
@export_enum("Password", "Tag") var type : int = 0
const banned_item_names : Array[String] = ["@all"]
const banned_item_name_starters : Array[String] = ["#", "£", "&"]
var password_generation_paramaters : Array[bool] = [false, false, false, false]
var active_data : Dictionary

func _ready() -> void:
	$".".set_deferred("visible", false)
	for item in %PasswordGenerationContainer/Row4/OptionsList.get_children():
		item.get_child(0).set_deferred("parent", $".".get_path())
	for item in [%PasswordContainer, %PasswordGenerationContainer, %LoginContainer, $ScrollContainer/Container/Separator4, $ScrollContainer/Container/Separator5]:
		item.set_deferred("visible", type == 0)
	return

func set_paramaters(new_active_data : Dictionary) -> void:
	active_data = new_active_data
	for i in range(0, 2):
		change_edit_mode(i, false)
	%TitleContainer/EditTitleField.set_deferred("text", active_data["name"])
	%TitleContainer/EditTitleField.set_deferred("placeholder_text", active_data["name"])
	%TitleContainer/Title.set_deferred("text", active_data["name"])
	if "password" in active_data:
		%LoginContainer/EditLoginField.set_deferred("text", active_data["login"])
		%LoginContainer/EditLoginField.set_deferred("placeholder_text", active_data["login"])
		%LoginContainer/Title.set_deferred("text", active_data["login"])
		%PasswordGenerationContainer/Row1/NewPasswordField.set_deferred("text", active_data["password"])
		%PasswordGenerationContainer/Row1/NewPasswordField.set_deferred("placeholder_text", active_data["password"])
		%PasswordContainer/PasswordDisplay.set_deferred("text", active_data["password"])
	populate_tag_list()
	$".".set_deferred("visible", true)
	return

func change_edit_mode(section : int, state : bool) -> void:
	var to_change : Array[Array] = [[%TitleContainer/EditTitleBtn, %TitleContainer/EditTitleField, %TitleContainer/ChangeTitleBtn, %TitleContainer/Title], [%LoginContainer/EditLoginBtn, %LoginContainer/EditLoginField, %LoginContainer/ChangeLoginBtn, %LoginContainer/Title], [%PasswordContainer/EditPasswordBtn, %PasswordContainer/ChangePasswordBtn, %PasswordGenerationContainer]]
	var to_change_to : Array[Array] = [[!state, state, state, !state], [!state, state, state, !state], [!state, state, state]]
	for item in to_change[section]:
		item.set_deferred("visible", to_change_to[section][to_change[section].find(item)])
	return

func generate_password() -> void:
	%PasswordGenerationContainer/Row2/GenerateBtn.set_deferred("disabled", true)
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_BUSY)
	var length : int = %PasswordGenerationContainer/Row3/PasswordLength.value
	var to_return : String = ""
	var characters : Array[String]
	var paramater_to_case : Array[String] = [DataManager.user_data["alphabet"]["special"], DataManager.user_data["alphabet"]["uppercase"], DataManager.user_data["alphabet"]["lowercase"], DataManager.user_data["alphabet"]["number"]]
	while "" in paramater_to_case:
		paramater_to_case[paramater_to_case.find("")] = "N"
	for i in range(0, length-len(characters)):
		characters.append(get_random(paramater_to_case.pick_random()))
	if true in password_generation_paramaters:
		for i in range(0, 4):
			if password_generation_paramaters[i] == true:
				characters.append(get_random(paramater_to_case[i]))
		characters.shuffle()
	for item in characters:
		to_return += item
	%PasswordGenerationContainer/Row1/NewPasswordField.text = to_return
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	%PasswordGenerationContainer/Row2/GenerateBtn.set_deferred("disabled", false)
	return

func get_random(input : String) -> String:
	return input[randi_range(0, len(input)-1)]

func populate_tag_list() -> void:
	for item in %TagsList.get_children():
		item.queue_free()
	var paramater : String = ["tags", "used_by"][int("used_by" in active_data)]
	for item in active_data[paramater]:
		%TagsList.add_child(add_entry_scene.instantiate())
		%TagsList.get_child(-1).call_deferred("set_paramaters", item, active_data[paramater].find(item), true)
	%TagsList.add_child(add_entry_scene.instantiate())
	%TagsList.get_child(-1).call_deferred("set_paramaters", [" Add New Tag ", " Attach To An Entry "][int("used_by" in active_data)], -2, false)
	return

func receive_optionscene_pressed(id : int, state : bool) -> void:
	password_generation_paramaters[id] = state
	%PasswordGenerationContainer/Row3/PasswordLength.set_deferred("min_value", 1+(int(password_generation_paramaters[0]) + int(password_generation_paramaters[1]) + int(password_generation_paramaters[2]) + int(password_generation_paramaters[3])))
	return

func handle_entry_actions(id : int) -> void:
	main.call_deferred("handle_entry_actions", id)
	return

func create_popup_searchbox() -> void:
	for item in main_popup_container.get_children():
		item.queue_free()
	main_popup_container.add_child(popup_searchbox_scene.instantiate())
	main_popup_container.get_child(-1).call_deferred("set_paramaters", $".", int(!bool(type)))
	main_popup_container.set_deferred("visible", true)
	return

func receive_popup_responses(popup_id : int, button_id : int) -> void:
	if popup_id == 0:
		if button_id == 0:
			change_edit_mode(0, true)
	elif popup_id == 1:
		if button_id == 0:
			if %TitleContainer/EditTitleField.text not in banned_item_names and %TitleContainer/EditTitleField.text[0] not in banned_item_name_starters:
				var data_set : Array[Dictionary] = [DataManager.tag_data, DataManager.passwords_data][main.main_page]
				var item_set : String = ["used_by", "tags"][main.main_page]
				for item in data_set:
					if active_data["name"] in item[item_set]:
						item[item_set][item[item_set].find(active_data["name"])] = %TitleContainer/EditTitleField.text
				active_data["name"] = %TitleContainer/EditTitleField.text
				[DataManager.passwords_data, DataManager.tag_data][main.main_page][active_data["index"]]["name"] = %TitleContainer/EditTitleField.text
				%TitleContainer/Title.set_deferred("text", active_data["name"])
				change_edit_mode(0, false)
			else:
				main.callv("create_notification", ["Name Is Invalid, Please Pick Another Name.", 0.25])
	elif popup_id == 3:
		if button_id == 0:
			change_edit_mode(2, true)
	elif popup_id == 4:
		if button_id == 0:
			if %PasswordGenerationContainer/Row1/NewPasswordField.text not in banned_item_names and %PasswordGenerationContainer/Row1/NewPasswordField.text[0] not in banned_item_name_starters:
				DataManager.passwords_data[active_data["index"]]["password"] = %PasswordGenerationContainer/Row1/NewPasswordField.text
				active_data["password"] = %PasswordGenerationContainer/Row1/NewPasswordField.text
				%PasswordContainer/PasswordDisplay.text = %PasswordGenerationContainer/Row1/NewPasswordField.text
				change_edit_mode(2, false)
			else:
				main.callv("create_notification", ["Password Is Invalid, Please Pick Another Password", 0.25])
	elif popup_id == 5:
		if button_id == 0:
			change_edit_mode(1, true)
	elif popup_id == 6:
		if button_id == 0:
			if %LoginContainer/EditLoginField.text not in banned_item_names and %LoginContainer/EditLoginField.text[0] not in banned_item_name_starters:
				DataManager.passwords_data[active_data["index"]]["login"] = %LoginContainer/EditLoginField.text
				active_data["login"] = %LoginContainer/EditLoginField.text
				%LoginContainer/Title.text = %LoginContainer/EditLoginField.text
				change_edit_mode(1, false)
			else:
				main.callv("create_notification", ["Login Is Invalid, Please Pick Another Password", 0.25])
	return

func receive_edit_buttons(button_type : int, id : int) -> void:
	var opening_popups_text : Array[String] = ["Are You Sure You Wish To Change This Entries Title?", "Are You Sure You Wish To Change " + str(active_data["name"]) + "'s Login?", "Are You Sure You Wish To Change " + str(active_data["name"]) + "'s Password?"]
	var opening_popups_id : Array[int] = [0, 5, 3]
	var if_statement : Array[bool] = [active_data["name"] != %TitleContainer/EditTitleField.text, active_data["login"] != %LoginContainer/EditLoginField.text, active_data["password"] != %PasswordGenerationContainer/Row1/NewPasswordField.text]
	var closing_popups_text : Array[String] = [("Do You Wish To Change " + str(active_data["name"]) + "'s Name To " + str(%TitleContainer/EditTitleField.text) + "?"), ("Do You Wish To Change " + active_data["name"] + "'s Login From " + active_data["login"] + " To " + %LoginContainer/EditLoginField.text + "?"), ("Do You Wish To Change " + active_data["name"] + "'s Password From " + active_data["password"] + " To " + %PasswordGenerationContainer/Row1/NewPasswordField.text + "?")]
	var closing_popups_id : Array[int] = [1, 6, 4]
	var edit_mode_id : Array[int] = [0, 1, 2]
	if id == 0:
		main.callv("create_popup", [opening_popups_text[button_type], opening_popups_id[button_type], [" Yes ", " No "]])
	elif id == 1:
		if if_statement[button_type] == true:
			main.callv("create_popup", [closing_popups_text[button_type], closing_popups_id[button_type], [" Yes ", " No "]])
		else:
			change_edit_mode(edit_mode_id[button_type], false)
	return

func receive_popup_searchbox_data(popup_data : Dictionary) -> void:
	var data_set_1 : String = ["tags", "used_by"][type]
	var data_set_2 : String = ["used_by", "tags"][type]
	if popup_data["name"] not in active_data[data_set_1]:
		active_data[data_set_1].append(popup_data["name"])
		DataManager.passwords_data[active_data["index"]][data_set_1].append(popup_data["name"])
		DataManager.tag_data[popup_data["index"]][data_set_2].append(active_data["name"])
	populate_tag_list()
	return

func copy_password() -> void:
	DisplayServer.clipboard_set(active_data["password"])
	main.callv("create_notification", [" Password '" + str(active_data["password"]) + "' Copied To Clipboard", 0.25])
	return

func hovered(state : bool, id : int = 0) -> void:
	var tooltip : Array[String] = ["Name of this entry, can be searched for by putting its name into the searchbox on the left.", "Login of this entry, can be searched for in the Passwords tab by prefixing your search with '&'.", "Password of this entry, this can be searched for in the Passwords tab by prefixing your search with '£'.", "Your generated passwords minimum length, this is equal to One plus One for every toggle turned on below."]
	main.call_deferred("tooltip_control", state, tooltip[id], 500)
	return
