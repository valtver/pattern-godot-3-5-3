extends Node
class_name StateMachine

export var initialStateNode: NodePath

var currentState: State
var states: Dictionary = {}

func _ready():
		
	var initialState = get_node(initialStateNode)
	
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.connect("TransitionToEvent", self, "OnChildTransitionEvent")
					
	if initialState:
		if states.has(initialState.name):
			if !initialState.actor.is_node_ready():
				yield(initialState.actor, "ready")
			initialState.Enter()
			currentState = states.get(initialState.name)
		else:
			printerr("Initial state %s is not found", initialState.name)
	
	else:
		print("Statemachine has no initial state")
			
func _process(delta):
	if currentState:
		currentState.Update(delta)
		
func OnChildTransitionEvent(state, newStateName):
	if state != currentState:
		print("State ", state, " vs ", currentState, " mismatch!")
		return
		
	var newState = states.get(newStateName)
	if !newState:
		print("Can't find ", newState)
		return
	
	if currentState:
		currentState.Exit()
		
	newState.Enter()
	currentState = newState
	
