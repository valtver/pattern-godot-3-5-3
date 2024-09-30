extends Node

var visibilityNotifiers = []

var cTiles = []
var cCompletes = []

var nTiles = []
var nCompletes = []

var pTiles = []
var pCompletes = []

var pIsland = null
var cIsland = null
var nIsland = null

var pIslandCache = []

func Init():
	visibilityNotifiers = []
	cTiles = []
	cCompletes = []
	nTiles = []
	nCompletes = []
	pTiles = []
	pCompletes = []
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
		InitCompletes(cCompletes)
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
	InitCompletes(cCompletes)
	
	
func AddLastIsland():
	pIsland = cIsland
	cIsland = Loader.GetResource( 
		Data.gameData.levels[Data.playerData.selectedLevelIndex].subLevels[Data.playerData.selectedSubLevelIndex].endIsland
		).instance()
	add_child(cIsland)
	cIsland.position = pIsland.position + Vector3.FORWARD * pIsland.aabb.size.z
	SortTiles()
	InitTiles(cTiles)
	InitCompletes(cCompletes)
	pass
	
func SortTiles():
	var tiles = get_tree().get_nodes_in_group("tiles")
	var completes = get_tree().get_nodes_in_group("completes")
	cTiles = []
	cCompletes = []
	pTiles = []
	pCompletes = []
	nTiles = []
	nCompletes = []
	
	for tile in tiles:
		if cIsland != null:
			if cIsland.is_a_parent_of(tile):
				cTiles.push_back(tile)
		elif pIsland != null:
			if pIsland.is_a_parent_of(tile):
				pTiles.push_back(tile)
		elif nIsland != null:
			if nIsland.is_a_parent_of(tile):
				nTiles.push_back(tile)
	
	for complete in completes:
		if cIsland != null:
			if cIsland.is_a_parent_of(complete):
				cCompletes.push_back(complete)
		elif pIsland != null:
			if pIsland.is_a_parent_of(complete):
				pCompletes.push_back(complete)
		elif nIsland != null:
			if nIsland.is_a_parent_of(complete):
				nCompletes.push_back(complete)

func InitTiles(tileSet):
	for tile in tileSet:
		tile.symbol.visible = false
		if tile.symbolBg != null:
			tile.symbolBg.visible = false

func InitCompletes(completeSet):
	for comp in completeSet:
		comp.visible = false

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

