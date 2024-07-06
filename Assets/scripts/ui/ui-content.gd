extends Node

var contentPages = []
var currentPageIndex = null

onready var container = $Pivot
onready var leftScrollButton = $ContentButtonLeft
onready var rightScrollButton = $ContentButtonRight

const SUB_LEVELS_X = 3
const SUB_LEVELS_Y = 3
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func Init(screenConfig):
	contentPages = []
	if screenConfig.uiContentId == Types.UiContentId.Main:
		for lvlData in Data.gameData.levels:
			var content = Loader.GetResource(screenConfig.uiContentPages[0]).instance()
			contentPages.push_back(content)
			container.add_child(content)
			content.position = Vector3(4.5 * (contentPages.size() - 1), 0, 0)
			content.get_node("LevelButton").index = lvlData.index
			content.get_node("LevelButton/SpritePivot/Sprite").texture = Loader.GetResource(lvlData.uiTexture)
			var locId = Types.LocId.keys()[Data.appData.locId]
			content.get_node("LevelName").text = lvlData.locName[locId]
			content.get_node("LevelName/LevelNameShadow").text = lvlData.locName[locId]

	elif screenConfig.uiContentId == Types.UiContentId.SubLevel:
		for lvlData in Data.gameData.levels:
			if lvlData.index == Data.playerData.selectedLevelIndex:
				var pagesN = ceil(float(lvlData.subLevels.size()) / 9)
				for pN in pagesN:
					var content = Loader.GetResource(screenConfig.uiContentPages[0]).instance()
					contentPages.push_back(content)
					container.add_child(content)
					content.position = Vector3(4.5 * (contentPages.size() - 1), 0, 0)
					var nextSubLevelIndex = 0
					for y in SUB_LEVELS_Y:
						for x in SUB_LEVELS_X:
							for subLvlData in lvlData.subLevels:
								if subLvlData.index == nextSubLevelIndex:
									var subLvlButton = Loader.GetResource(screenConfig.uiContentButtons[0].button).instance()
									content.add_child(subLvlButton)
									subLvlButton.position = Vector3(x - SUB_LEVELS_X/2, SUB_LEVELS_Y/2 - y, 0)
									subLvlButton.name = "SubLevel%s" % nextSubLevelIndex
									subLvlButton.index = nextSubLevelIndex
									subLvlButton.get_node("SubLevelName").text = str(nextSubLevelIndex + 1)
									subLvlButton.get_node("SubLevelName/SubLevelNameShadow").text = str(nextSubLevelIndex + 1)
									nextSubLevelIndex += 1
									break
									
	elif screenConfig.uiContentId == Types.UiContentId.Settings:
		for page in screenConfig.uiContentPages:
			var content = Loader.GetResource(page).instance()
			contentPages.push_back(content)
			container.add_child(content)
			content.position = Vector3(4.5 * (contentPages.size() - 1), 0, 0)
			for btn in get_tree().get_nodes_in_group("uiContentButtons"):
				if btn.buttonId == Types.UiButtonId.Sound:
					btn.active = Data.appData.sound
				if btn.buttonId == Types.UiButtonId.Music:
					btn.active = Data.appData.music

	if !leftScrollButton.is_connected("Click", self, "OnClickLeft"):
		leftScrollButton.connect("Click", self, "OnClickLeft")
	if !rightScrollButton.is_connected("Click", self, "OnClickRight"):
		rightScrollButton.connect("Click", self, "OnClickRight")
	currentPageIndex = 0;
	UpdateButtons();
	
func UpdatePages():
	var tween = get_node("Tween")
	tween.interpolate_property(container, "position",
		container.position, Vector3.LEFT * currentPageIndex * 4.5, 0.5,
		Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()	
#	container.position = Vector3.LEFT * currentPageIndex * 4.5
	
func UpdateButtons():
	if contentPages.size() < 2:
		leftScrollButton.visible = false
		rightScrollButton.visible = false
	elif currentPageIndex == 0:
		leftScrollButton.visible = false
		rightScrollButton.visible = true
	elif currentPageIndex == contentPages.size() - 1:
		leftScrollButton.visible = true
		rightScrollButton.visible = false
	else:
		leftScrollButton.visible = true
		rightScrollButton.visible = true

func OnClickLeft():
	if currentPageIndex > 0:
		currentPageIndex -= 1
	UpdatePages()
	UpdateButtons()

func OnClickRight():
	if currentPageIndex < contentPages.size()-1:
		currentPageIndex += 1
	UpdatePages()
	UpdateButtons()
	
func Show():
	var tween = get_node("Tween")
	tween.interpolate_property(container, "position",
		Vector3(4.5, 0, 0), Vector3.LEFT * currentPageIndex * 4.5, 0.5,
		Tween.TRANS_BACK, Tween.EASE_OUT)
	tween.start()	
	container.position = Vector3.LEFT * currentPageIndex * 4.5
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
