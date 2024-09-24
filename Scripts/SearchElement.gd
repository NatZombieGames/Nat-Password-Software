extends PanelContainer

@onready var add_entry_scene : Resource = preload("res://Scenes/AddEntryBtn.tscn")
@onready var item_scene : Resource = preload("res://Scenes/ItemScene.tscn")
@onready var main : Control = get_node("/root/Main")
@onready var active_infopanel : PanelContainer
@export var add_entry_title : String = ""
@export var add_entry_id : int = 0
@export_enum("Password", "Tag") var type : int = 0
@export var have_add_entry : bool = true
@export var parent : String = "/root/Main"
var can_search : bool = true
const search_shortcuts : Array[String] = ["@all"]
const search_prefix_types : Array[String] = ["#", "£", "&"]

func _ready() -> void:
	active_infopanel = get_node_or_null(str($".".get_path()) + "/../InfoPanel")
	if have_add_entry:
		%ResultList/AddEntryButton.call_deferred("set_paramaters", add_entry_title, add_entry_id, false, $".".get_path())
	else:
		%ResultList/AddEntryButton.queue_free()
	return

func search(query : String) -> void:
	if can_search:
		can_search = false
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_BUSY)
		var search_data : Array = []
		var data_set : Array[Dictionary] = [DataManager.passwords_data.duplicate(true), DataManager.tag_data.duplicate(true)][type]
		var item_set : String = "name"
		var special_search : bool = false
		var strict_search : bool = DataManager.user_data["strict_search"]
		if not DataManager.user_data["case_sensative_search"]:
			query = query.to_lower()
			var name_set_one : Array = [["name", "login", "password"], ["name"]][type]
			var array_name : String = ["tags", "used_by"][type]
			for item in data_set:
				for item2 in name_set_one:
					item[item2] = item[item2].to_lower()
				for item2 in item[array_name]:
					item[array_name][item[array_name].find(item2)] = item2.to_lower()
		if query in search_shortcuts:
			if query == "@all":
				search_data = range(0, len(data_set))
		elif query[0] in search_prefix_types:
			special_search = true
			if query[0] == "#":
				item_set = ["tags", "used_by"][type]
			elif query[0] == "&":
				item_set = "login"
			elif query[0] == "£":
				item_set = "password"
		if special_search:
			query = query.substr(1, -1)
		if len(search_data) < 1:
			if item_set == ["tags", "used_by"][type]:
				for item in data_set:
					for item2 in item[item_set]:
						if [query in item2, query == item2][int(strict_search)]:
							search_data.append(data_set.find(item))
							break
			else:
				for item in data_set:
					if [query in item[item_set], query == item[item_set]][int(strict_search)]:
						search_data.append(data_set.find(item))
		for item in %ResultList.get_children():
			item.queue_free()
		var active_data_set : Array[Dictionary] = [DataManager.passwords_data, DataManager.tag_data][type]
		for item in search_data:
			var item_name : String = active_data_set[item]["name"]
			var item_data : Array = active_data_set[item][["tags", "used_by"][type]]
			add_search_item(item_name, item_data, item)
		if have_add_entry:
			create_add_entry(["Create New Password Entry", "Create New Tag"][type], $".".get_path())
		%SearchResultsCounter.set_deferred("text", (str(len(search_data)) + " Results Found"))
		%SearchResultsCounter.set_deferred("visible", true)
		DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
		can_search = true
	return

func search_submitted(text : String) -> void:
	if len(text) > 0:
		search(text)
	return

func searchbox_text_changed(_text : String) -> void:
	if len(%ResultList.get_children()) > 1:
		%SearchResultsCounter.set_deferred("visible", false)
		for item in %ResultList.get_children():
			item.queue_free()
		if have_add_entry:
			create_add_entry(add_entry_title, $".".get_path())
	return

func create_add_entry(title : String, parent_path : String) -> void:
	%ResultList.add_child(add_entry_scene.instantiate())
	%ResultList.get_child(-1).call_deferred("set_paramaters", title, -1, false, parent_path)
	return

func receive_add_entry_pressed(id : int) -> void:
	get_node(parent).call_deferred("receive_add_entry_pressed", id)
	return

func add_search_item(item_name : String, tags : Array, id : int) -> void:
	%ResultList.add_child(item_scene.instantiate())
	%ResultList.get_child(-1).call_deferred("set_paramaters", item_name, tags, id, active_infopanel, parent)
	return
