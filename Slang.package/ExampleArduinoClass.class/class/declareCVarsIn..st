variabls
declareCVarsIn: aCCodeGenerator 
	aCCodeGenerator  var: #workBuffer type: #'int*'.
	aCCodeGenerator var: #edgeTransform declareC: 'float edgeTransform[6]'.