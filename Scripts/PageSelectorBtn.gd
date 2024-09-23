extends Button

@export var parent : String = "/root/Main"
@export var id : int
@export var send_output : bool = true

func set_paramaters(title : String, new_id : int, new_button_group : ButtonGroup, start_pressed : bool, new_parent : String) -> void:
	$".".set_deferred("text", " " + title + " ")
	id = new_id
	parent = new_parent
	$".".set_deferred("button_group", new_button_group)
	send_output = false
	$".".set_deferred("button_pressed", start_pressed)
	await get_tree().process_frame
	send_output = true
	return

func pressed() -> void:
	if send_output:
		get_node(parent).call_deferred("receive_page_btn_pressed", id)
	return
