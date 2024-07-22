extends StaticBody

export (Types.UiButtonId) var buttonId = Types.UiButtonId.None
export (int, 0, 99) var index

signal Click

var active: bool = false setget OnActive
var selected: bool = false setget OnSelected
var locked: bool = false setget OnLocked

func OnActive(value):
	if(typeof(value) != typeof(active)):
		return
	active = value
	if value:
		sprite.modulate = defaultColor
	else:
		sprite.modulate = defaultColor * disabledColor
		
func OnLocked(value):
	if(typeof(value) != typeof(locked) || lock == null):
		return
	locked = value
	if value:
		pass
	else:
		pass
		
func OnSelected(value):
	if(typeof(value) != typeof(selected) || selection == null):
		return
	selected = value
	selection.visible = value
		
onready var spritePivot = $SpritePivot
onready var sprite = $SpritePivot/Sprite
onready var selection = get_node_or_null("SpritePivot/Selection")
onready var lock = get_node_or_null("SpritePivot/Lock")
onready var defaultColor = sprite.modulate
onready var disabledColor = Color("9db0cd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func Init(activeVal, lockedVal, selectedVal):
	active = activeVal
	locked = lockedVal
	selected = selectedVal

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func OnPress():
	pass
	
func OnRelease():
	pass
		
func OnClick():
	Events.emit_signal("Click", self)
	var tween = get_node_or_null("Tween")
	if tween == null:
		return
	tween.interpolate_property(spritePivot, "scale",
		Vector3(1.2, 1.2, 1.2), Vector3.ONE, 0.5,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()

func Show():
	var tween = get_node_or_null("Tween")
	if tween == null:
		return
	tween.interpolate_property(spritePivot, "scale",
		Vector3(0, 0, 0), Vector3.ONE, 1,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	pass
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
