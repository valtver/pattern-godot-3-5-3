extends StaticBody

#export (Types.UiElementId) var uiElementId
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
	get_node("AnimationPlayer").play("UiButtonClick")
	if active:
		Events.emit_signal("Click", self)
	else:
		Events.emit_signal("InactiveClick", self)

func SetStars(starsNumber):
	var stars = [$"Pivot/Star-0", $"Pivot/Star-1", $"Pivot/Star-2"]
	for starIndex in stars.size():
		if starIndex < starsNumber:
			stars[starIndex].modulate = Color(0.235294, 0.098039, 0.015686)
		else:
			stars[starIndex].modulate = cachedActiveColors[stars[starIndex]]



	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
