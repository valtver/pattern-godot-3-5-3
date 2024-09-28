extends Node

enum AppState {
	NONE = -1,
	START = 0,
	UI = 1,
	GAME = 2,
	FIRST_START = 3
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

enum UiElementId {
	None = 0,
	UiButtonSettings = 1,
	UiButtonScrollerLeft = 2,
	UiButtonScrollerRight = 3,
	UiButtonBack = 4,
	UiButtonLevel = 5,
	UiButtonSubLevel = 6,
	UiButtonAbout = 7,
	UiButtonSound = 8,
	UiButtonMusic = 9,
	UiButtonAccept = 10,
	UiButtonDecline = 11
}

enum HudElementId {
	HudButtonStart = 0,
	HudButtonMenu = 1,
	HudButtonSymbol = 2,
	HudButtonReplay = 3,
	HudButtonHome = 4,
	HudButtonNext = 5,
	HudButtonTutorial = 6,
	HudButtonTutorialNext = 7
}

enum SymbolType {
	None = 0,
	Diamond = 1,
	DiagonalLeft = 2,
	DiagonalRight = 3,
	ZigzagUp = 4,
	ZigzagLeft = 5
}

enum SymbolOffset {
	Normal = 0,
	X = 1,
	Y = 2,
	XY = 3
}

enum SymbolMap {
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
