extends Node

var visibilityNotifiers = []

var cTiles = []
var cCompleters = []
var cBonuses = []

var nTiles = []
var nCompleters = []
var nBonuses = []

var pTiles = []
var pCompleters = []
var pBonuses = []

var pIsland = null
var cIsland = null
var nIsland = null

var pIslandCache = []

func Init():
	visibilityNotifiers = []
	cTiles = []
	cCompleters = []
	nTiles = []
	nCompleters = []
	pTiles = []
	pCompleters = []
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
		InitCompletes(cCompleters)
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
	InitCompletes(cCompleters)
	InitBonuses(cBonuses, gameStepData)
	
func AddLastIsland():
	pIsland = cIsland
	cIsland = Loader.GetResource( 
		Data.gameData.levels[Data.playerData.selectedLevelIndex].subLevels[Data.playerData.selectedSubLevelIndex].endIsland
		).instance()
	add_child(cIsland)
	cIsland.position = pIsland.position + Vector3.FORWARD * pIsland.aabb.size.z
	SortTiles()
	InitTiles(cTiles)
	InitCompletes(cCompleters)

	
func SortTiles():
	var tiles = get_tree().get_nodes_in_group("tiles")
	var completes = get_tree().get_nodes_in_group("completes")
	var bonuses = get_tree().get_nodes_in_group("bonuses")
	cTiles = []
	cCompleters = []
	cBonuses = []
	pTiles = []
	pCompleters = []
	pBonuses = []
	nTiles = []
	nCompleters = []
	nBonuses = []
	
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
				cCompleters.push_back(complete)
		elif pIsland != null:
			if pIsland.is_a_parent_of(complete):
				pCompleters.push_back(complete)
		elif nIsland != null:
			if nIsland.is_a_parent_of(complete):
				nCompleters.push_back(complete)
	
	for bonus in bonuses:
		if cIsland != null:
			if cIsland.is_a_parent_of(bonus):
				cBonuses.push_back(bonus)
		elif pIsland != null:
			if pIsland.is_a_parent_of(bonus):
				pBonuses.push_back(bonus)
		elif nIsland != null:
			if nIsland.is_a_parent_of(bonus):
				nBonuses.push_back(bonus)

func InitTiles(tileSet):
	for tile in tileSet:
		tile.symbol.visible = false
		if tile.symbolBg != null:
			tile.symbolBg.visible = false

func InitCompletes(completeSet):
	for comp in completeSet:
		comp.visible = false

func InitBonuses(bonusSet, gameStepData):
	if gameStepData.bonus == "":
		return
	randomize()
	var bonusSpawnPoint = bonusSet.pick_random()
	var bonus = Loader.GetResource(gameStepData.bonus).instance()
	bonusSpawnPoint.add_child(bonus)
	bonus.visible = false
	
func SpawnBonus():
	for bonusSpawnPoint in cBonuses:
		for bonus in bonusSpawnPoint.get_children():
			bonus.PlayBonus()

func OnVisibilityChanged(notifier):
	notifier.queue_free()
	pIslandCache.erase(notifier)
	pass
		

