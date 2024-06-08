tool
extends Spatial

export var refresh = false
export (PackedScene) var symbolBackground
export (PackedScene) var symbol
export (PackedScene) var terrain

export var idx: int
export var idy: int

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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
	if symbol != null:
		if node == null:
			var symbolInstance = symbol.instance()
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
	if symbol || symbolBackground:
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
		
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
