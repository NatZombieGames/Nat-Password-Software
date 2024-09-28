extends PanelContainer

func set_paramaters(title : String, fadeout_speed : float) -> void:
	$Text.text = title
	var mouse_pos : Vector2i = Vector2i(get_local_mouse_position())
	fadeout_speed = (3 * fadeout_speed)
	var tween : Tween = $".".create_tween().set_parallel(true)
	tween.tween_property($".", "position", Vector2i(mouse_pos[0], (mouse_pos[1]-75)), fadeout_speed).from(mouse_pos)
	tween.tween_property($".", "modulate", Color8(255, 255, 255, 0), fadeout_speed).from(Color8(255, 255, 255, 255))
	await tween.finished
	$".".queue_free()
	return
