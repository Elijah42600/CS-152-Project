/* Parser, Intermediate Code Generation */
/* mini_l.y */

%{
extern int currPos, currLine;
#include "heading.h"
int yyerror(char* s);
int yylex(void);
#include <stdio.h>
#include <stack>
#include <queue>
#include <vector>
#include <sstream>
#include <algorithm>
#include <fstream>
#include <iostream>

extern string fileName;

//Globals for intermediate code generation
vector<string> identVector; //Changed to vector to preserve ordering, passes up ident names
vector<string> tempVector; //Vector containing only created temp variables, for reuse 
vector<string> functionStack; //Contains names of encountered functions
int tempCounter = 0; //Used to name new temp variables
int labelCounter = 0; //Used to create new labels
int arrayIndex = 0;
vector<string> expressionVector; //Used to pass up expression value. 
vector<string> whileLabel; //Holds label for start of while loop to transition to at end of loop
vector<string> varVector; //Holds names for vars to pass up
vector<string> symbolVector; //Used for passing up symbol, such as in bool_exp. Use lifo?
vector<string> term2Vector;
vector<string> termVector;
vector<string> multTermVector;
vector<string> multSymbolVector;
vector<string> multVector;
vector<string> exprSymbolVector;
vector<string> exprTermVector;
vector<string> relationExpressionVector;
vector<string> relationAndExpressionTermVector;
vector<string> relationAndExpressionVector;
vector<string> boolExpressionTermVector;
vector<string> boolExpressionVector;
vector<string> functionLabel;
vector<string> identFuncVector;

//Param handling
bool isParam = false;
bool isDeclar = false;
vector<string> paramVector;
int paramCount = 0;

//Semantic handling
bool errorDetected = false;
vector<string> arrayIdentityVector; //Permanent vector of idents for all declared arrays
vector<string> identDeclarVector; //Holds declared idents

//Array handling system - 3 vectors with same index
vector<string> arrayTempVector; //Stores tempValue storing value of array index
vector<string> arrayIdentVector; //Stores the ident for the corresponding array
vector<string> arrayIndexVector; //Stores the index for the array corresponding to the temp

//temp Vars for use in productions
string tempExpression1;
string tempExpression2; 
string tempString; //tempString to be used within a single production.
string tempSymbol;
string tempTerm;
string tempTerm2;
string tempLabel;
string tempLabel2;

//Functions
string IntToString(int a) {
    ostringstream temp;
    temp << a;
    return temp.str();
}

string createTemp() {
	string createTemp_temp_string = "__temp__" + IntToString(tempCounter);
	tempCounter++;
	return createTemp_temp_string;
}

string createLabel() {
	string createLabel_temp_string = "__label__" + IntToString(labelCounter);
	labelCounter++;
	return createLabel_temp_string;
}

ostringstream tempOutput;
ofstream outputFile;



%}

%union { int ival; char* sval; }

%token<ival> NUMBER
%token<sval> IDENT

%token FUNCTION
%token BEGIN_PARAMS
%token END_PARAMS
%token BEGIN_LOCALS
%token END_LOCALS
%token BEGIN_BODY
%token END_BODY
%token INTEGER
%token ARRAY
%token OF
%token IF
%token THEN
%token ENDIF
%token ELSE
%token WHILE
%token DO
%token BEGINLOOP
%token ENDLOOP
%token BREAK
%token READ
%token WRITE
%token AND
%token OR
%token NOT
%token TRUE
%token FALSE
%token RETURN
%token SUB
%token ADD
%token DIV
%token MULT
%token MOD
%token EQ
%token NEQ
%token GT
%token LT
%token GTE
%token LTE
%token SEMICOLON
%token COLON
%token COMMA
%token L_PAREN
%token R_PAREN
%token L_SQUARE_BRACKET
%token R_SQUARE_BRACKET
%token ASSIGN
%token EQUAL


%start prog_start



%%

prog_start: output_setup functions { 	if (find(functionStack.begin(), functionStack.end(), "main") == functionStack.end()) {
						cout << "Semantic Error line " << currLine << ": No main function declared." << endl;
						errorDetected = true;
					}
					if (errorDetected) {
						return -1;
					}
					//outputFile << endl;
					outputFile << tempOutput.str() << endl;
					outputFile.close();	} /* Do nothing */

output_setup: epsilon {	//ostringstream tempOutput;
		//ofstream outputFile;
		//const string file2 = fileName;
		outputFile.open(fileName.c_str()); /* TODO: change fileName based on input */
} /* Sets up output for intermediate code */


functions: function functions {}  /* Do nothing */
	| epsilon {} /* Do nothing */

function: FUNCTION identF SEMICOLON begin_params declarations end_params begin_locals declarations end_locals BEGIN_BODY statements END_BODY {
		/* Beginning of function handled by identF production. */
		
		/* Middle of function - fixme maybe -> Maybe have function handle all its output? */
		/* Unnecessary if lower productions handle all ouput */

		/* End of function */
		tempOutput << "endfunc" << endl;
		//functionStack.pop();										

}

begin_locals: BEGIN_LOCALS {isDeclar = true;}

end_locals: END_LOCALS {isDeclar = false;}

begin_params: BEGIN_PARAMS {isParam = true;}

end_params: END_PARAMS {isParam = false;
			while(paramVector.size() > 0) {
				tempString = paramVector.back();
				paramVector.pop_back();
				tempOutput << "= " << tempString << ", $" << paramCount << endl;
				paramCount++;
			}
			paramCount = 0;
		}


declarations: declaration SEMICOLON declarations {} /* Declarations seem to be working. Do nothing for now */
	| epsilon {}

statements: statement SEMICOLON statements { /* Each statement should handle its own output. */} 
	| epsilon {/* Do nothing. */}


/* Declaration declares last ident in identifiers. Identifiers handles other idents. Necessary to handle arrays. Working. */
declaration: identifiers COLON INTEGER {tempOutput << ". " << identVector.back() << endl; 
					identVector.pop_back();} 
	| identifiers COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER  { tempOutput << ".[] " << identVector.back() <<", " << $5 << endl; 
											if (!(find(arrayIdentityVector.begin(), arrayIdentityVector.end(), identVector.back()) == arrayIdentityVector.end())) {
												arrayIdentityVector.push_back(identVector.back());
											}
											identVector.pop_back(); 
											if ($5 <= 0) {
												cout << "Semantic error line " << currLine << " : arraySize <= 0" << endl;
												errorDetected = true;
											}
										} 
	| identifiers INTEGER {printf("Syntax error at line %d: invalid declaration\n", currLine);}


statement: var ASSIGN expression {	tempString = expressionVector.back(); //expressionVector should hold expressionValue
					expressionVector.pop_back(); 
					tempTerm = varVector.back();
					varVector.pop_back();
					arrayIndex = -1;
					for(unsigned int i = 0; i < arrayTempVector.size(); i++) { //arrayIndex = -1 if not array, index otherwise
						if (arrayTempVector.at(i) == tempTerm) {
							arrayIndex = i;
							break;
						}
					} 
					if (arrayIndex == -1) /*Not array */ {
						tempOutput << "= " << tempTerm << "," << tempString << endl; //varVector should hold var
					} else {
						tempOutput << "= " << tempTerm << "," << tempString << endl;
						tempOutput << "[]= " << arrayIdentVector.at(arrayIndex) << "," << arrayIndexVector.at(arrayIndex) << "," << tempString << endl;
					}
					/* fixed array handling */
				} 
		/* outputs "=var,expressionVal" with expressionVal being the value of the expression.
		as such, expression must pass up its value. Stored at end of tempVector*/
	| IF bool_exp then statements else ENDIF { /* Handled by lower productions. */} 
	| while bool_exp beginloop statements endloop { /* 	while creates/outputs/stores label at start of loop (in whileLabel)
								bool_exp should create a temp, and pass it up, outputting intermediate steps
								Create goto whilelabel (create) if condition true
								Create Goto endlabel (create), probably in beginloop (happens when false) 
								Have statements handle statement output
								create goto start label (created in while), probably in endloop 
								Done. */
								} 
	| do BEGINLOOP statements ENDLOOP WHILE bool_exp {	tempLabel = whileLabel.at(whileLabel.size() - 2);
								//whileLabel.pop_back();
								tempTerm = boolExpressionVector.back();
								boolExpressionVector.pop_back();
								tempOutput << "?:= " << tempLabel << "," << tempTerm << endl;
								tempLabel = whileLabel.back();
								tempOutput << ": " << tempLabel << endl;
								whileLabel.pop_back();
								whileLabel.pop_back();
							} 
	| WRITE vars { 	while(varVector.size() > 0) {
				tempString = varVector.back();
				varVector.pop_back();
				tempOutput << ".> " << tempString  << endl;
			} /* No special array handling needed. */
		} 
	| READ vars {	while(varVector.size() > 0) {
				tempString = varVector.back();
				varVector.pop_back();
				arrayIndex = -1;
				for(unsigned int i = 0; i < arrayTempVector.size(); i++) {
					arrayIndex = i;
					break;
				}
				if(arrayIndex == -1) {
					tempOutput << ".< " << tempString << endl; 
				} else {
					tempOutput << ".[]< " << arrayIdentVector.at(arrayIndex) << "," << arrayIndexVector.at(arrayIndex) << endl;
				}
			}
			/* Should be working for multiple vars. Array handling done. */} 
	| BREAK { /* Exit while loop */
			tempLabel = whileLabel.back();
			tempOutput << ":= " << whileLabel.back() << endl;
			} 
	| RETURN expression { /* go to function call. Means function call must have a label. Returns value to expression that was the function call. */
				//tempString = functionLabel.back();
				//functionLabel.pop_back();
				tempOutput << "ret " << expressionVector.back() << endl;
				expressionVector.pop_back();
				} 
	| var EQUAL expression {printf("Syntax error at line %d: \":=\" expected\n", currLine);}

then: 	THEN	{	tempLabel = createLabel(); //Label to go to if condition true
			tempLabel2 = createLabel();	//Label to go to if condition false
			tempTerm = boolExpressionVector.back();
			boolExpressionVector.pop_back();
			tempOutput << "?:= " << tempLabel << "," << tempTerm << endl; //go to tempLabel if true
			tempOutput << ":= " << tempLabel2 << endl; //go to tempLabel2
			tempOutput << ": " << tempLabel << endl;	//tempLabel
			whileLabel.push_back(tempLabel2);

		}

do: DO	{	tempString = createLabel(); //Label at start of loop
		whileLabel.push_back(tempString);
		tempOutput << ": " << tempString << endl;
		tempString = createLabel(); //Label to end of loop
		whileLabel.push_back(tempString);
	}

while: WHILE {	tempString = createLabel(); 
		tempOutput << ": " << tempString << endl;
		whileLabel.push_back(tempString);
		/* Creates label at start of while loop, to transition back to when loop ends. Adds label to end of whileLabel */}

beginloop: BEGINLOOP	{	tempLabel = createLabel(); //creates the label to follow if the loop is true
				tempLabel2 = createLabel(); //Creates the label to follow if the loop is false
				tempTerm = boolExpressionVector.back();
				boolExpressionVector.pop_back();
				
				tempOutput << "?:= " << tempLabel << "," << tempTerm << endl;	//Go to tempLabel if tempTerm
				tempOutput << ":= " << tempLabel2 << endl;	//Go to tempLabel2
				tempOutput << ": " << tempLabel << endl;	//tempLabel
				whileLabel.push_back(tempLabel2);
				}

endloop: ENDLOOP	{	tempLabel = whileLabel.back(); //Label to exit loop, not placed
				whileLabel.pop_back();
				tempLabel2 = whileLabel.back(); //Label to loop again, placed above
				whileLabel.pop_back();
				tempOutput << ":= " << tempLabel2 << endl; //When while is finished, loop to beginning to recheck condition
				tempOutput << ": " << tempLabel << endl;	//Label reached when condition fails
			}

else: else2 statements {tempLabel = whileLabel.back();
			whileLabel.pop_back();
			tempOutput << ": " << tempLabel << endl;
			} 
	| epsilon { 	tempLabel = whileLabel.back(); //Label to go to when if not taken, no else present
			whileLabel.pop_back();
			tempOutput << ": " << tempLabel << endl;
			}

else2: ELSE {	tempLabel = whileLabel.back(); //Label to go to when else is taken
		whileLabel.pop_back();
		tempLabel2 = createLabel(); //Label to go to after "statements" when "if" is true, to avoid else
		tempOutput << ":= " << tempLabel2 << endl;
		tempOutput << ": " << tempLabel << endl;
		whileLabel.push_back(tempLabel2);
		}

bool_exp: relation_and_exp bool_exp_opt {	while(boolExpressionTermVector.size() > 0) {
							tempTerm2 = relationAndExpressionVector.back();
							relationAndExpressionVector.pop_back();
							tempTerm = boolExpressionTermVector.back();
							boolExpressionTermVector.pop_back();
							tempString = createTemp();
							tempOutput << "|| " << tempString << "," << tempTerm << "," << tempTerm2 << endl;
							relationAndExpressionVector.push_back(tempString);
							}
						tempString = relationAndExpressionVector.back();
						relationAndExpressionVector.pop_back();
						boolExpressionVector.insert(boolExpressionVector.begin(), tempString);
						}

bool_exp_opt: OR relation_and_exp bool_exp_opt {	boolExpressionTermVector.insert(boolExpressionTermVector.begin(), relationAndExpressionTermVector.back());
							relationAndExpressionTermVector.pop_back();
							} 
	| epsilon {/* Do nothing. */}

relation_and_exp: relation_exp relation_and_exp_opt {	while (relationAndExpressionTermVector.size() > 0) {
								tempTerm = relationAndExpressionTermVector.back();
								relationAndExpressionTermVector.pop_back();
								tempTerm2 = relationExpressionVector.back();
								relationExpressionVector.pop_back();
								tempString = createTemp();
								tempOutput << "&& " << tempString << "," << tempTerm << "," << tempTerm2 << endl;
								relationExpressionVector.push_back(tempString);
							}
							tempString = relationExpressionVector.back();
							relationExpressionVector.pop_back();
							relationAndExpressionVector.insert(relationAndExpressionVector.begin(), tempString);
						}

relation_and_exp_opt: AND relation_exp relation_and_exp_opt {	relationAndExpressionTermVector.insert(relationAndExpressionTermVector.begin(), relationExpressionVector.back());
								relationExpressionVector.pop_back();
 								} 
	| epsilon {/* Do nothing. */}

/* Insert relation_exp val in front of relationExpressionVector */
relation_exp: NOT relation_exp { 	tempString = createTemp();
					tempOutput << "! " << tempString << "," << relationExpressionVector.back() << endl;
					relationExpressionVector.pop_back();
					relationExpressionVector.insert(relationExpressionVector.begin(), tempString);
					} 
	| expression comp expression {	tempExpression1 = expressionVector.back();
					expressionVector.pop_back();
					tempExpression2 = expressionVector.back();
					expressionVector.pop_back();
					tempSymbol = symbolVector.back();
					symbolVector.pop_back();
					tempString = createTemp(); //createTemp creates temp string and returns it
					tempOutput << ". " << tempString << endl;
					tempOutput << tempSymbol << " " << tempString << "," << tempExpression1 << "," << tempExpression2 << endl;
					relationExpressionVector.insert(relationExpressionVector.begin(), tempString);
					} 
	| TRUE {expressionVector.insert(expressionVector.begin(), "1");} 
	| FALSE {expressionVector.insert(expressionVector.begin(), "0");} 
	| L_PAREN bool_exp R_PAREN {	tempTerm = boolExpressionVector.back();
					boolExpressionVector.pop_back();
					relationExpressionVector.insert(relationExpressionVector.begin(), tempTerm);
					}

expression: multiplicative_expression expression_opt {	/*testing 
							cout << "Display exprTermVector: ";
							for(unsigned i = 0; i < exprTermVector.size(); i++) {
								cout << exprTermVector.at(i) << "  ";
							} 
							cout << endl;
							cout << "Display multVector: ";
							for(unsigned j =0; j < multVector.size(); j++) {
								cout << multVector.at(j) << "  ";
							}
							cout << endl;
							 End test */
							while(exprSymbolVector.size() > 0) {
								tempTerm = exprTermVector.back();
								exprTermVector.pop_back();
								tempSymbol = exprSymbolVector.back();
								exprSymbolVector.pop_back();
								tempTerm2 = multVector.back();
								multVector.pop_back();

								tempString = createTemp();
								tempOutput << ". " << tempString << endl;
								tempOutput << tempSymbol << " " << tempString << "," << tempTerm2 << "," << tempTerm << endl; //testing
								multVector.push_back(tempString);
							} 
							tempTerm = multVector.back();
							multVector.pop_back();
							expressionVector.insert(expressionVector.begin(), tempTerm); 
							//expressionVector.push_back("ERROR HERE");
						}

expression_opt: ADD multiplicative_expression expression_opt {	exprSymbolVector.push_back("+");
								exprTermVector.push_back(multVector.back());
								multVector.pop_back();
								 } 
	| SUB multiplicative_expression expression_opt {exprSymbolVector.push_back("-");
							exprTermVector.push_back(multVector.back());
							multVector.pop_back();
							 } 
	| epsilon {/* Do nothing */}

multiplicative_expression: term multiplicative_expression_opt { while(multSymbolVector.size() > 0) { //evaluates full mult expression
									tempTerm = multTermVector.back();
									multTermVector.pop_back(); //grabs first term from mult_expr_opt = right operand
									tempSymbol = multSymbolVector.back();
									multSymbolVector.pop_back(); //grabs first symbol from mult_exp_opt
									tempTerm2 = termVector.back();
									termVector.pop_back(); 	//grabs left operand from termVector, means output in while 
												//must be stored in termVector
									tempString = createTemp();
									tempOutput << ". " << tempString << endl;
									tempOutput << tempSymbol << " " << tempString << "," << tempTerm2 << "," << tempTerm << endl;
									termVector.push_back(tempString);
								}
								tempTerm = termVector.back();
								termVector.pop_back();
								//multVector.insert(multVector.begin(), tempTerm); /* FIXED */
								multVector.push_back(tempTerm);
							}

/* Add symbol to multSymbolVector, and term to multTermVector. multiplicative_expression will handle creation of temps and evaluation */
multiplicative_expression_opt: MULT term multiplicative_expression_opt {multSymbolVector.insert(multSymbolVector.begin(), "*");
									multTermVector.insert(multTermVector.begin(), termVector.back());
									termVector.pop_back(); } 
	| DIV term multiplicative_expression_opt { 	multSymbolVector.insert(multSymbolVector.begin(), "/");
							multTermVector.insert(multTermVector.begin(), termVector.back());
							termVector.pop_back(); } 
	| MOD term multiplicative_expression_opt {	multSymbolVector.insert(multSymbolVector.begin(), "%");
							multTermVector.insert(multTermVector.begin(), termVector.back());
							termVector.pop_back(); } 
	| epsilon {/* Do nothing, allowing higher production to evaluate */}

/* Should pass operator to operatorVector to evaluate expressions. Finished.  */
comp: EQ {symbolVector.insert(symbolVector.begin(), "==");} 
	| NEQ {symbolVector.insert(symbolVector.begin(), "!=");} 
	| LT {symbolVector.insert(symbolVector.begin(), "<");} 
	| GT {symbolVector.insert(symbolVector.begin(), ">");} 
	| LTE {symbolVector.insert(symbolVector.begin(), "<=");} 
	| GTE {symbolVector.insert(symbolVector.begin(), ">=");} 

term: SUB term2 {/* 	Should pass negative value of term2. Thus, Term2 must pass up value. */
			tempString = createTemp();
			tempOutput << ". " << tempString << endl; //Output creation of tempString
			tempOutput << "- " << tempString << ",0," << term2Vector.back() << endl;
			term2Vector.pop_back(); //assignes new temp value of "0 - term2"
			termVector.push_back(tempString); //passes up temp by termVector
			 }
	| term2 { 	/*transfer term2Value to termVector */
			termVector.push_back(term2Vector.back()); 
			term2Vector.pop_back(); }
	| identFunc L_PAREN expressions R_PAREN {	 /* function call. Handle how? */
						if((find(functionStack.begin(), functionStack.end(), identFuncVector.back()) == functionStack.end())) {
							cout << "Semantic Error line " << currLine << ": Function " << identFuncVector.back() << " not declared." << endl;
							errorDetected = true;
						}
						while(expressionVector.size() > 0) { //Handle function parameters
							tempExpression1 = expressionVector.back();
							expressionVector.pop_back();
							tempOutput << "param " << tempExpression1 << endl;
						}
						tempString = createTemp();
						tempOutput << ". " << tempString << endl;
						tempOutput << "call " << identFuncVector.back() << ", " << tempString << endl;
						identFuncVector.pop_back();
						tempLabel = createLabel();
						tempOutput << ": " << tempLabel << endl;
						functionLabel.push_back(tempLabel);
						termVector.push_back(tempString);
						//termVector.insert(termVector.begin(), tempString); //testing
					} 

term2: var {	/* Move varValue from varVector to term2Vector */
		term2Vector.push_back(varVector.back()); varVector.pop_back(); }
	| NUMBER {	tempString = createTemp();
			tempOutput << ". " << tempString << endl;
			if ($1 < 0) {
				tempOutput << "- " << tempString << "," << "0," << $1 * -1 << endl;
				//term2Vector.push_back(IntToString($1));
			} else {
				tempOutput << "= " << tempString << ", " << $1 << endl;
			}
				term2Vector.push_back(tempString);
			//term2Vector.insert(term2Vector.begin(),IntToString($1));
			} /* Pass up NUMBER value to term by term2Vector, using same logic as ident */
	| L_PAREN expression R_PAREN { /* 	Expression value should already be in expressionVector
						move to term2Vector, to ensure uniformity */
						//term2Vector.insert(term2Vector.begin(), expressionVector.back()); 
						term2Vector.push_back(expressionVector.back()); 
						expressionVector.pop_back(); } 

expressions: expression COMMA expressions { /* Possible fixme for handling expression output. */ } 
	| expression { /* 	Expression production can handle storing the expression values. 
				fixme for handling expression output, if necessary. */ } 

vars: var COMMA vars {} /* Probably unnecessary. Vars stored by var productions, ouput can be handled by higher productions. */
	| var {} /* 	Single var should be handled by below productions
			If output is needed, it can be handled by an above production. */


/* Var will take ident value, and add to its own vector */
var: ident {varVector.push_back(identVector.back()); identVector.pop_back(); } /* Moves ident to var vector */
	| ident L_SQUARE_BRACKET expression R_SQUARE_BRACKET {	tempString = createTemp();
								tempTerm = identVector.back();
								identVector.pop_back();
								tempTerm2 = expressionVector.back();
								expressionVector.pop_back();
								tempOutput << ". " << tempString << endl;
								tempOutput << "=[] " << tempString << "," << tempTerm2 << "," << tempTerm << endl;
								arrayTempVector.push_back(tempString);
								arrayIdentVector.push_back(tempTerm2);
								arrayIndexVector.push_back(tempTerm);
								varVector.push_back(tempString);
								/* ident[expression] is an array call.
								Can set temp to ident[expression], and pass up temp
								Will require storing array params for the case that array is lhs.*/
								}

		/* Upper production will always be declaration -> this works. */
identifiers: ident COMMA identifiers {	tempOutput << ". " << identVector.back() << endl; 
					//identVector.erase(identVector.begin());
					identVector.pop_back();
					} 
		/* Above production only knows there will be one ident. Other idents must be printed here, after being passed up from ident 
		Takes from back of vector, replicating a queue*/

	| ident {} /* Nothing is done here, as it will be handled in the above production */

ident: IDENT  { identVector.insert(identVector.begin(), $1); /*Acts as push_front, to replicate queue functionality*/
		/* Passes ident name to front of vector for use in higher productions */ 
		if(isDeclar) {
			if(find(identDeclarVector.begin(), identDeclarVector.end(), $1) != identDeclarVector.end()) {
				//Declar already declared
				cout << "Semantic error line " << currLine << ": " << $1 << " already declared." << endl;
				errorDetected = true;
			}	
		}
		if(isParam) {
			paramVector.insert(paramVector.begin(), $1);
		}
		if(isDeclar || isParam) {
			identDeclarVector.push_back($1);
		} else {
			if(find(identDeclarVector.begin(), identDeclarVector.end(), $1) == identDeclarVector.end()) {
				cout << "Semantic error line " << currLine << ": ident " << $1 << " not declared." << endl;
				 errorDetected = true;
			}
		}
	} 

identF: IDENT { tempOutput << "func " << $1 << endl;
		if (find(functionStack.begin(), functionStack.end(), $1) == functionStack.end() ) {
		functionStack.push_back($1); } /* Only called on function start, should pass function name up for semantic analysis - functionStack? 
							functionStack changed to vector to enable searching */
		}

identFunc: IDENT {identFuncVector.push_back($1);}

epsilon: {} /* Should do nothing */

%%

int yyerror(char* s) //string
{
 
  extern char *yytext;	// defined and maintained in lex.c
  
  printf("ERROR: %s at symbol \"%s\" on line %d\n", s, yytext, currLine);
  exit(1);
}
