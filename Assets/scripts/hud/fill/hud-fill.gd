extends Node

const scoreDigitLength = 0

onready var fillTexture = $fillTexture
onready var scoreLabel = $scoreLabel
onready var scoreLabelZero = $scoreLabelZero
onready var animationPlayer = $AnimationPlayer
onready var animatedScore = $animatedScore
onready var safeColor = Color(0.43, 0.73, 0.31)
onready var critColor = Color(0.69, 0.21, 0.36)
onready var winColor = Color(0.87, 1.0, 0.7)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	RestoreUpdateFill(1.0)
	SetScore(Data.playerData.sessionScore)
	Events.connect("HudTimerUpdate", self, "UpdateFill")
	Events.connect("HudWinScore", self, "OnHudWinScore")
	pass # Replace with function body.

func SetScore(value):
	if value == 0:
		scoreLabel.text = ""
	else:
		scoreLabel.text = "%d" % value

	scoreLabelZero.text = "%0*d" % [scoreDigitLength, value]
	
func AnimateScore(value):
	pass

func UpdateFill(normalValue):
	var newWidth = fillTexture.texture.get_width() * normalValue
	fillTexture.region_rect.size = Vector2(newWidth, fillTexture.texture.get_height())
	fillTexture.modulate = safeColor.linear_interpolate(critColor, 1 - normalValue)
	
func RestoreUpdateFill(normalValue):
	var newWidth = fillTexture.texture.get_width() * normalValue
	fillTexture.region_rect.size = Vector2(newWidth, fillTexture.texture.get_height())
	fillTexture.modulate = safeColor.linear_interpolate(winColor, 1 - normalValue)
	
func OnHudWinScore():
	var fillWidth = fillTexture.region_rect.size.x / fillTexture.texture.get_width()
	var scoreVal = int(scoreLabel.text)
	var nextScoreVal = Data.playerData.sessionScore
	var scoreDif = Data.playerData.sessionScore - scoreVal
	var tween = create_tween().set_parallel(true)
	tween.tween_method(self, "SetScore", scoreVal, nextScoreVal, Data.gameData.nextGameStepDelay + 0.5)
	tween.tween_method(self, "RestoreUpdateFill", fillWidth, 0.0, Data.gameData.nextGameStepDelay)
	animatedScore.text = "+%d" % scoreDif
	animationPlayer.play("score-vfx")
	var col = scoreLabel.modulate
	scoreLabel.modulate = Color.white
	tween.tween_property(scoreLabel, "modulate", col, Data.gameData.nextGameStepDelay)
