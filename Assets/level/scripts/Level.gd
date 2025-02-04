extends Spatial

export (Array, Resource) var patternData

var tasks = []

class DistanceSorter:
	static func sort_by_distance(a, b):
		if a.position.z > b.position.z:
			return true
		return false
	
func Init():
	tasks = get_tree().get_nodes_in_group("Task")
	tasks.sort_custom(DistanceSorter, "sort_by_distance")
	for task in tasks:
		task.Init()
	var idx = -1
	for task in tasks:
		idx += 1
		task.index = idx
	var patterns = []
	editor_description += " (Step) Patterns required: %d \n" % get_tree().get_nodes_in_group("Step").size()
	var patternsGenerated = 0
	for data in patternData:
		var ptrn = data.GetGeneratedPatternData()
		patterns.append_array(ptrn)
		patternsGenerated += ptrn.size()
	editor_description += "Patterns generated: %d \n" % patternsGenerated
	assert(patternsGenerated >= get_tree().get_nodes_in_group("Step").size())
	for task in tasks:
		for step in task.steps:
			var randomPatternRef = patterns.pick_random()
			step.pattern = randomPatternRef.duplicate()
			patterns.erase(randomPatternRef)
	
func UpdateVisibility(forcedTaskIndex: int = -1):
	if forcedTaskIndex != -1:
		tasks[forcedTaskIndex].visible = true
		return
	for i in tasks.size():
		if i == forcedTaskIndex:
			tasks[i].visible = true
		else:
			tasks[i].visible = tasks[i].is_on_screen()
