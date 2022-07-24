extends Object

# ---------------------------------------------------------- UTILITIES
var EvalOut

func check( condition : bool, message : String):
	assert(condition, message)
	if ! condition:
		EvalOut.text = "Eva - Error: " + message

func throw( message ):
	assert(false, message)
	EvalOut.text = "Eva - Error: " + message
# ---------------------------------------------------------- UTILITIES END

class_name Eva

# ---------------------------------------------------------- GLOBALS
const Parser = preload("Parser.gd")
const NType  = Parser.NType

const EvaEnv = preload("EvaEnv.gd")
var   Env    : EvaEnv

var Parent
# ---------------------------------------------------------- GLOBALS END

func _init(parent, evalOut):
	EvalOut = evalOut
	Env     = EvaEnv.new(EvalOut)
	Parent  = parent

func eval( ast ):
	if ast.type() == NType.program :
		var   index = 1;
		while index < ast.num_args():
			eval( ast.arg(index) )
			index += 1
			
		var result = eval( ast.arg(index) )
		if result != null:
			return String( result )
		else:
			return null
	
	elif ast.type() == NType.block :
		return eval_Block( ast )
	
	elif ast.type() == NType.identifier :
		var identifier = ast.arg(1)
	
		if Parent != null && !Env.has( identifier):
			return Parent.Env.lookup( identifier )
	
		return Env.lookup( identifier )
		
	elif ast.type() == NType.fn_Print :
		return eval_Print( ast )
		
	elif ast.type() == NType.op_Assign :
		var symbol = ast.arg(1)
		var value  = eval( ast.arg(2) )
		
		if Parent != null && !Env.has( symbol):
			return Parent.Env.set( symbol, value )
		
		return Env.set( symbol, value )
	
	elif ast.type() == NType.variable :
		var symbol = ast.arg(1)
		var value  = eval( ast.arg(2) )

		Env.define_Var(symbol, value)
		return value
	
	elif ast.is_Number() : 	
		return float( ast.arg(1) )		
	
	elif ast.is_String() : 
		return ast.string()
		
	return eval_Numeric( ast )
		
	var msgT = "eval - Unimplemented: {ast}"
	var msg  = msgT.format({"ast" : JSON.print(ast.to_SExpression(), "\t") })
	throw(msg)

func eval_Block( ast ):
	var eva_Block = get_script().new( self, EvalOut )
	
	var result

	var index = 1;
	while index <= ast.num_args() :
		result = eva_Block.eval( ast.arg(index) )
		index += 1

	return result

func eval_Numeric( ast ):
	if ast.type() == NType.op_Add:
		var result  = 0.0; var index = 1
		
		while index <= ast.num_args():
			result += eval( ast.arg(index) )
			index  += 1
			
		return result
		
	if ast.type() == NType.op_Sub:
		var result = 0.0; var index = 1
		
		while index <= ast.num_args():
			result -= eval( ast.arg(index) )
			index  += 1
			
		return result
		
	if ast.type() == NType.op_Mult:
		var result = 1.0; var index = 1
		
		while index <= ast.num_args():
			result *= eval( ast.arg(index) )
			index  += 1
			
		return result
			
	if ast.type() == NType.op_Div:
		var result = 1.0; var index = 1
		
		while index <= ast.num_args():
			result /= eval( ast.arg(index) )
			result += 1
			
		return result
		
func eval_Print( ast ):
	EvalOut.text += "\n" + String( eval( ast.arg(1) ) )
	return null
	
func get_EnvSnapshot():
	var snapshot = Env.Records.duplicate(true)
	
	if Parent != null:
		snapshot[Parent] = Parent.Env.Records.duplicate(true)
		
	return snapshot
