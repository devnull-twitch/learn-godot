extends KinematicBody2D

class_name Character

var target = null
onready var nav_agent = $NavigationAgent2D;
onready var nav_path = get_node("../PlayerPath")
	
func _unhandled_input(event):
	if event is InputEventMouseButton:
		var mouse_event = event as InputEventMouseButton
		if mouse_event.button_index == BUTTON_LEFT:
			var mouse_target = get_global_mouse_position()
			nav_agent.set_target_location(mouse_target)
			target = nav_agent.get_final_location()

func _physics_process(delta):
	if target != null:
		nav_agent.set_target_location(target)
		var next_location = nav_agent.get_next_location()
		var unsafe_velocity =  global_position.direction_to(next_location).normalized() * 100		
		nav_agent.set_velocity(unsafe_velocity)

func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	move_and_slide(safe_velocity)

func _on_NavigationAgent2D_target_reached():
	target = null;

func _on_NavigationAgent2D_path_changed():
	nav_path.points = nav_agent.get_nav_path()
