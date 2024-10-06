extends Resource

export (int, -1, 99) var selectedLevelIndex = -1
export (int, -1, 99) var selectedSubLevelIndex = -1
export (int) var sessionScore = 0
export (int) var sessionStars = 0
export (int) var sessionScoreLastStep = 0
export (int) var gameStep = 0
var selectedButton = null

func GenerateUnlockData():
	for level in Data.gameData.levels:
		unlocks[String(level.index)] = levelEntry.duplicate(true)
		for subLevel in level.subLevels:
			unlocks[String(level.index)][String(subLevel.index)] = subLevelEntry.duplicate(true)

	print(unlocks)	

func _ready():

	pass

var levelEntry = {
	"unlock": false
}

var subLevelEntry = {
	"unlock": false,
	"score": 0
}

var unlocks = {
	# "level": {
	# 	"0": {
	# 		"unlock": true,
	# 		"0": {
	# 			"unlock": true,
	# 			"score": 0
	# 		}
	# 	}
	# },
	# "bonus": [{
	# 	"index": 0
	# }]
}
