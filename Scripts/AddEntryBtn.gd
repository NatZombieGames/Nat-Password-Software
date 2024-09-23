extends Button

var id : int
@onready var normal_stylebox : Resource = preload("res://Other/AddEntryNormalStylebox.tres")
@onready var hovered_stylebox : Resource = preload("res://Other/AddEntryHoveredStylebox.tres")
@onready var pressed_stylebox : Resource = preload("res://Other/AddEntryPressedStylebox.tres")
@export var run_set_on_ready : bool = false
@export_subgroup("Default Paramaters")
@export var default_title : String = ""
@export var default_id : int = 0
@export var remove_btn_enabled : bool = false
@export var parent_path : String = "/root/Main"

func _ready() -> void:
	if run_set_on_ready:
		set_paramaters(default_title, default_id, remove_btn_enabled)
	return

func set_paramaters(title : String, new_id : int, have_remove_btn : bool, new_parent_path : String = "/root/Main") -> void:
	parent_path = new_parent_path
	id = new_id
	%Text.set_deferred("text", title)
	%Void.set_deferred("visible", have_remove_btn)
	%RemoveBtn.set_deferred("visible", have_remove_btn)
	await get_tree().process_frame
	$".".set_deferred("custom_minimum_size", %Background.size)
	return

func main_pressed() -> void:
	get_node(parent_path).call_deferred("receive_add_entry_pressed", id)
	create_stylebox(2)
	%PressedTimer.start(0.12)
	await %PressedTimer.timeout
	create_stylebox(1)
	return

func remove_pressed() -> void:
	await get_node(parent_path).call_deferred("receive_add_entry_remove_pressed", id)
	$".".queue_free()
	return

func mouse_moved(entered : bool) -> void:
	create_stylebox(int(entered))
	return

func create_stylebox(colour_id : int) -> void:
	$Background.set_deferred("theme_override_styles/panel", [normal_stylebox, hovered_stylebox, pressed_stylebox][colour_id])
	return
