extends RigidBody3D
class_name MonsterType

@onready var Player : Node3D = get_node("/root/Main/Player")
@onready var WallLayoutSource = get_node("/root/Main/Player")
@onready var Floor : FloorType = get_node("/root/Main/Floor")

@export var max_speed = 7.0
@export var ACCELERATION_MULT = 0.08 

var current_path = null
func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10
	global_position = Vector3(cell_to_world(Floor.GRID_SIZE / 2) + randf(), 0, cell_to_world(Floor.GRID_SIZE / 2 - 5) + randf())
func world_to_cell(world_pos):
	return round(world_pos / Floor.TILE_SIZE) + floor((Floor.GRID_SIZE / 2))
func cell_to_world(cell_pos):
	return cell_pos * Floor.TILE_SIZE - (Floor.GRID_SIZE / 2) * Floor.TILE_SIZE

func _physics_process(delta: float) -> void:
	max_speed *= 1.00001
	#for i in path:
		#var placeholder = load("res://scenes/placeholder.tscn").instantiate()
		#placeholder.global_position = Vector3(cell_to_world(i.position_x), 0, cell_to_world(i.position_y))
		#get_tree().current_scene.add_child(placeholder)
	if current_path == null or (world_to_cell(global_position.x) != current_path[0].position_x or world_to_cell(global_position.z) != current_path[0].position_y):
		current_path = pathfind_to_player()
	var target = Vector2(Player.global_position.x, Player.global_position.z)
	if len(current_path) >= 2:
		target = Vector2(cell_to_world(current_path[1].position_x), cell_to_world(current_path[1].position_y))
	else:
		current_path = pathfind_to_player()
	if world_to_cell(global_position.x) == world_to_cell(Player.global_position.x) and world_to_cell(global_position.z) == world_to_cell(Player.global_position.z):
		target = Vector2(Player.global_position.x, Player.global_position.z)
		current_path = null
	
	var direction = (target - Vector2(global_position.x, global_position.z)).normalized()
	
	linear_velocity.x += direction.x * max_speed * ACCELERATION_MULT
	linear_velocity.z += direction.y * max_speed * ACCELERATION_MULT
	
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	
func _process(delta: float) -> void:
	var path = pathfind_to_player()
	if Input.is_action_just_pressed("debug_command"):
		for i in path:
			var placeholder = load("res://scenes/placeholder.tscn").instantiate()
			placeholder.global_position = Vector3(cell_to_world(i.position_x), 0, cell_to_world(i.position_y))
			get_tree().current_scene.add_child(placeholder)
func pathfind_to_player():
	return pathfind_to_pos(world_to_cell(global_position.x), world_to_cell(global_position.z), world_to_cell(Player.global_position.x), world_to_cell(Player.global_position.z))
func pathfind_to_pos(start_cell_x, start_cell_y, target_cell_x, target_cell_y):
	var next_tile_queue = [{
		"position_x": start_cell_x, 
		"position_y": start_cell_y, 
		"path": [{"position_x": start_cell_x, "position_y": start_cell_y}]
		}]
	var been_to = {}
	for i in range(1000):
		if len(next_tile_queue) == 0:
			return null
		var data = next_tile_queue.pop_front()
		var directions = [[1, 0], [0, 1], [-1, 0], [0, -1]]
		for ii in range(4):
			var direction = directions.pop_at(randi() % directions.size())
			var result = pathfind_check_connection(next_tile_queue, been_to, data.path, data.position_x, data.position_y, target_cell_x, target_cell_y, direction[0], direction[1])
			if not result.is_empty():
				return result
	return null

func pathfind_check_connection(queue, been_to, path, pos_x, pos_y, target_x, target_y, dir_x, dir_y):
	if dir_x > 0 and WallLayoutSource.wall_layout[pos_x][pos_y].positive_x:
		return []
	elif dir_x < 0 and WallLayoutSource.wall_layout[pos_x][pos_y].negative_x:
		return []
	elif dir_y > 0 and WallLayoutSource.wall_layout[pos_x][pos_y].positive_z:
		return []
	elif dir_y < 0 and WallLayoutSource.wall_layout[pos_x][pos_y].negative_z:
		return []
	if been_to.has(Vector2i(pos_x + dir_x, pos_y + dir_y)):
		return []
	been_to[Vector2i(pos_x + dir_x, pos_y + dir_y)] = true
	var path_copy = path.duplicate(true)
	path_copy.append({"position_x": pos_x + dir_x, "position_y": pos_y + dir_y})
	if pos_x + dir_x == target_x and pos_y + dir_y == target_y:
		return path_copy
	
	queue.append({
	"position_x": pos_x + dir_x, 
	"position_y": pos_y + dir_y, 
	"path": path_copy
	})
	return []


func _on_body_entered(body: Node) -> void:
	if body is CharacterBody3D:
		#print("Time Survived: " + str(Player.time_survived))
		Player.handle_death.call_deferred()
