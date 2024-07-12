tool
extends Spatial

export (bool) var refresh = false

signal inputClick

var state = Types.SymbolState.Fixed

var SubSymbolTypeAngles = {
	Types.SymbolType.None : [Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 0, 0)],
	Types.SymbolType.Diamond : [Vector3(0, 0, 0), Vector3(0, -90, 0), Vector3(0, 90, 0), Vector3(0, 180, 0)],
	Types.SymbolType.DiagonalLeft : [Vector3(0, 180, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 180, 0)],
	Types.SymbolType.DiagonalRight : [Vector3(0, -90, 0), Vector3(0, 90, 0), Vector3(0, 90, 0), Vector3(0, -90, 0)],
	Types.SymbolType.ZigzagUp : [Vector3(0, 0, 0), Vector3(0, -90, 0), Vector3(0, 180, 0), Vector3(0, 90, 0)],
	Types.SymbolType.ZigzagDown : [Vector3(0, -90, 0), Vector3(0, 0, 0), Vector3(0, 90, 0), Vector3(0, 180, 0)]
}

export (Types.SymbolType) var symbolType	
var defaultRotation = Vector3(-90, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(_delta):
	if Engine.is_editor_hint():
		if refresh:
			SetSymbol()
			refresh = false

func BreakSymbol():
	symbolType = Types.SymbolType.ZigzagDown
	SetSymbol()
	

func SetSymbol():
	var trs = SubSymbolTypeAngles[symbolType]
	var children = $Pivot.get_children()
	for child in children:
		child.rotation_degrees = defaultRotation
		child.rotation_degrees += trs[child.id]
			
func PlayJump():
	var tween = get_node_or_null("JumpTween")
	if tween == null:
		return
	tween.interpolate_property($Pivot, "position",
		Vector3(0, 0.5, 0), Vector3(0, 0, 0), 0.25,
		Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()

	
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
