extends Spatial

var lives = []

func SetLives(value, force: bool = false):
	print("Setting lives!", value)
	for n in lives.size():
		var fill1 = lives[n].get_node("heart-fill-1")
		var fill2 = lives[n].get_node("heart-fill-2")
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
	lives = [
		$"heart-1",
		$"heart-2",
		$"heart-3"
	]
	SetLives(Data.playerData.sessionLives, true)
	Events.connect("HudSetLives", self, "SetLives")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
