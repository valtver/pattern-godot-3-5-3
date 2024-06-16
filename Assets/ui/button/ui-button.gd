extends StaticBody

export (Types.UiButtonId) var buttonId = Types.UiButtonId.None

signal Click

onready var sprite = $Sprite
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func OnPress():
	pass
	
func OnRelease():
	pass
	
func OnClick():
	emit_signal("Click", buttonId)
	var tween = get_node("Tween")
	tween.interpolate_property(sprite, "scale",
		Vector3(1.2, 1.2, 1.2), Vector3(1, 1, 1), 0.5,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()

func Show():
	var tween = get_node("Tween")
	tween.interpolate_property(sprite, "scale",
		Vector3(0, 0, 0), Vector3.ONE, 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
