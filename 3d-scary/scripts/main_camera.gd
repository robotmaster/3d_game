extends Camera3D


@onready var Global : GlobalType = get_node("/root/Global")

func _process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(randf() * TAU)
	var dir_3d = transform.basis * Vector3(direction.x, 0, direction.y).normalized()
	
	position = dir_3d * Global.screen_shake
