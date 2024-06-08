extends Node

var visibilityNotifiers : Array
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	visibilityNotifiers.clear()
	visibilityNotifiers = get_tree().get_nodes_in_group("VisibilityNotifiers")
	for notifier in visibilityNotifiers:
		notifier.connect("screen_entered", self, "OnNotifierVisibilityChange", [notifier, true])
		notifier.connect("screen_exited", self, "OnNotifierVisibilityChange", [notifier, false])

func OnNotifierVisibilityChange(notifier, visibilityState):
	notifier.visible = visibilityState
	print("notifier ", notifier.get_parent().name, visibilityState)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
