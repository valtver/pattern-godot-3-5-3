tool
extends StaticBody

export (bool) var refresh = false

signal inputClick

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
			SetSymbolType(symbolType)
			refresh = false

func BreakSymbol():
	var children = get_tree().get_nodes_in_group("sub-symbol-group")
	for child in children:
		child.visibility = false

func SetSymbolType(type):
	var trs = SubSymbolTypeAngles[type]
	var children = get_tree().get_nodes_in_group("sub-symbol-group")
	for child in children:
		child.rotation_degrees = defaultRotation
		child.rotation_degrees += trs[child.id]
		
func InputClick():
	emit_signal("inputClick")
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
