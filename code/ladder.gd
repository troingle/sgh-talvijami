extends StaticBody3D

@onready var spawner = $".."
@onready var player = $"../../Player"
@onready var gem = $Gem

func _process(delta: float) -> void:
	player.compass.look_at(global_position)
	player.compass.rotation.x = 0
	player.compass.rotation.z = 0

func _on_detect_body_entered(body: Node3D) -> void:
	if body.is_in_group("tree"):
		spawner.spawn_ladder()
		queue_free()
