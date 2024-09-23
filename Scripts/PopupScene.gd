extends PanelContainer

@onready var option_scene : Resource = preload("res://Scenes/OptionScene.tscn")
@export var id : int

func set_paramaters(title : String, new_id : int, buttons_text : Array) -> void:
	%Title.text = title
	for item in buttons_text:
		%Buttons.add_child(option_scene.instantiate())
		%Buttons.get_child(-1).set_deferred("custom_minimum_size", Vector2(604, 70))
		%Buttons.get_child(-1).call_deferred("set_paramaters", buttons_text.find(item), 0, "", null, item, Vector2i(1, 2), "", 0, false, false, false, false)
		%Buttons.get_child(-1).parent = $".".get_path()
	id = new_id
	$".".set_deferred("visible", true)
	return

func receive_optionscene_pressed(btn_id : int, _value : bool) -> void:
	await get_node("/root/Main").call_deferred("receive_popup_button_pressed", id, btn_id)
	$"./..".set_deferred("visible", false)
	$".".queue_free()
	return
