extends Spatial

var index
var steps = []
var activeStep = -1

class CustomSorter:
	static func sort_by_index(a, b):
		if a.index < b.index:
			return true
		return false
		
func Init():
	if steps.size() <= 0:
		for child in get_children():
			if child is Step:
				steps.append(child)		
	steps.sort_custom(CustomSorter, "sort_by_index")
	
	for step in steps:
		step.Init()
		step.visible = false
