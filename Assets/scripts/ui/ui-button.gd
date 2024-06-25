extends StaticBody

export (Types.UiButtonId) var buttonId = Types.UiButtonId.None
export (int, 0, 99) var index

signal Click

var active: bool = false setget OnActive

func OnActive(value):
	active = value
	if value:
		sprite.modulate = defaultColor
	else:
		sprite.modulate = disabledColor
		
onready var sprite = $Sprite
onready var defaultColor = sprite.modulate
onready var disabledColor = Color("9db0cd")
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
	emit_signal("Click", self)
	var tween = get_node_or_null("Tween")
	if tween == null:
		return
	tween.interpolate_property(sprite, "scale",
		Vector3(1.2, 1.2, 1.2), Vector3(1, 1, 1), 0.5,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()

func Show():
	var tween = get_node_or_null("Tween")
	if tween == null:
		return
	tween.interpolate_property(sprite, "scale",
		Vector3(0, 0, 0), Vector3.ONE, 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
