extends PanelContainer

@onready var btn_scene : Resource = preload("res://Scenes/PageSelectorBtn.tscn")
@export var button_group : ButtonGroup
@export var selector_id : int = 0
@export_enum("Visible", "Invisible") var is_self_visible : int = 0
@export_enum("Vertical", "Horizontal") var type : int = 0
@export_enum("Begin", "Center", "End") var alignment : int = 0
@export var parent : String = "/root/Main"
@export var buttons : Array[String] = []
var active_container : Variant

func _ready() -> void:
	$".".set_deferred("self_modulate", Color(1, 1, 1, 1*(int(!bool(is_self_visible)))))
	active_container = [$VContainer, $HContainer][type]
	[$VContainer, $HContainer][int(!bool(type))].queue_free()
	active_container.set_deferred("alignment", alignment)
	for item in buttons:
		active_container.add_child(btn_scene.instantiate())
		active_container.get_child(-1).call_deferred("set_paramaters", item, buttons.find(item), button_group, buttons.find(item) == 0, $".".get_path())
	return

func receive_page_btn_pressed(id : int) -> void:
	get_node(parent).call_deferred("page_selector_selected", selector_id, id)
	return

func update_button_pressed(id : int) -> void:
	var children : Array = active_container.get_children()
	children.remove_at(0)
	for item in children:
		item.set_deferred("button_pressed", children.find(item) == id)
	return
