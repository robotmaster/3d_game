extends Node
class_name GlobalType

@export var mouse_sensitivity = 0.003

var game_paused = false


var input_logs : Dictionary = {}
var previous_inputs = {}
var logs_needed = ["left", "right", "forward", "back", "sprint", "JUSTjump", "JUSTclick"]
var unhandled_mouse_motion = Vector2()
var log_file

var playing_back_inputs = false
var input_file = ""


var settings = {
	"scary": false
}


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	set_physics_process_priority(-9999)
	set_process_priority(-9999)
	new_game()
func _input(event):
	if event.is_action_pressed("release mouse") and not game_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		game_paused = true
		#Engine.time_scale = 0
		#Engine.max_physics_steps_per_frame = 0
		#Engine.physics_ticks_per_second = 0
func _unhandled_input(event):
	if Global.game_paused:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		unhandled_mouse_motion += event.relative * mouse_sensitivity

func handle_mouse_down():
	if not Input.is_action_just_pressed("click"):
		return
		
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		game_paused = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		#Engine.time_scale = 1
		#Engine.physics_ticks_per_second = 60
		return
	var player = get_node("/root/Main/Player")
	if player.get_node("CameraPivot") != null:
		player.handle_mouse_click()

func new_game():
	input_logs = {}
	var time = Time.get_datetime_string_from_system()
	if playing_back_inputs:
		log_file = FileAccess.open(input_file, FileAccess.READ)
	else:
		log_file = FileAccess.open("user://game_logs/" + time + ".txt", FileAccess.WRITE)

func _physics_process(delta: float) -> void:
	handle_mouse_down()
	var mouse_motion = unhandled_mouse_motion
	var player = get_node("/root/Main/Player")
	if player != null and not player.dead:
		player.turn_player(mouse_motion)
	unhandled_mouse_motion = Vector2()
	
	log_inputs()

func log_inputs():	
	if log_file == null:
		return
	for input : String in logs_needed:
		if input.begins_with("JUST"):
			continue
		
		if not input_logs.has(input):
			input_logs[input] = {}
		var previous_input
		if previous_inputs.has(input):
			previous_input = previous_inputs[input]
		else:
			previous_input = false
			
		if not Input.is_action_pressed(input) == previous_input:
			input_logs[input][Engine.get_physics_frames()] = true
		previous_inputs[input] = Input.is_action_pressed(input)

	log_file.seek(0)
	log_file.store_string(JSON.stringify(input_logs))
	log_file.flush()
