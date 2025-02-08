extends Spatial

export (Array, Resource) var patternData
export (Array, Resource) var bonusData
export (float) var stepBonusChance = 0.0

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
	for data in patternData:
		var ptrn = data.GetGeneratedPatternData()
		patterns.append_array(ptrn)
	editor_description += "Patterns generated: %d \n" % patterns.size()
	assert(patterns.size() >= get_tree().get_nodes_in_group("Step").size())
	var bonuses = []
	for data in bonusData:
		for n in data.maxAmount:
			bonuses.append(data.bonus)
	bonuses.shuffle()
	editor_description += "Bonuses generated: %d \n" % bonuses.size()
	for task in tasks:
		for step in task.steps:
			var randomPatternRef = patterns.pick_random()
			step.pattern = randomPatternRef.duplicate()
			patterns.erase(randomPatternRef)
			if step.bonusPoints.size() > 0:
				step.bonus = GetRandomStepBonus(bonuses, stepBonusChance)
				
	
func GetRandomStepBonus(bonuses, chance):
	if bonuses.size() <= 0:
		return null
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var random = rng.randf()
	if random > 0 and random <= chance:
		var bonusPickRef = bonuses.pick_random()
		var returnValue = bonusPickRef.duplicate()
		bonuses.erase(bonusPickRef)
		return returnValue
	return null			
	
func UpdateVisibility(forcedTaskIndex: int = -1):
	if forcedTaskIndex != -1:
		tasks[forcedTaskIndex].visible = true
		return
	for i in tasks.size():
		if i == forcedTaskIndex:
			tasks[i].visible = true
		else:
			tasks[i].visible = tasks[i].is_on_screen()
