extends Node
class_name GlobalType

@export var mouse_sensitivity = 0.003

var game_paused = false

var physics_frames_at_last_game = 0

var input_logs : Dictionary = {}
var previous_inputs = {}
var logs_needed = ["left", "right", "forward", "back", "sprint", "JUSTjump", "JUSTclick"]
var unhandled_mouse_motion = Vector2()
var log_file

var playing_back_inputs = false
var input_file = "user://game_logs/2026-04-14T16-10-02.txt"
var inputs_to_play = {}

var screen_shake = 0
var screen_shake_decay = 0.1

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
	if game_paused:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		unhandled_mouse_motion += event.relative * mouse_sensitivity

func new_game():
	physics_frames_at_last_game = Engine.get_physics_frames()
	input_logs = {}
	var time = Time.get_datetime_string_from_system()
	time = time.replace(":", "-")
	time = time.replace("/", "-")
	time = time.replace(" ", "-")
	
	if log_file:
		log_file.close()
	
	if playing_back_inputs:
		inputs_to_play = JSON.parse_string(FileAccess.get_file_as_string(input_file))
		var read_seed = inputs_to_play["seed"]
		seed(read_seed)
	else:
		randomize()
		var game_seed = randi()
		seed(game_seed)
		log_file = FileAccess.open("user://game_logs/" + time + ".txt", FileAccess.WRITE)
		input_logs["seed"] = game_seed

func passed_physics_frames():
	return Engine.get_physics_frames() - physics_frames_at_last_game

func _physics_process(delta: float) -> void:
	if not playing_back_inputs:
		log_inputs(unhandled_mouse_motion)
	else:
		handle_playback_input_toggle()
	
	if playing_back_inputs and Input.is_action_just_pressed("debug_command"):
		var player = get_node("/root/Main/Player")
		if get_node("/root/Main/DebugCam").current != true:
			get_node("/root/Main/DebugCam").current = true
		elif player != null and not player.dead:
			get_node("/root/Main/Player/CameraPivot/Camera3D").current = true
func handle_playback_input_toggle():
	for input in logs_needed:
		if input.begins_with("JUST"):
			continue
		if not previous_inputs.has(input):
			previous_inputs[input] = false
		if inputs_to_play[input].has(str(passed_physics_frames())):
			previous_inputs[input] = not previous_inputs[input]

func get_input(input):
	if playing_back_inputs and len(inputs_to_play.mouse_movement) > passed_physics_frames():
		if input.begins_with("JUST"):
			return inputs_to_play[input].has(str(passed_physics_frames()))
		else:
			return previous_inputs[input]
	else:
		if input.begins_with("JUST"):
			return Input.is_action_just_pressed(input.substr(4))
		else:
			return Input.is_action_pressed(input)

func log_inputs(mouse_movement):	
	if log_file == null:
		return
	for input : String in logs_needed:
		if not input_logs.has(input):
			input_logs[input] = {}
		if input.begins_with("JUST"):
			if Input.is_action_just_pressed(input.substr(4)):
				input_logs[input][passed_physics_frames()] = true
			continue
			
		
		var previous_input
		if previous_inputs.has(input):
			previous_input = previous_inputs[input]
		else:
			previous_input = false
			
		if not Input.is_action_pressed(input) == previous_input:
			input_logs[input][passed_physics_frames()] = true
		previous_inputs[input] = Input.is_action_pressed(input)
	
	if not input_logs.has("mouse_movement"):
		input_logs["mouse_movement"] = []
	input_logs["mouse_movement"].append(str(mouse_movement.x) + " " + str(mouse_movement.y))
	
	log_file.seek(0)
	log_file.store_string(JSON.stringify(input_logs))
	log_file.flush()

func _process(delta: float) -> void:
	screen_shake *= pow(screen_shake_decay, delta)
