%{
  import java.io.*;
  import java.util.ArrayList;
%}


%token IDENT, INT, FLOAT, BOOL, NUM, STRING, RETURN, VOID
%token LITERAL, AND, MAIN, IF


%right '='
%nonassoc '>'
%left '+'
%left AND
%left '[' '.' 

%type <sval> IDENT
%type <sval> LITERAL
%type <ival> NUM
%type <obj> type
%type <obj> exp

%%

prog : { currEscopo = null; currClass = ClasseID.VarGlobal; } dList
      {
        TS_entry mainFunc = ts.pesquisa("main", currEscopo);
        if (mainFunc == null) {
          yyerror("(sem) funcao main nao declarada");
        } else {
          if (mainFunc.getTipo() != Tp_VOID) {
            yyerror("(sem) funcao main deve ser do tipo void");
          }
        }
      }
      ;

dList : decl dList | ;

decl : declFunc
    | declVar
    ;
    
declVar : type IDENT ';' 
            {  TS_entry nodo = ts.pesquisa($2, currEscopo);
              if (nodo != null) 
                  yyerror("(sem) variavel >" + $2 + "< jah declarada");
              else ts.insert(new TS_entry($2, (TS_entry)$1, currEscopo, currClass), currEscopo); 
            }
        | type '[' NUM ']' IDENT  ';' 
            { TS_entry nodo = ts.pesquisa($5, currEscopo);
              if (nodo != null) 
                  yyerror("(sem) variavel (array) >" + $5 + "< jah declarada");
              else ts.insert(new TS_entry($5, Tp_ARRAY, $3, (TS_entry)$1, currEscopo, currClass), currEscopo); 
            }
            
/* main : FUNCTION VOID MAIN '(' ')' bloco ; */

formalPar : paramList
          | /* vazio */
          ;

paramList : type IDENT sufixoArray restoParam 
            {
              TS_entry nodo = ts.pesquisa($2, currEscopo);
              if (nodo != null) 
                  yyerror("(sem) variavel >" + $2 + "< ja declarada");
              else {
                  nodo = new TS_entry($2, (TS_entry)$1, currEscopo, ClasseID.ParametroFuncao);
                  ts.insert(nodo, currEscopo);
              }
            }
          ;

sufixoArray : '['']' sufixoArray
            | /* vazio */
            ; 

restoParam : ',' type IDENT sufixoArray restoParam
            {
              TS_entry nodo = ts.pesquisa($3, currEscopo);
              if (nodo != null) 
                  yyerror("(sem) variavel >" + $3 + "< ja declarada");
              else {
                  nodo = new TS_entry($3, (TS_entry)$2, currEscopo, ClasseID.ParametroFuncao);
                  ts.insert(nodo, currEscopo);
              }
            }
          | /* vazio */
          ;
     
declFunc : type IDENT  {  TS_entry nodo = ts.pesquisa($2, currEscopo);
    	                        if (nodo != null) 
                                 yyerror("(sem) funcao >" + $2 + "< jah declarada");
                              else {
                                 nodo = new TS_entry($2, (TS_entry) $1, currEscopo, ClasseID.NomeFuncao);
                                 ts.insert(nodo, currEscopo);
 															   currEscopo = nodo; 
                                 currClass = ClasseID.ParametroFuncao; 
                                }
                            }
               '(' formalPar ')'
                  { 
                    currClass = ClasseID.VarLocal; 
                  }
                bloco 
                  { currEscopo = null; currClass = ClasseID.VarGlobal; }
             ;
              //
              // faria mais sentido reconhecer todos os tipos como ident! 
              // 
type : INT    { $$ = Tp_INT; }
     | FLOAT  { $$ = Tp_FLOAT; }
     | BOOL   { $$ = Tp_BOOL; }
	   | STRING { $$ = Tp_STRING; }
     | VOID   { $$ = Tp_VOID; }
     | IDENT  { TS_entry nodo = ts.pesquisa($1, currEscopo);
    	                if (nodo == null ) 
                           yyerror("(sem) Nome de tipo <" + $1 + "> nao declarado ");
                        else 
                            $$ = nodo;
                     } 
     ;

bloco : '{' listacmd '}';

listacmd : listacmd cmd
		|
 		;

cmd :  exp ';' 
      | IF '(' exp ')' cmd 
                 {if ( ((TS_entry)$3).getTipo() != Tp_BOOL.getTipo()) 
                           yyerror("(sem) expressão (if) deve ser lógica "+((TS_entry)$3).getTipo());
                  }    
      | RETURN exp ';'
        {
          TS_entry tipoFunc = currEscopo.getTipo();
          TS_entry tipoRet = ((TS_entry)$2);

          //VOID
          if (tipoFunc == Tp_VOID && tipoRet != Tp_VOID) {
            yyerror("(sem) função void não deve retornar valor. Encontrado: " + tipoRet.getTipoStr());
          } 
          //FLOAT
          else if (tipoFunc == Tp_FLOAT && (tipoRet != Tp_FLOAT && tipoRet != Tp_INT) || 
                  (tipoFunc == Tp_BOOL && (tipoRet != Tp_BOOL && tipoRet != Tp_INT)) ||
                  (tipoFunc == Tp_STRING && tipoRet != Tp_STRING) ||
                  (tipoFunc == Tp_INT && tipoRet != Tp_INT)){
              yyerror("(sem) tipo de retorno incompatível: esperado " + tipoFunc.getTipoStr() + ", encontrado " + (tipoRet.getTipoStr()));
          } 
        }
      | declVar
      ;

exp : exp '+' exp { $$ = validaTipo('+', (TS_entry)$1, (TS_entry)$3); }
   	| exp '>' exp { $$ = validaTipo('>', (TS_entry)$1, (TS_entry)$3);}
 	  | exp AND exp { $$ = validaTipo(AND, (TS_entry)$1, (TS_entry)$3); } 
    | NUM         { numLido = $1; $$ = Tp_INT; }      
    | '(' exp ')' { $$ = $2; }
    | LITERAL     { $$ = Tp_STRING; }      
    | IDENT       { TS_entry nodo = ts.pesquisa($1, currEscopo);
    	                 if (nodo == null) 
	                        yyerror("(sem) var <" + $1 + "> nao declarada");                
                      else
			                    $$ = nodo.getTipo();
			            }   
    | IDENT '[' exp ']' 
                 { TS_entry nodo = ts.pesquisa($1, currEscopo);
    	             if (nodo == null) 
	                     yyerror("(sem) var <" + $1 + "> nao declarada");                
                   else if (nodo.getTipo() != Tp_ARRAY)
                       yyerror("(sem) var <" + $1 + "> nao é do tipo array");
                   else if(((TS_entry)$3) != Tp_INT)
                       yyerror("(sem) index deve ser valor inteiro: Recebido " + ((TS_entry)$3));
                  else if(nodo.getNumElem() <= Integer.valueOf(numLido)){
                      yyerror("(sem) index maior ou igual que tamanho do array. Recebido: " + numLido + " | Tamanho: " + nodo.getNumElem());
                  }
                       $$ = validaTipo('[', nodo, (TS_entry)$3);
						     }
    | exp '=' exp  
                 {  $$ = validaTipo(ATRIB, (TS_entry)$1, (TS_entry)$3);                      
                 } 
    | IDENT 
      {
        TS_entry nodo = ts.pesquisa($1, currEscopo);
        if (nodo == null) 
            yyerror("(sem) funcao <" + $1 + "> nao declarada"); 
        currFuncCall = nodo;
        setParametroCall(currFuncCall);

        indiceParametro = 0;
      }
    '(' formalParCall ')' 
      {
        TS_entry nodo = ts.pesquisa($1, currEscopo);
        if (nodo == null) 
            yyerror("(sem) funcao <" + $1 + "> nao declarada"); 
        
        else
            $$ = nodo.getTipo();
      }
     /* | exp '.' IDENT 
                 { if (((TS_entry)$1).getTipo() != Tp_STRUCT) 
	                     yyerror("(sem) Esperado tipo STRUCT e recebido >" + ((TS_entry)$1).getId() + ">" + $1);                
                   else {
                         TS_entry nodo = ((TS_entry)$1).getLocalTS().pesquisa($3);
                         if (nodo == null)
                            yyerror("(sem) <" +$3+"> não é campo da STRUCT <"+ ((TS_entry)$1).getId() + ">");                
                         else 
                             $$ = nodo.getTipo();
                       }
						     }  */
    ;

formalParCall : paramCallList
              {
                if (listaParamCall.size() != listaArgumentosCall.size()) {
                  yyerror("(sem) numero de parametros da funcao <" + currFuncCall.getId() + "> invalido: esperado " + listaParamCall.size() + ", encontrado " + listaArgumentosCall.size());
                } else {
                  for (int i = 0; i < listaParamCall.size(); i++) {
                    TS_entry parametro = listaParamCall.get(i);
                    TS_entry argumento = listaArgumentosCall.get(i);
                    if ((argumento.getClasse() == ClasseID.TipoBase && parametro.getTipo() != argumento) ||
                        ((argumento.getClasse() != ClasseID.TipoBase && parametro.getTipo() != argumento.getTipo()))) {
                      if(argumento.getClasse() != ClasseID.TipoBase){
                        yyerror("(sem) tipo de parametro <" + parametro.getId() + "> da funcao <" + currFuncCall.getId() + "> invalido: esperado " + parametro.getTipo().getTipoStr() + ", encontrado " + argumento.getTipo().getId());
                      }
                      else{
                        yyerror("(sem) tipo de parametro <" + parametro.getId() + "> da funcao <" + currFuncCall.getId() + "> invalido: esperado " + parametro.getTipo().getTipoStr() + ", encontrado " + argumento.getId());
                      }
                    }
                  }
                }
              }
              | /* vazio */
              ;

paramCallList : IDENT  
                restoParamCall
                {
                  TS_entry nodo = ts.pesquisa($1, currEscopo);
                  if (nodo == null) 
                      yyerror("(sem) variavel >" + $1 + "< nao declarada");
                  else{
                    listaArgumentosCall.add(nodo);

                  }
                  // TS_entry parametro = listaParamCall.get(indiceParametro);
                  // if(parametro.getTipo() != nodo.getTipo() && parametro.getClasse() == ClasseID.ParametroFuncao) {
                  //     yyerror("(sem) tipo de parametro <"+ parametro.getId() +"> da funcao <" + currFuncCall.getId() + "> invalido: esperado " + listaParamCall.get(indiceParametro).getTipo().getTipoStr() + ", encontrado " + nodo.getTipo().getTipoStr());
                  // }
                  // indiceParametro++;
                }
              | NUM 
                restoParamCall
                {
                  // TS_entry parametro = listaParamCall.get(indiceParametro);
                  // if(parametro.getTipo() != Tp_INT && parametro.getTipo() != Tp_FLOAT && parametro.getClasse() == ClasseID.ParametroFuncao){
                  //     yyerror("(sem) tipo de parametro <"+ parametro.getId() +"> da funcao <" + currFuncCall.getId() + "> invalido: esperado " + listaParamCall.get(indiceParametro).getTipo().getTipoStr() + ", encontrado " + $1);
                  // }
                  // indiceParametro++;
                  listaArgumentosCall.add(Tp_INT);

                }
              | LITERAL 
                restoParamCall
                {
                  // TS_entry parametro = listaParamCall.get(indiceParametro);
                  // if(parametro.getTipo() != Tp_STRING && parametro.getClasse() == ClasseID.ParametroFuncao){
                  //     yyerror("(sem) tipo de parametro <"+ parametro.getId() +"> da funcao <" + currFuncCall.getId() + "> invalido: esperado " + listaParamCall.get(indiceParametro).getTipo().getTipoStr() + ", encontrado " + $1);
                  // }
                  // indiceParametro++;
                  listaArgumentosCall.add(Tp_STRING);

                }
              ;

restoParamCall  : ',' IDENT 
                  restoParamCall
                  {
                    TS_entry nodo = ts.pesquisa($2, currEscopo);
                    if (nodo == null) 
                        yyerror("(sem) variavel >" + $2 + "< nao declarada");
                    else{
                    listaArgumentosCall.add(nodo);

                    }
                    // TS_entry parametro = listaParamCall.get(indiceParametro);
                    // if(parametro.getTipo() != nodo.getTipo() && parametro.getClasse() == ClasseID.ParametroFuncao) {
                    //   yyerror("(sem) tipo de parametro <"+ parametro.getId() +"> da funcao <" + currFuncCall.getId() + "> invalido: esperado " + listaParamCall.get(indiceParametro).getTipo().getTipoStr() + ", encontrado " + nodo.getTipo().getTipoStr());
                    // }
                    // indiceParametro++;

                  }
                | ',' NUM 
                  restoParamCall
                  {
                    // TS_entry parametro = listaParamCall.get(indiceParametro);
                    // if(parametro.getTipo() != Tp_INT && parametro.getTipo() != Tp_FLOAT && parametro.getClasse() == ClasseID.ParametroFuncao){
                    //     yyerror("(sem) tipo de parametro <"+ parametro.getId() +"> da funcao <" + currFuncCall.getId() + "> invalido: esperado " + listaParamCall.get(indiceParametro).getTipo().getTipoStr() + ", encontrado " + $2);
                    // }
                    // indiceParametro++;
                    listaArgumentosCall.add(Tp_INT);

                  }
                | ',' LITERAL 
                  restoParamCall
                  {
                    // TS_entry parametro = listaParamCall.get(indiceParametro);
                    // if(parametro.getTipo() != Tp_STRING && parametro.getClasse() == ClasseID.ParametroFuncao){
                    //     yyerror("(sem) tipo de parametro <"+ parametro.getId() +"> da funcao <" + currFuncCall.getId() + "> invalido: esperado " + listaParamCall.get(indiceParametro).getTipo().getTipoStr() + ", encontrado " + $2);
                    // }
                    // indiceParametro++;
                    listaArgumentosCall.add(Tp_STRING);

                  }
                | /* vazio */
                ;

%%

  private Yylex lexer;

  private TabSimb ts;

  public static TS_entry Tp_INT =  new TS_entry("int", null, null, ClasseID.TipoBase);
  public static TS_entry Tp_FLOAT = new TS_entry("float", null, null, ClasseID.TipoBase);
  public static TS_entry Tp_BOOL = new TS_entry("bool", null, null, ClasseID.TipoBase);
  public static TS_entry Tp_STRING = new TS_entry("string", null, null, ClasseID.TipoBase);
  public static TS_entry Tp_ARRAY = new TS_entry("array", null, null, ClasseID.TipoBase);
  public static TS_entry Tp_VOID = new TS_entry("void", null, null, ClasseID.TipoBase);
  public static TS_entry Tp_ERRO = new TS_entry("_erro_", null, null, ClasseID.TipoBase);
  public static final int ARRAY = 1500;
  public static final int ATRIB = 1600;

  private TS_entry currEscopo;
  private ClasseID currClass;
  private int indiceParametro = 0;
  private int numLido = 0;
  private TS_entry currFuncCall;
  private static ArrayList<TS_entry> listaParamCall = new ArrayList<TS_entry>();
  private static ArrayList<TS_entry> listaArgumentosCall = new ArrayList<TS_entry>();
 

  public void setParametroCall(TS_entry func){
    listaParamCall = new ArrayList<TS_entry>();
    listaArgumentosCall = new ArrayList<TS_entry>();
    for(TS_entry simb : func.getLocalTS().getLista()){
      if (simb.getClasse() == ClasseID.ParametroFuncao){
        listaParamCall.add(simb);
      }
    }
  }

  private int yylex () {
    int yyl_return = -1;
    try {
      yylval = new ParserVal(0);
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      System.err.println("IO error :"+e);
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
    ts.insert(Tp_VOID);
  

  }  

  public void setDebug(boolean debug) {
    yydebug = debug;
  }

  public void listarTS() { ts.listar();}

  public static void main(String args[]) throws IOException {
    System.out.println("\n\nVerificador semantico simples\n");
    

    Parser yyparser;
    if ( args.length > 0 ) {
      // parse a file
      yyparser = new Parser(new FileReader(args[0]));
    }
    else {
      // interactive mode
      System.out.println("[Quit with CTRL-D]");
      System.out.print("Programa de entrada:\n");
	    yyparser = new Parser(new InputStreamReader(System.in));
    }

    yyparser.yyparse();

  	yyparser.listarTS();

	  System.out.print("\n\nFeito!\n");
    
  }


   TS_entry validaTipo(int operador, TS_entry A, TS_entry B) {
       
         switch ( operador ) {
              case ATRIB:
                    if ( (A == Tp_INT && B == Tp_INT)                        ||
                         ((A == Tp_FLOAT && (B == Tp_INT || B == Tp_FLOAT))) ||
                         (A ==Tp_STRING)                                     ||
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
                    else if (A==Tp_STRING || B==Tp_STRING)
                        return Tp_STRING;
                    else
                        yyerror("(sem) tipos incomp. para soma: "+ A.getTipoStr() + " + "+B.getTipoStr());
                    break;
             case '>' :
   	              if ((A == Tp_INT || A == Tp_FLOAT) && (B == Tp_INT || B == Tp_FLOAT))
                         return Tp_BOOL;
					        else
                        yyerror("(sem) tipos incomp. para op relacional: "+ A.getTipoStr() + " > "+B.getTipoStr());
			            break;
             case AND:
 	                if (A == Tp_BOOL && B == Tp_BOOL)
                         return Tp_BOOL;
					       else
                        yyerror("(sem) tipos incomp. para op lógica: "+ A.getTipoStr() + " && "+B.getTipoStr());
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

            return Tp_ERRO;
				}



