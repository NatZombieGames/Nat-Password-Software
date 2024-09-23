extends Control

@onready var app_path : String = str(OS.get_executable_path().get_base_dir())
@onready var item_scene : Resource = preload("res://Scenes/ItemScene.tscn")
@onready var popup_scene : Resource = preload("res://Scenes/PopupScene.tscn")
@onready var notification_scene : Resource = preload("res://Scenes/NotificationScene.tscn")
@onready var add_entry_scene : Resource = preload("res://Scenes/AddEntryBtn.tscn")
@onready var tooltip_scene : Resource = preload("res://Scenes/Tooltip.tscn")
@export var active_data : Dictionary
const main_pages : Array[String] = ["Passwords", "Tags", "AppSettings", "Help"]
const setting_pages : Array[String] = ["General", "Data", "Search"]
const help_pages : Array[String] = ["Passwords", "Tags", "Data", "App", "Search", "Developer"]
@export var main_page : int = 0
var settings_page : int = 0
var help_page : int = 0

func _ready() -> void:
	await loadingscreen_control(true)
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_BUSY)
	#
	set_decryption_screen(false)
	await DataManager.call_deferred("read_data")
	await get_tree().process_frame
	update_main_page(0)
	update_settings_page(0)
	update_help_page(0)
	apply_user_settings("all")
	set_infopanel(false)
	change_edit_mode(0, false)
	change_edit_mode(1, false)
	change_edit_mode(2, false)
	#
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	await loadingscreen_control(false)
	if DataManager.user_data["autobackup"] == true:
		if (DataManager.user_data["lastopened"] + int(DataManager.user_data["autobackup_interval"] * 86_400)) <= int(Time.get_unix_time_from_system()):
			create_popup("It Has Been Atleast " + str(DataManager.user_data["autobackup_interval"]) + [" Days", " Day"][int(DataManager.user_data["autobackup_interval"] == 1)] + " Since You Last Opened This App, Would You Like To Make A Backup?", 9, [" Yes ", " No "])
	DataManager.user_data["lastopened"] = int(Time.get_unix_time_from_system())
	return

func _unhandled_input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("SaveShortcut"):
		DataManager.call_deferred("save_data")
	else:
		var shortcuts : Array[String] = ["PasswordsShortcut", "TagsShortcut", "SettingsShortcut", "HelpShortcut"]
		for item in shortcuts:
			if Input.is_action_just_pressed(item):
				update_main_page(shortcuts.find(item))
	return

func apply_user_settings(type : String) -> void:
	#
	if type == "visuals" or type == "all":
		var general_content_1 : PanelContainer = %AppSettings/Container/Container/PageDisplay/General/PageContent
		var general_content_2 : PanelContainer = %AppSettings/Container/Container/PageDisplay/General/PageContent2
		var data_content_1 : PanelContainer = %AppSettings/Container/Container/PageDisplay/Data/PageContent
		var data_content_2 : PanelContainer = %AppSettings/Container/Container/PageDisplay/Data/PageContent2
		var search_content_1 : PanelContainer = %AppSettings/Container/Container/PageDisplay/Search/PageContent
		general_content_1.call_deferred("update_button_value", 0, DataManager.user_data["fpscapped"])
		general_content_1.call_deferred("update_button_value", 1, DataManager.user_data["frame_efficiency"])
		var num_to_key : Array[String] = ["special", "uppercase", "lowercase", "number"]
		for i in range(0, 4):
			general_content_2.call_deferred("update_button_value", i, DataManager.user_data["alphabet"][num_to_key[i]])
		var to_set_data : Array[Variant] = [DataManager.user_data["autosave"], DataManager.user_data["autosave_interval"], DataManager.user_data["autobackup"], DataManager.user_data["autobackup_interval"]]
		for i in range(0, len(to_set_data)):
			data_content_1.call_deferred("update_button_value", i, to_set_data[i])
		data_content_2.call_deferred("update_button_value", 0, DataManager.user_data["encryption"])
		data_content_2.call_deferred("update_button_value", 1, str(DataManager.decryption_key))
		search_content_1.call_deferred("update_button_value", 0, DataManager.user_data["case_sensative_search"])
		search_content_1.call_deferred("update_button_value", 1, DataManager.user_data["strict_search"])
	#
	if type == "values" or type == "all":
		Engine.max_fps = 30 * int(DataManager.user_data["fpscapped"])
		ProjectSettings.set_setting("application/run/low_processor_mode", DataManager.user_data["frame_efficiency"])
		if DataManager.user_data["autosave"] == true:
			%AutosaveTimer.start(DataManager.user_data["autosave_interval"] * 60)
		else:
			%AutosaveTimer.stop()
	#
	return

func update_main_page(new_page : int) -> void:
	main_page = new_page
	for item in %MasterContainer/AppBody.get_children():
		item.set_deferred("visible", main_pages.find(item.name) == main_page)
	%MasterContainer/TabBar.call_deferred("update_button_pressed", new_page)
	return

func update_settings_page(new_page : int) -> void:
	settings_page = new_page
	for item in %AppSettings/Container/Container/PageDisplay.get_children():
		item.set_deferred("visible", setting_pages.find(item.name) == settings_page)
	return

func update_help_page(new_page : int) -> void:
	help_page = new_page
	for item in %Help/Container/Container/PageDisplay/ScrollContainer/PageContainer.get_children():
		item.set_deferred("visible", help_pages.find(item.name) == help_page)
	return

func set_decryption_screen(state : bool) -> void:
	%DecryptionScreen.set_deferred("visible", state)
	return

func page_selector_selected(selector_id : int, id : int) -> void:
	if selector_id == 0:
		update_main_page(id)
	elif selector_id == 1:
		update_settings_page(id)
	elif selector_id == 2:
		update_help_page(id)
	return

func receive_window_control_buttons(btn_id : int) -> void:
	if btn_id == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)
	elif btn_id == 1:
		DisplayServer.window_set_mode([DisplayServer.WINDOW_MODE_MAXIMIZED, DisplayServer.WINDOW_MODE_WINDOWED][int(DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_MAXIMIZED)])
	elif btn_id == 2:
		create_popup("Do You Wish To Save Before Exiting?", 2, ["Yes", "No", "Don't Quit Programme"])
	return

func set_infopanel(set_visibility_to : bool = true) -> void:
	var panel : PanelContainer = [%Passwords/Panel/Container/InfoPanel, %Tags/Panel/Container/InfoPanel][main_page]
	if set_visibility_to == false:
		panel.set_deferred("visible", false)
		return
	panel.call_deferred("set_paramaters", active_data)
	return

func receive_item_scene_pressed(data_index : int) -> void:
	if main_page == 0:
		active_data = DataManager.passwords_data[data_index].duplicate(true)
	elif main_page == 1:
		active_data = DataManager.tag_data[data_index].duplicate(true)
	active_data["index"] = data_index
	set_infopanel()
	return

func page_content_value_altered(page_id : int, id : int, value : Variant) -> void:
	if main_page == 2:
		if settings_page == 0:
			if page_id == 0:
				DataManager.user_data[["fpscapped", "frame_efficiency"][id]] = value
			elif page_id == 1:
				var id_to_key : Array[String] = ["special", "uppercase", "lowercase", "number"]
				DataManager.user_data["alphabet"][id_to_key[id]] = value
		elif settings_page == 1:
			if page_id == 0:
				DataManager.user_data[["autosave", "autosave_interval", "autobackup", "autobackup_interval"][id]] = value
			elif page_id == 1:
				if id == 0:
					DataManager.user_data["encryption"] = value
				elif id == 1:
					var conditions : Array[bool] = [str(value).is_valid_int(), not "-" in str(value), not "+" in str(value), len(str(value)) == 4]
					if false in conditions:
						value = "0000"
						%AppSettings/Container/Container/PageDisplay/Data/PageContent2.call_deferred("update_button_value", 1, "1111")
					DataManager.decryption_key = str(value)
				if len(DataManager.decryption_key) != 4:
					create_notification("Please Set A Valid Encryption Key Before Enabling Encryption.", 0.25)
					DataManager.user_data["encryption"] = false
					%AppSettings/Container/Container/PageDisplay/Data/PageContent2.call_deferred("update_button_value", 0, false)
				else:
					DataManager.call_deferred("save_data")
		elif settings_page == 2:
			DataManager.user_data[["case_sensative_search", "strict_search"][id]] = value
		apply_user_settings("values")
	elif main_page == 3:
		if help_page == 2:
			if page_id == 0:
				var popup_titles : Array[String] = ["Are You Sure You Want To Delete All Your Data? This Action Is Permanent.", "Do You Wish To Save Your Data?", "Would You Like To Create A Backup Of Your Data? This Will Save Your Data First."]
				var popup_ids : Array[int] = [7, 8, 9]
				create_popup(popup_titles[id], popup_ids[id], [" Yes ", " No "])
			else:
				var popup_titles : Array[String] = ["", "Are You Sure You Wish To Delete All Your Password Data? This Action Is Permanent.", "Are You Sure You Wish To Delete All Your Tag Data? This Action Is Permanent.", "Are You Sure You Wish To Delete All Your User Data? This Action Is Permanent."]
				create_popup(popup_titles[page_id], page_id*10, [" Yes ", " No "])
	return

func receive_popup_button_pressed(popup_id : int, btn_id : int) -> void:
	if popup_id in [0, 1, 3, 4, 5, 6]:
		if main_page == 0:
			%Passwords/Panel/Container/InfoPanel.call_deferred("receive_popup_responses", popup_id, btn_id)
		elif main_page == 1:
			%Tags/Panel/Container/InfoPanel.call_deferred("receive_popup_responses", popup_id, btn_id)
	elif popup_id == 2:
		if btn_id in [0, 1]:
			if btn_id == 0:
				DataManager.call_deferred("save_data")
			get_tree().quit()
		elif btn_id == 2:
			pass
	elif popup_id in [7, 8, 9, 10, 11, 12]:
		if btn_id == 0:
			if popup_id in [7, 10, 11, 12]:
				var data_deletion_types : Dictionary = {7: ["Passwords", "Tags", "UserData"], 10: ["Passwords"], 11: ["Tags"], 12: ["UserData"]}
				DataManager.call_deferred("delete_data", data_deletion_types[popup_id])
			elif popup_id in [8, 9]:
				DataManager.call_deferred("save_data")
				if popup_id == 9:
					var current_time : Dictionary = Time.get_datetime_dict_from_system()
					DataManager.call_deferred("save_data", "NPS_Data_Copy_" + str(current_time["day"]) + "_" + str(current_time["month"]) + "_" + str(current_time["year"]))
	$Camera/ScreenContainer/PopupContainer.set_deferred("visible", false)
	return

func receive_add_entry_pressed(id : int) -> void:
	if id == -1:
		if main_page == 0:
			DataManager.passwords_data.append({"name": ("NewPasswordEntry" + random_numbers(5)), "login": "Login", "password": "Password", "tags": []})
			active_data = DataManager.passwords_data[-1]
			active_data["index"] = len(DataManager.passwords_data)-1
			set_infopanel()
			await get_tree().process_frame
			%Passwords/Panel/Container/InfoPanel.callv("change_edit_mode", [0, true])
		elif main_page == 1:
			DataManager.tag_data.append({"name": ("NewTag" + random_numbers(5)), "used_by": []})
			active_data = DataManager.tag_data[-1]
			active_data["index"] = len(DataManager.tag_data)-1
			set_infopanel()
			await get_tree().process_frame
			%Tags/Panel/Container/InfoPanel.callv("change_edit_mode", [0, true])
	elif id == -2:
		[%Passwords/Panel/Container/InfoPanel, %Tags/Panel/Container/InfoPanel][main_page].call_deferred("create_popup_searchbox")
	else:
		var item_set : String = ["tags", "used_by"][main_page]
		[%Passwords/Panel/Container/SearchElement/Container/SearchBox, %Tags/Panel/Container/SearchElement/Container/SearchBox][main_page].set_deferred("text", str("#" + active_data[item_set][id]))
		[%Passwords/Panel/Container/SearchElement, %Tags/Panel/Container/SearchElement][main_page].call_deferred("search", str("#" + active_data[item_set][id]))
	return

func receive_add_entry_remove_pressed(id : int) -> void:
	for item in DataManager.tag_data:
		if item["name"] == active_data["tags"][id]:
			item["used_by"].pop_at(item["used_by"].find(active_data["name"]))
	active_data["tags"].pop_at(id)
	DataManager.passwords_data[active_data["index"]]["tags"] = active_data["tags"]
	return

func handle_entry_actions(id : int) -> void:
	if main_page == 0:
		var password_name : String = DataManager.passwords_data[id]["name"]
		for item in DataManager.tag_data:
			if password_name in item["used_by"]:
				item["used_by"].pop_at(item["used_by"].find(password_name))
		DataManager.passwords_data.pop_at(id)
		%Passwords/Panel/Container/SearchElement/Container/SearchBox.set_deferred("text", "")
		%Passwords/Panel/Container/SearchElement.call_deferred("searchbox_text_changed", "")
	elif main_page == 1:
		var tag_name : String = DataManager.tag_data[id]["name"]
		for item in DataManager.passwords_data:
			if tag_name in item["tags"]:
				item["tags"].pop_at(item["tags"].find(tag_name))
		DataManager.tag_data.pop_at(id)
		%Tags/Panel/Container/SearchElement/Container/SearchBox.set_deferred("text", "")
		%Tags/Panel/Container/SearchElement.call_deferred("searchbox_text_changed", "")
	set_infopanel(false)
	return

func random_numbers(length : int) -> String:
	var to_return : String = ""
	var numbers : Array[String] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
	for i in range(0, length):
		to_return += numbers[randi_range(0, 9)]
	return to_return

func change_edit_mode(num : int, mode : bool) -> void:
	%Passwords/Panel/Container/InfoPanel.call_deferred("change_edit_mode", num, mode)
	return

func create_popup(title : String, id : int, buttons_text : Array) -> void:
	for item in $Camera/ScreenContainer/PopupContainer.get_children():
		item.queue_free()
	$Camera/ScreenContainer/PopupContainer.add_child(popup_scene.instantiate())
	await $Camera/ScreenContainer/PopupContainer.get_child(0).callv("set_paramaters", [title, id, buttons_text])
	$Camera/ScreenContainer/PopupContainer.set_deferred("visible", true)
	return

func create_notification(title : String, fadeout_speed : float = 1) -> void:
	$Camera/ScreenContainer/NotificationContainer.add_child(notification_scene.instantiate())
	$Camera/ScreenContainer/NotificationContainer.get_child(-1).call_deferred("set_paramaters", title, fadeout_speed)
	return

func create_add_entry(place : String, title : String, id : int) -> void:
	get_node(place).add_child(add_entry_scene.instantiate())
	get_node(place).get_child(-1).call_deferred("set_paramaters", title, id, false)
	return

func tooltip_control(state : bool, text : String = "", width : int = 0) -> void:
	if state == true:
		await tooltip_control(false)
		$Camera/ScreenContainer/TooltipContainer.add_child(tooltip_scene.instantiate())
		$Camera/ScreenContainer/TooltipContainer.get_child(-1).call_deferred("set_paramaters", text, width)
	else:
		for item in $Camera/ScreenContainer/TooltipContainer.get_children():
			item.queue_free()
	return

func loadingscreen_control(state : bool) -> void:
	if state == true:
		$Camera/ScreenContainer/LoadingScreen.set_deferred("modulate", Color(255, 255, 255, 255))
		$Camera/ScreenContainer/LoadingScreen.set_deferred("visible", true)
	else:
		$Camera/ScreenContainer/LoadingScreen/FadePlayer.play("fadeout")
		await $Camera/ScreenContainer/LoadingScreen/FadePlayer.animation_finished
		$Camera/ScreenContainer/LoadingScreen.set_deferred("visible", false)
		$Camera/ScreenContainer/LoadingScreen.set_deferred("modulate", Color(255, 255, 255, 255))
	return

func autosave_timer_timeout() -> void:
	DataManager.call_deferred("save_data")
	return
