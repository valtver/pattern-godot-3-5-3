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
			resourceData.uiResources = []
			for dir in resourceData.uiResDir:
				ParseDirToArray(dir, resourceData.uiResources)
			resourceData.gameResources = []
			for dir in resourceData.gameResDir:
				ParseDirToArray(dir, resourceData.gameResources)
			resourceData.hudResources = []
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
		
	for pattern in subLevel.patterns:
		match pattern.symbolMap:
			
			Types.SymbolMap.Single:
				var step = {}
				for sprite in pattern.sprites:
					var typeData = Data.gameData.symbolData.SymbolTypes[pattern.symbolType]
					var mapData = Data.gameData.symbolData.SymbolMap[pattern.symbolMap]
					for offset in pattern.symbolOffsets:
						step["sprites"] = []
						step["angles"] = []
						step["buttons"] = []
						step["island"] = ""
						step["bonus"] = ""
						for n in mapData.size():
							step["sprites"].push_back(sprite)
						var offsetData = Data.gameData.symbolData.SymbolOffset[offset] 
						for i in typeData["angles"].size():
							step["angles"].push_back(typeData["angles"][offsetData[i]])
						var buttons = GenerateButtons(pattern.symbolType, offset)
						step["buttons"].append_array(buttons)
						gameSteps.push_back(step.duplicate())
						
			Types.SymbolMap.DoubleDiagonal, Types.SymbolMap.DoubleTop, Types.SymbolMap.DoubleBottom:
				var step = {}
				assert(pattern.sprites.size() > 1)
				var spritePairs = GetSpritePairs(pattern.sprites)
				for spritePair in spritePairs:
					var typeData = Data.gameData.symbolData.SymbolTypes[pattern.symbolType]
					var mapData = Data.gameData.symbolData.SymbolMap[pattern.symbolMap]
					for offset in pattern.symbolOffsets:
						step["sprites"] = []
						step["angles"] = []
						step["buttons"] = []
						step["island"] = ""
						step["bonus"] = ""
						for n in mapData.size():
							step["sprites"].push_back(spritePair[mapData[n]])
						var offsetData = Data.gameData.symbolData.SymbolOffset[offset] 
						for i in typeData["angles"].size():
							step["angles"].push_back(typeData["angles"][offsetData[i]])
						var buttons = GenerateButtons(pattern.symbolType, offset)
						step["buttons"].append_array(buttons)
						gameSteps.push_back(step.duplicate())
				
	randomize()
	gameSteps.shuffle()
	
	var rndGen = RandomNumberGenerator.new()
	
	for i in gameSteps.size():
		if i == 0:
			gameSteps[i]["island"] = subLevel.startIsland
			gameSteps[i]["bonus"] = ""
			gameSteps[i]["bonusDelay"] = rndGen.randf_range(0.0, subLevel.bonusDelay)
		else:
			gameSteps[i]["island"] = subLevel.islands.pick_random()
			gameSteps[i]["bonus"] = GetSubLevelBonusByRandom(subLevel, rndGen)
			gameSteps[i]["bonusDelay"] = rndGen.randf_range(0.0, subLevel.bonusDelay)
			
	print(gameSteps.size(), " steps generated")
	return gameSteps

func GetSpritePairs(spritesArray):
	var spriteCompares = []
	var gUniqueDouble = []
	spriteCompares.append_array(spritesArray)
	for sprite in spritesArray:
		spriteCompares.erase(spriteCompares[0])
		for cSprite in spriteCompares:
			gUniqueDouble.push_back([sprite, cSprite])
			
	return gUniqueDouble

func GetSubLevelBonusByRandom(subLevelData, randomGen):
	if subLevelData.bonusChance == 0.0:
		return ""
	
	randomGen.randomize()
	var candidate = ""
	var randomBonusChance = randomGen.randf_range(0.0, 1.0)
	
	if randomBonusChance > 0 and randomBonusChance <= subLevelData.bonusChance:
		# Okay we can choose the bonus now
		var randomBonusChoiceChance = randomGen.randf_range(0.0, 1.0)
		for bonusData in subLevelData.bonuses:
			var lastDistance = 1.0
			if bonusData.chance > 0 and bonusData.chance <= randomBonusChoiceChance:
				var nextDistance = randomBonusChoiceChance - bonusData.chance
				if nextDistance < lastDistance:
					candidate = bonusData.bonusScene
					lastDistance = nextDistance
	
	return candidate
				
		
		
				
			

func GenerateButtons(symbolType, correctOffset):
	var buttons = []
	var button = {"angles": []}
	var typeData = Data.gameData.symbolData.SymbolTypes[symbolType]
	var offsetData = Data.gameData.symbolData.SymbolOffset[correctOffset]
	
	for i in typeData["angles"].size():
		button["angles"].push_back(typeData["angles"][offsetData[i]])
	buttons.push_back(button.duplicate())
		
	if symbolType == Types.SymbolType.DiagonalLeft:
		button = {
			"angles": []
		}
		var newTypeData = Data.gameData.symbolData.SymbolTypes[Types.SymbolType.DiagonalRight]
		for i in newTypeData["angles"].size():
			button["angles"].push_back( newTypeData["angles"][i] )
		buttons.push_back(button.duplicate())

		
		button = {
			"angles": []
		}
		offsetData = Data.gameData.symbolData.SymbolOffset[Types.SymbolOffset.X]
		for i in newTypeData["angles"].size():
			button["angles"].push_back( newTypeData["angles"][offsetData[i]] )
		buttons.push_back(button.duplicate())

	elif symbolType == Types.SymbolType.DiagonalRight:
		button = {
			"angles": []
		}
		offsetData = Data.gameData.symbolData.SymbolOffset[Types.SymbolOffset.Normal]
		var newTypeData = Data.gameData.symbolData.SymbolTypes[Types.SymbolType.DiagonalLeft]
		for i in newTypeData["angles"].size():
			button["angles"].push_back( newTypeData["angles"][i] )
		buttons.push_back(button.duplicate())
		
		button = {
			"angles": []
		}
		offsetData = Data.gameData.symbolData.SymbolOffset[Types.SymbolOffset.X]
		for i in newTypeData["angles"].size():
			button["angles"].push_back( newTypeData["angles"][offsetData[i]] )
		buttons.push_back(button.duplicate())
		
	else:
		var keys = Data.gameData.symbolData.SymbolOffset.keys()
		keys.erase(correctOffset)
		var randomRemove = keys.pick_random()
		keys.erase(randomRemove)
	
		for offset in keys:
			button = {
				"angles": []
			}
			offsetData = Data.gameData.symbolData.SymbolOffset[offset] 
			for i in typeData["angles"].size():
				button["angles"].push_back( typeData["angles"][offsetData[i]] )
			buttons.push_back(button.duplicate())
		#
#	print("Buttons: ", symbolType, " ", buttons, "\n")
	randomize()
	buttons.shuffle()
	return buttons
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
