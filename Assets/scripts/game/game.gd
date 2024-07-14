extends Spatial

signal AppMainMenu

var cameraTransform
var scroller
var gameStarted : bool = false
const BREAK_DISTANCE = 3
const FIXES_PER_PATTERN = 5

var symbolFixes = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Init()
	StartGame()
	pass # Replace with function body.

func Init():
	cameraTransform = get_viewport().get_camera().get_parent()
	InitScroller()
	SubscribeToTiles()
#	var selectedLevel = Data.playerData.selectedLevelIndex
#	var selectedSubLevel = Data.playerData.selectedSubLevelIndex
#	var level = Data.gameData.GetLevel(selectedLevel, selectedSubLevel);
#	if level == null:
#		print("Level ", selectedLevel, selectedSubLevel, " not found")
#		return
#
#	var levelString = "level-%s%s%s" % [selectedLevel, "-", selectedSubLevel];
#	var levelIsLoaded = (get_node_or_null(levelString) != null)
#	if levelIsLoaded:
#		print("Level ", selectedLevel, " is loaded already")
#		return
#	else:
#		var levelScene = Loader.GetResource(level).instance()
#		add_child(levelScene)
	

func InitScroller():
	scroller = get_node_or_null("Scroller")
	if scroller == null:
		scroller = Loader.GetResource(Data.gameData.scrollerScene).instance()
		add_child(scroller)
	scroller.Init()
	
func SubscribeToTiles():
	var tiles = get_tree().get_nodes_in_group("tiles")
	for tile in tiles:
		if !tile.is_connected("inputClick", self, "OnTileClick"):
			tile.connect("inputClick", self, "OnTileClick")
		if !tile.is_connected("symbolFix", self, "OnSymbolFix"):
			tile.connect("symbolFix", self, "OnSymbolFix")
		
func BreakRandomTiles(refTile, n):
	var allTiles = get_tree().get_nodes_in_group("tiles")
	var tiles = []
	for tile in allTiles:
		if tile.global_position.z == (refTile.global_position.z - BREAK_DISTANCE):
			tiles.append(tile)
	var randIndecies = Random.GetUniqueRandomInRange(0, tiles.size(), n)
	for index in randIndecies:
		tiles[index].BreakSymbol()
		for tile in allTiles:
			if tile.global_position.x == tiles[index].global_position.x && tile.global_position.z < tiles[index].global_position.z:
				tile.visible = false
				

func OnTileClick(tile):
	tile.Action()
	BreakRandomTiles(tile, 1)
	
func OnSymbolFix(fixTile):
	symbolFixes += 1
	if symbolFixes == 5:
		symbolFixes = 0
		PlayTileChangeWave(fixTile)
	var tiles = get_tree().get_nodes_in_group("tiles")
	for tile in tiles:
		if tile.global_position.x == fixTile.global_position.x:
			tile.visible = true
	
func PlayTileChangeWave(actionTile):
	var tiles = get_tree().get_nodes_in_group("tiles")
	var keys = actionTile.symbol.SubSymbolTypeAngles.keys();
	keys.pop_at(0)
	var randomKey = keys.pick_random()
	for tile in tiles:
		Data.sessionData.activeSymbol = randomKey
		tile.symbol.symbolType = randomKey
		tile.symbol.Update()
		var distance = actionTile.global_position.distance_to(tile.global_position)
		if distance < 50 && distance > 0:
			var delayTime = distance / 10.0
			Timeline.Delay(tile.symbol, "PlayJump", delayTime)
	
func StartGame():
	gameStarted = true

func _process(delta):
	if !gameStarted:
		return
	cameraTransform.position -= Vector3(0, 0, delta * 2)
