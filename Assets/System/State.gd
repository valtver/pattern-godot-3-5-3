extends Node
class_name State
export var controlNode: NodePath
onready var actor = get_node(controlNode)
# Do take note that the node itself isn't being exported -
# there is one more step to call the true node:

signal TransitionToEvent
		
func Enter():
	pass
	
func Exit():
	pass
	
func Update(_delta: float):
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
