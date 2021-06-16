%option noyywrap yylineno
%{
	#include <string.h>
  	#include "Parser.tab.h"
  	#include "defs.h"
%}

%%
[\ \n\t]+
\/\/.*             
"/*"([^*]|"\n"|(\*+([^*/]|"\n")))*\*+"/" 
(Function) 					{return _FUN;}
"**" 						{return FUNZAG;}
(\() 						{return OZAG;}
(\)) 						{return ZZAG;}
\.   						{return TACKA;}
\,							{return ZAREZ;}
\; 			    			{return TACKAZAREZ;}
\:							{return DVOTACKA;}

(bool)|(\*bool)				{yylval.i= BOOL; return TIP;}
(int)|(\*ceo) 				{yylval.i= INT;  return TIP;}
(uint)|(\*nceo) 		{yylval.i= UINT;  return TIP;}
(float)|(\*dec) 			{yylval.i= FLOAT; return TIP;}
(void)|(\*void)				{yylval.i= VOID; return TIP;}

(tacno)|(netacno)           {yylval.s=strdup(yytext); return _BOOL;}
[0-9]{1,5}[u] 				{yylval.s=strdup(yytext); 
							 yylval.s[yyleng-1] = 0; return _UINT;}
[+-]?[0-9]{1,5} 			{yylval.s=strdup(yytext); return _INT;}
[0-9]{1,5}(,)[0-9]{1,5} 		{yylval.s=strdup(yytext);	return _FLOAT;}
[vV](_)[A-Za-z0-9]{1,5}			{yylval.s=strdup(yytext);	return ID;}

(increment)						{return INCR;}
(decrement)						{return DECR;}


(<)|(\?manje) 				{yylval.i= LT;    return ROP;}
(>)|(\?vece) 				{yylval.i= GT;	return ROP;}
(<=)|(\?manje=) 			{yylval.i= LE;   return ROP;}
(>=)|(\?vece=) 				{yylval.i= GE;     return ROP;}
(==)|(\?jednako) 			{yylval.i= EQ;   return ROP;}
(!=)|(=!)|(\?razlicito) 	{yylval.i= NE;  return ROP;}


(\+)|(\*dodaj) 				{yylval.i= ADD;  return AOP;}
(-)|(\*oduzmi) 				{yylval.i= SUB; return AOP;}
(\/)|(\*podeli) 			{yylval.i= DIV; return AOP;}
(\*)|(\*pomnozi) 			{yylval.i= MUL; return AOP;}
(=)|(\*dodeli) 				{return DOP;}

(branch)					{return BRANCH;}
(first)						{return FIRST;}
(second)					{return SECOND;}
(third)						{return THIRD;}
(otherwise)					{return OTHERWISE;}
->							{return ARROW;}

(for) 						{return FOR;}
(downto) 					{return DOWNTO;}
(to)						{return TO;}

{							{return OVITICASTA;}
}							{return ZVITICASTA;}
\? 							{return IF;}
\[ 							{return IF_OZAG;}
\] 							{return IF_ZZAG;}
\!\?						{return ELSE;}
(return)|(\*vrati)			{return IZLAZ;}

	

.          { printf("\nLINIJA %d: LEKSICKA GRESKA NA KARAKTER %c", 
                      yylineno, *yytext); }    

