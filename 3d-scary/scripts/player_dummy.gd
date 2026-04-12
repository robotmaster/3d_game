extends RigidBody3D

@onready var Global : GlobalType = get_node("/root/Global")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3).timeout
	Global.new_game()
	get_tree().reload_current_scene()
