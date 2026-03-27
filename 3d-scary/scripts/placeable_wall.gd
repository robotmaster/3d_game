extends StaticBody3D

@export var WALL_RISE_TIME = 0.3
func _ready() -> void:
	#wall_rise_timer = WALL_RISE_TIME
	var Floor : FloorType = get_node("/root/Main/Floor")
	$WallMesh.mesh.size.x = Floor.LINE_SIZE
	$WallMesh.mesh.size.z = Floor.TILE_SIZE + Floor.LINE_SIZE
	
	$WallCollision.shape.size = $WallMesh.mesh.size
	
	$WallMesh.global_position.y = -$WallMesh.mesh.size.y / 2
	var new_tween = get_tree().create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	new_tween.tween_property($WallMesh, "global_position:y", 0, WALL_RISE_TIME)
