extends RigidBody3D
class_name MonsterType

@onready var Player : Node3D = get_node("/root/Main/Player")
@onready var WallLayoutSource = get_node("/root/Main/Player")
@onready var Camera : Camera3D = get_node("/root/Main/Player/CameraPivot/Camera3D")
@onready var Floor : FloorType = get_node("/root/Main/Floor")

@export var max_speed = 6.8
@export var ACCELERATION_MULT = 0.1
@export var SCARE_SEEN_TIME = 0.5

var current_path = null
var other_monsters = []
var seen_time = 0
var seen_time_reset_timer = 0
var seen_time_reset_time = 0.7


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10
	global_position = Vector3(cell_to_world(Floor.GRID_SIZE / 2) + randf(), 0, cell_to_world(Floor.GRID_SIZE / 2 - 5) + randf())
	set_physics_process_priority(-10)
func world_to_cell(world_pos):
	return round(world_pos / Floor.TILE_SIZE) + floor((Floor.GRID_SIZE / 2))
func cell_to_world(cell_pos):
	return cell_pos * Floor.TILE_SIZE - (Floor.GRID_SIZE / 2) * Floor.TILE_SIZE


func _physics_process(delta: float) -> void:
	max_speed *= 1.00001
	#repathfinding logic
	if current_path == null or (world_to_cell(global_position.x) != current_path[0].position_x or world_to_cell(global_position.z) != current_path[0].position_y):
		current_path = pathfind_to_player()
	
	var target = Vector2()
	if len(current_path) >= 2:
		target = Vector2(cell_to_world(current_path[1].position_x), cell_to_world(current_path[1].position_y))
	else:
		target = Vector2(Player.global_position.x, Player.global_position.z)
		current_path = null
	
	var direction = (target - Vector2(global_position.x, global_position.z)).normalized()
	
	#linear_velocity.x += direction.x * max_speed * ACCELERATION_MULT
	#linear_velocity.z += direction.y * max_speed * ACCELERATION_MULT
	
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	look_at(Vector3(target.x, 0, target.y))
	global_rotation.x = 0
	global_rotation.z = 0

func _process(delta: float) -> void:
	if Camera.is_position_in_frustum(global_position):
		seen_time += delta
		seen_time_reset_timer = 0
	else:
		seen_time_reset_timer += delta
		if seen_time_reset_timer > seen_time_reset_time:
			seen_time = 0
	if Global.settings.scary:
		var new_material = StandardMaterial3D.new()
		new_material.albedo_color = Color(0.5, 0.1, 0.1)
		$BeanShape.set_surface_override_material(0, new_material)
		$Mouth.visible = true

func pathfind_to_player():
	return pathfind_to_pos(world_to_cell(global_position.x), world_to_cell(global_position.z), world_to_cell(Player.global_position.x), world_to_cell(Player.global_position.z))
func pathfind_to_pos(start_cell_x, start_cell_y, target_cell_x, target_cell_y):
	# if already there, stop
	if start_cell_x == target_cell_x and start_cell_y == target_cell_y:
		return [{"position_x": start_cell_x, "position_y": start_cell_y}]
	
	var next_tile_queue = [{
		"position_x": start_cell_x, 
		"position_y": start_cell_y, 
		"weight": 1,
		"path": [{"position_x": start_cell_x, "position_y": start_cell_y}]
		}]
	var been_to = {}
	var weights = {}
	
	for monster in other_monsters:
		if monster.current_path == null:
			continue
		for tile in monster.current_path:
			weights[Vector2i(tile.position_x, tile.position_y)] = 2
						
	for i in range(5000):
		if len(next_tile_queue) == 0:
			return null
		var data = next_tile_queue.pop_front()
		
		data.weight -= 1
		if data.weight > 0:
			next_tile_queue.append(data)
			continue
		
		var directions = [[1, 0], [0, 1], [-1, 0], [0, -1]]
		for ii in range(4):
			var direction = directions.pop_at(randi() % directions.size())
			var result = pathfind_check_connection(next_tile_queue, been_to, weights, data.weight, data.path, data.position_x, data.position_y, target_cell_x, target_cell_y, direction[0], direction[1])
			if not result.is_empty():
				return result
	return null

func pathfind_check_connection(queue, been_to, weights, weight, path, pos_x, pos_y, target_x, target_y, dir_x, dir_y):
	#walls check
	if dir_x > 0 and WallLayoutSource.wall_layout[pos_x][pos_y].positive_x:
		return []
	elif dir_x < 0 and WallLayoutSource.wall_layout[pos_x][pos_y].negative_x:
		return []
	elif dir_y > 0 and WallLayoutSource.wall_layout[pos_x][pos_y].positive_z:
		return []
	elif dir_y < 0 and WallLayoutSource.wall_layout[pos_x][pos_y].negative_z:
		return []
	#if this tile is alerady checked
	if been_to.has(Vector2i(pos_x + dir_x, pos_y + dir_y)):
		return []
	
	var new_pos_x = pos_x + dir_x
	var new_pos_y = pos_y + dir_y
	
	been_to[Vector2i(new_pos_x, new_pos_y)] = true
	var path_copy = path.duplicate(true)
	path_copy.append({"position_x": new_pos_x, "position_y": new_pos_y})
	if new_pos_x == target_x and new_pos_y == target_y:
		return path_copy
	
	var added_weight = 1
	
	if weights.has(Vector2i(new_pos_x, new_pos_y)):
		added_weight = weights[Vector2i(new_pos_x, new_pos_y)]
	
	queue.append({
	"position_x": new_pos_x, 
	"position_y": new_pos_y, 
	"weight": weight + added_weight,
	"path": path_copy
	})
	return []



func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		#print("Time Survived: " + str(Player.time_survived))
		Player.handle_death.call_deferred(seen_time < SCARE_SEEN_TIME)
