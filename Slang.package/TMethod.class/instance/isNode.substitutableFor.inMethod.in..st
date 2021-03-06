inlining
isNode: aNode substitutableFor: argName inMethod: targetMeth in: aCodeGen
	"Answer true if the given parameter node is either a constant, a local variable, or a formal parameter of the receiver. Such parameter nodes may be substituted directly into the body of the method during inlining. Note that global variables cannot be subsituted into methods with possible side effects (i.e., methods that may assign to global variables) because the inlined method might depend on having the value of the global variable captured when it is passed in as an argument."

	| var madeNonTrivialCall |
	aNode isConstant ifTrue: [^true].

	aNode isVariable ifTrue:
		[var := aNode name.
		((locals includes: var) or: [args includes: var]) ifTrue: [^true].
		(#(self true false nil) includes: var) ifTrue: [^true].
		"We can substitute any variable provided it is only read in the method being inlined,
		 and if it is not read after any non-trivial call (which may update the variable)."
		madeNonTrivialCall := false.
		(targetMeth isComplete
		 and: [targetMeth parseTree
				noneSatisfy:
					[:node|
					 (node isSend
					  and: [(aCodeGen isBuiltinSelector: node selector) not]) ifTrue:
						[madeNonTrivialCall := true].
					 (madeNonTrivialCall and: [node isVariable and: [node name = argName]])
					 or: [node isAssignment
						  and: [node variable name = argName]]]
				unless:
					[:node|
					node isSend and: [aCodeGen isAssertSelector: node selector]]]) ifTrue:
			[^true].
		(targetMeth maySubstituteGlobal: var in: aCodeGen) ifTrue: [^true]].

	"For now allow literal blocks to be substituted.  They better be accessed only
	 with value[:value:*] messages though!"
	aNode isStmtList ifTrue: [^true].

	"scan expression tree; must contain only constants, builtin ops, and inlineable vars"
	aNode nodesDo: [ :node |
		node isSend ifTrue: [
			node isBuiltinOperator ifFalse: [^false].
		].
		node isVariable ifTrue: [
			var := node name.
			((locals includes: var) or:
			 [(args includes: var) or:
			 [(#(self true false nil) includes: var) or:
			 [targetMeth maySubstituteGlobal: var in: aCodeGen]]]) ifFalse: [^false].
		].
		(node isConstant or: [node isVariable or: [node isSend]]) ifFalse: [^false].
	].

	^ true