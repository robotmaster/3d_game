extends Node

@onready var Global : GlobalType = get_node("/root/Global")

func _ready() -> void:
	
	set_physics_process_priority(9999)
	set_process_priority(9999)

func _physics_process(delta: float) -> void:
	handle_mouse_down()
	var mouse_motion = Global.unhandled_mouse_motion
	var player = get_node("/root/Main/Player")
	if player != null and not player.dead:
		if Global.playing_back_inputs:
			var all_movement = Global.inputs_to_play.mouse_movement
			if len(all_movement) <= Global.passed_physics_frames():
				player.turn_player(mouse_motion)
			else:
				var turn_string : String = all_movement[Global.passed_physics_frames()]
				var x_and_y = turn_string.split(" ")
				var x = float(x_and_y[0])
				var y = float(x_and_y[1])
				player.turn_player(Vector2(x, y))
		else:
			player.turn_player(mouse_motion)
	Global.unhandled_mouse_motion = Vector2()


func handle_mouse_down():
	if Input.is_action_just_pressed("click") and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Global.game_paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#Engine.time_scale = 1
		#Engine.physics_ticks_per_second = 60
		if not Global.playing_back_inputs:
			return
	if not Global.get_input("JUSTclick"):
		return
		
	var player = get_node("/root/Main/Player")
	if player.get_node("CameraPivot") != null:
		player.handle_mouse_click()
