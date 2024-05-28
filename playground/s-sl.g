//From: https://github.com/CordyJ/Open-TuringPlus/blob/main/doc/SSL_Specification.pdf
//https://en.wikipedia.org/wiki/S/SL_programming_language
//https://github.com/alegemaate/s-sl
//https://github.com/open-watcom/open-watcom-v2/tree/master/bld/ssl
// S/SL grammar

%token id string integer tInputAny tOtherwise
%token tInput tOutput tError tType tMechanism tRules tEnd
%token tCall tExit tReturn tErrorSignal tOr tCycle tCycleEnd  tChoice tChoiceEnd

%%

s_sl :
	definitions tRules rule_list tEnd
	| definitions tRules rule_list
	;

definitions :
	definition
	| definitions definition
	;

definition :
	inputDefinition
	| outputDefinition
	| inputOutputDefinition
	| errorDefinition
	| typeDefinition
	| mechanismDefinition
	;

inputDefinition :
	tInput ':' tokenDefinitions ';'
	;

outputDefinition :
	tOutput ':' tokenDefinitions ';'
	;

inputOutputDefinition :
	tInput tOutput ':' tokenDefinitions ';'
	| tOutput tInput ':' tokenDefinitions ';'
	;

errorDefinition :
	tError ':' errorSignalDefinitions ';'
	;

typeDefinition :
	tType id ':' valueDefinitions ';'
	;

mechanismDefinition :
	tMechanism id ':' operationDefinitions ';'
	;

rule_list :
	rule
	| rule_list rule
	;

rule :
	proc_rule
	| choice_rule
	;

proc_rule :
	id ':' actions ';'
	;

choice_rule :
	id tReturn id /*typeId*/ ':' return_actions ';'
	;

actions :
	action
	| actions action
	;

action :
	id 					/*a: inputToken*/
	| string 				/*a: inputToken*/
	| tInputAny			/*a:*/
	| '.' id 				/*b: outputToken*/
	| '.' string 				/*b: outputToken*/
	| tErrorSignal id 		/*c: errorId*/
	| tCycle cycle_actions tCycleEnd /*d: */
	| choice				/*f:*/
	| tCall id 				/*g: procedureRuleId*/
	//|	/*k: updateOpId*/
	| id '(' tokenValue ')'		/*l: parameterizedUpdateOpId(valueId)*/
	| tCall id '(' tokenValue ')'
	;

cycle_actions :
	return_actions
	| tExit				/*e:*/
	| return_actions tExit		/*e:*/
	;

return_actions :
	actions
	| return_action
	| actions return_action
	;

return_action :
	tReturn		/*h:*/
	| tReturn id 	/*J: valueId*/
	| tReturn string 	/*J: valueId*/
	| tReturn integer 	/*J: valueId*/
	| tReturn id '(' tokenValue ')' 	/*only in openwatocm version*/
	;

choice :
	tChoice input_choice_body tChoiceEnd /*f:*/
	| tChoice tCall id /*choiceRuleId*/ value_choice_body tChoiceEnd /*i:*/
	| tChoice id /*choiceOpId*/ value_choice_body tChoiceEnd /*m:*/
	| tChoice id '(' tokenValue /*valueId*/ ')' /*parameterizedChoiceOpId*/ value_choice_body tChoiceEnd /*n:*/
	| tChoice tOtherwise /*InputLookaheadChoice*/ input_choice_body tChoiceEnd
	;

input_choice_body :
	input_choice_cases
	| input_choice_cases choice_otherwise
	;

input_choice_cases :
	input_choice_case
	| input_choice_cases input_choice_case
	;

input_choice_case :
	tOr inputToken_list ':'
	| tOr inputToken_list ':' cycle_actions
	;

choice_otherwise :
	tOr tOtherwise ':'
	| tOr tOtherwise ':' cycle_actions
	;

value_choice_body :
	value_choice_cases
	| value_choice_cases choice_otherwise
	;

value_choice_cases :
	value_choice_case
	| value_choice_cases value_choice_case
	;

value_choice_case :
	tOr valueId_list ':'
	| tOr valueId_list ':' cycle_actions
	;

inputToken_list :
	id
	| string
	| inputToken_list ',' id
	| inputToken_list ',' string
	;

valueId_list :
	id
	| string
	| integer
	| valueId_list ',' id
	| valueId_list ',' string
	| valueId_list ',' integer
	;

tokenDefinitions :
	tokenDefinition
	| tokenDefinitions tokenDefinition
	;

tokenDefinition :
	id
	| id string /*synonym*/
	| id '=' tokenValue
	| id string '=' tokenValue
	;

tokenValue :
	id
	| integer
	| string
	;

errorSignalDefinitions :
	errorSignalDefinition
	| errorSignalDefinitions errorSignalDefinition
	;

errorSignalDefinition :
	id
	| id '=' integer /*errorValue*/
	| id '=' id /*reference errorValue*/
	;

valueDefinitions :
	valueDefinition
	| valueDefinitions valueDefinition
	;

valueDefinition :
	id
	| string
	| id '=' tokenValue
	| string '=' tokenValue
	;

operationDefinitions :
	operationDefinition
	| operationDefinitions operationDefinition
	/*only in open-watcom version*/
	| operationDefinition '=' integer
	| operationDefinitions operationDefinition '=' integer
	;

operationDefinition :
	id
	| id '(' id /*typeId*/ ')'
	| id tReturn id /*typeId*/
	| id '(' id /*typeId*/ ')' tReturn id /*typeId*/
	;

%%

%option caseless

%%

[ \t\r\n\f]+  skip()
"%".*   skip()

"." '.'
";" ';'
"," ','
":" ':'
"=" '='
"(" '('
")" ')'
"?"	tInputAny
"*"	tOtherwise
"["|"if" tChoice
"]"|"fi" tChoiceEnd
"{"|"do" tCycle
"}"|"od" tCycleEnd
"|"|"!" tOr
"@" tCall
"#" tErrorSignal
">" tExit
">>"    tReturn

"INPUT" tInput
"OUTPUT"    tOutput
"ERROR" tError
"TYPE"  tType
"MECHANISM" tMechanism
"RULES" tRules
"END"   tEnd

"-"?[0-9]+  integer

'(\\.|[^'\r\n\\])+' string

[A-Za-z_][A-Za-z0-9_]* id

%%
