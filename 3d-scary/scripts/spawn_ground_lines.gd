extends StaticBody3D
class_name FloorType

@export var GRID_SIZE := 15
@export var TILE_SIZE := 6.0
@export var LINE_SIZE = 0.2
@export var DIAGONAL_TILE_SIZE = 0.05
@export var DIAGONAL_COLOR = Color(0.93, 0.93, 0.93)

func _ready():
	add_to_group("Floor")
	
	var diagonal_line_material = StandardMaterial3D.new()
	diagonal_line_material.albedo_color = DIAGONAL_COLOR
	#spawn horizontal lines
	for i in range(GRID_SIZE + 1):
		#spawn x lines
		var new_mesh = MeshInstance3D.new()
		add_child(new_mesh)
		new_mesh.mesh = BoxMesh.new()
		new_mesh.global_position = Vector3(0, 0.01, TILE_SIZE * (i - GRID_SIZE / 2) - TILE_SIZE / 2)
		new_mesh.scale = Vector3(10000, 0.0001, LINE_SIZE)
		#spawn z lines
		new_mesh = MeshInstance3D.new()
		add_child(new_mesh)
		new_mesh.mesh = BoxMesh.new()
		new_mesh.global_position = Vector3(TILE_SIZE * (i - GRID_SIZE / 2) - TILE_SIZE / 2, 0.01, 0)
		new_mesh.scale = Vector3(LINE_SIZE, 0.0001, 10000)
	#spawn diagonal lines
	for i in range(2 * GRID_SIZE - 1):
		var new_mesh = MeshInstance3D.new()
		add_child(new_mesh)
		new_mesh.mesh = BoxMesh.new()
		new_mesh.global_position = Vector3(TILE_SIZE * (i - GRID_SIZE + 1), 0.005, 0)
		new_mesh.global_rotation = Vector3(0, PI / 4, 0)
		new_mesh.scale = Vector3(DIAGONAL_TILE_SIZE, 0.0001, 10000)
		new_mesh.set_surface_override_material(0, diagonal_line_material)
		new_mesh = MeshInstance3D.new()
		add_child(new_mesh)
		new_mesh.mesh = BoxMesh.new()
		new_mesh.global_position = Vector3(TILE_SIZE * (i - GRID_SIZE + 1), 0.005, 0)
		new_mesh.global_rotation = Vector3(0, -PI / 4, 0)
		new_mesh.scale = Vector3(DIAGONAL_TILE_SIZE, 0.0001, 10000)
		new_mesh.set_surface_override_material(0, diagonal_line_material)
