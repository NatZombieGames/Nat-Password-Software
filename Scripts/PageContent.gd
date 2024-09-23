extends PanelContainer

@onready var option_scene : Resource = preload("res://Scenes/OptionScene.tscn")
@onready var default_stylebox : StyleBoxFlat = preload("res://Other/PageContentHeaderNormalStylebox.tres")
@onready var pressed_stylebox : StyleBoxFlat = preload("res://Other/PageContentHeaderPressedStylebox.tres")
@export var content_id : int = 0
@export var title : String = ""
@export_multiline var body_text : String = ""
@export var buttons : int = 0
@export var buttons_text : Array[String] = []
@export var int_to_button : Dictionary = {"Normal": 0, "CheckBox": 1, "ToggleBox": 2, "SpinBox": 3, "TextBox": 4}
@export var button_types : Array[int] = []
@export var option_texts : Array[String] = []
@export var text_tooltips : Array[String] = []
@export var tooltip_widths : Array[int] = []
@export var normal_button_uses_tooltips : Array[bool] = []
@export var textboxs_use_tooltips : Array[bool] = []
@export var normal_buttons_are_toggles : Array[bool] = []
@export var spinbox_ranges : Array[Vector2i] = []
@export var button_groups : Array[ButtonGroup] = []
@export var requires_confirmation : Array[bool] = []
var send_output : bool = true

func _ready() -> void:
	set_paramaters(title, body_text)
	for i in range(0, buttons):
		%OptionRows.add_child(option_scene.instantiate())
		%OptionRows.get_child(-1).call_deferred("set_paramaters", i, button_types[i], option_texts[i], button_groups[i], buttons_text[i], spinbox_ranges[i], text_tooltips[i], tooltip_widths[i], normal_button_uses_tooltips[i], normal_buttons_are_toggles[i], textboxs_use_tooltips[i], requires_confirmation[i])
		%OptionRows.get_child(-1).set_deferred("parent", $".".get_path())
	$ContentContainer/Header.set_deferred("theme_override_styles/panel", default_stylebox)
	return

func set_paramaters(new_title : String, new_body_text : String) -> void:
	title = new_title
	body_text = new_body_text
	%Button/Title.set_deferred("text", title)
	%Body.set_deferred("text", body_text)
	%Body.set_deferred("visible", body_text != "")
	return

func update_button_value(row : int, value : Variant) -> void:
	send_output = false
	await %OptionRows.get_child(row).call_deferred("set_button_state", value)
	await get_tree().process_frame
	send_output = true
	return

func pressed() -> void:
	$ContentContainer/BodyContainer.set_deferred("visible", !%Button.button_pressed)
	$ContentContainer/Header.set_deferred("theme_override_styles/panel", [default_stylebox, pressed_stylebox][int($ContentContainer/Header/Button.button_pressed)])
	return

func receive_optionscene_pressed(id : int, value : Variant) -> void:
	if send_output:
		get_node("/root/Main").call_deferred("page_content_value_altered", content_id, id, value)
	return
