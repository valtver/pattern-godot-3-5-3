extends Resource

var SymbolTypes = {
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

var SymbolOffset = {
	Types.SymbolOffset.Normal : [0, 1, 2, 3],
	Types.SymbolOffset.X : [1, 0, 3, 2],
	Types.SymbolOffset.Y : [2, 3, 0, 1],
	Types.SymbolOffset.XY: [3, 2, 1, 0]
}

var SymbolMap = {
	Types.SymbolMap.Single : [0, 0, 0, 0],
	Types.SymbolMap.DoubleDiagonal : [0, 1, 1, 0],
	Types.SymbolMap.DoubleTop : [0, 0, 1, 1],
	Types.SymbolMap.DoubleBottom : [1, 1, 0, 0]
}
