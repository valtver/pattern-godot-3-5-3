extends Spatial

export (Types.HudElementId) var hudElementId
export (int) var index
export (bool) var active = true setget activeSet, activeGet

func activeSet(val):
	var children = $Pivot.get_children()
	for child in children:
		if val:
			child.modulate.a = 1.0
		else:
			child.modulate.a = 0.25
	active = val
	
func activeGet():
	return active

var tween = null

var defaultRotation = Vector3(-90, 0, 0)

func UpdateSymbol(subSymbolAngles, subSymbolSprites):
	var children = $Pivot/SubPivot/ClickFace.get_children()
	for child in children:
		if "id" in child:
			child.rotation_degrees = defaultRotation
			child.rotation_degrees += subSymbolAngles[child.id]
			child.texture = subSymbolSprites[child.id]
			
func GetSymbolAngles():
	var angles = []
	angles.resize(4)
	var children = $Pivot/SubPivot/ClickFace.get_children()
	for child in children:
		if "id" in child:
			angles[child.id] = Vector3.UP * child.rotation_degrees
	
	return angles 

func AnimateSuccessClick():
	var animationPlayer = get_node_or_null("AnimationPlayer")
	if animationPlayer != null:
		animationPlayer.play("click-success")
	
func AnimateFailClick():
	var animationPlayer = get_node_or_null("AnimationPlayer")
	if animationPlayer != null:
		animationPlayer.play("click-fail")

func OnClick():
	var animationPlayer = get_node_or_null("AnimationPlayer")
	if animationPlayer != null:
		pass
	else:
		if tween != null:
			tween.kill()
		tween = create_tween()
		$Pivot.scale = Vector3(1.2, 1.2, 1.2)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property($Pivot, "scale", Vector3.ONE, 0.5)
		tween.play()
		
	if active:
		Events.emit_signal("Click", self)
	else:
		Events.emit_signal("InactiveClick", self)
		
func Show():
	visible = true
	
func Hide():
	visible = false

func AnimateShow(style: String = ""):
	var animationPlayer = get_node_or_null("AnimationPlayer")
	if animationPlayer != null:
		animationPlayer.play("RESET")
	visible = true
	if tween != null:
		tween.kill()
	if style == "":
		tween = create_tween()
		$Pivot.scale = Vector3.ZERO
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($Pivot, "scale", Vector3.ONE, 0.3)
	elif style == "alpha":
		for child in $Pivot.get_children():
			tween = create_tween()
			child.opacity = 0
			tween.set_trans(Tween.TRANS_LINEAR)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(child, "opacity", 1, 0.3)

	return tween

func AnimateHide(style: String = ""):
	visible = true
	if tween != null:
		tween.kill()
	tween = create_tween()
	if style == "":
		$Pivot.scale = Vector3.ONE
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property($Pivot, "scale", Vector3.ZERO, 0.3)
	elif style == "alpha":
		for child in $Pivot.get_children():
			child.opacity = 1
			tween.set_trans(Tween.TRANS_LINEAR)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(child, "opacity", 0, 0.3)

	return tween
	
