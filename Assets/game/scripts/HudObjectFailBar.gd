extends Spatial

export (NodePath) var failFill1
export (NodePath) var failFill2
export (NodePath) var failFill3

var fails = []

func SetFails(value, force: bool = false):
	for n in fails.size():
		var fill1 = fails[n].get_node("fail-fill-1")
		var fill2 = fails[n].get_node("fail-fill-2")
		if n < value:
			if fill1.opacity != 1.0:
				if !force:
					yield(create_tween().tween_interval(1), "finished")
					var tween = create_tween()
					tween.set_parallel(true)
					tween.tween_property(fill1, "opacity", 1, 0.25)
					tween.tween_property(fill2, "opacity", 1, 0.25)
					var originalScale = fill1.scale
					fill1.scale = originalScale * 3
					fill2.scale = originalScale * 3
					tween.set_ease(Tween.EASE_OUT)
					tween.set_trans(Tween.TRANS_BOUNCE)
					tween.tween_property(fill1, "scale", originalScale, 0.5)
					tween.tween_property(fill2, "scale", originalScale, 0.5)
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
		get_node(failFill1),
		get_node(failFill2),
		get_node(failFill3)
	]
	SetFails(Data.playerData.sessionFails, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
