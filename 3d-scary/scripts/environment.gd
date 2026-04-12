extends Node3D

@onready var Global : GlobalType = get_node("/root/Global")

func _process(delta: float) -> void:
	if Global.settings.scary:
		$Lighting.light_energy = 0.01
		$Skybox.environment.fog_density = 0.05
		$Skybox.environment.fog_light_color = Color(0.03, 0.02, 0.02)
		$Skybox.environment.background_color = Color(0.3, 0.3, 0.7)
