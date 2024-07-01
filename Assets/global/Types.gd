extends Node

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

enum SymbolType {
	None = 0,
	Diamond = 1,
	DiagonalLeft = 2,
	DiagonalRight = 3,
	ZigzagUp = 4,
	ZigzagDown = 5
}

enum gridSize {
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
}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
