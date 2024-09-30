tool
extends Spatial

const PATH_TILE_Y_OFFSET = 0.02

var tween = null

export var refresh = false
export (PackedScene) var symbolBackground
export (PackedScene) var symbolScene

export var idx: int
export var idy: int

onready var symbol = get_node_or_null("symbol")
onready var symbolBg = get_node_or_null("symbolBackground")

func _process(_delta):
	if Engine.is_editor_hint():
		if refresh:
			SetupTile()
			refresh = false
			
func SetupTile():		
	ProcessSymbol()
	ProcessSymbolBackground()
	ProcessPlaceholder()
	
func ProcessSymbol():
	var node = get_node_or_null("symbol")
	if symbolScene != null:
		if node == null:
			var symbolInstance = symbolScene.instance()
			symbolInstance.name = "symbol"
			self.add_child(symbolInstance)
			symbolInstance.owner = get_tree().edited_scene_root
	else:
		if node != null:
			node.free()
			
func ProcessSymbolBackground():
	var isValid = false
	var node = get_node_or_null("symbolBackground")
	if (idx % 2 == 0) == (idy % 2 == 0):
		isValid = true;
	
	if symbolBackground != null:
		if node == null:
			if isValid:
				var symbolBackgroundInstance = symbolBackground.instance()
				symbolBackgroundInstance.name = "symbolBackground"
				self.add_child(symbolBackgroundInstance)
				symbolBackgroundInstance.owner = get_tree().edited_scene_root
		elif node != null:
			if !isValid:
				node.free()
	else:
		if node != null:
			node.free()
												
func ProcessPlaceholder():
	var children = self.get_children()
	var node = get_node_or_null("placeholder")
	if symbolScene || symbolBackground:
		if node != null:
			node.free()
			return
	if children.size() > 1:
		if node != null:
			node.free()
			return
	if children.size() == 0:
		var placeholderInstance = preload("res://Assets/placeholder/placeholder.tscn").instance()
		placeholderInstance.name = "placeholder"
		self.add_child(placeholderInstance)
		placeholderInstance.owner = get_tree().edited_scene_root
		
func SymbolFadeIn(timer: float = 0, chain: bool = false):
	if symbol == null:
		return
	if symbolBg != null:
		symbolBg.visible = true
	symbol.visible = true
	symbol.SetSymbolAlpha(0)
	
	if tween != null and not chain:
		tween.kill()
	if not chain:
		tween = create_tween()
		return tween.tween_method(symbol, "SetSymbolAlpha", 0.0, 1.0, timer + 0.3)
	if chain:
		return tween.chain().tween_method(symbol, "SetSymbolAlpha", 0.0, 1.0, timer + 0.3)

func SymbolFadeOut(timer: float = 0, chain: bool = false):
	if symbol == null:
		return
	if symbolBg != null:
		symbolBg.visible = true
	symbol.visible = true
	symbol.SetSymbolAlpha(1)
	
	if tween != null and not chain:
		tween.kill()
	if not chain:
		tween = create_tween()
		return tween.tween_method(symbol, "SetSymbolAlpha", 1.0, 0.0, timer)
	if chain:
		return tween.chain().tween_method(symbol, "SetSymbolAlpha", 1.0, 0.0, timer)
				
func OnClick():
	pass

				
func Reset():
	pass
			
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
