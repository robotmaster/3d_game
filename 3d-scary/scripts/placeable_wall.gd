extends StaticBody3D


func _ready() -> void:
	var Floor : FloorType = get_node("/root/Main/Floor")
	$WallMesh.mesh.size.x = Floor.LINE_SIZE
	$WallMesh.mesh.size.z = Floor.TILE_SIZE + Floor.LINE_SIZE
	
	$WallCollision.shape.size = $WallMesh.mesh.size
