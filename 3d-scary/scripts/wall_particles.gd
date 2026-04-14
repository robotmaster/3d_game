extends CPUParticles3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var Floor : FloorType = get_node("/root/Main/Floor")
	emission_box_extents.x = Floor.LINE_SIZE
	emission_box_extents.z = Floor.TILE_SIZE / 2 + Floor.LINE_SIZE
