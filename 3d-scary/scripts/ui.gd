extends Control

@onready var Player : PlayerType = get_node("/root/Main/Player")

func _process(delta: float) -> void:
	if !is_instance_valid(Player):
		return
	$StaminaBar.max_value = Player.STAMINA_TIME
	$StaminaBar.value = Player.stamina
