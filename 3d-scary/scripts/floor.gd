extends StaticBody3D
class_name FloorType

@export var GRID_SIZE := 15
@export var TILE_SIZE := 6.0
@export var LINE_SIZE = 0.2
@export var DIAGONAL_TILE_SIZE = 0.05
@export var DIAGONAL_COLOR = Color(0.93, 0.93, 0.93)
@export var HORIZONTAL_COLOR = Color(0.7, 0.7, 0.7)

var diagonal_line_material = null
var horizontal_line_material = null

func _ready():
	add_to_group("Floor")
	
	diagonal_line_material = StandardMaterial3D.new()
	diagonal_line_material.albedo_color = DIAGONAL_COLOR
	horizontal_line_material = StandardMaterial3D.new()
	horizontal_line_material.albedo_color = HORIZONTAL_COLOR
	#spawn horizontal lines
	for i in range(GRID_SIZE + 1):
		#spawn x lines
		var new_mesh = MeshInstance3D.new()
		add_child(new_mesh)
		new_mesh.mesh = BoxMesh.new()
		new_mesh.global_position = Vector3(0, 0.01, TILE_SIZE * (i - GRID_SIZE / 2) - TILE_SIZE / 2)
		new_mesh.scale = Vector3(10000, 0.0001, LINE_SIZE)
		new_mesh.set_surface_override_material(0, horizontal_line_material)
		#spawn z lines
		new_mesh = MeshInstance3D.new()
		add_child(new_mesh)
		new_mesh.mesh = BoxMesh.new()
		new_mesh.global_position = Vector3(TILE_SIZE * (i - GRID_SIZE / 2) - TILE_SIZE / 2, 0.01, 0)
		new_mesh.scale = Vector3(LINE_SIZE, 0.0001, 10000)
		new_mesh.set_surface_override_material(0, horizontal_line_material)
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

func _process(delta: float) -> void:
	if Global.settings.scary:
		var new_material = StandardMaterial3D.new()
		new_material.albedo_color = Color(0.5, 0.5, 0.5)
		$FloorMesh.set_surface_override_material(0, new_material)
		
		
		diagonal_line_material.albedo_color = Color()
		horizontal_line_material.albedo_color = Color(0.1, 0.1, 0.1)
