extends PanelContainer

signal set_decryption_key

func show_error(text : String) -> void:
	%ErrorLabel.text = text
	%ErrorLabel.set_deferred("visible", true)
	%Timer.start(3)
	await %Timer.timeout
	%ErrorLabel.set_deferred("visible", false)
	return

func handle_buttons(id : int) -> void:
	if id == 0:
		var conditions : Array[bool] = [str(%KeyEntryBox.text).is_valid_int(), "+" not in %KeyEntryBox.text, "-" not in %KeyEntryBox.text, len(%KeyEntryBox.text) == 4]
		var error_responses : Array[String] = ["ERROR: Entry Is Not A Valid Number", "ERROR: '+' In Key.", "ERROR: '-' In Key.", "ERROR: Invalid Text Length."]
		if false in conditions:
			show_error(error_responses[conditions.find(false)])
		else:
			DataManager.decryption_key = %KeyEntryBox.text
			$".".emit_signal("set_decryption_key")
	elif id == 1:
		get_tree().quit()
	return

func update_chances(chances : int) -> void:
	%ChancesLabel.text = "Chances Remaining: " + str(chances)
	if chances < 1:
		get_tree().quit()
	return

func receive_keyentry_input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("Enter"):
		%KeyEntryBox.release_focus()
		handle_buttons(0)
	return
