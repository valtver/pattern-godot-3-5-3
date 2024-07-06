extends Spatial

onready var panelPivot = $PanelPivot
onready var screenShade = $ShadeBlock/SpritePivot/Sprite
onready var confirmLabel = $PanelPivot/ConfirmLabel
onready var collision = $ShadeBlock/CollisionShape
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	collision.disabled = true
	pass # Replace with function body.

func Show():
	collision.disabled = false
	var tween = get_node_or_null("TweenMove")
	if tween == null:
		return
	visible = true
	tween.interpolate_property(panelPivot, "position",
		Vector3(-6, 0, 0), Vector3.ZERO, 0.2,
		Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	
	tween = get_node_or_null("TweenFade")
	if tween == null:
		return
	tween.interpolate_property(screenShade, "opacity",
		0, 1, 0.2,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
func Hide():
	collision.disabled = true
	var tween = get_node_or_null("TweenMove")
	if tween == null:
		return
	visible = true
	tween.interpolate_property(panelPivot, "position",
		Vector3.ZERO, Vector3(6, 0, 0), 0.2,
		Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()
	
	tween = get_node_or_null("TweenFade")
	if tween == null:
		return
	tween.interpolate_property(screenShade, "opacity",
		1, 0, 0.2,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tween.start()
	
	Timeline.OnCompleteTimer(self, "SetInvisible", 0.2)
	
func SetInvisible():
	visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
