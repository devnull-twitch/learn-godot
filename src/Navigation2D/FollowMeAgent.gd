extends KinematicBody2D

export(NodePath) var path_to_player
var player_node: Character
onready var nav_agent = $NavigationAgent2D
onready var sprite = $Sprite
var active_follow = false setget update_active_follow

const active_color = Color(1, 1, 0, 1)
const inactive_color = Color(1, 1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	player_node = get_node(path_to_player)

func _physics_process(delta):
	if player_node == null or !active_follow:
		return
	
	nav_agent.set_target_location(player_node.global_position)
	if nav_agent.is_target_reached():
		return
		
	var d = global_position.distance_to(player_node.global_position)
	if d < 90:
		return
	
	var next_location = nav_agent.get_next_location()
	var unsafe_velocity =  global_position.direction_to(next_location).normalized() * 50			
	nav_agent.set_velocity(unsafe_velocity)


func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	move_and_slide(safe_velocity)


func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.is_pressed() and mouse_event.button_index == BUTTON_LEFT:
			update_active_follow(!active_follow)
			get_tree().set_input_as_handled()
			
func update_active_follow(new_val):
	active_follow = new_val
	if new_val:
		sprite.modulate = active_color
	else:
		sprite.modulate = inactive_color
