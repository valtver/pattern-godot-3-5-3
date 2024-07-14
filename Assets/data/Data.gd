tool
extends Node

export (bool) var refresh

export (Resource) var appData
export (Resource) var uiData
export (Resource) var gameData
export (Resource) var playerData
export (Resource) var resourceData
export (Resource) var sessionData
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _process(_delta):
	if Engine.editor_hint:
		if refresh:
			resourceData.uiResources.clear()
			for dir in resourceData.uiResDir:
				ParseDirToArray(dir, resourceData.uiResources)
			resourceData.gameResources.clear()
			for dir in resourceData.gameResDir:
				ParseDirToArray(dir, resourceData.gameResources)
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


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
