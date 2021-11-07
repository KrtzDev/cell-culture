extends KinematicBody

var velocity = Vector3.ZERO
var speed = .07

onready var player_camera = $"Camera"
var spin = 0.1
var mouse_sensitivity = 2

#func _ready():
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	player_camera.rotation_degrees.y = 180
	player_camera.rotation_degrees.z = 0

	movement(delta)
	velocity = move_and_collide(velocity)

func movement(_delta):
	var dir = Vector3.ZERO
	velocity = Vector3.ZERO
	
	if Input.is_action_pressed("ui_up"):
		dir += transform.basis.z
	elif Input.is_action_pressed("ui_down"):
		dir -= transform.basis.z

	if Input.is_action_pressed("ui_left"):
		dir += transform.basis.x
	elif Input.is_action_pressed("ui_right"):
		dir -= transform.basis.x
		
	if Input.is_action_pressed("raise"):
		dir += transform.basis.y
	elif Input.is_action_pressed("lower"):
		dir -= transform.basis.y

	if Input.is_action_just_pressed("sprint"):
		speed *= 2.5
	elif Input.is_action_just_released("sprint"):
		speed /= 2.5
	
	velocity = dir.normalized() * speed

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:

		rotate_y(lerp(0, -spin, event.relative.x*(mouse_sensitivity * 0.01) ))
		player_camera.rotate_x(lerp(0,spin, event.relative.y*(mouse_sensitivity * 0.01) ))

		var curr_rot = player_camera.rotation_degrees
		curr_rot.x = clamp(curr_rot.x,-80,80)
		player_camera.rotation_degrees = curr_rot
