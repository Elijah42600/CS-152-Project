#include "y.tab.h"
#include "heading.h"

int yyparse();

extern FILE * yyin;

string fileName;

int main(int argc, char ** argv)
{
   if(argc >= 2)
   {
	fileName = argv[1];
	fileName = fileName.substr(0, fileName.size() - 4);
	fileName = fileName + ".mil";
      yyin = fopen(argv[1], "r");
      if(yyin == NULL)
      {
         yyin = stdin;
      }
   }
   else
   {
      yyin = stdin;
   }
   yyparse();
}

