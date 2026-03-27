extends StaticBody3D
class_name FloorType

@export var GRID_SIZE := 15
@export var TILE_SIZE := 6.0
@export var LINE_SIZE = 0.2

func _ready():
	add_to_group("Floor")
	#spawn x lines
	for i in range(GRID_SIZE + 1):
		var new_mesh = MeshInstance3D.new()
		add_child(new_mesh)
		new_mesh.mesh = BoxMesh.new()
		new_mesh.global_position = Vector3(0, 0.005, TILE_SIZE * (i - GRID_SIZE / 2) - TILE_SIZE / 2)
		new_mesh.scale = Vector3(1000, 0.0001, LINE_SIZE)
	#spawn z lines
	for i in range(GRID_SIZE + 1):
		var new_mesh = MeshInstance3D.new()
		add_child(new_mesh)
		new_mesh.mesh = BoxMesh.new()
		new_mesh.global_position = Vector3(TILE_SIZE * (i - GRID_SIZE / 2) - TILE_SIZE / 2, 0.005, 0)
		new_mesh.scale = Vector3(LINE_SIZE, 0.0001, 1000)
