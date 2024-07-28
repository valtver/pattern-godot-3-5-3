extends Node

enum AppState {
	START = 0,
	UI = 1,
	GAME = 2
}

enum LocId {
	en = 0,
	ru = 1
}

enum UiAnchor {
	None = 0,
	Top = 1,
	Bottom = 2
}

enum UiContentId {
	None = 0,
	Main = 1,
	Settings = 2,
	About = 3,
	SubLevel = 4
}

enum UiButtonId {
	None = 0,
	Settings = 1,
	ContentLeft = 2,
	ContentRight = 3,
	Back = 4,
	Level = 5,
	SubLevel = 6,
	About = 7,
	Sound = 8,
	Music = 9,
	Accept = 10,
	Decline = 11
}

enum HudElementId {
	HudButtonStart = 0,
	HudButtonMenu = 1,
	HudButtonSymbol = 2
}

enum SymbolType {
	None = 0,
	Diamond = 1,
	DiagonalLeft = 2,
	DiagonalRight = 3,
	ZigzagUp = 4,
	ZigzagLeft = 5
}

enum SubSymbolOffset {
	None = 0,
	X = 1,
	Y = 2,
	XY = 3
}

enum SubSymbolMap {
	Single = 0,
	DoubleDiagonal = 1,
	DoubleTop = 2,
	DoubleBottom = 3
}

enum SymbolState {
	Fixed = 0,
	Broken = 1
}

enum gridSize {
	_1 = 1,
	_2 = 2,
	_3 = 3,
	_4 = 4,
	_5 = 5,
	_6 = 6,
	_7 = 7,
	_8 = 8,
	_9 = 9,
	_10 = 10,
	_11 = 11
	_12 = 12
	_14 = 14
	_16 = 16
}
