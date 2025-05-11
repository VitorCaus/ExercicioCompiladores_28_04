//### This file created by BYACC 1.8(/Java extension  1.15)
//### Java capabilities added 7 Jan 97, Bob Jamison
//### Updated : 27 Nov 97  -- Bob Jamison, Joe Nieten
//###           01 Jan 98  -- Bob Jamison -- fixed generic semantic constructor
//###           01 Jun 99  -- Bob Jamison -- added Runnable support
//###           06 Aug 00  -- Bob Jamison -- made state variables class-global
//###           03 Jan 01  -- Bob Jamison -- improved flags, tracing
//###           16 May 01  -- Bob Jamison -- added custom stack sizing
//###           04 Mar 02  -- Yuval Oren  -- improved java performance, added options
//###           14 Mar 02  -- Tomas Hurka -- -d support, static initializer workaround
//### Please send bug reports to tom@hukatronic.cz
//### static char yysccsid[] = "@(#)yaccpar	1.8 (Berkeley) 01/20/90";






//#line 7 "exerc.y"
  import java.io.*;
//#line 19 "Parser.java"




public class Parser
{

boolean yydebug;        //do I want debug output?
int yynerrs;            //number of errors so far
int yyerrflag;          //was there an error?
int yychar;             //the current working character

//########## MESSAGES ##########
//###############################################################
// method: debug
//###############################################################
void debug(String msg)
{
  if (yydebug)
    System.out.println(msg);
}

//########## STATE STACK ##########
final static int YYSTACKSIZE = 500;  //maximum stack size
int statestk[] = new int[YYSTACKSIZE]; //state stack
int stateptr;
int stateptrmax;                     //highest index of stackptr
int statemax;                        //state when highest index reached
//###############################################################
// methods: state stack push,pop,drop,peek
//###############################################################
final void state_push(int state)
{
  try {
		stateptr++;
		statestk[stateptr]=state;
	 }
	 catch (ArrayIndexOutOfBoundsException e) {
     int oldsize = statestk.length;
     int newsize = oldsize * 2;
     int[] newstack = new int[newsize];
     System.arraycopy(statestk,0,newstack,0,oldsize);
     statestk = newstack;
     statestk[stateptr]=state;
  }
}
final int state_pop()
{
  return statestk[stateptr--];
}
final void state_drop(int cnt)
{
  stateptr -= cnt; 
}
final int state_peek(int relative)
{
  return statestk[stateptr-relative];
}
//###############################################################
// method: init_stacks : allocate and prepare stacks
//###############################################################
final boolean init_stacks()
{
  stateptr = -1;
  val_init();
  return true;
}
//###############################################################
// method: dump_stacks : show n levels of the stacks
//###############################################################
void dump_stacks(int count)
{
int i;
  System.out.println("=index==state====value=     s:"+stateptr+"  v:"+valptr);
  for (i=0;i<count;i++)
    System.out.println(" "+i+"    "+statestk[i]+"      "+valstk[i]);
  System.out.println("======================");
}


//########## SEMANTIC VALUES ##########
//public class ParserVal is defined in ParserVal.java


String   yytext;//user variable to return contextual strings
ParserVal yyval; //used to return semantic vals from action routines
ParserVal yylval;//the 'lval' (result) I got from yylex()
ParserVal valstk[];
int valptr;
//###############################################################
// methods: value stack push,pop,drop,peek.
//###############################################################
void val_init()
{
  valstk=new ParserVal[YYSTACKSIZE];
  yyval=new ParserVal();
  yylval=new ParserVal();
  valptr=-1;
}
void val_push(ParserVal val)
{
  if (valptr>=YYSTACKSIZE)
    return;
  valstk[++valptr]=val;
}
ParserVal val_pop()
{
  if (valptr<0)
    return new ParserVal();
  return valstk[valptr--];
}
void val_drop(int cnt)
{
int ptr;
  ptr=valptr-cnt;
  if (ptr<0)
    return;
  valptr = ptr;
}
ParserVal val_peek(int relative)
{
int ptr;
  ptr=valptr-relative;
  if (ptr<0)
    return new ParserVal();
  return valstk[ptr];
}
final ParserVal dup_yyval(ParserVal val)
{
  ParserVal dup = new ParserVal();
  dup.ival = val.ival;
  dup.dval = val.dval;
  dup.sval = val.sval;
  dup.obj = val.obj;
  return dup;
}
//#### end semantic value section ####
public final static short IF=257;
public final static short ELSE=258;
public final static short WHILE=259;
public final static short AND=260;
public final static short NUM=261;
public final static short IDENT=262;
public final static short VOID=263;
public final static short INT=264;
public final static short DOUBLE=265;
public final static short BOOLEAN=266;
public final static short FUNC=267;
public final static short RETURN=268;
public final static short NOT=269;
public final static short OR=270;
public final static short GREATER_EQUAL=271;
public final static short LESS_EQUAL=272;
public final static short EQUALS=273;
public final static short NOT_EQUAL=274;
public final static short YYERRCODE=256;
final static short yylhs[] = {                           -1,
    0,    1,    1,    1,    2,    3,    6,    6,    4,    4,
    4,   10,   10,    9,    9,    5,   11,   11,    7,    7,
   13,   13,   15,   15,   12,   14,   14,   14,   16,   16,
   17,    8,    8,   18,   18,   18,   18,   18,   18,   18,
   20,   20,   19,   19,   19,   19,   19,   19,   19,   19,
   19,   19,   19,   19,   19,   19,   19,   19,   19,   19,
};
final static short yylen[] = {                            2,
    1,    2,    2,    0,    3,    9,    1,    2,    1,    1,
    1,    3,    0,    2,    0,    3,    3,    0,    1,    0,
    2,    2,    1,    0,    4,    3,    3,    0,    5,    0,
    3,    2,    0,    1,    5,    7,    5,    2,    3,    1,
    1,    0,    3,    3,    3,    3,    3,    3,    4,    3,
    3,    3,    3,    3,    3,    2,    1,    3,    4,    2,
};
final static short yydefred[] = {                         0,
    9,   10,   11,    0,    0,    1,    0,    0,    0,    7,
    0,    0,    2,    3,    0,    0,    0,    8,    0,    0,
    0,    5,   14,    0,    0,    0,   16,    0,    0,   19,
   12,    0,    0,    0,   17,    0,    0,    0,   25,    0,
    0,   57,    0,    0,    0,    0,    0,   40,    0,   34,
    0,    0,    0,    0,    0,    0,    0,    0,    0,   56,
    0,    0,    6,   32,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,   38,    0,    0,    0,
    0,    0,   23,    0,    0,   39,   58,   31,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,   45,   46,
    0,    0,    0,    0,   22,   21,   59,   49,   29,    0,
   37,    0,    0,    0,   27,   26,   36,
};
final static short yydgoto[] = {                          5,
    6,   48,    8,    9,   16,   12,   29,   49,   18,   21,
   27,   30,   83,  105,   84,   39,   50,   51,   52,   59,
};
final static short yysindex[] = {                      -144,
    0,    0,    0, -123,    0,    0, -144, -144, -259,    0,
  -81, -247,    0,    0,  -67,  -27,  -52,    0,   13, -201,
   18,    0,    0,  -82,  -24, -175,    0, -169,   55,    0,
    0,   18,  -81,  -20,    0,   61,  133,  -82,    0,   68,
   73,    0,  -23,  -18,  -18,  -18,  133,    0,   -7,    0,
  133,   86, -136,  -18,  -18, -172,   69,   92,   77,    0,
  -12,    7,    0,    0,  -18,  -18,  -18,  -18,  -18,  -18,
  -18,  -18,  -18,  -18,  -18,  -18,    0,  -81,   -5,    4,
   94,   94,    0,  103,  -18,    0,    0,    0,  114,  108,
  120,  120,  120,  120,  120,  120,   30,   30,    0,    0,
   61,  133,  133,  -90,    0,    0,    0,    0,    0, -111,
    0,   94,   94,  133,    0,    0,    0,
};
final static short yyrindex[] = {                       149,
    0,    0,    0,    0,    0,    0,  149,  149,    0,    0,
 -259,    0,    0,    0,  -32,    0,    0,    0,    0,    0,
   99,    0,    0,  119,    0,    0,    0,    0,    0,    0,
    0,   99,   40,    0,    0,  123,   41,    0,    0,    0,
    0,    0,  -41,  110,    0,    0,   41,    0,    0,    0,
   41,    0,    0,    0,    0,  134,  -34,  126,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,   40,    0,    0,
  145,  145,    0,    0,    0,    0,    0,    0,  -36,  -25,
   26,   35,   42,   50,   57,   65,   11,   20,    0,    0,
  123,    0,    0,    0,    0,    0,    0,    0,    0,  147,
    0,  145,  145,    0,    0,    0,    0,
};
final static short yygindex[] = {                         0,
  170,  107,    0,   54,    0,    0,    0,   -8,  -19,  148,
  156,    0,    0,  -38,    0,   91,    0,   -3,  135,    0,
};
final static int YYTABLESIZE=416;
static short yytable[];
static { yytable();}
static void yytable(){
yytable = new short[]{                         13,
   13,   13,   15,   13,   50,   13,   60,   60,   60,   17,
   60,   13,   60,   36,   19,   51,   56,   13,   13,   13,
   13,   46,   50,   20,   60,   60,   13,   60,   87,   75,
   73,   22,   74,   51,   76,  102,   75,   73,   62,   74,
   23,   76,   64,  106,  103,   75,   73,   72,   74,   71,
   76,   43,   24,   43,   72,   43,   71,   11,  101,   25,
   44,   26,   44,   72,   44,   71,   53,   20,   31,   43,
   43,   75,   43,  115,  116,   54,   76,   28,   44,   44,
   15,   44,   52,   15,   53,   53,   32,   53,   81,   82,
   55,   53,   33,   54,   54,   34,   54,   48,  110,  111,
   52,   52,   37,   52,   38,   47,    7,   54,   55,   55,
  117,   55,   55,    7,    7,   48,   48,   63,   48,    1,
    2,    3,    4,   47,   47,   78,   47,   75,   73,   85,
   74,   88,   76,   75,   73,   86,   74,  104,   76,   10,
    1,    2,    3,  107,   77,   72,  114,   71,    4,   75,
   73,   72,   74,   71,   76,   75,   73,   18,   74,   20,
   76,   75,   73,   30,   74,   33,   76,   72,   42,   71,
  112,  113,   46,   72,   24,   71,   13,   14,   58,   60,
   61,    1,    2,    3,   41,   28,   35,   35,   79,   80,
   57,  109,    0,    0,    0,    0,    0,    0,    0,   89,
   90,   91,   92,   93,   94,   95,   96,   97,   98,   99,
  100,    0,    0,    0,    0,    0,    0,    0,   13,  108,
    0,    0,    0,   50,    0,   60,    0,    0,   13,   13,
   13,   13,   13,   50,    0,   60,   60,   60,   60,   60,
    0,    0,   42,   43,   51,    0,    0,   65,    0,    0,
   45,    0,    0,    0,   65,   47,    0,   66,   67,   68,
   69,   70,    0,   65,   66,   67,   68,   69,   70,   35,
   43,   35,    0,   66,   67,   68,   69,   70,    0,   44,
   43,   43,   43,   43,   43,   53,    0,    0,    0,   44,
   44,   44,   44,   44,   54,   53,   53,   53,   53,   53,
    0,   52,    0,    0,   54,   54,   54,   54,   54,   55,
    0,   52,   52,   52,   52,   52,   48,    0,    0,   55,
   55,   55,   55,   55,   47,    0,   48,   48,   48,   48,
   48,    0,    0,    0,   47,   47,   47,   47,   47,    0,
    0,    0,    0,    0,    0,   65,    0,    0,    0,    0,
    0,   65,    0,    0,    0,   66,   67,   68,   69,   70,
    0,   66,   67,   68,   69,   70,    0,   65,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,   67,   68,
   69,   70,    0,    0,   67,   68,   69,   70,    0,   40,
    0,   41,    0,   42,   43,    0,    1,    2,    3,    0,
   44,   45,    0,   35,    0,   35,    0,   35,   35,    0,
   35,   35,   35,    0,   35,   35,
};
}
static short yycheck[];
static { yycheck(); }
static void yycheck() {
yycheck = new short[] {                         41,
   42,   43,  262,   45,   41,   47,   41,   42,   43,   91,
   45,   44,   47,   33,  262,   41,   40,   59,   60,   61,
   62,   40,   59,   91,   59,   60,   59,   62,   41,   42,
   43,   59,   45,   59,   47,   41,   42,   43,   47,   45,
   93,   47,   51,   82,   41,   42,   43,   60,   45,   62,
   47,   41,   40,   43,   60,   45,   62,    4,   78,  261,
   41,   44,   43,   60,   45,   62,   41,   91,   93,   59,
   60,   42,   62,  112,  113,   41,   47,   24,   59,   60,
   41,   62,   41,   44,   59,   60,  262,   62,  261,  262,
   41,   38,  262,   59,   60,   41,   62,   41,  102,  103,
   59,   60,  123,   62,   44,   41,    0,   40,   59,   60,
  114,   62,   40,    7,    8,   59,   60,  125,   62,  264,
  265,  266,  267,   59,   60,  262,   62,   42,   43,   61,
   45,  125,   47,   42,   43,   59,   45,   44,   47,  263,
  264,  265,  266,   41,   59,   60,  258,   62,    0,   42,
   43,   60,   45,   62,   47,   42,   43,   59,   45,   41,
   47,   42,   43,   41,   45,  125,   47,   60,   59,   62,
  261,  262,   40,   60,   41,   62,    7,    8,   44,   45,
   46,  264,  265,  266,   59,   41,   40,   32,   54,   55,
   43,  101,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   65,
   66,   67,   68,   69,   70,   71,   72,   73,   74,   75,
   76,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  260,   85,
   -1,   -1,   -1,  260,   -1,  260,   -1,   -1,  270,  271,
  272,  273,  274,  270,   -1,  270,  271,  272,  273,  274,
   -1,   -1,  261,  262,  270,   -1,   -1,  260,   -1,   -1,
  269,   -1,   -1,   -1,  260,  123,   -1,  270,  271,  272,
  273,  274,   -1,  260,  270,  271,  272,  273,  274,  123,
  260,  125,   -1,  270,  271,  272,  273,  274,   -1,  260,
  270,  271,  272,  273,  274,  260,   -1,   -1,   -1,  270,
  271,  272,  273,  274,  260,  270,  271,  272,  273,  274,
   -1,  260,   -1,   -1,  270,  271,  272,  273,  274,  260,
   -1,  270,  271,  272,  273,  274,  260,   -1,   -1,  270,
  271,  272,  273,  274,  260,   -1,  270,  271,  272,  273,
  274,   -1,   -1,   -1,  270,  271,  272,  273,  274,   -1,
   -1,   -1,   -1,   -1,   -1,  260,   -1,   -1,   -1,   -1,
   -1,  260,   -1,   -1,   -1,  270,  271,  272,  273,  274,
   -1,  270,  271,  272,  273,  274,   -1,  260,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  271,  272,
  273,  274,   -1,   -1,  271,  272,  273,  274,   -1,  257,
   -1,  259,   -1,  261,  262,   -1,  264,  265,  266,   -1,
  268,  269,   -1,  257,   -1,  259,   -1,  261,  262,   -1,
  264,  265,  266,   -1,  268,  269,
};
}
final static short YYFINAL=5;
final static short YYMAXTOKEN=274;
final static String yyname[] = {
"end-of-file",null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,"'('","')'","'*'","'+'","','",
"'-'",null,"'/'",null,null,null,null,null,null,null,null,null,null,null,"';'",
"'<'","'='","'>'",null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
"'['",null,"']'",null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,"'{'",null,"'}'",null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,
null,null,null,null,null,null,null,null,"IF","ELSE","WHILE","AND","NUM","IDENT",
"VOID","INT","DOUBLE","BOOLEAN","FUNC","RETURN","NOT","OR","GREATER_EQUAL",
"LESS_EQUAL","EQUALS","NOT_EQUAL",
};
final static String yyrule[] = {
"$accept : Prog",
"Prog : ListaDecl",
"ListaDecl : DeclVar ListaDecl",
"ListaDecl : DeclFunc ListaDecl",
"ListaDecl :",
"DeclVar : Tipo ListaIdent ';'",
"DeclFunc : FUNC TipoOuVoid IDENT '(' FormalPar ')' '{' LCmd '}'",
"TipoOuVoid : VOID",
"TipoOuVoid : Tipo SufixoTipoArraySemIndex",
"Tipo : INT",
"Tipo : DOUBLE",
"Tipo : BOOLEAN",
"SufixoTipoArrayIndex : '[' NUM ']'",
"SufixoTipoArrayIndex :",
"SufixoTipoArraySemIndex : '[' ']'",
"SufixoTipoArraySemIndex :",
"ListaIdent : IDENT SufixoTipoArrayIndex RestoListaIdent",
"RestoListaIdent : ',' IDENT RestoListaIdent",
"RestoListaIdent :",
"FormalPar : ParamList",
"FormalPar :",
"ParamCallList : IDENT RestoParamCall",
"ParamCallList : NUM RestoParamCall",
"FormalParCall : ParamCallList",
"FormalParCall :",
"ParamList : Tipo IDENT SufixoTipoArraySemIndex RestoParam",
"RestoParamCall : ',' IDENT RestoParamCall",
"RestoParamCall : ',' NUM RestoParamCall",
"RestoParamCall :",
"RestoParam : ',' Tipo IDENT SufixoTipoArraySemIndex RestoParam",
"RestoParam :",
"Bloco : '{' LCmd '}'",
"LCmd : C LCmd",
"LCmd :",
"C : Bloco",
"C : IF '(' E ')' C",
"C : IF '(' E ')' C ELSE C",
"C : WHILE '(' E ')' C",
"C : E ';'",
"C : RETURN RestoReturn ';'",
"C : DeclVar",
"RestoReturn : E",
"RestoReturn :",
"E : E '+' E",
"E : E '-' E",
"E : E '*' E",
"E : E '/' E",
"E : E '<' E",
"E : E '>' E",
"E : IDENT SufixoTipoArrayIndex '=' E",
"E : E AND E",
"E : E OR E",
"E : E EQUALS E",
"E : E GREATER_EQUAL E",
"E : E LESS_EQUAL E",
"E : E NOT_EQUAL E",
"E : NOT E",
"E : NUM",
"E : '(' E ')'",
"E : IDENT '(' FormalParCall ')'",
"E : IDENT SufixoTipoArrayIndex",
};

//#line 126 "exerc.y"

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






//#line 418 "Parser.java"
//###############################################################
// method: yylexdebug : check lexer state
//###############################################################
void yylexdebug(int state,int ch)
{
String s=null;
  if (ch < 0) ch=0;
  if (ch <= YYMAXTOKEN) //check index bounds
     s = yyname[ch];    //now get it
  if (s==null)
    s = "illegal-symbol";
  debug("state "+state+", reading "+ch+" ("+s+")");
}





//The following are now global, to aid in error reporting
int yyn;       //next next thing to do
int yym;       //
int yystate;   //current parsing state from state table
String yys;    //current token string


//###############################################################
// method: yyparse : parse input and execute indicated items
//###############################################################
int yyparse()
{
boolean doaction;
  init_stacks();
  yynerrs = 0;
  yyerrflag = 0;
  yychar = -1;          //impossible char forces a read
  yystate=0;            //initial state
  state_push(yystate);  //save it
  val_push(yylval);     //save empty value
  while (true) //until parsing is done, either correctly, or w/error
    {
    doaction=true;
    if (yydebug) debug("loop"); 
    //#### NEXT ACTION (from reduction table)
    for (yyn=yydefred[yystate];yyn==0;yyn=yydefred[yystate])
      {
      if (yydebug) debug("yyn:"+yyn+"  state:"+yystate+"  yychar:"+yychar);
      if (yychar < 0)      //we want a char?
        {
        yychar = yylex();  //get next token
        if (yydebug) debug(" next yychar:"+yychar);
        //#### ERROR CHECK ####
        if (yychar < 0)    //it it didn't work/error
          {
          yychar = 0;      //change it to default string (no -1!)
          if (yydebug)
            yylexdebug(yystate,yychar);
          }
        }//yychar<0
      yyn = yysindex[yystate];  //get amount to shift by (shift index)
      if ((yyn != 0) && (yyn += yychar) >= 0 &&
          yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
        {
        if (yydebug)
          debug("state "+yystate+", shifting to state "+yytable[yyn]);
        //#### NEXT STATE ####
        yystate = yytable[yyn];//we are in a new state
        state_push(yystate);   //save it
        val_push(yylval);      //push our lval as the input for next rule
        yychar = -1;           //since we have 'eaten' a token, say we need another
        if (yyerrflag > 0)     //have we recovered an error?
           --yyerrflag;        //give ourselves credit
        doaction=false;        //but don't process yet
        break;   //quit the yyn=0 loop
        }

    yyn = yyrindex[yystate];  //reduce
    if ((yyn !=0 ) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
      {   //we reduced!
      if (yydebug) debug("reduce");
      yyn = yytable[yyn];
      doaction=true; //get ready to execute
      break;         //drop down to actions
      }
    else //ERROR RECOVERY
      {
      if (yyerrflag==0)
        {
        yyerror("syntax error");
        yynerrs++;
        }
      if (yyerrflag < 3) //low error count?
        {
        yyerrflag = 3;
        while (true)   //do until break
          {
          if (stateptr<0)   //check for under & overflow here
            {
            yyerror("stack underflow. aborting...");  //note lower case 's'
            return 1;
            }
          yyn = yysindex[state_peek(0)];
          if ((yyn != 0) && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == YYERRCODE)
            {
            if (yydebug)
              debug("state "+state_peek(0)+", error recovery shifting to state "+yytable[yyn]+" ");
            yystate = yytable[yyn];
            state_push(yystate);
            val_push(yylval);
            doaction=false;
            break;
            }
          else
            {
            if (yydebug)
              debug("error recovery discarding state "+state_peek(0)+" ");
            if (stateptr<0)   //check for under & overflow here
              {
              yyerror("Stack underflow. aborting...");  //capital 'S'
              return 1;
              }
            state_pop();
            val_pop();
            }
          }
        }
      else            //discard this token
        {
        if (yychar == 0)
          return 1; //yyabort
        if (yydebug)
          {
          yys = null;
          if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
          if (yys == null) yys = "illegal-symbol";
          debug("state "+yystate+", error recovery discards token "+yychar+" ("+yys+")");
          }
        yychar = -1;  //read another
        }
      }//end error recovery
    }//yyn=0 loop
    if (!doaction)   //any reason not to proceed?
      continue;      //skip action
    yym = yylen[yyn];          //get count of terminals on rhs
    if (yydebug)
      debug("state "+yystate+", reducing "+yym+" by rule "+yyn+" ("+yyrule[yyn]+")");
    if (yym>0)                 //if count of rhs not 'nil'
      yyval = val_peek(yym-1); //get current semantic value
    yyval = dup_yyval(yyval); //duplicate yyval if ParserVal is used as semantic value
    switch(yyn)
      {
//########## USER-SUPPLIED ACTIONS ##########
//########## END OF USER-SUPPLIED ACTIONS ##########
    }//switch
    //#### Now let's reduce... ####
    if (yydebug) debug("reduce");
    state_drop(yym);             //we just reduced yylen states
    yystate = state_peek(0);     //get new state
    val_drop(yym);               //corresponding value drop
    yym = yylhs[yyn];            //select next TERMINAL(on lhs)
    if (yystate == 0 && yym == 0)//done? 'rest' state and at first TERMINAL
      {
      if (yydebug) debug("After reduction, shifting from state 0 to state "+YYFINAL+"");
      yystate = YYFINAL;         //explicitly say we're done
      state_push(YYFINAL);       //and save it
      val_push(yyval);           //also save the semantic value of parsing
      if (yychar < 0)            //we want another character?
        {
        yychar = yylex();        //get next character
        if (yychar<0) yychar=0;  //clean, if necessary
        if (yydebug)
          yylexdebug(yystate,yychar);
        }
      if (yychar == 0)          //Good exit (if lex returns 0 ;-)
         break;                 //quit the loop--all DONE
      }//if yystate
    else                        //else not done yet
      {                         //get next state and push, for next yydefred[]
      yyn = yygindex[yym];      //find out where to go
      if ((yyn != 0) && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yystate)
        yystate = yytable[yyn]; //get new state
      else
        yystate = yydgoto[yym]; //else go to new defred
      if (yydebug) debug("after reduction, shifting from state "+state_peek(0)+" to state "+yystate+"");
      state_push(yystate);     //going again, so push state & val...
      val_push(yyval);         //for next action
      }
    }//main loop
  return 0;//yyaccept!!
}
//## end of method parse() ######################################



//## run() --- for Thread #######################################
/**
 * A default run method, used for operating this parser
 * object in the background.  It is intended for extending Thread
 * or implementing Runnable.  Turn off with -Jnorun .
 */
public void run()
{
  yyparse();
}
//## end of method run() ########################################



//## Constructors ###############################################
/**
 * Default constructor.  Turn off with -Jnoconstruct .

 */
public Parser()
{
  //nothing to do
}


/**
 * Create a parser, setting the debug to true or false.
 * @param debugMe true for debugging, false for no debug.
 */
public Parser(boolean debugMe)
{
  yydebug=debugMe;
}
//###############################################################



}
//################### END OF CLASS ##############################
