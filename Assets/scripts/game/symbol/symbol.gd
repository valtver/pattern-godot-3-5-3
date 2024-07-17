tool
extends Spatial

export (bool) var refresh = false

signal inputClick

var state = Types.SymbolState.Fixed

export (Types.SymbolType) var symbolType	
var defaultRotation = Vector3(-90, 0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _process(_delta):
	if Engine.is_editor_hint():
		if refresh:
			Update()
			refresh = false

func Break():
	state = Types.SymbolState.Broken
	symbolType = Types.SymbolType.None
	Update()
	
func Fix():
	state = Types.SymbolState.Fixed
	symbolType = Data.sessionData.activeSymbol
	Update()
	
func Change():
	symbolType = Data.sessionData.activeSymbol
	Update()
	
func Update():
	var trs = Data.gameData.symbolData.SymbolType[symbolType]["angles"]
	var children = $Pivot.get_children()
	for child in children:
		child.rotation_degrees = defaultRotation
		child.rotation_degrees += trs[child.id]
			
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
