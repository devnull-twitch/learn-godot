# The FollowMeAgent is placed on a kinematic body that will alws try to reach
#
# a position close to the character supplyed in the editors property
# "Path to player"

extends KinematicBody2D

# This creates a field in the editor UI for you to assign the target character
# node to follow. This will contain a string as ap node path to the character
# node and not a direct reference of said node.
export(NodePath) var path_to_player

# player_node will contain a reference to the actual node after the 
# ready function is complete
var player_node: Character

# A few references to other nodes in this scene
onready var nav_agent = $NavigationAgent2D
onready var sprite = $Sprite

# This internal state represents if the node is curretly following the
# character or not. You can change that by clicking on the follower
# in the game.
var active_follow = false setget update_active_follow

# Just a few color values for modulation to visualize the active state
const active_color = Color(1, 1, 0, 1)
const inactive_color = Color(1, 1, 1, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	player_node = get_node(path_to_player)

# _physics_process is called once every physics frame
func _physics_process(delta):
	# If we do not have a reference to a node to follow or we are not in an
	# active follow state we dont do anything.
	if player_node == null or !active_follow:
		return
	
	# Otherwise we take the current target position as our target position to move to.
	nav_agent.set_target_location(player_node.global_position)
	
	# If we are close enough to the character we dont do anything.
	if nav_agent.is_navigation_finished():
		return
	
	# If we are not we get the next point oin our path to the player.
	var next_location = nav_agent.get_next_location()
	# We then calculate a unsafe velocity. So If we use this without collision avoidance we might
	# run into a physics object or other agent. 
	var unsafe_velocity =  global_position.direction_to(next_location).normalized() * 50
	# So we ask the navigation system to calculate a safe velocity			
	nav_agent.set_velocity(unsafe_velocity)

# _on_NavigationAgent2D_velocity_computed is called when a safe velocity is calculated
func _on_NavigationAgent2D_velocity_computed(safe_velocity):
	# We use that velocity to let the physics engione move the follower.
	move_and_slide(safe_velocity)

# set state and update modulate color of the sprite to visualize follow state
func update_active_follow(new_val):
	active_follow = new_val
	if new_val:
		sprite.modulate = active_color
	else:
		sprite.modulate = inactive_color

# If the follower is clicked we do not want to move to that.
# Because of the order of methods we need a few methods to prevent this.
# If you read the documentation you see an area has a "input_event" signal.
# But have a look at this page:
# https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html#how-does-it-work
# The collision methods are called even after the "_unhandled_input" in the character.
# So the better option is to detect when the mouse enter or leaves and then handle clicks in 
# _input. 

var mouse_in_are: bool = false

func _input(event):
	# same as in Character we check if the input event is a mouse button click
	if mouse_in_are and event is InputEventMouseButton:
		# we then check if the left mouse button was clicked
		var mouse_event = event as InputEventMouseButton
		if mouse_event.is_pressed() and mouse_event.button_index == BUTTON_LEFT:
			# and update the internal active follow state
			update_active_follow(!active_follow)
			# and we also mark this click as handled. So we dont trigger a movement to this location.
			get_tree().set_input_as_handled()

func _on_Area2D_mouse_entered():
	mouse_in_are = true

func _on_Area2D_mouse_exited():
	mouse_in_are = false
