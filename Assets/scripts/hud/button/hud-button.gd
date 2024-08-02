extends Spatial

export (Types.HudElementId) var hudElementId
export (int) var index
var tween = null

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
	if tween != null:
		tween.kill()
		
	tween = create_tween()
	$Pivot.scale = Vector3(1.2, 1.2, 1.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property($Pivot, "scale", Vector3.ONE, 0.5)
	tween.play()
	Events.emit_signal("Click", self)

func Show():
	visible = true
	
func Hide():
	visible = false

func AnimateShow(style: String = ""):
	visible = true
	if tween != null:
		tween.kill()
	tween = create_tween()
	if style == "":
		$Pivot.scale = Vector3.ZERO
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($Pivot, "scale", Vector3.ONE, 0.3)
	elif style == "alpha":
		for child in $Pivot.get_children():
			child.opacity = 0
			tween.set_trans(Tween.TRANS_LINEAR)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(child, "opacity", 1, 0.3)
	tween.play()

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
	
