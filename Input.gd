extends Node

var wasClickDown = false

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.is_pressed() and !wasClickDown:
			wasClickDown = true
		elif !event.is_pressed() and wasClickDown:
			wasClickDown = false
			print("Mouse Click/Unclick at: ", event.position)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
