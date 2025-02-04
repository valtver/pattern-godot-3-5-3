extends Spatial

var tween = null
var defaultRotation = Vector3(-90, 0, 0)
	
func UpdateSymbol(subSymbolAngles, subSymbolSprites):
	var children = $Pivot.get_children()
	children.append_array($Vfx.get_children())
	for child in children:
		child.rotation_degrees = defaultRotation
		child.rotation_degrees += subSymbolAngles[child.id]
		child.texture = subSymbolSprites[child.id]
	var background = $Background
	background.visible = (int(self.position.x + self.position.z) % 2)
	
func SetColor(color):
	var children = $Pivot.get_children()
	for child in children:
		child.modulate = color
		
func PlayJump():
	if tween != null:
		tween.kill()
	tween = create_tween()
	$Pivot.position = Vector3(0, 1, 0)
	tween.tween_property($Pivot, "position", Vector3(0, 0, 0), 0.3)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.play()
	return tween
		
func SetSymbolAlpha(val):
	var children = $Pivot.get_children()
	for child in children:
		if "id" in child:
			child.opacity = val
	
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
