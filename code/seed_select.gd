extends Node2D

@onready var line_edit = $LineEdit

var old_text = ""

func _ready() -> void:
	line_edit.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
func _process(delta: float) -> void:
	old_text = line_edit.text

func _on_begin_pressed() -> void:
	if line_edit.text == "":
		Global.seed = randi()
	else:
		Global.seed = line_edit.text
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_line_edit_text_changed(new_text: String) -> void:
	for char in new_text:
		if !char.is_valid_int():
			line_edit.text = old_text
	
