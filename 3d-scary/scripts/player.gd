extends CharacterBody3D
class_name PlayerType

@export var SPEED := 4.7
@export var SPRINT_SPEED_MULT := 2.05
@export var SIDEWAYS_SPRINT_NERF = 0.4
@export var STAMINA_TIME = 2
@export var STAMINA_REGEN_TIME = 4.5
@export var JUMP_VELOCITY := 4.5
@export var CAMERA_SEE_LENGTH = 10

@export var MONSTER_COUNT := 1

@onready var Floor : FloorType = get_node("/root/Main/Floor")
@onready var Global : GlobalType = get_node("/root/Global")
@onready var UI : UIType = get_node("/root/Main/CanvasLayer/UI")
@onready var Jumpscare = get_node("/root/Main/CanvasLayer/Jumpscare")

const PLAYER_DEATH_SCENE = preload("res://scenes/player_dummy.tscn")
const WALL_SCENE = preload("res://scenes/placeable_wall.tscn")
const BOUNDARY_WALL_SCENE = preload("res://scenes/set_wall.tscn")
const MONSTER_SCENE = preload("res://scenes/monster.tscn")

var stamina = 0

var dead = false

var time_survived = 0.0

var camera_pitch = 0.0

var highlight_line : MeshInstance3D = null

var wall_layout = []

var monsters = []
func cell_to_world(cell_pos):
	return cell_pos * Floor.TILE_SIZE - (Floor.GRID_SIZE / 2) * Floor.TILE_SIZE


func _ready():
	UI.draw_crosshair = true
	setup_monsters()
	global_position = Vector3(0, 0, cell_to_world(Floor.GRID_SIZE / 2 + 5))
	initialize_wall_placement_highlight()
	init_wall_grid_tracking()
	place_boundary_walls()

func setup_monsters():
	for i in range(MONSTER_COUNT):
		var monster = MONSTER_SCENE.instantiate()
		get_tree().current_scene.add_child.call_deferred(monster)
		monsters.append(monster)
	for monster in monsters:
		#setup "other monsters" array
		var other_monsters = []
		for other_monster in monsters:
			if other_monster == monster:
				continue
			other_monsters.append(other_monster)
		monster.other_monsters = other_monsters


func init_wall_grid_tracking():
	var info = {"positive_x": false, "negative_x": false, "positive_z": false, "negative_z": false}
	#create grid
	for i in range(Floor.GRID_SIZE):
		var new_array = []
		for ii in range(Floor.GRID_SIZE):
			new_array.append(info.duplicate(true))
		wall_layout.append(new_array)
	#add set walls
	
	#for i in range(Floor.GRID_SIZE):
		#wall_layout[0][i].negative_x = true
		#wall_layout[Floor.GRID_SIZE - 1][i].positive_x = true
	#for i in range(Floor.GRID_SIZE):
		#wall_layout[i][0].negative_z = true
		#wall_layout[i][Floor.GRID_SIZE - 1].positive_z = true

func initialize_wall_placement_highlight():
	highlight_line = MeshInstance3D.new()
	highlight_line.mesh = BoxMesh.new()
	highlight_line.scale = Vector3(Floor.LINE_SIZE, 0.0001, Floor.TILE_SIZE + Floor.LINE_SIZE)
	get_tree().current_scene.add_child.call_deferred(highlight_line)
	
	var line_color = StandardMaterial3D.new()
	highlight_line.set_surface_override_material(0, line_color)

func place_boundary_walls():
	#x facing
	for i in range(Floor.GRID_SIZE):
		var x_pos = (Floor.GRID_SIZE / 2) * Floor.TILE_SIZE + Floor.TILE_SIZE / 2
		var z_pos = cell_to_world(i)
		handle_wall_placement({"tile_pos": Vector2i(0, i), "direction": Vector2(-1, 0), "position": Vector3(x_pos, 0, z_pos), "is_x_facing": true, "type": "set"})
		handle_wall_placement({"tile_pos": Vector2i(Floor.GRID_SIZE - 1, i), "direction": Vector2(1, 0),"position": Vector3(-x_pos, 0, z_pos), "is_x_facing": true, "type": "set"})
	#z facing
	for i in range(Floor.GRID_SIZE):
		var z_pos = (Floor.GRID_SIZE / 2) * Floor.TILE_SIZE + Floor.TILE_SIZE / 2
		var x_pos = cell_to_world(i)
		handle_wall_placement({"tile_pos": Vector2i(i, 0), "direction": Vector2(0, -1), "position": Vector3(x_pos, 0, z_pos), "type": "set"})
		handle_wall_placement({"tile_pos": Vector2i(i, Floor.GRID_SIZE - 1), "direction": Vector2(0, 1), "position": Vector3(x_pos, 0, -z_pos), "type": "set"})


func turn_player(mouse_motion):
	rotate_y(-mouse_motion.x)
	camera_pitch -= mouse_motion.y
	camera_pitch = clamp(camera_pitch, deg_to_rad(-80), deg_to_rad(80))
	$CameraPivot.rotation.x = camera_pitch

func _physics_process(delta: float) -> void:
	handle_movement(delta)
	time_survived += delta
func _process(delta: float) -> void:
	handle_wall_highlight()

func handle_movement(delta):
	#prevent moving into wall the moment it is pressed
	#var saved_velocity = velocity
	#velocity = velocity * 0.0000005
	#move_and_slide()
	#velocity = saved_velocity
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction and Input.is_action_pressed("sprint") and stamina > 0:
		if input_dir.y < 0:
			direction += transform.basis * Vector3(input_dir.x * SIDEWAYS_SPRINT_NERF, 0, input_dir.y) * (SPRINT_SPEED_MULT - 1)
		else:
			direction += transform.basis * Vector3(input_dir.x * SIDEWAYS_SPRINT_NERF, 0, input_dir.y * SIDEWAYS_SPRINT_NERF) * (SPRINT_SPEED_MULT - 1)
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x *= 0.8
		velocity.z *= 0.8
	
	
	if Input.is_action_pressed("sprint"):
		stamina -= delta
		if stamina < 0:
			stamina = 0
	else:
		stamina += STAMINA_TIME / STAMINA_REGEN_TIME * delta
		if stamina > STAMINA_TIME:
			stamina = STAMINA_TIME
	
	
	move_and_slide()


func handle_death(activate_scare):
	if dead:
		return
	dead = true
	
	UI.draw_crosshair = false
	
	var camera = $CameraPivot
	var move_direction = Vector2.UP.rotated(camera.global_rotation.y) * 1.5
	
	remove_child(camera)
	get_tree().current_scene.add_child(camera)
	
	
	var move_up_amount = 5
	
	camera.global_position = global_position + Vector3(-move_direction.x, move_up_amount, move_direction.y)
	camera.look_at(global_position, Vector3.UP)
	var dummy = PLAYER_DEATH_SCENE.instantiate()
	get_tree().current_scene.add_child(dummy)
	dummy.global_transform = global_transform
	
	
	for i in range(MONSTER_COUNT):
		monsters[i].Player = dummy
	$PlayerCollision.disabled = true
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	
	if Global.settings.scary and activate_scare:
		Jumpscare.scare_started = true
		var audio = AudioStreamPlayer3D.new()
		get_tree().current_scene.add_child(audio)
		
		audio.stream = load("res://scare.mp3")
		audio.global_position = global_position
		audio.play()




func handle_mouse_click():
	
	var wall_info = get_closest_grid_edge(raycast_from_camera())
	if wall_info == null:
		return
	if update_wall_layout(wall_info):
		var valid = true
		for i in range(MONSTER_COUNT):
			if monsters[i].pathfind_to_player() == null:
				valid = false
		delete_wall_layout(wall_info)
		if valid:
			handle_wall_placement(wall_info)
			for i in range(MONSTER_COUNT):
				monsters[i].current_path = monsters[i].pathfind_to_player()

func handle_wall_highlight():
	var wall_info = get_closest_grid_edge(raycast_from_camera())
	if wall_info == null:
		highlight_line.position = Vector3(0, -100000, 0)
		return
	highlight_line.position = wall_info.position + Vector3(0, 0.015, 0)
	if !wall_info.direction.x != 0:
		highlight_line.global_rotation = Vector3(0, PI/2, 0)
	else:
		highlight_line.global_rotation = Vector3(0, 0, 0)
	
	var valid_placement = true
	if update_wall_layout(wall_info):
		for i in range(MONSTER_COUNT):
			if monsters[i].pathfind_to_player() == null:
				valid_placement = false
		delete_wall_layout(wall_info)
	if valid_placement:
		highlight_line.get_surface_override_material(0).albedo_color = Color(0.7, 1, 0.7)
	else:
		highlight_line.get_surface_override_material(0).albedo_color = Color(1, 0.3, 0.3)

func handle_wall_placement(position_and_type_info):
	var new_wall = null
	
	if position_and_type_info.type == "set":
		new_wall = BOUNDARY_WALL_SCENE.instantiate()
		get_tree().current_scene.add_child.call_deferred(new_wall)
	else:
		new_wall = WALL_SCENE.instantiate()
		get_tree().current_scene.add_child.call_deferred(new_wall)
	new_wall.global_position = position_and_type_info.position
	
	if position_and_type_info.direction.x == 0:
		new_wall.rotation = Vector3(0, PI/2, 0)
	
	update_wall_layout(position_and_type_info)
	
func update_wall_layout(position_and_type_info):
	var tile_x = position_and_type_info.tile_pos.x
	var tile_y = position_and_type_info.tile_pos.y
	var direction_x = position_and_type_info.direction.x
	var direction_y = position_and_type_info.direction.y
	
	if direction_x != 0:
		
		if direction_x > 0 and not wall_layout[tile_x][tile_y].positive_x:
			wall_layout[tile_x][tile_y].positive_x = true
			if tile_x != Floor.GRID_SIZE - 1:
				wall_layout[tile_x + 1][tile_y].negative_x = true
			return true
		elif direction_x < 0 and not wall_layout[tile_x][tile_y].negative_x:
			wall_layout[tile_x][tile_y].negative_x = true
			if tile_x != 0:
				wall_layout[tile_x - 1][tile_y].positive_x = true
			return true
	else:
		if direction_y > 0 and not wall_layout[tile_x][tile_y].positive_z:
			wall_layout[tile_x][tile_y].positive_z = true
			if tile_y != Floor.GRID_SIZE - 1:
				wall_layout[tile_x][tile_y + 1].negative_z = true
			return true
		elif direction_y < 0 and not wall_layout[tile_x][tile_y].negative_z:
			wall_layout[tile_x][tile_y].negative_z = true
			if tile_y != 0:
				wall_layout[tile_x][tile_y - 1].positive_z = true
			return true
	return false

func delete_wall_layout(position_and_type_info):
	var tile_x = position_and_type_info.tile_pos.x
	var tile_y = position_and_type_info.tile_pos.y
	var direction_x = position_and_type_info.direction.x
	var direction_y = position_and_type_info.direction.y
	
	if direction_x != 0:
		if direction_x > 0:
			wall_layout[tile_x][tile_y].positive_x = false
			if tile_x != Floor.GRID_SIZE - 1:
				wall_layout[tile_x + 1][tile_y].negative_x = false
		else:
			wall_layout[tile_x][tile_y].negative_x = false
			if tile_x != 0:
				wall_layout[tile_x - 1][tile_y].positive_x = false
	else:
		if direction_y > 0:
			wall_layout[tile_x][tile_y].positive_z = false
			if tile_y != Floor.GRID_SIZE - 1:
				wall_layout[tile_x][tile_y + 1].negative_z = false
		else:
			wall_layout[tile_x][tile_y].negative_z = false
			if tile_y != 0:
				wall_layout[tile_x][tile_y - 1].positive_z = false



func raycast_from_camera():
	var camera = $CameraPivot/Camera3D

	var from = camera.global_transform.origin
	var to = from + camera.global_transform.basis.z * -CAMERA_SEE_LENGTH

	var space = get_world_3d().direct_space_state
	var result = space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 1))

	if result:
		return result
	return null

func get_closest_grid_edge(raycast_result):
	if raycast_result == null:
		return null
	if !raycast_result.collider.is_in_group("Floor"):
		return null
		
	var divided_by_tile_size = raycast_result.position / Floor.TILE_SIZE
	var tile_pos = round(divided_by_tile_size) * Floor.TILE_SIZE
	
	var remaining_position = divided_by_tile_size - Vector3(round(divided_by_tile_size))
	var direction = Vector3()
	if abs(remaining_position.x) > abs(remaining_position.z):
		direction = Vector3(sign(remaining_position.x) * Floor.TILE_SIZE / 2, 0, 0)
	else:
		direction = Vector3(0, 0, sign(remaining_position.z) * Floor.TILE_SIZE / 2)
	var tile_looking_at = Vector2i(round(divided_by_tile_size.x) + floor((Floor.GRID_SIZE / 2)), round(divided_by_tile_size.z) + floor((Floor.GRID_SIZE / 2)))
	return {"tile_pos": tile_looking_at, "direction": Vector2(direction.x, direction.z), "position": tile_pos + direction, "type": "placed"}
