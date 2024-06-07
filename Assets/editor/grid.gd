tool
extends Spatial

export var refresh = false
export (PackedScene) var gridObjectScene

export (int, 1, 3, 1) var visibilityHeight = 1
export (Types.gridSize) var gridWidth
export (Types.gridSize) var gridHeight
		
func _process(_delta):
	if Engine.is_editor_hint():
		if refresh:
			SetupGrid()
			refresh = false

func SetupGrid():
	for n in self.get_children():
		self.remove_child(n)
		n.free()
		
	for nHeight in gridHeight:
#		var rowNode = Position3D.new()
#		rowNode.name = "row-%s" % nHeight
#		self.add_child(rowNode)
#		rowNode.owner = get_tree().edited_scene_root
		
		for nWidth in gridWidth:
			var gridTile = gridObjectScene.instance()
			gridTile.idx = nWidth
			gridTile.idy = nHeight
			gridTile.name = "tile-%s" % nWidth + "-%s" % nHeight
			gridTile.position = Vector3(nWidth-gridWidth/2, 0, -nHeight)
			add_child(gridTile)
			gridTile.owner = get_tree().edited_scene_root
			gridTile.set_meta("_edit_group_", true)
			gridTile.refresh = true
			
#	var vizNotifier = VisibilityNotifier.new()
#	vizNotifier.aabb.size = Vector3(gridWidth, visibilityHeight, gridHeight)
#	vizNotifier.aabb.position = Vector3(-float(gridWidth)/2, 0, -float(gridHeight)/2)
#	self.add_child(vizNotifier)
#	vizNotifier.owner = get_tree().edited_scene_root
	
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
