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


func define(symbol : String, value) :
	Records[symbol] = value

func has(symbol : String) :
	return Records.has(symbol)
	
func lookup(symbol : String) :
	check(Records.has(symbol), String("Symbol not found in environment records"))

	return Records[symbol]
	
func set(symbol : String, value) :
	check(Records.has(symbol), String("Symbol not found in environment records"))
	
	Records[symbol] = value
	
	return Records[symbol]

func setup_Globals():
	Records["null"]  = null
	Records["true"]  = true
	Records["false"] = false
	
	
func _init(errorOut):
	ErrorOut = errorOut
	
	
# Serialization ----------------------------------------------------
var SEva

func array_Serialize(array, fn_objSerializer) :
	var result = []

	for entry in array :
		if typeof(entry) == TYPE_ARRAY :
			result.append( array_Serialize( entry, fn_objSerializer ))

		elif typeof(entry) == TYPE_OBJECT :
			if entry.get_class() ==  "Eva":
				result.append(entry)
			else:
				fn_objSerializer.set_instance(entry)
				result.append( fn_objSerializer.call_func() )
		else :
			result.append( entry )
			
	return result

func to_SExpression():
	var expression = []
	
	for key in Records.keys() :
		var entry = [key]
		var Value = Records[key]
		
		if typeof( Value ) == TYPE_ARRAY :
			var \
			to_SExpression_Fn = FuncRef.new()
			to_SExpression_Fn.set_function("to_SExpression")
			
			var array = array_Serialize( Value, to_SExpression_Fn )
			
			entry.append(array)
			
		elif typeof( Value ) == TYPE_OBJECT :
			entry.append( Value.to_SExpression() )
			
		else :
			entry.append(Value)
			
		expression.append(entry)
		
	return expression

func to_Dictionary():
	var result = {}

	for key in Records.keys() :
		var Value = Records[key]
		
		if typeof(Value) == TYPE_ARRAY :
			var \
			to_SExpression_Fn = FuncRef.new()
			to_SExpression_Fn.set_function("to_SExpression")
			
			var array = array_Serialize( Value, to_SExpression_Fn )
			
			result[key] = array

		elif typeof(Value) == TYPE_OBJECT :
			result[key] = Value.to_SExpression()
			
		else :
			result[key] = Value
			
	return result
# Serialization END -------------------------------------------------
