extends Node2D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_begin_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/seed_select.tscn")
