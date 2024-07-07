extends Spatial

export (int) var selectedLevel = 0
export (int) var selectedSubLevel = 0

signal MainMenu

var activeCameraTransform
var gameStarted : bool = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Init()
	StartGame()
	pass # Replace with function body.

func Init():
	activeCameraTransform = get_viewport().get_camera().get_parent()
	selectedLevel = Data.playerData.selectedLevelIndex
	selectedSubLevel = Data.playerData.selectedSubLevelIndex
	var level = Data.gameData.GetLevel(selectedLevel, selectedSubLevel);
	if level == null:
		print("Level ", selectedLevel, selectedSubLevel, " not found")
		return
	
	var levelString = "level-%s%s%s" % [selectedLevel, "-", selectedSubLevel];
	var levelIsLoaded = (get_node_or_null(levelString) != null)
	if levelIsLoaded:
		print("Level ", selectedLevel, " is loaded already")
		return
	else:
		var levelScene = Loader.GetResource(level).instance()
		add_child(levelScene)
	
func StartGame():
	gameStarted = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !gameStarted:
		return
	activeCameraTransform.position -= Vector3(0, 0, delta/2)
#	pass
