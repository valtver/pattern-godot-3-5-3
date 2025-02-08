extends HudScreen

export (Array, NodePath) var pageNodes

export (NodePath) var animationPlayerNodePath
onready var animationPlayer = get_node(animationPlayerNodePath)
export (NodePath) var tutorialPageTitleNode
onready var tutorialPageTitle = get_node(tutorialPageTitleNode)
export (NodePath) var tutorialPageLabelNode
onready var tutorialPageLabel = get_node(tutorialPageLabelNode)

var pages = []
var currentPage = 0
	
func Init():
	var hudButtons = get_tree().get_nodes_in_group("HudButton")
	for button in hudButtons:
		button.visible = false
		
	pages = []
	for pageNode in pageNodes:
		var page = get_node(pageNode)
		pages.append(page)
		page.visible = false
	
func NextPage():
	var nextPage = currentPage + 1
	if nextPage >= pages.size():
		nextPage = 0
	ShowPage(nextPage)
	AppInput.EnableUi()
	
func ShowPage(nextPage):
	var pagePlayer = pages[currentPage].get_node_or_null("AnimationPlayer")
	if pagePlayer:
		pagePlayer.stop()
	pages[currentPage].visible = false
	
	pages[nextPage].visible = true
	pagePlayer = pages[nextPage].get_node_or_null("AnimationPlayer")
	tutorialPageLabel.text = "%s %d-%d" % [tr("TUTORIAL_PAGE_LABEL"), nextPage + 1, pages.size()]
	var nodeName = "%s%d%s" % ["TUTORIAL_PAGE_", nextPage + 1, "_TEXT"] 
	pages[nextPage].get_node(nodeName).text = tr(nodeName)
	if pagePlayer:
		pagePlayer.play("loop")
	currentPage = nextPage
	
func ShowSpecial():
	
	ShowPage(currentPage)
	animationPlayer.play("show")
	yield(animationPlayer, "animation_finished")
		
	var hudButtons = get_tree().get_nodes_in_group("HudButton")
	for button in hudButtons:
		if button.has_method("AnimateShow"):
			button.AnimateShow("alpha")
	AppInput.EnableUi()
			
