extends Node

var game
var ui
var hecticPlayLogo
var gameLogo

var appStart: bool = true

export (PackedScene) var hecticPlayLogoScene
export (PackedScene) var gameLogoScene
# Called when the node enters the scene tree for the first time.
func _ready():
	Init()
	ShowBlocker()

func Init():
	var node = get_node_or_null("HecticPlayLogo")
	if node == null:
		var inst = hecticPlayLogoScene.instance()
		$CameraPivot/Camera.add_child(inst)
		inst.position.z = -2
		hecticPlayLogo = inst.get_node("HecticPlayLogo")
		
	node = get_node_or_null("GameLogo")
	if node == null:
		var inst = gameLogoScene.instance()
		$CameraPivot/Camera.add_child(inst)
		inst.position.z = -1
		gameLogo = inst.get_node("GameLogo")
	
func OnCompleteTimer(methodName, delayTime):
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = delayTime
	timer.one_shot = true
	timer.connect("timeout", self, methodName)
	timer.connect("timeout", self, "CleanTimer", [timer])
	timer.start()
	
func CleanTimer(timerInstance):
	timerInstance.queue_free()

func ShowBlocker():
	if appStart:
		appStart = false
		ShowHectic()
	else:
		ShowGameLogo()
		
func HideBlocker():
	HideGameLogo()
		
func ShowHectic():
	hecticPlayLogo.play("hecticPlayLogoShow")
	OnCompleteTimer("ShowBlocker", hecticPlayLogo.current_animation_length)
	
func ShowGameLogo():
	gameLogo.play("game-logo-start")
	OnCompleteTimer("OnBlockerShown", gameLogo.current_animation_length)
	
func HideGameLogo():
	gameLogo.play("game-logo-end")
	OnCompleteTimer("OnBlockerHidden", gameLogo.current_animation_length)
		
func Load():
	OnLoadComplete()
	pass
	
func OnBlockerShown():
	gameLogo.play("game-logo-loop")
	hecticPlayLogo.get_parent().free()
	Load()
		
func OnLoadComplete():
	OnCompleteTimer("HideBlocker", 0.1)
	pass
		
func OnBlockerHidden():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
