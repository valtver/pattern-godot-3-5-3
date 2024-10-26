extends Node

const scoreDigitLength = 0

onready var levelIcon = $levelIcon
onready var levelLabel = $levelLabel
onready var fillTexture = $fillTexture

onready var animationPlayer = $"../../ManualAnimationPlayer"
onready var animatedScore = $animatedScore
onready var safeColor = Color(0.43, 0.73, 0.31)
onready var critColor = Color(0.69, 0.21, 0.36)
onready var winColor = Color(0.87, 1.0, 0.7)

func _ready():
	RestoreUpdateFill(1.0)
	SetLevelLabel(Data.playerData.selectedSubLevelIndex)
	Events.connect("HudTimerUpdate", self, "UpdateFill")
	Events.connect("HudWinScore", self, "OnHudWinScore")
	pass # Replace with function body.

func SetLevelLabel(value):
	levelLabel.text = "%d" % (value + 1)

func UpdateFill(normalValue):
	var newWidth = fillTexture.texture.get_width() * normalValue
	fillTexture.region_rect.size = Vector2(newWidth, fillTexture.texture.get_height())
	fillTexture.modulate = safeColor.linear_interpolate(critColor, 1 - normalValue)
	
func RestoreUpdateFill(normalValue):
	var newWidth = fillTexture.texture.get_width() * normalValue
	fillTexture.region_rect.size = Vector2(newWidth, fillTexture.texture.get_height())
	fillTexture.modulate = safeColor.linear_interpolate(winColor, 1 - normalValue)
	# warning-ignore-all:UNUSED_ARGUMENT
func OnHudWinScore(tweenTime:= Data.gameData.nextGameStepDelay, reset:= false, addDelay:= 0.0):
	var fillWidth = fillTexture.region_rect.size.x / fillTexture.texture.get_width()
	var tween = create_tween().set_parallel(true)
	tween.tween_method(self, "RestoreUpdateFill", fillWidth, 0.0, tweenTime)
	animatedScore.text = "+%d" % Data.playerData.sessionScoreLastStep
	animationPlayer.play("score-vfx")
