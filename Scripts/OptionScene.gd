extends Control

@onready var buttons : Array[Variant] = [%NormalButton, %CheckButton, %ToggleButton, %SpinBox, %TextBox]
@export var run_set_on_ready : bool = false
@export_subgroup("Default Paramaters")
@export var default_id : int = 0
@export_enum("Normal", "Checkbox", "Toggle", "Spinbox", "Text") var button_type : int = 0
@export var button_text : String = ""
@export var spinbox_range : Vector2i = Vector2i(1, 100)
@export var default_text : String = ""
@export var parent : String = "/root/Main"
@export var button_group : ButtonGroup
@export var text_tooltip : String = ""
@export var tooltip_width : int = 0
@export var normal_button_uses_tooltip : bool = false
@export var normal_button_is_toggle : bool = false
@export var textbox_uses_tooltip : bool = false
@export var requires_confirmation : bool = false
var send_output : bool = true
var id : int

func _ready() -> void:
	if run_set_on_ready:
		set_paramaters(default_id, button_type, default_text, button_group, button_text, spinbox_range, text_tooltip, tooltip_width, normal_button_uses_tooltip, normal_button_is_toggle, textbox_uses_tooltip, requires_confirmation)
	return

func set_paramaters(new_id : int, new_button_type : int, text : String, new_button_group : ButtonGroup, new_button_text : String, new_spinbox_range : Vector2i, new_text_tooltip : String, new_tooltip_width : int, new_normal_button_uses_tooltip : bool, new_normal_button_is_toggle : bool, new_textbox_uses_tooltip : bool, new_requires_confirmation : bool) -> void:
	id = new_id
	requires_confirmation = new_requires_confirmation
	normal_button_uses_tooltip = new_normal_button_uses_tooltip
	textbox_uses_tooltip = new_textbox_uses_tooltip
	normal_button_is_toggle = new_normal_button_is_toggle
	text_tooltip = new_text_tooltip
	tooltip_width = new_tooltip_width
	spinbox_range = new_spinbox_range
	button_type = new_button_type
	button_group = new_button_group
	button_text = new_button_text
	for item in [%NormalButton, %CheckButton, %ToggleButton, %SpinBox, %TextBox]:
		if item.name != "SpinBox" or item.name != "TextBox":
			item.set_deferred("button_group", button_group)
		item.set_deferred("visible", [%NormalButton, %CheckButton, %ToggleButton, %SpinBox, %TextBox].find(item) == button_type)
	if not requires_confirmation:
		%SpinBox.connect("value_changed", Callable(self, "spinbox_pressed"), CONNECT_DEFERRED)
		%TextBox.connect("text_changed", Callable(self, "textbox_changed"), CONNECT_DEFERRED)
	%NormalButton.set_deferred("text", button_text)
	%SpinBox.set_deferred("min_value", spinbox_range[0])
	%SpinBox.set_deferred("max_value", spinbox_range[1])
	%Text.set_deferred("text", text)
	%Text.set_deferred("visible", text != "")
	var uses_tooltip : Array[bool] = [normal_button_uses_tooltip, textbox_uses_tooltip]
	var tooltipable_buttons : Array[Variant] = [%NormalButton, %TextBox]
	for i in range(0, len(uses_tooltip)):
		if uses_tooltip[i]:
			tooltipable_buttons[i].connect("mouse_entered", Callable(self, "hovered").bind(true), CONNECT_DEFERRED)
			tooltipable_buttons[i].connect("mouse_exited", Callable(self, "hovered").bind(false), CONNECT_DEFERRED)
	%NormalButton.set_deferred("toggle_mode", normal_button_is_toggle)
	%NormalButton.set_deferred("custom_minimum_size", Vector2i($".".size[0]-24, 21))
	%SetButton.set_deferred("visible", requires_confirmation)
	return

func set_button_state(new_state : Variant) -> void:
	send_output = false
	var id_to_paramater : Array[String] = ["button_pressed", "button_pressed", "button_pressed", "value", "text"]
	[%NormalButton, %CheckButton, %ToggleButton, %SpinBox, %TextBox][button_type].set_deferred(id_to_paramater[button_type], new_state)
	await get_tree().process_frame
	send_output = true
	return

func hovered(state : bool) -> void:
	get_node("/root/Main").call_deferred("tooltip_control", state, text_tooltip, tooltip_width)
	return

func pressed() -> void:
	if send_output:
		if button_type == 3:
			get_node(parent).call_deferred("receive_optionscene_pressed", id, %SpinBox.value)
		elif button_type == 4:
			get_node(parent).call_deferred("receive_optionscene_pressed", id, %TextBox.text)
		else:
			get_node(parent).call_deferred("receive_optionscene_pressed", id, buttons[button_type].button_pressed)
	return

func spinbox_pressed(_value : float = 0.0) -> void:
	pressed()
	return

func textbox_changed(_new_text : String = "") -> void:
	pressed()
	return
