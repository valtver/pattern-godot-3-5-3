extends Node

var visibilityNotifiers = []
var cTiles = []
var nTiles = []
var pTiles = []
var pIsland = null
var cIsland = null
var nIsland = null

var pIslandCache = []

func Init():
	visibilityNotifiers = []
	cTiles = []
	nTiles = []
	pTiles = []
	pIsland = null
	cIsland = null
	nIsland = null
	pIslandCache = []
	for child in get_children():
		child.free()
		
func AddFirstIsland():
	if cIsland == null:
		var editorIsland = get_node_or_null("start")
		if editorIsland == null:
			cIsland = Loader.GetResource(
				Data.gameData.levels[Data.playerData.selectedLevelIndex].subLevels[Data.playerData.selectedSubLevelIndex].startIsland
			).instance()
			add_child(cIsland)
			cIsland.position = Vector3.ZERO
		else:
			cIsland = editorIsland
		SortTiles()
		InitTiles(cTiles)
	return cIsland
	
	
func AddNextIsland(gameStepData):
	if pIsland != null:
		pIslandCache.push_back(pIsland)
		pIsland.connect("screen_exited", self, "OnVisibilityChanged", [pIsland])
	
	pIsland = cIsland
	cIsland = Loader.GetResource(gameStepData.island).instance()
	add_child(cIsland)
	cIsland.position = pIsland.position + Vector3.FORWARD * pIsland.aabb.size.z
	SortTiles()
	InitTiles(cTiles)
	
	
func AddLastIsland():
	pIsland = cIsland
	cIsland = Loader.GetResource( 
		Data.gameData.levels[Data.playerData.selectedLevelIndex].subLevels[Data.playerData.selectedSubLevelIndex].endIsland
		).instance()
	add_child(cIsland)
	cIsland.position = pIsland.position + Vector3.FORWARD * pIsland.aabb.size.z
	SortTiles()
	InitTiles(cTiles)
	pass
	
func SortTiles():
	var tiles = get_tree().get_nodes_in_group("tiles")
	cTiles = []
	pTiles = []
	nTiles = []
	for tile in tiles:
		if cIsland != null && cIsland.is_a_parent_of(tile):
			cTiles.push_back(tile)
		if pIsland != null && pIsland.is_a_parent_of(tile):
			pTiles.push_back(tile)
		if nIsland != null && nIsland.is_a_parent_of(tile):
			nTiles.push_back(tile)

func InitTiles(tileSet):
	for tile in tileSet:
		if tile.symbol != null:
			tile.symbol.visible = false
		if tile.symbolBg != null:
			tile.symbolBg.visible = false
		if tile.symbolPath != null:
			tile.symbolPath.visible = false

func OnVisibilityChanged(notifier):
	notifier.queue_free()
	pIslandCache.erase(notifier)
	pass
		
func SubScribeToNotifiers():
	visibilityNotifiers.clear()
	visibilityNotifiers = get_tree().get_nodes_in_group("IslandVisibilityNotifiers")
	for notifier in visibilityNotifiers:
		if !notifier.is_connected("screen_exited", self, "OnVisibilityChanged"):
			Events.connect("screen_exited", self, "OnVisibilityChanged", [notifier])

