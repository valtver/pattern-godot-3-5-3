extends Spatial

signal AppMainMenu

var cameraTransform
var scroller
var gameStarted : bool = false
var grid = {}
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
	BreakRandomTiles(1)
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
	var tiles = scroller.nIsland.get_tree().get_nodes_in_group("tiles")
	for tile in tiles:
		if !tile.is_connected("inputClick", self, "OnTileClick"):
			tile.connect("inputClick", self, "OnTileClick")
	
func BreakRandomTiles(n):
	var tiles = scroller.nIsland.get_tree().get_nodes_in_group("tiles")
	var randIndecies = GetUniqueRandomInRange(0, tiles.size(), 2)
	for index in randIndecies:
		tiles[index].BreakSymbol()

func GetUniqueRandomInRange(a, b, count):
	var array = []
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for n in count:
		var randN = rng.randi_range(0, b-1)
		while randN in array:
			randN = rng.randi_range(0, b-1)
		array.append(randN)
	print(array)
	return array
		 
	
func OnTileClick(tile):
	tile.SymbolAction()
	BreakRandomTiles(1)
	
func StartGame():
	gameStarted = true

func _process(delta):
	if !gameStarted:
		return
	cameraTransform.position -= Vector3(0, 0, delta)
