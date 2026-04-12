extends Control
class_name UIType

@onready var Player : PlayerType = get_node("/root/Main/Player")
@onready var Global : GlobalType = get_node("/root/Global")

var draw_crosshair = true

func _process(delta: float) -> void:
	
	if Global.settings.scary:
		pass
	
	if !is_instance_valid(Player):
		return
	$StaminaBar.max_value = Player.STAMINA_TIME
	$StaminaBar.value = Player.stamina
	
	
	$SurviveTime.text = "Survived Time: " + str(floor(Player.time_survived * 10) / 10)
	queue_redraw()

func _draw():
	if draw_crosshair:
		if Global.settings.scary:
			draw_circle(Vector2(1920 / 2, 1080 / 2), 10, Color(1, 1, 1, 0.1))
		else:
			draw_circle(Vector2(1920 / 2, 1080 / 2), 10, Color(0, 0, 0, 0.1))
