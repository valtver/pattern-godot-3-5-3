extends Spatial

signal AppMainMenu

var progressionStep
var gameSteps = []

var tiles
var cameraTransform
var scroller

var gameStarted : bool = false
const BREAK_DISTANCE = 3
const FIXES_PER_PATTERN = 5

func _ready():
	Init()
#	StartGame()
	pass # Replace with function body.

func Init():
	Data.playerData.progressionStep = 0
	cameraTransform = get_viewport().get_camera().get_parent()
	InitScroller()
	GenerateGameData(Data.playerData.progressionStep)

func InitScroller():
	scroller = get_node_or_null("Scroller")
	if scroller == null:
		scroller = Loader.GetResource(Data.gameData.scrollerScene).instance()
		add_child(scroller)
	scroller.Init()
	
func GenerateGameData(progressionStep):
	if progressionStep > Data.gameData.progressionData.size() - 1:
		print("No Data Left")
		return
	var gUniqueSingle = []
	var gUniqueDouble = []
	
	var spriteCompares = []
	spriteCompares.append_array(Data.gameData.progressionData[progressionStep].sprites)
	gUniqueSingle.append_array(spriteCompares)
	for sprite in Data.gameData.progressionData[progressionStep].sprites:
		spriteCompares.erase(spriteCompares[0])
		for cSprite in spriteCompares:
			gUniqueDouble.push_back([sprite, cSprite])
	print("Singles: ", gUniqueSingle.size(), "\nDoubles: ", gUniqueDouble.size())
	#Singles and offsets
	var step = {}
	for singleSprite in gUniqueSingle:
		for symbolType in Data.gameData.progressionData[progressionStep].symbolTypes:
			var symbolData = Data.gameData.symbolData.SymbolTypes[symbolType]
			for map in symbolData["maps"]:
				if map == Types.SubSymbolMap.Single:
					step["sprites"] = []
					for n in Data.gameData.symbolData.SubSymbolMap[map].size():
						step["sprites"].push_back(singleSprite)
			for offset in symbolData["offsets"]:
				var offsetData = Data.gameData.symbolData.SubSymbolOffset[offset] 
				step["angles"] = []
				for i in symbolData["angles"].size():
					step["angles"].push_back( symbolData["angles"][offsetData[i]] )
				gameSteps.push_back(step.duplicate())
			print(gameSteps)
			return
				
				
				
#		var step = {
#			"angles": 
#		}
#		gameSteps.push_back(step)

func StartGame():
	gameStarted = true
	MoveToNextPattern()
	
func NextPatternLoopStart():	
	var tween = get_node_or_null("Tween")
	if tween == null:
		tween = Tween.new()
		add_child(tween)
	var startCameraPos = cameraTransform.position
	var endCameraPos = cameraTransform.position + Vector3.FORWARD * 8
	tween.interpolate_property(cameraTransform, "position",
		startCameraPos, endCameraPos, 5.0,
		Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	tween.start()
	Timeline.Delay(self, "NextPatternLoopEnd", 5.0)
	
func NextPatternLoopEnd():
	MoveToNextPattern()
	
func MoveToNextPattern():
	var tween = get_node_or_null("Tween")
	if tween == null:
		tween = Tween.new()
		add_child(tween)
	var startCameraPos = cameraTransform.position
	var endCameraPos = cameraTransform.position + Vector3.FORWARD * 16
	tween.interpolate_property(cameraTransform, "position",
		startCameraPos, endCameraPos, 1.5,
		Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
	tween.start()
	Timeline.Delay(self, "NextPatternLoopStart", 1.5)
	Timeline.Delay(self, "UpdateSymbols", 0.75)
	
func UpdateSymbols():
	var tiles = get_tree().get_nodes_in_group("tiles")
	var keys = Data.gameData.symbolData.SymbolType.keys();
	keys.pop_at(0)
	var randomKey = keys.pick_random()
	for tile in tiles:
		Data.sessionData.activeSymbol = randomKey
		tile.symbol.symbolType = randomKey
		tile.symbol.Update()
	keys.pop_at(keys.find(randomKey, 0))
	var randOption = keys.pick_random()
	var button = get_node("../CameraPivot/Camera/symbol-1-button")
	button.symbolType = randOption
	button.Update()
	keys.pop_at(keys.find(randOption, 0))
	randOption = keys.pick_random()
	button = get_node("../CameraPivot/Camera/symbol-2-button")
	button.symbolType = randOption
	button.Update()
	keys.pop_at(keys.find(randOption, 0))
	randOption = keys.pick_random()
	button = get_node("../CameraPivot/Camera/symbol-3-button")
	button.symbolType = randOption
	button.Update()
	
	

