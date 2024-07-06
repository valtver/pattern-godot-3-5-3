extends Node

var state = Types.AppState.START

var game
var ui
var hecticPlayLogo
var gameLogo

var appStart: bool = true

onready var Content2D = $CameraPivot/Camera
onready var Content3D = $"."

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
		Content2D.add_child(inst)
		inst.position.z = -3
		hecticPlayLogo = inst.get_node("HecticPlayLogo")
		
	node = get_node_or_null("GameLogo")
	if node == null:
		var inst = gameLogoScene.instance()
		Content2D.add_child(inst)
		inst.position.z = -1
		gameLogo = inst.get_node("GameLogo")
		
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
	Timeline.OnCompleteTimer(self, "ShowBlocker", hecticPlayLogo.current_animation_length)
	
func ShowGameLogo():
	gameLogo.play("game-logo-start")
	Timeline.OnCompleteTimer(self, "OnBlockerShown", gameLogo.current_animation_length)
	
func HideGameLogo():
	gameLogo.play("game-logo-end")
	Timeline.OnCompleteTimer(self, "OnBlockerHidden", gameLogo.current_animation_length)
		
func Unload():
	if is_instance_valid(game):
		game.queue_free()
	if is_instance_valid(ui):
		ui.queue_free()
	
	Loader.Unload()
		
func Load():
	if state == Types.AppState.START:
		for res in Data.resourceData.ui:
			Loader.QueueResource(res)
		Loader.connect("LoadComplete", self, "OnLoadComplete")
		Loader.Load()
		return
	if state == Types.AppState.GAME:
		for res in Data.resourceData.level[Data.playerData.selectedLevelIndex]:
			Loader.QueueResource(res)
		for res in Data.resourceData.hud:
			Loader.QueueResource(res)
		
			
#	Loader.QueueResource()
#	OnLoadComplete()
	pass
	
func OnBlockerShown():
	Unload()
	gameLogo.play("game-logo-loop")
	hecticPlayLogo.get_parent().free()
	Load()
		
func OnLoadComplete():
	if state == Types.AppState.START:
		ui = Loader.GetResource(Data.appData.uiScene).instance()
		Content2D.add_child(ui)
		ui.connect("StartGame", self, "OnGameStart")
	Timeline.OnCompleteTimer(self, "HideBlocker", 0.5)
	pass
		
func OnBlockerHidden():
	pass
	
func OnGameStart():
	state = Types.AppState.GAME
	ShowBlocker()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.

