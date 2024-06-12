extends Node

var game
var ui
var blocker
var hecticPlayLogo

var appStart: bool = true

export (PackedScene) var blockerScene
export (PackedScene) var hecticPlayLogoScene
# Called when the node enters the scene tree for the first time.
func _ready():
	Init()
	ShowBlocker()

func Init():
	var node = get_node_or_null("AppBlocker")
	if node == null:
		blocker = blockerScene.instance()
		add_child(blocker)

	node = get_node_or_null("HecticPlayLogo")
	if node == null:
		hecticPlayLogo = hecticPlayLogoScene.instance()
		add_child(hecticPlayLogo)
	
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
	blocker.play("blockerShow")
	OnCompleteTimer("OnBlockerShown", blocker.current_animation_length)
	
func HideBlocker():
	blocker.play("blockerHide")
	OnCompleteTimer("OnBlockerHidden", blocker.current_animation_length)

func ShowStartLogoSequence():
	hecticPlayLogo.play("hecticPlayLogoShow")
	OnCompleteTimer("ShowGameLogo", hecticPlayLogo.current_animation_length)
	
func ShowGameLogo():
	#add logo later
	OnCompleteTimer("OnGameLogoShown", 0.1)
	pass
	
func OnGameLogoShown():
	#loading...
	OnBlockerShown()
	pass
	
func Load():
	OnLoadComplete()
	pass
	
func OnBlockerShown():
	if appStart:
		appStart = false
		ShowStartLogoSequence()
	else:
		Load()
		
func OnLoadComplete():
	OnCompleteTimer("HideBlocker", 0.1)
	pass
		
func OnBlockerHidden():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
