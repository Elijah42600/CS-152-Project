/*
	CS 152 Project Part 1

*/

%{ 
	int currLine = 1;
	int currPos = 1;
	#include "y.tab.h"
%}

NUMBER		[0-9]+
ID 		[a-z]([a-z0-9_]*[a-z0-9])*
BAD_ID_1	[0-9_][a-z0-9_]*
BAD_ID_2	[a-z][a-z0-9_]*_
COMMENT		##[^\n]*\n

%% 

"function" 	{currPos += yyleng; return FUNCTION;}
"beginparams" 	{currPos += yyleng; return BEGIN_PARAMS;}
"endparams"     {currPos += yyleng; return END_PARAMS;}
"beginlocals"   {currPos += yyleng; return BEGIN_LOCALS;}
"endlocals"     {currPos += yyleng; return END_LOCALS;}
"beginbody"     {currPos += yyleng; return BEGIN_BODY;}
"endbody"       {currPos += yyleng; return END_BODY;}
"integer"       {currPos += yyleng; return INTEGER;}
"array"         {currPos += yyleng; return ARRAY;}
"of"            {currPos += yyleng; return OF;}
"if"            {currPos += yyleng; return IF;}
"then"          {currPos += yyleng; return THEN;}
"endif"         {currPos += yyleng; return ENDIF;}
"else"          {currPos += yyleng; return ELSE;}
"while"         {currPos += yyleng; return WHILE;}
"do"            {currPos += yyleng; return DO;}
"beginloop"     {currPos += yyleng; return BEGINLOOP;}
"endloop"       {currPos += yyleng; return ENDLOOP;}
"break"         {currPos += yyleng; return BREAK;}
"read"          {currPos += yyleng; return READ;}
"write"         {currPos += yyleng; return WRITE;}
"and"           {currPos += yyleng; return AND;}
"or"            {currPos += yyleng; return OR;}
"not"           {currPos += yyleng; return NOT;}
"true"          {currPos += yyleng; return TRUE;}
"false"         {currPos += yyleng; return FALSE;}
"return"        {currPos += yyleng; return RETURN;}
"-"             {currPos += yyleng; return SUB;}
"+"             {currPos += yyleng; return ADD;}
"*"             {currPos += yyleng; return MULT;}
"/"             {currPos += yyleng; return DIV;}
"%"             {currPos += yyleng; return MOD;}
"=="            {currPos += yyleng; return EQ;}
"<>"            {currPos += yyleng; return NEQ;}
"<"             {currPos += yyleng; return LT;}
">"             {currPos += yyleng; return GT;}
"<="            {currPos += yyleng; return LTE;}
">="            {currPos += yyleng; return GTE;}
{ID}		{currPos += yyleng; yylval.sval = strdup(yytext); return IDENT;}
{NUMBER}	{currPos += yyleng; yylval.ival = atoi(yytext); return NUMBER;}
"\n"		{currLine++; currPos = 1;}
{BAD_ID_1}	{printf("Error at line %d, column %d: identifier \"%s\" must begin with a letter\n", currLine, currPos, yytext); exit(0);}
{BAD_ID_2}      {printf("Error at line %d, column %d: identifier \"%s\" cannot end  with an underscore\n", currLine, currPos, yytext); exit(0);}
";"		{currPos += yyleng; return SEMICOLON;}
":"             {currPos += yyleng; return COLON;}
","             {currPos += yyleng; return COMMA;}
"("             {currPos += yyleng; return L_PAREN;}
")"             {currPos += yyleng; return R_PAREN;}
"["             {currPos += yyleng; return L_SQUARE_BRACKET;}
"]"             {currPos += yyleng; return R_SQUARE_BRACKET;}
":="            {currPos += yyleng; return ASSIGN;}
"="            	{currPos += yyleng; return EQUAL;}
[ \t]+          {/* ignore spaces */ currPos += yyleng;}
{COMMENT}	{currLine++; currPos = 1;}
.               {printf("Error at line %d, column %d: unrecognized symbol \"%s\"\n", currLine, currPos, yytext); exit(0);}

%%


