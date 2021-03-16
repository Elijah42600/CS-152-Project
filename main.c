#include "y.tab.h"
#include "heading.h"

int yyparse();

extern FILE * yyin;

int main(int argc, char ** argv)
{
   if(argc >= 2)
   {
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

