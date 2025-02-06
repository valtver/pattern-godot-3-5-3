extends Node

const scoreDigitLength = 0

export (NodePath) var levelIconNode
export (NodePath) var levelLabelNode
export (NodePath) var fillTextureNode
export (NodePath) var animationPlayerNode
export (NodePath) var animatedScoreNode
export (NodePath) var scoreCounterNode

onready var levelIcon = get_node(levelIconNode)
onready var levelLabel = get_node(levelLabelNode)
onready var fillTexture = get_node(fillTextureNode)
onready var animationPlayer = get_node(animationPlayerNode)
onready var animatedScore = get_node(animatedScoreNode)
onready var scoreCounter = get_node(scoreCounterNode)

onready var safeColor = Color(0.43, 0.73, 0.31)
onready var critColor = Color(0.69, 0.21, 0.36)
onready var winColor = Color(0.87, 1.0, 0.7)

var fillTween = null
var scoreTween = null

func _ready():
#	RestoreUpdateFill(1.0)
#	SetLevelLabel(Data.playerData.selectedSubLevelIndex)
#	Events.connect("HudTimerUpdate", self, "UpdateFill")
#	Events.connect("HudTimeScoreAnimation", self, "OnHudTimeScoreAnimation")
#	Events.connect("HudTimeUp", self, "OnHudTimeUp")
	pass # Replace with function body.

func SetLevelLabel(value):
	levelLabel.text = "%d" % (value + 1)
	
func SetCounter(value):
	scoreCounter.text =  "%d" % value

func UpdateFill(normalValue):
	var newWidth = fillTexture.texture.get_width() * normalValue
	fillTexture.region_rect.size = Vector2(newWidth, fillTexture.texture.get_height())
	fillTexture.modulate = safeColor.linear_interpolate(critColor, 1 - normalValue)
	
func RestoreUpdateFill(normalValue):
	var newWidth = fillTexture.texture.get_width() * normalValue
	fillTexture.region_rect.size = Vector2(newWidth, fillTexture.texture.get_height())
	fillTexture.modulate = safeColor.linear_interpolate(winColor, 1 - normalValue)
	# warning-ignore-all:UNUSED_ARGUMENT
	
func TimeScoreAnimation(stepScore):
	if fillTween != null:
		fillTween.kill()
	fillTween = create_tween()
		
	var fillWidth = fillTexture.region_rect.size.x / fillTexture.texture.get_width()
	fillTween.tween_method(self, "RestoreUpdateFill", fillWidth, 0.0, Data.nextTaskDelay)
	var stepScoreValue = floor(stepScore * Data.constScoreMultiplier)
	animatedScore.text = "+%d" % stepScoreValue
	animationPlayer.play("time-win")
	yield(animationPlayer, "animation_finished")
	var finalScore = floor(Data.playerData.sessionTimeScore * Data.constScoreMultiplier)
	var startScore = finalScore - stepScoreValue
	if scoreTween != null:
		scoreTween.kill()
	scoreTween = create_tween()
	scoreTween.tween_method(self, "SetCounter", startScore, finalScore, Data.nextTaskDelay-Data.nextStepDelay)
	
func TimeUp():
	UpdateFill(0.0)
	animationPlayer.play("time-up-vfx")
	
func TimeEnd():
	if fillTween != null:
		fillTween.kill()
	fillTween = create_tween()
		
	var fillWidth = fillTexture.region_rect.size.x / fillTexture.texture.get_width()
	fillTween.tween_method(self, "UpdateFill", fillWidth, 0.0, Data.nextTaskDelay)
	
