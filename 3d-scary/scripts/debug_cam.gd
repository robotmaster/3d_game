extends Camera3D

var CAM_SPEED = 0.2
var camera_pitch = 0.0
@onready var Global : GlobalType = get_node("/root/Global")

func _physics_process(delta: float) -> void:
	if not current:
		return
	if Input.is_physical_key_pressed(Key.KEY_SPACE):
		global_position.y += CAM_SPEED
	if Input.is_physical_key_pressed(Key.KEY_SHIFT):
		global_position.y -= CAM_SPEED
	
	
	var mouse_motion = Global.unhandled_mouse_motion
	rotate_y(-mouse_motion.x)
	camera_pitch -= mouse_motion.y
	camera_pitch = clamp(camera_pitch, deg_to_rad(-80), deg_to_rad(80))
	rotation.x = camera_pitch
	
	
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	direction.y = 0
	direction = direction.normalized()
	global_position += direction * CAM_SPEED
