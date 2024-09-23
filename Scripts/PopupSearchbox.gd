extends PanelContainer

@onready var main : Control = get_node("/root/Main")
@export_enum("Password", "Tag") var type : int = 0
@export var to_send_pressed_data : PanelContainer

func _ready() -> void:
	$Container/SearchElement.set_deferred("parent", $".".get_path())
	$Container/SearchElement.set_deferred("type", type)
	return

func set_paramaters(who_to_send_pressed_data_to : PanelContainer, new_type : int) -> void:
	to_send_pressed_data = who_to_send_pressed_data_to
	type = new_type
	$Container/SearchElement.set_deferred("type", type)
	return

func receive_item_scene_pressed(id : int) -> void:
	var to_send : Dictionary = [DataManager.passwords_data, DataManager.tag_data][type][id]
	to_send["index"] = id
	to_send_pressed_data.call_deferred("receive_popup_searchbox_data", to_send)
	return

func closed_pressed() -> void:
	$"./..".set_deferred("visible", false)
	$".".queue_free()
	return
