tool
extends Node

export (bool) var refresh

export (Resource) var appData
export (Resource) var uiData
export (Resource) var gameData
export (Resource) var playerData
export (Resource) var resourceData
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _process(delta):
	if Engine.editor_hint:
		if refresh:
			resourceData.uiResources.clear()
			ParseDirToArray(resourceData.uiResDir[0], resourceData.uiResources)
			ParseDirToArray(resourceData.uiResDir[1], resourceData.uiResources)
			resourceData.gameResources.clear()
			ParseDirToArray(resourceData.gameResDir, resourceData.gameResources)
			refresh = false

func ParseDirToArray(dirPath, destArray):
	var ignoreLine = ".import"
	var dir = Directory.new()
	if dir.open(dirPath) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		for i in 20:
			if file_name == "":
				print("I break here ", dirPath + file_name)
				break
			if dir.current_is_dir():
				print("I dive here ", dirPath, file_name)
				ParseDirToArray(dirPath + file_name + "/", destArray)
			else:
				if not ignoreLine in file_name:
					print("I found file here ", dirPath)
					destArray.push_back(dirPath + file_name)
			file_name = dir.get_next()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
