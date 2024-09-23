extends PanelContainer

@export var text : String = ""
@export var width : int = 0

func _ready() -> void:
	$".".set_deferred("visible", false)
	$Text.set_deferred("text", text)
	return

func _process(_delta : float) -> void:
	$".".set_deferred("position", Vector2(get_global_mouse_position()[0]+30, get_global_mouse_position()[1]+30))
	return

func set_paramaters(new_text : String, new_width : int) -> void:
	text = new_text
	width = new_width
	$Text.set_deferred("text", text)
	$".".set_deferred("custom_minimum_size", Vector2(width, 0))
	$".".set_deferred("visible", true)
	return
