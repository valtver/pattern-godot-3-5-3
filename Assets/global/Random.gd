extends Node

func GetUniqueRandomInRange(a, b, count):
	var array = []
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for n in count:
		var randN = rng.randi_range(a, b-1)
		while randN in array:
			randN = rng.randi_range(a, b-1)
		array.append(randN)
	print(array)
	return array


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
