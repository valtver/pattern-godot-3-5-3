extends Spatial

onready var scoreLabel = $scoreLabel

func SetScore(value):
	var minutes = (value / 1000) / 60
	var seconds = (value / 1000) - minutes * 60;
	
	scoreLabel.text = "%02d:%02d" % [minutes, seconds]
		
func _ready():
	SetScore(Data.playerData.sessionTimeScore)
	Events.connect("ShowHudWinScreenScore", self, "OnHudWinScore")
	pass # Replace with function body.

func OnHudWinScore(tweenTime:= Data.gameData.nextGameStepDelay, reset:= false, addDelay:= 0.5):
	var scoreVal
	
	if reset:
		scoreVal = Data.playerData.sessionTimeScore * 100
	else:
		scoreVal = int(scoreLabel.text)
		
	var nextScoreVal = Data.playerData.sessionTimeScore
	var tween = create_tween().set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(self, "SetScore", scoreVal, nextScoreVal, tweenTime + addDelay)
	if not reset:
		var col = scoreLabel.modulate
		scoreLabel.modulate = Color.white
		tween.tween_property(scoreLabel, "modulate", col, tweenTime)
