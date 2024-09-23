extends PanelContainer

@onready var main : Control = get_node("/root/Main")
@onready var normal_panel : StyleBoxFlat = preload("res://Other/ItemSceneNormalStylebox.tres")
@onready var hovered_panel : StyleBoxFlat = preload("res://Other/ItemSceneHoveredStylebox.tres")
@onready var pressed_panel : StyleBoxFlat = preload("res://Other/ItemScenePressedStylebox.tres")
@export var to_send_pressed_data : String = "/root/Main"
var data_index : int
var active_infopanel : PanelContainer

func _ready() -> void:
	set_panel(0)
	return

func set_paramaters(title : String, tags : Array, new_data_index : int, currently_active_infopanel : PanelContainer, who_to_send_pressed_data_to : String) -> void:
	%Title.set_deferred("text", " " + title)
	%Separator.set_deferred("visible", not tags == [])
	while len(tags) > 5:
		tags.remove_at(len(tags)-1)
	for item in tags:
		%Value.text += [", " + item, " " + item][int(tags.find(item) == 0)]
	data_index = new_data_index
	active_infopanel = currently_active_infopanel
	to_send_pressed_data = who_to_send_pressed_data_to
	$".".set_deferred("visible", true)
	return

func set_panel(panel : int) -> void:
	$".".set_deferred("theme_override_styles/panel", [normal_panel, hovered_panel, pressed_panel][panel])
	return

func pressed(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("LClick"):
		get_node(to_send_pressed_data).call_deferred("receive_item_scene_pressed", data_index)
		set_panel(2)
		%PressedTimer.start(0.12)
		await %PressedTimer.timeout
		set_panel(int(str(get_viewport().gui_get_hovered_control().get_path()) == (str($".".get_path()) + "/Button/Container")))
	elif Input.is_action_just_pressed("RClick") and main.main_page == 0:
		main.callv("create_notification", [" Password '" + str(DataManager.passwords_data[data_index]["password"]) + "' Copied To Clipboard", 0.25])
	return
