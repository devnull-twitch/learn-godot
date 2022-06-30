extends RigidBody2D


export(NodePath) var node_path_to_path2d
var path: Path2D
var current_index = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var target_path = get_node(node_path_to_path2d)
	if not target_path is Path2D:
		printerr("Path of PathedObstacle is not a path to a Path2D")
		return
	path = target_path

func _physics_process(delta):
	if path == null:
		return
	
	var points = path.curve.get_baked_points()
	var current_target_vector = points[current_index]	
	if global_position.distance_to(current_target_vector) <= 100:
		current_index = current_index + 1
		if current_index >= len(points):
			current_index = 0
		current_target_vector = points[current_index]	
	
	linear_velocity =  global_position.direction_to(current_target_vector).normalized() * 100
