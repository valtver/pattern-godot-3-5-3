extends Spatial
class_name Step

export (int) var index

var bonus = null
var pattern = null
var symbols = []
var completes = []
var bonusPoints = []

class DistanceSorter:
	static func sort_by_distance_inc(a, b):
		if a.position.z > b.position.z:
			return true
		return false
		
	static func sort_by_distance_dec(a, b):
		if a.position.z > b.position.z:
			return true
		return false
		
func Init():
	if symbols.size() <= 0:
		var nodes = get_tree().get_nodes_in_group("Symbol")
		for node in nodes:
			if is_a_parent_of(node):
				symbols.push_back(node)
				node.visible = false
		symbols.sort_custom(DistanceSorter, "sort_by_distance_inc")
	
	if completes.size() <= 0:
		var nodes = get_tree().get_nodes_in_group("Complete")
		for node in nodes:
			if is_a_parent_of(node):
				completes.push_back(node)
				node.visible = false
				
	if bonusPoints.size() <= 0:
		var nodes = get_tree().get_nodes_in_group("BonusPosition")
		for node in nodes:
			if is_a_parent_of(node):
				bonusPoints.push_back(node)
				
		completes.sort_custom(DistanceSorter, "sort_by_distance_inc")
	
	for symbol in symbols:
		symbol.visible = false
	
	for complete in completes:
		complete.get_node("AnimationPlayer").stop()
		complete.visible = false
					
func Start():	
	for symbol in symbols:
		symbol.UpdateSymbol(pattern.angles, pattern.sprites)
		symbol.visible = true
		symbol.get_node("AnimationPlayer").play("Show")
		symbol.get_node("AnimationPlayer").advance(0)
		yield(get_tree().create_timer(0.02), "timeout")
	
	if bonus != null:
		var bonusInstance = bonus.instance()
		bonusPoints.pick_random().add_child(bonusInstance)
		bonusInstance.Show()
		
func Complete():
	for symbol in symbols:
		symbol.UpdateSymbol(pattern.angles, pattern.sprites)
		symbol.visible = true
		symbol.get_node("AnimationPlayer").play("HideWin")
		yield(get_tree().create_timer(0.02), "timeout")
		
	var animationDelay = float(Data.nextTaskDelay - Data.nextStepDelay)/completes.size()
	for complete in completes:
		complete.visible = true
		complete.get_node("AnimationPlayer").play("Complete")
		yield(get_tree().create_timer(animationDelay), "timeout")
		
func Fail():
	var symbolsShuffled = []
	symbolsShuffled.append_array(symbols)
	symbolsShuffled.shuffle()
	for symbol in symbolsShuffled:
		symbol.UpdateSymbol(pattern.angles, pattern.sprites)
		symbol.visible = true
		symbol.get_node("AnimationPlayer").play("HideFail")
		symbol.get_node("AnimationPlayer").advance(0)
		yield(get_tree().create_timer(0.1), "timeout")

func ValidButtonSymbol(button):
	return button.GetSymbolAngles() == pattern.angles
