extends Object

# ---------------------------------------------------------- UTILITIES
var ErrorOut

func check( condition : bool, message : String):
	assert(condition, message)
	if ! condition:
		ErrorOut.text = "Eva - Error: " + message

func throw( message ):
	assert(false, message)
	ErrorOut.text = "Eva - Error: " + message
# ---------------------------------------------------------- UTILITIES END

class_name EvaEnv


var Records : Dictionary

	
func _init(errorOut):
	ErrorOut = errorOut
	
func define_Var(symbol : String, value) :
	Records[symbol] = value

func has(symbol : String) :
	return Records.has(symbol)
	
func set(symbol : String, value) :
	check(Records.has(symbol), String("Symbol not found in environment records"))
	
	Records[symbol] = value
	
	return Records[symbol]

func lookup(symbol : String) :
	check(Records.has(symbol), String("Symbol not found in environment records"))

	return Records[symbol]
