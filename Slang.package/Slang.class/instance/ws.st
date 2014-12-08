as yet unclassified
ws


gen := CCodeGenerator new
		vmMaker: ArduinoCodeDelegation new ;
		logger: Transcript;
		options: Dictionary new;
		vmClass: ArduinoCodeDelegation;
		yourself.
		
gen addClass: ExampleArduinoClass .

gen inferTypesForImplicitlyTypedVariablesAndMethods. 	
gen storeCodeOnFile: '/home/santiago/out.c' doInlining: true.
gen storeAPIExportHeader: 'out.h' OnFile:'/home/santiago/out.h'.

Smalltalk garbageCollect.
