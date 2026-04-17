extends Node3D

@onready var Floor : FloorType = get_node("/root/Main/Floor")
@onready var Global : GlobalType = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.settings.scary:
		$Particles.mesh.material.albedo_color = Color(0.3, 0.35, 0.3, 0.2)
	else:
		$Particles.mesh.material.albedo_color = Color(0.85, 1 ,0.85, 0.2)
	$LineMesh.scale = Vector3(Floor.LINE_SIZE / 2, 1, Floor.TILE_SIZE / 2 + Floor.LINE_SIZE / 2)
	$Particles.emission_box_extents = Vector3(Floor.LINE_SIZE / 2, 0, Floor.TILE_SIZE / 2 + Floor.LINE_SIZE / 2)

func update_valid_placement():
	$LineMesh.get_surface_override_material(0).albedo_color = Color(0.7, 1, 0.7)
	$Particles.emitting = true
	
func update_invalid_placement():
	$LineMesh.get_surface_override_material(0).albedo_color = Color(1, 0.3, 0.3)
	$Particles.emitting = false
