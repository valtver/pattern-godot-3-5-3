extends StaticBody

export (Types.UiElementId) var uiElementId
export (int, 0, 99) var index

export (bool) var active setget activeSet, activeGet
export (Color) var inactiveColor = Color(0.8, 0.905882, 1, 1)

const cachedActiveColors = {}

func activeSet(val):
	var children = $Pivot.get_children()
	for child in children:
		if val:
			child.modulate = cachedActiveColors[child]
		else:
			child.modulate *= inactiveColor
	active = val
	
func activeGet():
	return active
	
var tween = null

func _ready():
	var children = $Pivot.get_children()
	for child in children:
		cachedActiveColors[child] = child.modulate
	pass # Replace with function body.

func OnPress():
	pass
	
func OnRelease():
	pass
		
func OnClick():
	if tween != null:
		tween.kill()
		
	tween = create_tween()
	$Pivot.scale *= Vector3(1.2, 1.2, 1.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property($Pivot, "scale", Vector3.ONE, 0.5)
	tween.play()
	if active:
		Events.emit_signal("Click", self)
	else:
		Events.emit_signal("InactiveClick", self)

func AnimateShow(style: String = ""):
	visible = true
	if tween != null:
		tween.kill()
	tween = create_tween()
	if style == "":
		$Pivot.scale = Vector3.ZERO
		tween.set_trans(Tween.TRANS_BACK)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($Pivot, "scale", Vector3.ONE, 0.5)
	elif style == "alpha":
		for child in $Pivot.get_children():
			if "opacity" in child:
				child.opacity = 0
				tween.set_trans(Tween.TRANS_LINEAR)
				tween.set_ease(Tween.EASE_IN_OUT)
				tween.tween_property(child, "opacity", 1, 0.25)
	tween.play()
	return tween

	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
