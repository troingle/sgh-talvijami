extends CharacterBody3D

@export var speed = 6.6
@export var run_speed = 6.6
@export var accel = 4.7
@export var sensitivity = 0.1
@export var min_angle = -80
@export var max_angle = 90

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var rc = $Head/RayCast3D
@onready var gun_rc = $Head/GunRC
@onready var full_compass = $Head/CompassReal
@onready var compass = $Head/CompassReal/Compass
@onready var carry_gem = $Head/Gem
@onready var gun = $Head/Gun

@onready var end_timer = $EndTimer

@onready var monster = $"../Monster"
@onready var gem = $"../Gem"
@onready var ladder = null
@onready var spawner = $"../ObjectSpawner"

@onready var step_sounds = ["res://audio/walk1.wav", "res://audio/walk2.wav", "res://audio/walk3.wav", "res://audio/walk4.wav", "res://audio/walk5.wav", "res://audio/walk6.wav"]
@onready var collect_sound = $Collect

var input_dir

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var look_rot : Vector2
var stand_height : float

var bob_freq = 1.5
var bob_amp = 0.1
var t_bob = 0.0

var loaded = false

var running = false
var has_gem = false
var has_gun = false

var stamina = 1
var drained = false

func _input(event):
	if event is InputEventMouseMotion and not monster.jumpscared:
		look_rot.y -= (event.relative.x * sensitivity)
		look_rot.x -= (event.relative.y * sensitivity)
		look_rot.x = clamp(look_rot.x, min_angle, max_angle)
		
func _physics_process(delta):
	if not loaded:
		pass
	else:
		head.rotation_degrees.x = look_rot.x
		rotation_degrees.y = look_rot.y
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
		if not is_on_floor():
			velocity.y -= gravity * delta
		
		input_dir = Input.get_vector("left", "right", "forward", "backward")
		
		if Input.is_action_pressed("run") and not drained:
			running = true
		else:
			running = false
		
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			pass
			
		if not running:
			velocity.x = lerp(velocity.x, direction.x * speed, accel * delta)
			velocity.z = lerp(velocity.z, direction.z * speed, accel * delta)
			bob_freq = 0.8
			bob_amp = 0.1
			if not drained:
				stamina += 0.05 * delta
		else:
			velocity.x = lerp(velocity.x, direction.x * run_speed, accel * delta)
			velocity.z = lerp(velocity.z, direction.z * run_speed, accel * delta)
			bob_freq = 1
			bob_amp = 0.1
			monster.update_location()
			if not drained:
				stamina -= 0.10 * delta
		
		if stamina > 1:
			stamina = 1
		if stamina < 0:
			drained = true
			$DrainedTimer.start()
			stamina = 0
		
		$CanvasLayer/StaminaParent.scale.x = stamina
		
		if not monster.jumpscared:
			move_and_slide()
	
		if Input.is_action_pressed("quit"):
			get_tree().quit()
			
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin = headbob(t_bob)
		
		if rc.is_colliding():
			if rc.get_collider().name == "Gem" and rc.get_collider().visible:
				$CanvasLayer/CrosshairInteract.visible = true
				if Input.is_action_just_pressed("interact"):
					has_gem = true
					carry_gem.visible = true
					rc.get_collider().visible = false	
					spawner.spawn_ladder()
			elif rc.get_collider().is_in_group("ladder"):
				$CanvasLayer/CrosshairInteract.visible = true
				if Input.is_action_just_pressed("interact") and carry_gem.visible:
					rc.get_collider().gem.visible = true
					carry_gem.visible = false
					loaded = false
					$CanvasLayer/BlackScreenEnd/AnimationPlayer.play("fade")
					end_timer.start()
			else:
				$CanvasLayer/CrosshairInteract.visible = false
		else:
			$CanvasLayer/CrosshairInteract.visible = false
			
		if !has_gem:
			compass.look_at(gem.position)
			compass.rotation.x = 0
			compass.rotation.z = 0
			
		if monster.jumpscared:
			$Heartbeat.queue_free()
			$Ambience.queue_free()

func display_desc(is_gun):
	var desc = ""
	if is_gun:
		desc = "A gun
		Broken. Doesn't do anything, but looks cool."
	else:
		desc = "A compass
		Points to your current objective."
	$CanvasLayer/Desc.text = desc
	$CanvasLayer/Desc.visible = true
	$HideTimer.start()
	
func headbob(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	return pos

func _on_drained_timer_timeout() -> void:
	drained = false

func _on_black_screen_removal_timeout() -> void:
	$CanvasLayer/BlackScreen.visible = false
	$Ambience.play()
	$Heartbeat.play()

func _on_end_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/end.tscn")

func _on_hide_timer_timeout() -> void:
	$CanvasLayer/Desc.visible = false
