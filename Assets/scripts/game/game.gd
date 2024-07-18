extends Spatial

signal AppMainMenu

var gameSteps = []

var tiles
var cameraTransform
var scroller

var gameStarted : bool = false
const BREAK_DISTANCE = 3
const FIXES_PER_PATTERN = 5

func _ready():
	Init()
	StartGame()
	pass # Replace with function body.

func Init():
	Data.playerData.progressionStep = 0
	Data.playerData.gameStep = 0
	cameraTransform = get_viewport().get_camera().get_parent()
	InitScroller()
	gameSteps = GenerateGameData(Data.playerData.progressionStep)

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
#	print("Singles: ", gUniqueSingle.size(), "\nDoubles: ", gUniqueDouble.size())
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
				#generate buttons options ahead
				step["buttons"] = []
				step["buttons"].append_array(GenerateButtons(symbolType, offset))
				gameSteps.push_back(step.duplicate())
		gameSteps.shuffle()
	print(gameSteps.size())
	return gameSteps

func GenerateButtons(symbolType, correctOffset):
	var symbolData = Data.gameData.symbolData.SymbolTypes[symbolType]
	var buttons = []
	
	var button = {
		"angles": []
	}
	var offsetData = Data.gameData.symbolData.SubSymbolOffset[correctOffset]
	for i in symbolData["angles"].size():
		button["angles"].push_back( symbolData["angles"][offsetData[i]] )
	buttons.push_back(button.duplicate())
		
	if symbolType == Types.SymbolType.DiagonalLeft:
		button = {
			"angles": []
		}
		var newSymbolData = Data.gameData.symbolData.SymbolTypes[Types.SymbolType.DiagonalRight]
		for i in newSymbolData["angles"].size():
			button["angles"].push_back( newSymbolData["angles"][i] )
		buttons.push_back(button.duplicate())

		
		button = {
			"angles": []
		}
		offsetData = Data.gameData.symbolData.SubSymbolOffset[Types.SubSymbolOffset.X]
		for i in newSymbolData["angles"].size():
			button["angles"].push_back( newSymbolData["angles"][offsetData[i]] )
		buttons.push_back(button.duplicate())

	elif symbolType == Types.SymbolType.DiagonalRight:
		button = {
			"angles": []
		}
		offsetData = Data.gameData.symbolData.SubSymbolOffset[Types.SubSymbolOffset.None]
		var newSymbolData = Data.gameData.symbolData.SymbolTypes[Types.SymbolType.DiagonalLeft]
		for i in newSymbolData["angles"].size():
			button["angles"].push_back( newSymbolData["angles"][i] )
		buttons.push_back(button.duplicate())
		
		button = {
			"angles": []
		}
		offsetData = Data.gameData.symbolData.SubSymbolOffset[Types.SubSymbolOffset.X]
		for i in newSymbolData["angles"].size():
			button["angles"].push_back( newSymbolData["angles"][offsetData[i]] )
		buttons.push_back(button.duplicate())
		
	else:
		var keys = Data.gameData.symbolData.SubSymbolOffset.keys()
		keys.erase(correctOffset)
		var randomRemove = keys.pick_random()
		keys.erase(randomRemove)
	
		for offset in keys:
			button = {
				"angles": []
			}
			offsetData = Data.gameData.symbolData.SubSymbolOffset[offset] 
			for i in symbolData["angles"].size():
				button["angles"].push_back( symbolData["angles"][offsetData[i]] )
			buttons.push_back(button.duplicate())
		#
#	print("Buttons: ", symbolType, " ", buttons, "\n")
	buttons.shuffle()
	return buttons

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
	Timeline.Delay(self, "NextPatternLoopEnd", 1.5)
	
func NextPatternLoopEnd():
	MoveToNextPattern()
	
func MoveToNextPattern():
	Data.playerData.gameStep += 1
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
	for tile in tiles:
		tile.symbol.UpdateSymbol(
			gameSteps[Data.playerData.gameStep]["angles"],
			gameSteps[Data.playerData.gameStep]["sprites"]
		)
	var button = get_node("../CameraPivot/Camera/symbol-1-button")
	button.UpdateSymbol(
			gameSteps[Data.playerData.gameStep]["buttons"][0]["angles"],
			gameSteps[Data.playerData.gameStep]["sprites"]
		)
	button = get_node("../CameraPivot/Camera/symbol-2-button")
	button.UpdateSymbol(
			gameSteps[Data.playerData.gameStep]["buttons"][1]["angles"],
			gameSteps[Data.playerData.gameStep]["sprites"]
		)
	button = get_node("../CameraPivot/Camera/symbol-3-button")
	button.UpdateSymbol(
			gameSteps[Data.playerData.gameStep]["buttons"][2]["angles"],
			gameSteps[Data.playerData.gameStep]["sprites"]
		)
	
	

