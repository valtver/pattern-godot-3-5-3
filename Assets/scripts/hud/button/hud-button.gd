extends Spatial

export (Types.HudButtonId) var buttonId
export (int) var index

var defaultRotation = Vector3(-90, 0, 0)

func UpdateSymbol(subSymbolAngles, subSymbolSprites):
	var children = $Pivot.get_children()
	for child in children:
		if "id" in child:
			child.rotation_degrees = defaultRotation
			child.rotation_degrees += subSymbolAngles[child.id]
			child.texture = Loader.GetResource(subSymbolSprites[child.id])

func OnClick():
	Events.emit_signal("Click", self)
	var tween = get_node_or_null("Tween")
	if tween == null:
		return
	tween.interpolate_property($Pivot, "scale",
		Vector3(1.2, 1.2, 1.2), Vector3.ONE, 0.5,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()

func AnimateShow():
	visible = true
	var tween = get_node_or_null("Tween")
	if tween == null:
		return
	tween.interpolate_property($Pivot, "scale",
		Vector3.ZERO, Vector3.ONE, 0.3,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func AnimateHide():
	visible = true
	var tween = get_node_or_null("Tween")
	if tween == null:
		return
	tween.interpolate_property($Pivot, "scale",
		Vector3.ONE, Vector3.ZERO, 0.3,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
func AnimateShowUpdated():
	visible = true
	var tween = get_node_or_null("VisibilityTween")
	if tween == null:
		return
	tween.interpolate_property($SpritePivot, "scale",
		Vector3.ZERO, Vector3.ONE, 0.3,
		Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
