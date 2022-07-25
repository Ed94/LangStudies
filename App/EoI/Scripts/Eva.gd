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

func get_class():
	return "Eva"

func _init(parent, evalOut):
	EvalOut = evalOut
	Env     = EvaEnv.new(EvalOut)
	Parent  = parent
	
	if Parent == null:
		Env.setup_Globals()

func eval( ast ):
	match ast.type():
		NType.program :
			var   index = 1;
			while index < ast.num_args():
				eval( ast.arg(index) )
				index += 1
				
			var result = eval( ast.arg(index) )
			if result != null:
				if typeof(result) == TYPE_OBJECT && result.get_class() == "ASTNode":
					return JSON.print(result.to_SExpression())
					
				return String( result )
			else:
				return null
	
		NType.block :
			return eval_Block( ast )

		NType.conditional :
			var condition = eval( ast.arg(1) )

			if condition:
				# consequent
				return eval( ast.arg(2) )
			
			# Alternate
			if ast.num_args() > 2:
				return eval( ast.arg(3))

		NType.expr_Switch:
			var index = 1 
			while ast.arg(index).is_op_Relation():
				if eval( ast.arg(index) ):
					return eval( ast.arg(index + 1) )

				index += 2

			return eval( ast.arg(index) )
				
		NType.expr_While :
			var result
			
			while eval( ast.arg(1) ):
				result = eval( ast.arg(2) )
				
			return result

		NType.expr_For:
			var forEva = get_script().new( self, EvalOut )

			forEva.eval( ast.arg(1) )
			
			var index = 3; var result
			while  forEva.eval( ast.arg(2) ) :
				result = forEva.eval( ast.arg(index) )
				index += 1
				if index > ast.num_args() :
					index = 3
			
			return result
			
		NType.fn_User :
			var symbol = ast.arg(1)
			var fnDef  = \
			[ 
				ast.arg(2), # Parameters
				ast.arg(3), # Body
				self        # Closure (Environment capture)
			]
			
			Env.define(symbol, fnDef)
			return Env.lookup(symbol)
			
		NType.fn_Lambda:
			var fnDef  = \
			[ 
				ast.arg(1), # Parameters
				ast.arg(2), # Body
				self        # Closure (Environment capture)
			]
			
			return fnDef
			
		NType.fn_IIL:
			var params = ast.arg(1).arg(1)
			var body   = ast.arg(1).arg(2)
			var fnEva  = get_script().new( self, EvalOut )
			
			if params.type() != NType.empty:
				var index = 1
				while index <= params.num_args():
					var paramVal = eval( ast.arg(index + 1) )
					fnEva.Env.define(params.arg(index), paramVal )
					index += 1
			
			var result

			var index = 1;
			while index <= body.num_args() :
				result = fnEva.eval( body.arg( index ) )
				index += 1
	
			return result
	
		NType.identifier :
			return eval_Lookup( ast )
		NType.op_Assign :
			return eval_Assign( ast )
		NType.op_Fn:
			return eval_Func( ast )

		NType.op_Add:
			var result  = 0.0; var index = 1
			
			while index <= ast.num_args():
				result += eval( ast.arg(index) )
				index  += 1
				
			return result
			
		NType.op_Sub:
			if ast.num_args() < 2:
				return -eval( ast.arg(1) )
			
			var result = eval( ast.arg(1) ); var index = 2
			
			while index <= ast.num_args():
				result -= eval( ast.arg(index) )
				index  += 1
				
			return result
			
		NType.op_Mult:
			var result = 1.0; var index = 1
			
			while index <= ast.num_args():
				result *= eval( ast.arg(index) )
				index  += 1
				
			return result
				
		NType.op_Div:
			var result = eval( ast.arg(1) ); var index = 2
			
			while index <= ast.num_args():
				result /= eval( ast.arg(index) )
				index += 1
				
			return result

		NType.op_Increment:
			return eval( ast.arg(1) ) + 1
		NType.op_Decrement:
			return eval( ast.arg(1) ) - 1

		NType.op_Greater:
			return eval( ast.arg(1) ) > eval( ast.arg(2) )
		NType.op_Lesser:
			return eval( ast.arg(1) ) < eval( ast.arg(2) )
		NType.op_GreaterEqual:
			return eval( ast.arg(1) ) >= eval( ast.arg(2) )
		NType.op_LesserEqual:
			return eval( ast.arg(1) ) <= eval( ast.arg(2) )
			
		NType.op_Equal:
			return eval( ast.arg(1) ) == eval( ast.arg(2) )
		NType.op_NotEqual:
			return eval( ast.arg(1) ) != eval( ast.arg(2) )
			
		NType.fn_Print :
			return eval_Print( ast )
	
		NType.variable :
			var symbol = ast.arg(1)
			var value
			
			if ast.num_args() == 2:
				value = eval( ast.arg(2) )
				
			Env.define(symbol, value)
			
			return Env.lookup(symbol)
	
	if ast.is_Number() : 	
		return float( ast.arg(1) )		
	
	elif ast.is_String() : 
		return ast.string()

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

func eval_Lookup( ast ) :
	var identifier = ast.arg(1)
		
	if Parent != null && !Env.has( identifier):
		return Parent.eval_Lookup( ast )
		
	return Env.lookup( identifier )
	
func eval_Assign( ast, oriEva = null ) :
	var symbol = ast.arg(1)
	
	if Parent != null && !Env.has( symbol):
		return Parent.eval_Assign( ast, self )
	
	var value
	
	if oriEva != null :
		value = oriEva.eval( ast.arg(2) )
	else :
		value = eval( ast.arg(2) )
	
	return Env.set( symbol, value )
	
func eval_Func( ast ):
	var fn     = eval_Lookup( ast )
	var params = fn[0]
	var body   = fn[1]
	var fnEva  = get_script().new( fn[2], EvalOut )

	if params.type() != NType.empty:
		var index = 1
		while index <= params.num_args():
			var paramVal = eval( ast.arg(index + 1) )
			fnEva.Env.define(params.arg(index), paramVal )
			index += 1
			
	var result

	var index = 1;
	while index <= body.num_args() :
		result = fnEva.eval( body.arg( index ) )
		index += 1
	
	return result
	
func eval_Print( ast ):
	EvalOut.text += "\n" + String( eval( ast.arg(1) ) )
	return null
	
func get_EnvSnapshot():
	var \
	snapshot         = EvaEnv.new(EvalOut)
	snapshot.Records = Env.Records.duplicate(true)
	
	if Parent != null:
		snapshot[Parent] = Parent.get_EnvSnapshot()
		
	return snapshot.to_Dictionary()
