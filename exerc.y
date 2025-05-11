/*
    Nomes: Henrique Balejos, Miguel Warken e Vitor Caús
    T2 Construção de Compiladores
*/

%{
  import java.io.*;
%}
   

%token IF, ELSE, WHILE, AND, NUM, IDENT, VOID, INT, DOUBLE, BOOLEAN, FUNC, RETURN, NOT, OR, GREATER_EQUAL, LESS_EQUAL, EQUALS, NOT_EQUAL

%left OR
%left AND
%left '>' '<' GREATER_EQUAL, LESS_EQUAL, EQUALS, NOT_EQUAL
%left '+' '-'
%left '*' '/'
%right '='
%right NOT

%%
 
Prog  :  ListaDecl
      ;

ListaDecl : DeclVar ListaDecl
          | DeclFunc ListaDecl
	        | /* vazio */
          ;

DeclVar   : Tipo ListaIdent ';'
          ;

DeclFunc  : FUNC TipoOuVoid IDENT '(' FormalPar ')' '{' LCmd '}'
          ;

TipoOuVoid  : VOID
            | Tipo SufixoTipoArraySemIndex
            ;

Tipo  : INT
      | DOUBLE
      | BOOLEAN
      ;

SufixoTipoArrayIndex  : '[' NUM ']'
            | /* vazio */
            ; 

SufixoTipoArraySemIndex : '['']'
            | /* vazio */
            ; 

ListaIdent : IDENT SufixoTipoArrayIndex RestoListaIdent
          ;

RestoListaIdent : ',' IDENT RestoListaIdent
                | /* vazio */
                ;

FormalPar : ParamList
          | /* vazio */
          ;

ParamCallList : IDENT RestoParamCall
              | NUM RestoParamCall
              ;    
                
FormalParCall : ParamCallList
              |
              ;
              
ParamList : Tipo IDENT SufixoTipoArraySemIndex RestoParam
          ;

RestoParamCall  : ',' IDENT RestoParamCall
                | ',' NUM RestoParamCall
                |
                ;

RestoParam : ',' Tipo IDENT SufixoTipoArraySemIndex RestoParam
          | /* vazio */
          ;

Bloco : '{' LCmd '}'
      ;

LCmd : C  LCmd
     | /* vazio */
     ;

C : Bloco
  | IF '(' E ')' C
  | IF '(' E ')' C ELSE C  
  | WHILE '(' E ')' C
  | E ';'
  | RETURN RestoReturn ';'
  | DeclVar
  ;

RestoReturn : E 
            | /* vazio */
            ;

E : E '+' E
  | E '-' E
  | E '*' E
  | E '/' E
  | E '<' E
  | E '>' E
  | IDENT SufixoTipoArrayIndex '=' E
  | E AND E
  | E OR E
  | E EQUALS E
  | E GREATER_EQUAL E
  | E LESS_EQUAL E
  | E NOT_EQUAL E
  | NOT E
  | NUM
  | '(' E ')'
  | IDENT '(' FormalParCall ')'
  | IDENT SufixoTipoArrayIndex
  ;

%%

  private Yylex lexer;


  private int yylex () {
    int yyl_return = -1;
    try {
      yylval = new ParserVal(0);
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      System.err.println("IO error :"+e.getMessage());
    }
    return yyl_return;
  }


  public void yyerror (String error) {
    System.err.println ("Error: " + error);
  }


  public Parser(Reader r) {
    lexer = new Yylex(r, this);
  }


  static boolean interactive;

  public void setDebug(boolean debug) {
    yydebug = debug;
  }


  public static void main(String args[]) throws IOException {
    System.out.println("");

    Parser yyparser;
    if ( args.length > 0 ) {
      // parse a file
      yyparser = new Parser(new FileReader(args[0]));
    }
    else {System.out.print("> ");
      interactive = true;
	    yyparser = new Parser(new InputStreamReader(System.in));
    }

    yyparser.yyparse();
    
  //  if (interactive) {
      System.out.println();
      System.out.println("done!");
  //  }
  }






