extends CharacterBody3D

@onready var player = $"../Player"

@onready var js_camera = $JumpscareCamera
@onready var js_anim = $JumpscareAnim

@onready var jumpscare_timer = $JumpscareTimer

@onready var step_sounds = [load("res://audio/walk1.wav"), load("res://audio/walk2.wav"), load("res://audio/walk3.wav"), load("res://audio/walk4.wav"), load("res://audio/walk5.wav"), load("res://audio/walk6.wav")]

const SPEED = 16.2

var target_pos = Vector3.ZERO
var sight_distance = 40.0

var jumpscared = false

var on = false

func _ready():
	update_location()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if global_position.distance_to(player.global_position) < sight_distance:
		update_location()
		
	look_at(target_pos)
	global_rotation.x = 0
	global_rotation.z = 0
	
	var forward = -global_transform.basis.z.normalized()
	velocity.x = forward.x * SPEED
	velocity.z = forward.z * SPEED
	
	if player.loaded and not jumpscared:
		move_and_slide()
		
	if global_position.distance_to(player.global_position) < 6:
		if not jumpscared:
			js_camera.current = true
			js_anim.play("jumpscare")
			$Jumpscare.play()
			jumpscared = true
			
			player.carry_gem.visible = false
			player.full_compass.visible = false
			
			jumpscare_timer.start()
			
			$FootstepTimer.queue_free()

func _on_basic_detection_timeout() -> void:
	update_location()
	
func update_location():
	target_pos = player.global_position

func _on_jumpscare_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_footstep_timer_timeout() -> void:
	if on:
		on = false
		$Footsteps1.stream = step_sounds.pick_random()
		$Footsteps1.play()
	else:
		on = true
		$Footsteps2.stream = step_sounds.pick_random()
		$Footsteps2.play()
