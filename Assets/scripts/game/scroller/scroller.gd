extends Node

var visibilityNotifiers = []
var currentTiles = []
var nTiles = []
var pTiles = []
var cIsland
var pIsland
var nIsland

func Init():
#	island = get_node_or_null("start")
#	if island == null:
#		print("Cant' init start island...")
#		return
#	pIsland = island.duplicate()
#	pIsland.position = island.position - Vector3.FORWARD * island.aabb.size.z
#	add_child(pIsland)
#	nIsland = island.duplicate()
#	nIsland.position = island.position + Vector3.FORWARD * island.aabb.size.z
#	add_child(nIsland)
#	SubScribeToNotifiers()
	pass
	
func AddFirstIsland(gameStepData):
	if cIsland == null:
		var editorIsland = get_node_or_null("start")
		if editorIsland == null:
			cIsland = Loader.GetResource(gameStepData.island).instance()
			add_child(cIsland)
			cIsland.position = Vector3.ZERO
		else:
			cIsland = editorIsland
		SortTiles()
		InitTiles(currentTiles)
	else:
		print("First island had been added already")
	
func AddNextIsland(gameStepData):
	if nIsland == null:
		nIsland = Loader.GetResource(gameStepData.island).instance()
		add_child(nIsland)
		nIsland.position = cIsland.position - Vector3.FORWARD * cIsland.aabb.size.z
		SortTiles()
		InitTiles(nTiles)
	else:
		print("Next island had been added already")
	
func SortTiles():
	var tiles = get_tree().get_nodes_in_group("tiles")
	for tile in tiles:
		if cIsland != null && cIsland.is_a_parent_of(tile):
			currentTiles.push_back(tile)
		if pIsland != null && pIsland.is_a_parent_of(tile):
			pTiles.push_back(tile)
		if nIsland != null && nIsland.is_a_parent_of(tile):
			nTiles.push_back(tile)

func InitTiles(tileSet):
	for tile in tileSet:
		tile.symbol.visible = false
		if tile.symbolBg != null:
			tile.symbolBg.visible = false
		tile.symbolPath.visible = false

#func OnVisibilityChanged(notifier):
#	if notifier == pIsland:
#		for tile in tiles:
#			if pIsland.is_a_parent_of(tile):
#				tile.Reset()
#
#		var OLDpIsland = pIsland
#		pIsland = island
#		island = nIsland
#		nIsland = OLDpIsland
#		nIsland.position = island.position + Vector3.FORWARD * island.aabb.size.z
#
#	elif notifier == nIsland:
#		var OLDnIsland = nIsland
#		nIsland = island
#		island = pIsland
#		pIsland = OLDnIsland
#		nIsland.position = island.position - Vector3.FORWARD * island.aabb.size.z
	
#func CheckVisibility():
#	if !pIsland.is_on_screen():
#		OnVisibilityChanged(pIsland)
		
func SubScribeToNotifiers():
	visibilityNotifiers.clear()
	visibilityNotifiers = get_tree().get_nodes_in_group("IslandVisibilityNotifiers")
	for notifier in visibilityNotifiers:
		if !notifier.is_connected("screen_exited", self, "OnVisibilityChanged"):
			Events.connect("screen_exited", self, "OnVisibilityChanged", [notifier])

