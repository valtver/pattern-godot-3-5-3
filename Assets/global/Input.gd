extends Spatial

const RAYCAST_DISTANCE = 1000
var wasClickDown = false

var lastPosition = null

export (bool) var ui = true
export (bool) var scene = true

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed() and !wasClickDown:
			wasClickDown = true
		elif !event.is_pressed() and wasClickDown and lastPosition.distance_to(event.position) < 0.1:
			wasClickDown = false
			print("Mouse Click/Unclick at: ", event.position)
			if ui:
				ProcessUi(event.position)
			if scene:
				ProcessScene(event.position)
		
func ProcessUi(position):
	pass
	
func ProcessScene(position):
	var camera = get_tree().get_nodes_in_group("main-camera")[0]
	var from = camera.project_ray_origin(position)
	var to = from + camera.project_ray_normal(position) * RAYCAST_DISTANCE
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self], 0b00000000001000000000) #Layer 10
	if result != null:
		result.collider.InputClick()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
