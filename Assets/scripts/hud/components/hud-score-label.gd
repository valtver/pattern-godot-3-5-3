extends Spatial

onready var scoreLabel = $scoreLabel

func SetScore(value):
	scoreLabel.text = "%d" % value
	
func _ready():
	SetScore(Data.playerData.sessionTimeScore)
	Events.connect("ShowHudWinScreenScore", self, "OnHudWinScore")
	pass # Replace with function body.

func OnHudWinScore(tweenTime:= Data.gameData.nextGameStepDelay, reset:= false, addDelay:= 0.5):
	var scoreVal
	
	if reset:
		scoreVal = 0
	else:
		scoreVal = int(scoreLabel.text)
		
	var nextScoreVal = Data.playerData.sessionTimeScore
	var tween = create_tween().set_parallel(true)
	tween.tween_method(self, "SetScore", scoreVal, nextScoreVal, tweenTime + addDelay)
	if not reset:
		var col = scoreLabel.modulate
		scoreLabel.modulate = Color.white
		tween.tween_property(scoreLabel, "modulate", col, tweenTime)
