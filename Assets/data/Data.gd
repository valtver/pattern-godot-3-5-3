tool
extends Node

export (bool) var refresh

export (Resource) var appData
export (Resource) var uiData
export (Resource) var gameData
export (Resource) var playerData
export (Resource) var resourceData
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if Engine.editor_hint:
		if refresh:
			resourceData.uiResources.clear()
			for dir in resourceData.uiResDir:
				ParseDirToArray(dir, resourceData.uiResources)
			resourceData.gameResources.clear()
			for dir in resourceData.gameResDir:
				ParseDirToArray(dir, resourceData.gameResources)
			resourceData.hudResources.clear()
			for dir in resourceData.hudResDir:
				ParseDirToArray(dir, resourceData.hudResources)
			refresh = false
			property_list_changed_notify()
			

func ParseDirToArray(dirPath, destArray):
	var ignoreLines = [".import"]
	var dir = Directory.new()
	if dir.open(dirPath) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		for i in 20:
			var ignoreCount = 0
			if file_name == "":
#				print("I break here ", dirPath + file_name)
				break
			if dir.current_is_dir():
#				print("I dive here ", dirPath, file_name)
				ParseDirToArray(dirPath + file_name + "/", destArray)
			else:
				for line in ignoreLines:
					if line in file_name:
						ignoreCount += 1
				if ignoreCount < 1:
#					print("I found file here ", dirPath)
					destArray.push_back(dirPath + file_name)
			file_name = dir.get_next()

func GetGeneratedRuntimeGameData(subLevel):
	var gameSteps = []
	
	var gUniqueSingle = []
	var gUniqueDouble = []
	var spriteCompares = []
	
	spriteCompares.append_array(subLevel.sprites)
	gUniqueSingle.append_array(spriteCompares)
	for sprite in subLevel.sprites:
		spriteCompares.erase(spriteCompares[0])
		for cSprite in spriteCompares:
			gUniqueDouble.push_back([sprite, cSprite])
#	print("Singles: ", gUniqueSingle.size(), "\nDoubles: ", gUniqueDouble.size())
	#Pick an island
	var step = {}	
	#Singles and offsets
	for singleSprite in gUniqueSingle:
		for symbolType in subLevel.symbolTypes:
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
				#island
				step["island"] = []
				
				gameSteps.push_back(step.duplicate())
	
	randomize()
	gameSteps.shuffle()
	#AFTER SHUFFLE
	for i in gameSteps.size():
		if i == 0:
			gameSteps[i]["island"] = subLevel.startIsland
		else:
			gameSteps[i]["island"] = subLevel.islands.pick_random()
			
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
	randomize()
	buttons.shuffle()
	return buttons
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
