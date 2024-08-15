extends Resource

export (float) var gameStepDelay
export (float) var gameScoreMultiplier
export (float) var nextGameStepDelay
export (String, FILE) var scrollerScene
export (Resource) var symbolData
export (Array, Resource) var levels
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func GetLevel(levelId, subLevelId):
	for level in levels:
		if level.index == levelId:
			for subLevel in level.subLevels:
				if subLevel.index == subLevelId:
					return subLevel.levelScene
	return null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
