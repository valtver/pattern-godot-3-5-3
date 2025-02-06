extends Node

enum AppState {START = 0, GAME = 2}
export (AppState) var appState

var tutorial
var game
var ui
var hud
var hecticPlayLogo
var gameLogo

var Content2D
var Content3D

func _ready():
	yield(get_tree().get_root(), "ready")
	Events.connect("AppStart", self, "Start")
	Events.connect("GameRestart", self, "Restart")
	Events.connect("GameQuit", self, "StartMainMenu")
	Init()
	
func Init():	
	AppInput.DisableUi()
	
	Content2D = $MapCamera/Camera
	Content3D = $"."
	
	var node = get_node_or_null("HecticPlayLogo")
	if node == null:
		var inst = ResourceLoader.load(Data.hecticPlayLogoScene).instance()
		Content2D.add_child(inst)
		inst.position.z = -3
		hecticPlayLogo = inst.get_node("HecticPlayLogo")
		
	node = get_node_or_null("GameLogo")
	if node == null:
		var inst = load(Data.gameLogoScene).instance()
		Content2D.add_child(inst)
		inst.position.z = -1
		gameLogo = inst.get_node("GameLogo")
		
	hecticPlayLogo.play("hecticPlayLogoShow")
	yield(hecticPlayLogo, "animation_finished")
	
	match appState:
		AppState.START:
			StartMainMenu()
		AppState.GAME:
			Start(Data.gameSceneResources,	Data.levels[Data.playerData.selectedLevelIndex].subLevels[Data.playerData.selectedSubLevelIndex].scene)
	
func StartMainMenu():
	Start(Data.uiSceneResources)
	
func Restart(gameNode):
	gameLogo.play("game-logo-restart-in")
	yield(gameLogo, "animation_finished")
	gameNode.Init()
	gameLogo.play("game-logo-restart-out")
	
func Start(AppDataResourceArray, LevelResource: String = ""):
	AppInput.DisableUi()
	
	gameLogo.play("game-logo-start")
	yield(gameLogo, "animation_finished")
	
	gameLogo.play("game-logo-loop")
	Unload()
	
	for resource in AppDataResourceArray:
		Loader.QueueResource(resource)
	if LevelResource != "":
		Loader.QueueResource(LevelResource)
		
	Loader.Load()
	yield(Events, "LoadComplete")
	
	for resource in AppDataResourceArray:
		if "Ui.tscn" in resource:
			if !ui:
				ui = Loader.GetResource(resource).instance()
				Content2D.add_child(ui)
				ui.ShowScreen("UiMainScreen")
		if "Hud.tscn" in resource:
			if !hud:
				hud = Loader.GetResource(resource).instance()
				Content2D.add_child(hud)
		if "Game.tscn" in resource:
			if !game:
				game = Loader.GetResource(resource).instance()
				Content3D.add_child(game)
				game.Init()
				
	yield(gameLogo, "animation_finished")
	gameLogo.play("game-logo-end")
	yield(gameLogo, "animation_finished")
	AppInput.EnableUi()
			
func Unload():
	if is_instance_valid(hecticPlayLogo):
		hecticPlayLogo.get_parent().queue_free()
	if is_instance_valid(game):
		var removeNode = game
		game = null
		removeNode.queue_free()
	if is_instance_valid(ui):
		var removeNode = ui
		ui = null
		removeNode.queue_free()
	if is_instance_valid(hud):
		var removeNode = hud
		hud = null
		removeNode.queue_free()
		
	Loader.Unload()
