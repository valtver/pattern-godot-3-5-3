extends Spatial

var defaultRotation = Vector3(-90, 0, 0)
	
func UpdateSymbol(subSymbolAngles, subSymbolSprites):
	var children = $Pivot.get_children()
	for child in children:
		child.rotation_degrees = defaultRotation
		child.rotation_degrees += subSymbolAngles[child.id]
		child.texture = Loader.GetResource(subSymbolSprites[child.id])
			
func PlayJump():
	var tween = get_node_or_null("JumpTween")
	if tween == null:
		return
	tween.interpolate_property($Pivot, "position",
		Vector3(0, 1, 0), Vector3(0, 0, 0), 0.3,
		Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()

	
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
