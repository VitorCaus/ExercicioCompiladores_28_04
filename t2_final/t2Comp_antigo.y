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
%nonassoc '>' '<' GREATER_EQUAL, LESS_EQUAL, EQUALS, NOT_EQUAL
%left '+' '-'
%left '*' '/'
%right '='
%right NOT

%%
 
Prog  :  { currEscopo = null; currClass = ClasseID.VarGlobal; } ListaDecl 
      ;

ListaDecl : DeclVar ListaDecl
          | DeclFunc ListaDecl
	        | /* vazio */
          ;

DeclVar   : Tipo ListaIdent ';'
          ;

DeclFunc  : FUNC TipoOuVoid IDENT '(' FormalPar ')' '{' 
            {
                TS_entry nodo = ts.pesquisa($3);
                if(nodo != null){
                  yyerror("(sem) Funcao >" + $3 + "< ja declarada");
                }
                ts.insert(new TS_entry($3, $2, null, ClasseID.NomeFuncao), null);
                currEscopo= nodo;
                currClass = ClasseID.Funcao;
            }
          LCmd '}'
            {
                currEscopo = null;
                currClass = ClasseID.VarGlobal;
            }
          ;

TipoOuVoid  : VOID {$$ = Tp_VOID;}
            | Tipo SufixoTipoArraySemIndex
            ;

Tipo  : INT {$$ = Tp_INT;}
      | DOUBLE {$$ = Tp_FLOAT;}
      | BOOLEAN {$$ = Tp_BOOL;}
      ;

SufixoTipoArrayIndex  : '[' NUM ']' SufixoTipoArrayIndex
            | /* vazio */
            ; 

SufixoTipoArraySemIndex : '['']' SufixoTipoArraySemIndex
            | /* vazio */
            ; 

ListaIdent : IDENT SufixoTipoArrayIndex RestoListaIdent
            {
              TS_entry nodo = ts.pesquisa($1);
              if(nodo != null){
                yyerror("(sem) Variavel >" + $1 + "< ja declarada");
              }
              ts.insert(new TS_entry($1, $2, null, ClasseID.NomeVar), currEscopo);
            }
          ;

RestoListaIdent : ',' IDENT RestoListaIdent
                | /* vazio */
                ;

FormalPar : ParamList
          | /* vazio */
          ;

ParamCallList : IDENT RestoParamCall
                {
                  TS_entry nodo = ts.pesquisa($1);
                  if(nodo == null){
                    yyerror("(sem) Variavel >" + $1 + "< não declarada");
                  }
                }
              | NUM RestoParamCall
              ;    
                
FormalParCall : ParamCallList
              | /* vazio */
              ;
              
ParamList : Tipo IDENT SufixoTipoArraySemIndex RestoParam
            {
              ts.insert(new TS_entry($2, $1, null, ClasseID.NomeParam), currEscopo);
            }
          ;

RestoParamCall  : ',' IDENT RestoParamCall
                | ',' NUM RestoParamCall
                | /* vazio */
                ;

RestoParam : ',' Tipo IDENT SufixoTipoArraySemIndex RestoParam
            {
              ts.insert(new TS_entry($3, $2, null, ClasseID.NomeParam), currEscopo);
            }
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
              {
                $$ = $1;
              }
            | /* vazio */
              {
                $$ = Tp_VOID;
              }
            ;

E : E '+' E {$$ = validaTipo('+', (TS_entry)$1, (TS_entry)$3);}
  | E '-' E {$$ = validaTipo('-', (TS_entry)$1, (TS_entry)$3);}
  | E '*' E {$$ = validaTipo('*', (TS_entry)$1, (TS_entry)$3);}
  | E '/' E {$$ = validaTipo('/', (TS_entry)$1, (TS_entry)$3);}
  | E '<' E {$$ = validaTipo('<', (TS_entry)$1, (TS_entry)$3);}
  | E '>' E {$$ = validaTipo('>', (TS_entry)$1, (TS_entry)$3);}
  | IDENT SufixoTipoArrayIndex '=' E 
    {
      TS_entry nodo = ts.pesquisa($1);
      if(nodo == null){
        yyerror("(sem) Variavel >" + $1 + "< não declarada");
      }
      $$ = validaTipo('=', nodo, (TS_entry)$4);
      ts.insert(new TS_entry($1, nodo.getTipo(), null, ClasseID.NomeVar), currEscopo);
    }
  | E AND E {$$ = validaTipo(AND, (TS_entry)$1, (TS_entry)$3);}
  | E OR E  {$$ = validaTipo(OR, (TS_entry)$1, (TS_entry)$3);}
  | E EQUALS E {$$ = validaTipo(EQUALS, (TS_entry)$1, (TS_entry)$3);}
  | E GREATER_EQUAL E {$$ = validaTipo(GREATER_EQUAL, (TS_entry)$1, (TS_entry)$3);}
  | E LESS_EQUAL E {$$ = validaTipo(LESS_EQUAL, (TS_entry)$1, (TS_entry)$3);}
  | E NOT_EQUAL E {$$ = validaTipo(NOT_EQUAL, (TS_entry)$1, (TS_entry)$3);}
  | NOT E {$$ = validaTipo(NOT, (TS_entry)$2, null);}
  | NUM {$$ = validaTipo(NUM, (TS_entry)$1, null);}
  | '(' E ')' {$$ = $2;}
  | IDENT '(' FormalParCall ')'
    {
      TS_entry nodo = ts.pesquisa($1);
      if(nodo == null){
        yyerror("(sem) Funcao >" + $1 + "< não declarada");
      }
      ts.insert(new TS_entry($1, nodo.getTipo(), null, ClasseID.NomeFuncao), currEscopo);
    }
  | IDENT SufixoTipoArrayIndex
    {
      TS_entry nodo = ts.pesquisa($1);
      if(nodo == null){
        yyerror("(sem) Variavel >" + $1 + "< não declarada");
      }
      $$ = validaTipo('[', nodo, null);
    }
  ;

%%

  private Yylex lexer;
  
  private TabSimb ts;

  public static TS_entry Tp_INT =  new TS_entry("int", null, null, ClasseID.TipoBase);
  public static TS_entry Tp_FLOAT = new TS_entry("float", null, null, ClasseID.TipoBase);
  public static TS_entry Tp_BOOL = new TS_entry("bool", null, null, ClasseID.TipoBase);
  public static TS_entry Tp_ARRAY = new TS_entry("array", null, null, ClasseID.TipoBase);
  public static TS_entry Tp_ERRO = new TS_entry("_erro_", null, null, ClasseID.TipoBase);

  public static final int ARRAY = 1500;
  public static final int ATRIB = 1600;

  private TS_entry currEscopo;
  private ClasseID currClass;



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
    System.err.println ("Erro (linha: "+ lexer.getLine() + ")\tMensagem: "+error);
  }


  
  public Parser(Reader r) {
    lexer = new Yylex(r, this);

    ts = new TabSimb();

    //
    // não me parece que necessitem estar na TS
    // já que criei todas como public static...
    //
    ts.insert(Tp_ERRO);
    ts.insert(Tp_INT);
    ts.insert(Tp_FLOAT);
    ts.insert(Tp_BOOL);
    ts.insert(Tp_STRING);
    ts.insert(Tp_ARRAY);
    ts.insert(Tp_STRUCT);
    

  }  


  static boolean interactive;

  public void setDebug(boolean debug) {
    yydebug = debug;
  }

  public void listarTS() { ts.listar();}


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

  TS_entry validaTipo(int operador, TS_entry A, TS_entry B) {
       
         switch ( operador ) {
            case '=':
                  if ( (A == Tp_INT && B == Tp_INT)                        ||
                        ((A == Tp_FLOAT && (B == Tp_INT || B == Tp_FLOAT))) ||
                        (A == B) )
                        return A;
                    else
                        yyerror("(sem) tipos incomp. para atribuicao: "+ A.getTipoStr() + " = "+B.getTipoStr());
                  break;


            case '+' :
                  if ( A == Tp_INT && B == Tp_INT)
                        return Tp_INT;
                  else if ( (A == Tp_FLOAT && (B == Tp_INT || B == Tp_FLOAT)) ||
                              (B == Tp_FLOAT && (A == Tp_INT || A == Tp_FLOAT)) ) 
                        return Tp_FLOAT;
                  else
                      yyerror("(sem) tipos incomp. para soma: "+ A.getTipoStr() + " + "+B.getTipoStr());
                  break;
            case '-': 
            case '*':
            case '/':
                    if ( A == Tp_INT && B == Tp_INT)
                          return Tp_INT;
                    else if ( (A == Tp_FLOAT && (B == Tp_INT || B == Tp_FLOAT)) ||
				              		      (B == Tp_FLOAT && (A == Tp_INT || A == Tp_FLOAT)) ) 
                         return Tp_FLOAT;
                    else
                        yyerror("(sem) tipos incomp. para operação: "+ A.getTipoStr() + " "+ operador +" "+B.getTipoStr());
                    break;
            case '>' :
            case '<':
            case GREATER_EQUAL:
            case LESS_EQUAL:
            case EQUALS:
            case NOT_EQUAL:
                if ((A == Tp_INT || A == Tp_FLOAT) && (B == Tp_INT || B == Tp_FLOAT))
                        return Tp_BOOL;
                else
                      yyerror("(sem) tipos incomp. para op relacional: "+ A.getTipoStr() + " "+ operador + " "+B.getTipoStr());
                break;
            case AND:
            case OR:
                if (A == Tp_BOOL && B == Tp_BOOL)
                        return Tp_BOOL;
                else
                      yyerror("(sem) tipos incomp. para op lógica: "+ A.getTipoStr() + " "+ operador + " "+B.getTipoStr());
                break;
            case NOT:
                if (A == Tp_BOOL)
                        return Tp_BOOL;
                else
                      yyerror("(sem) tipos incomp. para op lógica: "+ A.getTipoStr() + " "+ operador + " "+B.getTipoStr());
                break;
            case '[':
                if (B != Tp_INT)
                    yyerror("(sem) expressão indexadora deve ser inteira: " + B.getTipoStr());                
                else if (A.getTipo() != Tp_ARRAY)
                          yyerror("(sem) var <" + A.getTipoStr() + "> nao é do tipo array");                
                else 
                    return A.getTipoBase();
                break;
						}
            case NUM:
                if (A == Tp_INT)
                    return Tp_INT;
                else if (A == Tp_FLOAT)
                    return Tp_FLOAT;
                break;
            return Tp_ERRO;
				}






