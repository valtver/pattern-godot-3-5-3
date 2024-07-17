extends Node

var visibilityNotifiers = []
var tiles
var island
var pIsland
var nIsland

func Init():
	island = get_node("0-0")
	tiles = get_tree().get_nodes_in_group("tiles")
	pIsland = island.duplicate()
	pIsland.position = island.position - Vector3.FORWARD * island.aabb.size.z
	add_child(pIsland)
	nIsland = island.duplicate()
	nIsland.position = island.position + Vector3.FORWARD * island.aabb.size.z
	add_child(nIsland)
	SubScribeToNotifiers()
	
func OnVisibilityChanged(notifier):
	if notifier == pIsland:
		for tile in tiles:
			if pIsland.is_a_parent_of(tile):
				tile.Reset()
			
		var OLDpIsland = pIsland
		pIsland = island
		island = nIsland
		nIsland = OLDpIsland
		nIsland.position = island.position + Vector3.FORWARD * island.aabb.size.z
		
	elif notifier == nIsland:
		var OLDnIsland = nIsland
		nIsland = island
		island = pIsland
		pIsland = OLDnIsland
		nIsland.position = island.position - Vector3.FORWARD * island.aabb.size.z
	
func CheckVisibility():
	if !pIsland.is_on_screen():
		OnVisibilityChanged(pIsland)
		
func SubScribeToNotifiers():
	visibilityNotifiers.clear()
	visibilityNotifiers = get_tree().get_nodes_in_group("IslandVisibilityNotifiers")
	for notifier in visibilityNotifiers:
		if !notifier.is_connected("screen_exited", self, "OnVisibilityChanged"):
			notifier.connect("screen_exited", self, "OnVisibilityChanged", [notifier])

