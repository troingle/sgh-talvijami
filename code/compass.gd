extends Node3D

@onready var player = $"../../Player"

func _process(delta: float) -> void:
	if player.global_position.distance_to(global_position) < 7:
		if is_in_group("compass"):
			player.full_compass.visible = true
			player.display_desc(false)
			for c in get_tree().get_nodes_in_group("compass"):
				c.queue_free()
		else:
			player.gun.visible = true
			player.display_desc(true)
			player.has_gun = true
			for c in get_tree().get_nodes_in_group("gun"):
				c.queue_free()
		player.collect_sound.play()
