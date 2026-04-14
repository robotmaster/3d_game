extends StaticBody3D

const PARTICLES = preload("res://scenes/wall_particles.tscn")

@export var WALL_RISE_TIME = 0.3
func _ready() -> void:
	var particle : CPUParticles3D = PARTICLES.instantiate()
	add_child(particle)
	particle.global_position = global_position
	
	#wall_rise_timer = WALL_RISE_TIME
	var Floor : FloorType = get_node("/root/Main/Floor")
	$WallMesh.mesh.size.x = Floor.LINE_SIZE
	$WallMesh.mesh.size.z = Floor.TILE_SIZE + Floor.LINE_SIZE
	
	$WallCollision.shape.size = $WallMesh.mesh.size
	
	$WallMesh.global_position.y = -$WallMesh.mesh.size.y / 2
	var new_tween = get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	new_tween.tween_property($WallMesh, "global_position:y", 0, WALL_RISE_TIME)
	
	await get_tree().create_timer(WALL_RISE_TIME).timeout
	$Particles.emitting = false
