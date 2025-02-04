extends Resource
class_name PatternData

export (Array, Texture) var sprites
export (Types.SymbolMap) var symbolMap
export (Types.SymbolType) var symbolType
export (Array, Types.SymbolOffset) var symbolOffsets

var SymbolTypeData = {
	Types.SymbolType.Diamond : {
		"angles" : [Vector3(0, 0, 0), Vector3(0, -90, 0), Vector3(0, 90, 0), Vector3(0, 180, 0)],
		"offsets" : [Types.SymbolOffset.Normal, Types.SymbolOffset.X, Types.SymbolOffset.Y, Types.SymbolOffset.XY]
	},
	Types.SymbolType.DiagonalLeft : {
		"angles" : [Vector3(0, 180, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 180, 0)],
		"offsets" : [Types.SymbolOffset.Normal, Types.SymbolOffset.Y]
	},
	Types.SymbolType.DiagonalRight : {
		"angles" : [Vector3(0, -90, 0), Vector3(0, 90, 0), Vector3(0, 90, 0), Vector3(0, -90, 0)],
		"offsets" : [Types.SymbolOffset.Normal, Types.SymbolOffset.Y]
	},
	Types.SymbolType.ZigzagUp : {
		"angles" : [Vector3(0, 0, 0), Vector3(0, -90, 0), Vector3(0, 180, 0), Vector3(0, 90, 0)],
		"offsets" : [Types.SymbolOffset.Normal, Types.SymbolOffset.X, Types.SymbolOffset.Y]
	},
	Types.SymbolType.ZigzagLeft : {
		"angles" : [Vector3(0, 0, 0), Vector3(0, 180, 0), Vector3(0, 90, 0), Vector3(0, -90, 0)],
		"offsets" : [Types.SymbolOffset.Normal, Types.SymbolOffset.X, Types.SymbolOffset.Y]
	}
}

var SymbolOffsetData = {
	Types.SymbolOffset.Normal : [0, 1, 2, 3],
	Types.SymbolOffset.X : [1, 0, 3, 2],
	Types.SymbolOffset.Y : [2, 3, 0, 1],
	Types.SymbolOffset.XY: [3, 2, 1, 0]
}

var SymbolMapData = {
	Types.SymbolMap.Single : [0, 0, 0, 0],
	Types.SymbolMap.DoubleDiagonal : [0, 1, 1, 0],
	Types.SymbolMap.DoubleTop : [0, 0, 1, 1],
	Types.SymbolMap.DoubleBottom : [1, 1, 0, 0]
}
	
func GetGeneratedPatternData():
	var patterns = []
	match symbolMap:
		Types.SymbolMap.Single:
			var patternData = {}
			for sprite in sprites:
				var typeData = SymbolTypeData[symbolType]
				var mapData = SymbolMapData[symbolMap]
				for offset in symbolOffsets:
					patternData["sprites"] = []
					patternData["angles"] = []
					patternData["buttons"] = []
					for n in mapData.size():
						patternData.sprites.push_back(sprite)
					var offsetData = SymbolOffsetData[offset] 
					for i in typeData.angles.size():
						patternData.angles.push_back(typeData.angles[offsetData[i]])
					var buttons = GenerateButtons(symbolType, offset)
					patternData.buttons.append_array(buttons)
					patterns.push_back(patternData.duplicate())
					
		Types.SymbolMap.DoubleDiagonal, Types.SymbolMap.DoubleTop, Types.SymbolMap.DoubleBottom:
			var patternData = {}
			assert(sprites.size() > 1)
			var spritePairs = GetSpritePairs(sprites)
			for spritePair in spritePairs:
				var typeData = SymbolTypeData[symbolType]
				var mapData = SymbolMapData[symbolMap]
				for offset in symbolOffsets:
					patternData["sprites"] = []
					patternData["angles"] = []
					patternData["buttons"] = []
					for n in mapData.size():
						patternData.sprites.push_back(spritePair[mapData[n]])
					var offsetData = SymbolOffsetData[offset] 
					for i in typeData.angles.size():
						patternData.angles.push_back(typeData.angles[offsetData[i]])
					var buttons = GenerateButtons(symbolType, offset)
					patternData.buttons.append_array(buttons)
					patterns.push_back(patternData.duplicate())
	randomize()
	patterns.shuffle()
	return patterns
		
func GetSpritePairs(spritesArray):
	var spriteCompares = []
	var gUniqueDouble = []
	spriteCompares.append_array(spritesArray)
	for sprite in spritesArray:
		spriteCompares.erase(spriteCompares[0])
		for cSprite in spriteCompares:
			gUniqueDouble.push_back([sprite, cSprite])
			
	return gUniqueDouble

func GenerateButtons(bSymbolType, correctOffset):
	var buttons = []
	var button = {"angles": []}
	var typeData = SymbolTypeData[bSymbolType]
	var offsetData = SymbolOffsetData[correctOffset]
	
	for i in typeData.angles.size():
		button.angles.push_back(typeData.angles[offsetData[i]])
	buttons.push_back(button.duplicate())
		
	if symbolType == Types.SymbolType.DiagonalLeft:
		button = {
			"angles": []
		}
		var newTypeData = SymbolTypeData[Types.SymbolType.DiagonalRight]
		for i in newTypeData.angles.size():
			button.angles.push_back( newTypeData.angles[i] )
		buttons.push_back(button.duplicate())

		
		button = {
			"angles": []
		}
		var oppositeOffsetKey = typeData.offsets.duplicate()
		oppositeOffsetKey.erase(correctOffset)
		
		offsetData = SymbolOffsetData[oppositeOffsetKey.pick_random()]
		for i in typeData.angles.size():
			button.angles.push_back( typeData.angles[offsetData[i]] )
		buttons.push_back(button.duplicate())

	elif symbolType == Types.SymbolType.DiagonalRight:
		button = {
			"angles": []
		}
		offsetData = SymbolOffsetData[Types.SymbolOffset.Normal]
		var newTypeData = SymbolTypeData[Types.SymbolType.DiagonalLeft]
		for i in newTypeData.angles.size():
			button.angles.push_back( newTypeData.angles[i] )
		buttons.push_back(button.duplicate())
		
		button = {
			"angles": []
		}
		var oppositeOffsetKey = typeData.offsets.duplicate()
		oppositeOffsetKey.erase(correctOffset)
		
		offsetData = SymbolOffsetData[oppositeOffsetKey.pick_random()]
		for i in typeData.angles.size():
			button.angles.push_back( typeData.angles[offsetData[i]] )
		buttons.push_back(button.duplicate())
		
	else:
		var keys = SymbolOffsetData.keys()
		keys.erase(correctOffset)
		var randomRemove = keys.pick_random()
		keys.erase(randomRemove)
	
		for offset in keys:
			button = {
				"angles": []
			}
			offsetData = SymbolOffsetData[offset] 
			for i in typeData.angles.size():
				button.angles.push_back( typeData.angles[offsetData[i]] )
			buttons.push_back(button.duplicate())
		#
#	print("Buttons: ", symbolType, " ", buttons, "\n")
	randomize()
	buttons.shuffle()
	return buttons
