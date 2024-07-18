extends Resource

var SymbolTypes = {
	Types.SymbolType.Diamond : {
		"angles" : [Vector3(0, 0, 0), Vector3(0, -90, 0), Vector3(0, 90, 0), Vector3(0, 180, 0)],
		"offsets" : [Types.SubSymbolOffset.None, Types.SubSymbolOffset.X, Types.SubSymbolOffset.Y, Types.SubSymbolOffset.XY],
		"maps" : [Types.SubSymbolMap.Single, Types.SubSymbolMap.DoubleDiagonal, Types.SubSymbolMap.DoubleTop, Types.SubSymbolMap.DoubleBottom]
	},
	Types.SymbolType.DiagonalLeft : {
		"angles" : [Vector3(0, 180, 0), Vector3(0, 0, 0), Vector3(0, 0, 0), Vector3(0, 180, 0)],
		"offsets" : [Types.SubSymbolOffset.None, Types.SubSymbolOffset.Y],
		"maps" : [Types.SubSymbolMap.Single]
	},
	Types.SymbolType.DiagonalRight : {
		"angles" : [Vector3(0, -90, 0), Vector3(0, 90, 0), Vector3(0, 90, 0), Vector3(0, -90, 0)],
		"offsets" : [Types.SubSymbolOffset.None, Types.SubSymbolOffset.Y],
		"maps" : [Types.SubSymbolMap.Single]
	},
	Types.SymbolType.ZigzagUp : {
		"angles" : [Vector3(0, 0, 0), Vector3(0, -90, 0), Vector3(0, 180, 0), Vector3(0, 90, 0)],
		"offsets" : [Types.SubSymbolOffset.None, Types.SubSymbolOffset.X, Types.SubSymbolOffset.Y],
		"maps" : [Types.SubSymbolMap.Single, Types.SubSymbolMap.DoubleTop, Types.SubSymbolMap.DoubleBottom]
	},
	Types.SymbolType.ZigzagLeft : {
		"angles" : [Vector3(0, 0, 0), Vector3(0, 180, 0), Vector3(0, 90, 0), Vector3(0, -90, 0)],
		"offsets" : [Types.SubSymbolOffset.None, Types.SubSymbolOffset.X, Types.SubSymbolOffset.Y],
		"maps" : [Types.SubSymbolMap.Single, Types.SubSymbolMap.DoubleTop, Types.SubSymbolMap.DoubleBottom]
	}
}

var SubSymbolOffset = {
	Types.SubSymbolOffset.None : [0, 1, 2, 3],
	Types.SubSymbolOffset.X : [1, 0, 3, 2],
	Types.SubSymbolOffset.Y : [2, 3, 0, 1],
	Types.SubSymbolOffset.XY: [3, 2, 1, 0]
}

var SubSymbolMap = {
	Types.SubSymbolMap.Single : [0, 0, 0, 0],
	Types.SubSymbolMap.DoubleDiagonal : [0, 1, 1, 0],
	Types.SubSymbolMap.DoubleTop : [0, 0, 1, 1],
	Types.SubSymbolMap.DoubleBottom : [1, 1, 0, 0]
}
