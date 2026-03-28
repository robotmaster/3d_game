extends Control
class_name UIType

@onready var Player : PlayerType = get_node("/root/Main/Player")

var draw_crosshair = true

func _process(delta: float) -> void:
	if !is_instance_valid(Player):
		return
	$StaminaBar.max_value = Player.STAMINA_TIME
	$StaminaBar.value = Player.stamina
	queue_redraw()

func _draw():
	if draw_crosshair:
		draw_circle(Vector2(1920 / 2, 1080 / 2), 10, Color(0, 0, 0, 0.1))
