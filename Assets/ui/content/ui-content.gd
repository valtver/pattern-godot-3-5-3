extends Node

var pages = []
var currentPageIndex = null
onready var leftButton = $ContentButtonLeft
onready var rightButton = $ContentButtonRight
onready var container = $Pivot
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	leftButton.connect("Click", self, "OnClickLeft")
	rightButton.connect("Click", self, "OnClickRight")
	pass # Replace with function body.

func Init(uiContentId):
	pages = []
	print(Data.levels)
	if(uiContentId == Types.UiContentId.Main):
		for lvlData in Data.levels:
			var page = lvlData.uiPage.instance()
			pages.push_back(page)
			container.add_child(page)
			page.position = Vector3(4.5 * (pages.size() - 1), 0, 0)
			page.get_node("LevelName").text = lvlData.locName.en
			page.get_node("LevelName/LevelNameShadow").text = lvlData.locName.en
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
	if pages.size() < 2:
		leftButton.visible = false
		rightButton.visible = false
	elif currentPageIndex == 0:
		leftButton.visible = false
		rightButton.visible = true
	elif currentPageIndex == pages.size() - 1:
		leftButton.visible = true
		rightButton.visible = false
	else:
		leftButton.visible = true
		rightButton.visible = true

func OnClickLeft(id):
	if currentPageIndex > 0:
		currentPageIndex -= 1
	UpdatePages()
	UpdateButtons()

func OnClickRight(id):
	if currentPageIndex < pages.size()-1:
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
