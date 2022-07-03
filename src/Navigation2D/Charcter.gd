# This script is assigned to the main player node.
# The main player is controlled with RTS like controls. A player click on the
# map will make the player character go to the clicked position. 

# The base node for the main character is a KinematicBody2D this allows us
# to do physics based moivements later on.
extends KinematicBody2D

# We set a custom class name for this node so we reference this specific node
# type in FollowMeAgent.gd as the target for the follower.
class_name Character

# target is last clicked position of the player. This is set within the
# _unhandled_input method.
var target = null

# Getting a reference of two other nodes in this character scene.
onready var nav_agent = $NavigationAgent2D;
onready var nav_path = get_node("../PlayerPath")
	
# _unhandled_input is called whener any button press or mouse movement, clicks,
# or any other user input occurs.
func _unhandled_input(event):
	
	# We only care for mouse button events
	if event is InputEventMouseButton:
		
		# We type cast the event to be a mouse button event so we can read 
		# properties exclusive to a InputEventMouseButton
		var mouse_event = event as InputEventMouseButton
		
		# The explusive iknfo we need is the button index that is pressed.
		# If we do not check this a right mouse button click would also 
		# make the character move.	
		if mouse_event.is_pressed() and mouse_event.button_index == BUTTON_LEFT:
			
			# You can get the current mouse pointer location in world space
			# at any time from a node using get_global_mouse_position()
			var mouse_target = get_global_mouse_position()
			
			# We use that position as the taret for the character
			nav_agent.set_target_location(mouse_target)
			target = nav_agent.get_final_location()


# _physics_process is called once every physics frame.
func _physics_process(delta):
	
	# If we are currently having a target position to go to
	if target != null:
		# we get the next point on our path to the target
		var next_location = nav_agent.get_next_location()
		# and calculate a vector that represents the velocity we want the
		# character to have so it will reach the next location on the path.
		var unsafe_velocity =  global_position.direction_to(next_location).normalized() * 100
		# But this would not take into account obstacles or other agants.
		# We dont want to collide with anyone, so we ask the godot navigation
		# service to calculate a safe velocity that takles our surroundings
		# into account.	
		nav_agent.set_velocity(unsafe_velocity)

# _on_NavigationAgent2D_velocity_computed is a method called by a signal from
# the NavigationAgent2D with  a safe velocity. It is guaranteed that we will 
# not run into anything using the velocity.  
func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	# If we are slow we might be running into an obstacle so lets see if we can
	# identfy a better path by re-calculating the path to the target.
	# You could also do this in _physics_process if you dont have many agents
	# in your game and as such performance is not an issue for you. 
	if safe_velocity.length() <= 35:
		nav_agent.set_target_location(target)
	
	# move_and_slide is a method provided by KinematicBody2D and will do the
	# actual movement
	move_and_slide(safe_velocity)

# This method is conencted to a signal from the agent, and is called when the 
# path to the target is updated. We use this to update the rendering of the
# path preview you see for the character. 
func _on_NavigationAgent2D_path_changed():
	nav_path.points = nav_agent.get_nav_path()

# _NavigationAgent2D_navigation_finished is also a method called be an agent
# signal and removes the current target because we have reached the closest 
# point we can to the clicked position.
func _on_NavigationAgent2D_navigation_finished():
	target = null;
