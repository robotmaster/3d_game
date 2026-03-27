extends Node

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _input(event):
	if event.is_action_pressed("release mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
func _unhandled_input(event):
	handle_mouse_down(event)

func handle_mouse_down(event):
	if not(event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
		
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return
	var player = get_node("/root/Main/Player")
	if player.get_node("CameraPivot") != null:
		player.handle_mouse_click(event)
