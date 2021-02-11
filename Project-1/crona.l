	/*CHASE ODGERS | EECS 665 | 2/10/2021 | Project 1 | Scanner*/
	/* Partnered with Adam Wallace */
%{
#include <string>
#include <limits.h>

/* Get our custom yyFlexScanner subclass */
#include "scanner.hpp"
#include "tokens.hpp"
#undef  YY_DECL
#define YY_DECL int crona::Scanner::yylex( crona::Parser::semantic_type * const lval )

/* define yyterminate as this instead of NULL */
#define yyterminate() return( TokenKind::END )

/* Exclude unistd.h for Visual Studio compatability. */
#define YY_NO_UNISTD_H

/* typedef to make the reference to token kinds shorter */
using TokenKind = crona::Parser::token;

%}

%option debug
%option nodefault
%option yyclass="crona::Scanner"
%option noyywrap
%option c++

	/* Macros */
DIGIT [0-9]
LETTER [a-zA-z]
TAB [\t]
SPACE [\040]
ALPHA [a-zA-Z]
ALPHANUM [a-zA-Z0-9]
COMMENT ("//")[^\n]*
STRLIT [\"]([^\\\"\n]|\\[nt\"\\])*[\"]
STRUNTERM [\"]([^\\\"\n]|\\[nt\"\\])*
BADESCAPE \"([\\[nt\"?\\]|[^\n\"\\])*\\[^\nnt\"?\\]([^\n\"])*\"
UNTERMESCAPE \"([^\n\"\\]|\\[nt\"?\\])*(\\[^\nnt\"?\\])?(\\[nt\"?\\]|[^\n\"\\])*\\?
ID (_|{ALPHA})({ALPHANUM}|_)*

%%
%{      /** Code executed at the beginning of yylex **/
            yylval = lval;
%}

	/* Reserved Words */
int		{ return makeBareToken(TokenKind::INT); 	}
bool		{ return makeBareToken(TokenKind::BOOL); 	}
byte		{ return makeBareToken(TokenKind::BYTE); 	}
string		{ return makeBareToken(TokenKind::STRING); 	}
void		{ return makeBareToken(TokenKind::VOID); 	}
if 		{ return makeBareToken(TokenKind::IF); 	}
else	 	{ return makeBareToken(TokenKind::ELSE); 	}
while	 	{ return makeBareToken(TokenKind::WHILE); 	}
return 	{ return makeBareToken(TokenKind::RETURN); 	}
array		{ return makeBareToken(TokenKind::ARRAY); 	}
true 		{ return makeBareToken(TokenKind::TRUE); 	}
false		{ return makeBareToken(TokenKind::FALSE); 	}
read 		{ return makeBareToken(TokenKind::READ); 	}
write	 	{ return makeBareToken(TokenKind::WRITE); 	}
havoc	 	{ return makeBareToken(TokenKind::HAVOC); 	}


	/* Symbol Operators */
"[" 		{ return makeBareToken(TokenKind::LBRACE); 	}
"]" 		{ return makeBareToken(TokenKind::RBRACE); 	}
"{" 		{ return makeBareToken(TokenKind::LCURLY); 	}
"}" 		{ return makeBareToken(TokenKind::RCURLY); 	}
"(" 		{ return makeBareToken(TokenKind::LPAREN); 	}
")" 		{ return makeBareToken(TokenKind::RPAREN); 	}
";" 		{ return makeBareToken(TokenKind::SEMICOLON);	}
":" 		{ return makeBareToken(TokenKind::COLON); 	}
"," 		{ return makeBareToken(TokenKind::COMMA); 	}
"-"		{ return makeBareToken(TokenKind::DASH); 	}
"--" 		{ return makeBareToken(TokenKind::DASHDASH); 	}
"+" 		{ return makeBareToken(TokenKind::CROSS); 	}
"++" 		{ return makeBareToken(TokenKind::CROSSCROSS);}
"*" 		{ return makeBareToken(TokenKind::STAR); 	}
"/" 		{ return makeBareToken(TokenKind::SLASH); 	}
"!" 		{ return makeBareToken(TokenKind::NOT); 	}
"=" 		{ return makeBareToken(TokenKind::ASSIGN); 	}
"==" 		{ return makeBareToken(TokenKind::EQUALS); 	}
"!="		{ return makeBareToken(TokenKind::NOTEQUALS); }
"<=" 		{ return makeBareToken(TokenKind::LESSEQ); 	}
">=" 		{ return makeBareToken(TokenKind::GREATEREQ); }
"&&" 		{ return makeBareToken(TokenKind::AND); 	}
"||" 		{ return makeBareToken(TokenKind::OR); 	}


	/* Comments */
{COMMENT}	{
		}


	/* Whitespace */
{TAB}		{
			colNum += yyleng;
		}

{SPACE} 	{
			colNum += yyleng;
		}


	/* Integer Literals */
{DIGIT}+	{
			int intVal = atoi(yytext);
			double checkOverflow = std::stod(yytext);
			if(checkOverflow > INT_MAX)
				{
					errIntOverflow(lineNum, colNum);
					intVal = INT_MAX;
				}
			yylval->lexeme = new IntLitToken(lineNum, colNum, intVal);
			colNum += yyleng;
			return TokenKind::INTLITERAL;
		}


	/* String Literals */
{STRLIT}	{
			yylval->lexeme = new StrToken(lineNum, colNum, yytext);
			colNum += yyleng;
			return TokenKind::STRLITERAL;
		}


	/* New Line */
\n		{
			lineNum++;
			colNum = 1;
		}


	/* VIOLATIONS*/
			/* String literal with bad escape sequence */
{BADESCAPE} 	{
			errStrEsc(lineNum, colNum);
			colNum += yyleng;
         	}

			/* Unterminated string literal */
{STRUNTERM}	{
			errStrUnterm(lineNum, colNum);
			colNum += yyleng;
		}

			/* Unterminated string literal with bad escape */
{UNTERMESCAPE} {
			errStrEscAndUnterm(lineNum, colNum);
			colNum += yyleng;
		}


	/* Identifiers */
{ID}		{
			yylval->lexeme = new IDToken(lineNum, colNum, yytext);
  			colNum += yyleng;
			return TokenKind::ID;
		}

.   		{
			errIllegal(lineNum,colNum,yytext);
			colNum += yyleng;
    		}
%%
