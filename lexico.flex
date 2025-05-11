/*
    Nomes: Henrique Balejos, Miiguel Warken e Vitor Caús
    T2 Construção de Compiladores
*/

%%

%byaccj


%{
  private Parser yyparser;

  public Yylex(java.io.Reader r, Parser yyparser) {
    this(r);
    this.yyparser = yyparser;
  }
%}

NL  = \n | \r | \r\n


%%

"$TRACE_ON"  { yyparser.setDebug(true);  }
"$TRACE_OFF" { yyparser.setDebug(false); }

if { return Parser.IF;}
else { return Parser.ELSE;}
while { return Parser.WHILE;}
void {return Parser.VOID;}
int { return Parser.INT;}
double { return Parser.DOUBLE;}
boolean { return Parser.BOOLEAN;}
and {return Parser.AND;}
or  {return Parser.OR;}
not {return Parser.NOT;}
func {return Parser.FUNC;}
return {return Parser.RETURN;}

[0-9]+ { return Parser.NUM;}
[a-zA-Z][a-zA-Z0-9]* { return Parser.IDENT;}

"{" |
"}" |
"=" |
"[" |
"]" |
"(" |
")" |
";" |
"*" |
"/" |
"+" |
"-" |
">" |
"<" |
","    { return (int) yycharat(0); }

"!="    {return Parser.NOT_EQUAL;}
">="    {return Parser.GREATER_EQUAL;}
"<="    {return Parser.LESS_EQUAL;}
"=="    {return Parser.EQUALS;}

[ \t]+ { }
{NL}+  { } 

.    { System.err.println("Error: unexpected character '"+yytext()+"' na linha "+yyline); return YYEOF; }






