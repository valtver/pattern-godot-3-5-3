extends Spatial

var fails = []

func SetFails(value, force: bool = false):
	print("Setting fails!", value)
	for n in fails.size():
		var fill1 = fails[n].get_node("fail-fill-1")
		var fill2 = fails[n].get_node("fail-fill-2")
		if n < value:
			if fill1.opacity != 1.0:
				if !force:
					var tween = create_tween().set_parallel(true)
					tween.tween_property(fill1, "opacity", 1, 0.5)
					tween.tween_property(fill2, "opacity", 1, 0.5)
					tween.play()
				else:
					fill1.opacity = 1
					fill2.opacity = 1
		else:
			if fill1.opacity != 0.0:
				if !force:
					var tween = create_tween().set_parallel(true)
					tween.tween_property(fill1, "opacity", 0, 0.5)
					tween.tween_property(fill2, "opacity", 0, 0.5)
					tween.play()
				else:
					fill1.opacity = 0
					fill2.opacity = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	fails = [
		$"fail-1",
		$"fail-2",
		$"fail-3"
	]
	SetFails(Data.playerData.sessionFails, true)
	Events.connect("HudSetFails", self, "SetFails")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
