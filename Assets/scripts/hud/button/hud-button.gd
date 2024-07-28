extends Spatial

export (Types.HudElementId) var hudElementId
export (int) var index

var defaultRotation = Vector3(-90, 0, 0)

func UpdateSymbol(subSymbolAngles, subSymbolSprites):
	var children = $Pivot.get_children()
	for child in children:
		if "id" in child:
			child.rotation_degrees = defaultRotation
			child.rotation_degrees += subSymbolAngles[child.id]
			child.texture = Loader.GetResource(subSymbolSprites[child.id])
			
func GetSymbolAngles():
	var angles = []
	angles.resize(4)
	var children = $Pivot.get_children()
	for child in children:
		if "id" in child:
			angles[child.id] = Vector3.UP * child.rotation_degrees
	
	return angles 

func OnClick():
	var tween = get_node_or_null("Tween")
	if tween != null:
		tween.remove_all()
	tween.interpolate_property($Pivot, "scale",
		Vector3(1.2, 1.2, 1.2), Vector3.ONE, 0.5,
		Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()
	Events.emit_signal("Click", self)

func Show():
	visible = true
	
func Hide():
	visible = false

func AnimateShow(style: String = ""):
	visible = true
	var tween = get_node_or_null("Tween")
	if tween != null:
		tween.remove_all()
	if style == "":
		tween.interpolate_property($Pivot, "scale",
			Vector3.ZERO, Vector3.ONE, 0.3,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
	elif style == "alpha":
		for child in $Pivot.get_children():
			tween.interpolate_property(child, "opacity",
				0, 1, 0.3,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func AnimateHide(style: String = ""):
	visible = true
	var tween = get_node_or_null("Tween")
	if tween != null:
		tween.remove_all()
	if style == "":
		tween.interpolate_property($Pivot, "scale",
			Vector3.ONE, Vector3.ZERO, 0.3,
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
	elif style == "alpha":
		for child in $Pivot.get_children():
			tween.interpolate_property(child, "opacity",
				1, 0, 0.3,
				Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	
