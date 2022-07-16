extends Object


const epsilon = 'ε'


class State :
	var accepting     : bool = false
	var transitionMap : Dictionary

	func _init(accepting : bool):
		self.accepting = accepting

		transitionMap[epsilon] = Array.new()

	func add_Transition(symbol : string, state : State):
		if symbol == epsilon :
			transitionMap[symbol].append(state)
			return

		transitionMap[symbol] = state
	
	func get_Transition(symbol : string) :
		return transitionMap[symbol]

class NFA :
	var input  : State
	var output : State

	func _init(input : State, output : State):
		self.input  = input
		self.output = output

	func test(string : String) :
		return input.test(string)



func concat(first : NFA, rest : Array):
	for entry in rest :
		first = concat_pair(first, entry)

	return first

func concat_pair(first : NFA, second : NFA):
	first.output.accepting  = false
	second.output.accepting = true

	first.output.add_Transition(epsilon, second.input)

	return NFA.new(first.input, second.output)

# Epsilon-Transition machine
func empty():
	return glyph(epsilon)

# Single character machine.
func glyph(symbol : string):
	var start     = State.new(false)
	var accepting = State.new(true)

	start.add_Transition(symbol, accepting)

	return NFA.new(start, accepting)

func repeat(entry : NFA)
	var start     = State.new(false)
	var accepting = State.new(true)

	start.add_Transition(epsilon, entry.input)

	entry.output.accepting(false)
	entry.output.add_Transition(epsilon, entry.input) # Repeater transition
	entry.output.add_Transition(epsilon, accepting)

	return NFA.new(start, accepting)

func union(first : NFA, rest : Array):
	for entry in rest : 
		first = union_pair(first, entry)

	return first

func union_pair(a : NFA, b : NFA):
	var start     = State.new(false)
	var accepting = State.new(true)

	start.add_Transition(epsilon, a.input)
	start.add_Transition(epsilon, b.output)

	a.output.accepting = false
	b.output.accepting = false

	a.output.add_Transition(epsilon, accepting)
	b.output.add_Transition(epsilon, accepting)

	return NFA.new(start, accepting)



func test():
	var state_1 = State.new(false)
	var state_2 = State.new(true)

	state_1.add_Transition('A', state_2)
	
	print("State 1 Transition for " + "A: " + state_1.get_Transition('A'))	
