tool
extends Node

export (bool) var refresh
export (Resource) var playerData
export (float) var nextTaskDelay
export (float) var nextStepDelay
export (float) var taskTimerDelay
export (int) var sessionFailsLimit
export (int) var constScoreMultiplier
export (String) var uiSceneResourcesDirectory
export (String) var gameSceneResourcesDirectory

export (String) var hecticPlayLogoScene
export (String) var gameLogoScene
export (Array, Resource) var levels


export (Array, String) var uiSceneResources
export (Array, String) var gameSceneResources

export (Resource) var gameData
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if Engine.editor_hint:
		if refresh:
			uiSceneResources = []
			ParseDirToArray(uiSceneResourcesDirectory, uiSceneResources)
			gameSceneResources = []
			ParseDirToArray(gameSceneResourcesDirectory, gameSceneResources)
			refresh = false
			property_list_changed_notify()
			

func ParseDirToArray(dirPath, destArray):
	var ignoreLines = [".import"]
	var dir = Directory.new()
	if dir.open(dirPath) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		for i in 20:
			var ignoreCount = 0
			if file_name == "":
#				print("I break here ", dirPath + file_name)
				break
			if dir.current_is_dir():
#				print("I dive here ", dirPath, file_name)
				ParseDirToArray(dirPath + file_name + "/", destArray)
			else:
				for line in ignoreLines:
					if line in file_name:
						ignoreCount += 1
				if ignoreCount < 1:
#					print("I found file here ", dirPath)
					destArray.push_back(dirPath + file_name)
			file_name = dir.get_next()
