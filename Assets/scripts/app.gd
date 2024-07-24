extends Node

var state = Types.AppState.START

var game
var ui
var hud
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
	Timeline.Delay(self, "ShowBlocker", hecticPlayLogo.current_animation_length)
	
func ShowGameLogo():
	gameLogo.play("game-logo-start")
	Timeline.Delay(self, "OnBlockerShown", gameLogo.current_animation_length)
	
func HideGameLogo():
	gameLogo.play("game-logo-end")
	Timeline.Delay(self, "OnBlockerHidden", gameLogo.current_animation_length)
		
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
		for res in Data.resourceData.gameResources:
			Loader.QueueResource(res) 
		for res in Data.resourceData.level[Data.playerData.selectedLevelIndex]:
			Loader.QueueResource(res)
		for res in Data.resourceData.hudResources:
			Loader.QueueResource(res)

	Events.connect("LoadComplete", self, "OnLoadComplete")
	Loader.Load()
	
func OnBlockerShown():
	Unload()
	gameLogo.play("game-logo-loop")
	Load()
		
func OnLoadComplete():
	Events.disconnect("LoadComplete", self, "OnLoadComplete")
	if state == Types.AppState.START:
		ui = Loader.GetResource(Data.appData.uiScene).instance()
		Content2D.add_child(ui)
		Events.connect("StartGame", self, "OnGameStart")
	if state == Types.AppState.GAME:
		hud = Loader.GetResource(Data.appData.hudScene).instance()
		Content2D.add_child(hud)
		hud.Init()
		game = Loader.GetResource(Data.appData.gameScene).instance()
		Content3D.add_child(game)
		Events.connect("AppMainMenu", self,"OnMainMenu")
		game.Init()
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

