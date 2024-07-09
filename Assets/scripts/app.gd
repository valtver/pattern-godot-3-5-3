extends Node

var state = Types.AppState.START

var game
var ui
var hecticPlayLogo
var gameLogo

var appStart: bool = true

onready var Content2D = $CameraPivot/Camera
onready var Content3D = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
#	Timeline.OnCompleteTimer(self, "Init", 2.0)
	Init()
#	Timeline.OnCompleteTimer(self, "ShowBlocker", 4.0)
	ShowBlocker()
	pass

func Init():
	var node = get_node_or_null("HecticPlayLogo")
	if node == null:
		var inst = ResourceLoader.load(Data.appData.hecticPlayLogoScene).instance()
		Content2D.add_child(inst)
		inst.position.z = -3
		hecticPlayLogo = inst.get_node("HecticPlayLogo")
		
	node = get_node_or_null("GameLogo")
	if node == null:
		var inst = load(Data.appData.gameLogoScene).instance()
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
	if is_instance_valid(hecticPlayLogo):
		hecticPlayLogo.get_parent().queue_free()
	if is_instance_valid(game):
		game.queue_free()
	if is_instance_valid(ui):
		ui.queue_free()
	
	Loader.Unload()
		
func Load():
	if state == Types.AppState.START:
		for res in Data.resourceData.uiResources:
			Loader.QueueResource(res)
			
	if state == Types.AppState.GAME:
		return
		for res in Data.resourceData.gameResources:
			Loader.QueueResource(res) 
		for res in Data.resourceData.level[Data.playerData.selectedLevelIndex]:
			Loader.QueueResource(res)
		for res in Data.resourceData.hudResources:
			Loader.QueueResource(res)

	Loader.connect("LoadComplete", self, "OnLoadComplete")
	Loader.Load()
	
func OnBlockerShown():
	Unload()
	gameLogo.play("game-logo-loop")
	Load()
		
func OnLoadComplete():
	Loader.disconnect("LoadComplete", self, "OnLoadComplete")
	if state == Types.AppState.START:
		ui = Loader.GetResource(Data.appData.uiScene).instance()
		Content2D.add_child(ui)
		ui.connect("StartGame", self, "OnGameStart")
	if state == Types.AppState.GAME:
		game = Loader.GetResource(Data.appData.gameScene).instance()
		Content3D.add_child(game)
		game.connect("MainMenu", self, "OnMainMenu")
#	Timeline.OnCompleteTimer(self, "HideBlocker", 0.5)
	HideBlocker()
	pass
		
func OnBlockerHidden():
	pass
	
func OnGameStart():
	state = Types.AppState.GAME
	ShowBlocker()

func OnMainMenu():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.

