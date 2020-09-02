/*	Definition section */
%{
    #include "common.h" //Extern variables that communicate with lex
    // #define YYDEBUG 1
    // int yydebug = 1;

    extern int yylineno;
    extern int yylex();

    extern FILE *yyin;
    extern int decl_flag;   //determine if the statement is declaration
    extern int for_flag;    //determine if the statement is for loop
    extern int assign_flag;
    extern int if_flag;
    extern int semi_count;
    extern int for_count;
    /* Global variables */
    int AddressNum = -1;    //count the number of address
    int ScopeNum = -1;      //record the number of scope
    int i;                  //the variable of for loop 
    int id_flag = 0;        //determine if data type is ident
    int str_flag = 0;       //determine if data type is string
    int int_flag = 0;       //determine if data type is int
    int float_flag = 0;     //determine if data type is float
    int labelCount = 0;
    int exitCount = 0;
    bool semi = false;
    char *cmp = "L_cmp_";
    int _index = 0;
    void *fp;
    
    bool HAS_ERROR = false;
    
    /* doubly linked list */
    struct Symbol{
        char *name;
        char *type;
        int address;
        int lineno;
        char *ElementType;   
    };

    struct SymbolTable{
        int SymbolNum;
        struct Symbol s[10];
        struct SymbolTable *pre;
        struct SymbolTable *next;
    };
    typedef struct SymbolTable table;
    typedef struct Symbol symbol;
    table *head = NULL, *temp = NULL, *tail = NULL;
    symbol variable;
    bool if_bool = false;
    /* Symbol table function - you can add new function if needed. */
    static void create_symbol();
    static void insert_symbol(char *name, char *type, int address, int lineno, char *ElementType);
    int lookup_symbol(char *name);
    static void dump_symbol();
    void printLoad();
    void assignOperator(char *name, char *operation);
    void printFunction(char *name, char *function);
    void printId(char *name, char *function);
    void boolOperator(char *name, char *operation);
    void yyerror (char const *s)
    {
        printf("error:%d: %s\n", yylineno, s);
    }
    void sematic_error(char const *s, int number)
    {
        if(decl_flag)
        {
            decl_flag = 0;
            HAS_ERROR = true;
        }
        else 
            HAS_ERROR = true;
    }
    void type_error(char *str1, char *str2, char *operation)
    {
        if(strcmp(str1, "int32") == 0 || strcmp(str2, "int32") == 0 || strcmp(str1, "float32") == 0 || strcmp(str2, "float32") == 0)
        {
            if(strcmp(str1, "int32") == 0 && strcmp(str2, "float32") == 0)
                HAS_ERROR = true;
            else if(strcmp(str1, "float32") == 0 && strcmp(str2, "int32") == 0)
                HAS_ERROR = true;
            else if(strcmp(str1, "int32") == 0 && strcmp(str2, "int32") == 0)
                fprintf(fp, "i%s\n", operation);
            else if(strcmp(str1, "float32") == 0 && strcmp(str2, "float32") == 0)
                fprintf(fp, "f%s\n", operation);
            else if(strcmp(str2, "float32") == 0){
                if(lookup_symbol(str1) == 1){
                    if(strcmp(variable.type, "array") == 0){
                        if(strcmp(variable.ElementType, "float32") == 0)
                            fprintf(fp, "f%s\n", operation);
                    }
                    else{
                        printLoad();
                        if(strcmp(variable.type, "float32") == 0)
                            fprintf(fp, "f%s\n", operation);
                    }                     
                }
            }
            else if(strcmp(str2, "int32") == 0){
                if(lookup_symbol(str1) == 1){
                    if(strcmp(variable.type, "array") == 0){
                        if(strcmp(variable.ElementType, "int32") == 0)
                            fprintf(fp, "i%s\n", operation);
                    }
                    else{
                        printLoad();
                        if(strcmp(variable.type, "int32") == 0)
                            fprintf(fp, "i%s\n", operation);
                    } 
                }
            }
            else if(strcmp(str1, "float32") == 0){
                if(lookup_symbol(str2) == 1){
                    if(strcmp(variable.type, "array") == 0){
                        if(strcmp(variable.ElementType, "float32") == 0)
                            fprintf(fp, "f%s\n", operation);
                    }
                    else{
                        printLoad();
                        if(strcmp(variable.type, "float32") == 0)
                            fprintf(fp, "f%s\n", operation);
                    } 
                }
            }
            else if(strcmp(str2, "int32") == 0){
                if(lookup_symbol(str1) == 1){
                    if(strcmp(variable.type, "array") == 0){
                        if(strcmp(variable.ElementType, "int32") == 0)
                            fprintf(fp, "i%s\n", operation);
                    }
                    else{
                        printLoad();
                        if(strcmp(variable.type, "int32") == 0)
                            fprintf(fp, "i%s\n", operation);
                    } 
                }
            }
        }
        else
        {
            char *type1;
            char *type2;
            if(lookup_symbol(str1) == 1)
                type1 = variable.type;
            if(lookup_symbol(str2) == 1)          
                type2 = variable.type;      
            if((strcmp(type1, "int32") == 0) && (strcmp(type2, "float32") == 0))
                HAS_ERROR = true;
            else if(strcmp(type1, "float32") == 0 && strcmp(type2, "int32") == 0)
                HAS_ERROR = true;
            else if(strcmp(type1, "int32") == 0 && strcmp(type2, "int32") == 0)
            {
                lookup_symbol(str1);
                printLoad();
                lookup_symbol(str2);
                printLoad();
                fprintf(fp, "i%s\n", operation);
            }
            else if(strcmp(type1, "float32") == 0 && strcmp(type2, "float32") == 0)
            {
                lookup_symbol(str1);
                printLoad();
                lookup_symbol(str2);
                printLoad();
                fprintf(fp, "f%s\n", operation);
            }
        }
    }
    
%}

%error-verbose

/* Use variable or self-defined structure to represent
 * nonterminal and token type
 */
%union {
    int i_val;
    float f_val;
    char *s_val;
    /* ... */
}

/* Token without return */
%token INT FLOAT STRING BOOL TRUE FALSE VAR 
%token '>' '<' GEQ LEQ EQL NEQ
%token '+' '-' '*' '/' '%' INC DEC
%token '=' ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN
%token LAND LOR '!'
%token '(' ')' '[' ']' '{' '}' '"'
%token ';' ',' NEWLINE
%token PRINT PRINTLN IF ELSE FOR

%right '='
%left LOR
%left LAND 
%left '>' '<' GEQ LEQ EQL NEQ
%left '+' '-'
%left '*' '/' '%'
%left '!'
%nonassoc UMINUS
%left '[' ']'
%left '(' ')'

/* Token with return, which need to sepcify type */
%token <i_val> INT_LIT
%token <f_val> FLOAT_LIT
%token <s_val> STRING_LIT
%token <s_val> IDENT

/* Nonterminal with return, which need to sepcify type */
%type <s_val> Type
%type <s_val> Expression
%type <s_val> Literal

/* Yacc will start at this nonterminal */
%start Program

/* Grammar section */
%%

Program
    : StatementList
;

StatementList
    : StatementList Statement
    | Statement
;

Statement
    : DeclarationStmt NEWLINE
    | Expression NEWLINE
    | '{'  { create_symbol(); }
    | '}'  { dump_symbol(); if(for_count > 0){
            if(semi)
                fprintf(fp,"goto L_add_%d\n", for_count);
                    
            else
                fprintf(fp, "goto L_for_begin%d\n", for_count);
            fprintf(fp, "EXIT_%d\:\n", for_count);
            for_count--;
            for_flag = 0;
            }
            
    }
    | IfStmt StatementList
    | IfStmt StatementList ELSE StatementList
    | ForStmt StatementList {}
    | PrintStmt NEWLINE
    | NEWLINE
;

DeclarationStmt
    : VAR IDENT Type { 
        if(lookup_symbol($2) == 0){
            AddressNum++;
            insert_symbol($2, $3, AddressNum, yylineno, "-");
            if(strcmp($3, "string") == 0)
                fprintf(fp, "ldc \"\"\n");  
            else             
                fprintf(fp, "ldc 0\n");
            if(lookup_symbol($2) == 1){
                if(strcmp($3, "int32") == 0)
                    fprintf(fp, "istore %d\n", _index);
                if(strcmp($3, "float32") == 0)
                    fprintf(fp, "fstore %d\n", _index);
                
            }
        }
        else
            HAS_ERROR = true;
        decl_flag = 0;
    }
    | VAR IDENT Type '=' Expression {
        if(lookup_symbol($2) == 0){
            AddressNum++;
            insert_symbol($2, $3, AddressNum, yylineno, "-");
            if(lookup_symbol($2) == 1){
                if(strcmp(variable.type, "int32") == 0)
                    fprintf(fp, "istore %d\n", _index);
                if(strcmp(variable.type, "float32") == 0)
                    fprintf(fp, "fstore %d\n", _index);
                
            }
        }
        else
            HAS_ERROR = true;
        decl_flag = 0;
    }
    | VAR IDENT '[' Expression ']' Type {
        if(lookup_symbol($2) == 0){
            AddressNum++;
            insert_symbol($2, "array", AddressNum, yylineno+1, $6);
            if(lookup_symbol($2) == 1){
                if(strcmp($6, "int32") == 0)
                    fprintf(fp, "newarray int\n");
                if(strcmp($6, "float32") == 0)
                    fprintf(fp, "newarray float\n");  
                fprintf(fp, "astore %d\n", _index);             
            }
        }
        else
            HAS_ERROR = true;
        decl_flag = 0;
    }
;

IfStmt
    : IF Expression {
        if(strcmp($2, "bool") !=0)
        {
            if((strcmp($2, "int32") ==0) || (strcmp($2, "float32") ==0))
                HAS_ERROR = true;
            else
            {
                if(lookup_symbol($2) == 1)
                    HAS_ERROR = true;
            }
        }
    } 
;

ForStmt
    : FOR Expression {
        if(strcmp($2, "bool") !=0)
        {
            if((strcmp($2, "int32") ==0) || (strcmp($2, "float32") ==0))
                HAS_ERROR = true;
            else
            {
                if(lookup_symbol($2) == 1)
                    HAS_ERROR = true;
            }
        }
    }
    | FOR ForClause  
;

ForClause
    : Expression ';' Expression ';' Expression {semi = true;}
;

PrintStmt
    : PRINT '(' Expression ')'{
        printFunction($3, "print");
    }
    | PRINT '(' IDENT ')' {        
        printId($3, "print");
    }
    | PRINTLN '(' IDENT ')' { 
        printId($3, "println");
    }
    | PRINTLN '(' Expression '[' Expression ']' ')'{
            if(lookup_symbol($3) == 1){
                if(strcmp(variable.ElementType, "int32") == 0)
                    fprintf(fp, "iaload\n");  
                else if(strcmp(variable.ElementType, "float32") == 0)
                    fprintf(fp, "faload\n");
                fprintf(fp, "getstatic java/lang/System/out Ljava/io/PrintStream;\n");
                fprintf(fp, "swap\n");
                if(strcmp(variable.ElementType, "int32") == 0)
                    fprintf(fp, "invokevirtual java/io/PrintStream/println(I)V\n");
                else if(strcmp(variable.ElementType, "float32") == 0)
                    fprintf(fp, "invokevirtual java/io/PrintStream/println(F)V\n");
            }
    }
    | PRINTLN '(' Expression ')' { 
        printFunction($3, "println");
    }
;

Expression
    : '(' Expression ')' { $$ = $2;}
    | Type '(' Expression ')' {
        if(id_flag){
            if(lookup_symbol($3) == 1){
                printLoad();
                if(strcmp(variable.type, "float32") == 0 && strcmp($1, "int32") == 0)
                    fprintf(fp, "f2i\n");
                else if(strcmp(variable.type, "int32") == 0 && strcmp($1, "float32") == 0)
                    fprintf(fp, "i2f\n");
            }
        }
        else
        {
            if(float_flag && strcmp($1, "int32") == 0)
                fprintf(fp, "f2i\n");
            else if(int_flag && strcmp($1, "float32") == 0)
                fprintf(fp, "i2f\n");
        }
    }
    | Expression '[' Expression ']' {
        if(lookup_symbol($1) == 1 && assign_flag == 1){
            if(strcmp(variable.ElementType, "float32") == 0)
                fprintf(fp, "faload\n");
            if(strcmp(variable.ElementType, "int32") == 0)
                fprintf(fp, "iaload\n");
        }
    }
    | Expression '=' Expression     {
        assign_flag = 0;
        if(lookup_symbol($1) == 1){
                lookup_symbol($1);
                if(strcmp(variable.type, "int32") == 0)
                    fprintf(fp, "istore %d\n" , _index);
                else if(strcmp(variable.type, "float32") == 0)
                    fprintf(fp, "fstore %d\n" , _index);
                else if(strcmp(variable.type, "array") == 0){
                    if(strcmp(variable.ElementType, "float32") == 0)
                        fprintf(fp, "fastore\n");
                    if(strcmp(variable.ElementType, "int32") == 0)
                        fprintf(fp, "iastore\n");
                }
            
        }
        if(for_count > 0 && semi_count > 0){
            fprintf(fp, "L_for_begin%d\:\n", for_count);
        }
    }
    | Expression ADD_ASSIGN Expression     {
        assignOperator($1, "add");
    }
    | Expression SUB_ASSIGN Expression     {
        assignOperator($1, "sub");  
    }
    | Expression MUL_ASSIGN Expression     {
        assignOperator($1, "mul");  
    }
    | Expression QUO_ASSIGN Expression     {
        assignOperator($1, "div"); 
    }
    | Expression REM_ASSIGN Expression     {
        assignOperator($1, "rem"); 
    }
    | Expression '+' Expression     { 
        type_error($1, $3, "add");
    } 
    | Expression '-' Expression     { 
        type_error($1, $3, "sub");
    }
    | Expression '*' Expression     { 
        type_error($1, $3, "mul"); 
    }
    | Expression '/' Expression     { 
        type_error($1, $3, "div");
    }
    | Expression '%' Expression     { 
        if((strcmp($1, "float32") == 0) || (strcmp($3, "float32") == 0))
            HAS_ERROR = true;
        else if(strcmp($1, "int32") == 0 || strcmp($3, "int32") == 0)
            fprintf(fp, "irem\n");
        else
        {
            if(lookup_symbol($1) == 1)
            {
                if((strcmp(variable.type, "float32") == 0))
                    HAS_ERROR = true;
                else
                {
                    if(lookup_symbol($3) == 1)
                    {
                        if((strcmp(variable.type, "float32") == 0))
                            HAS_ERROR = true;
                        else{
                            lookup_symbol($1);
                            printLoad();                          
                            lookup_symbol($3);
                            printLoad();
                            fprintf(fp, "irem\n");
                        }
                    }
                }
            }
        } 
    }
    | Expression '>' Expression     { 
        $$ = "bool";
        //boolOperator($1, "ifgt");
        int preLabelCount = 0;
        labelCount++;
        if(strcmp($1, "int32") == 0){   
            fprintf(fp, "isub\n");
        }
        else if(strcmp($1, "float32") == 0){
            fprintf(fp, "fcmpl\n");
        } 
        else{
            if(lookup_symbol($1) == 1){
                if(strcmp(variable.type, "int32") == 0){
                    fprintf(fp, "iload %d\n", _index);
                    fprintf(fp, "swap\n");
                    fprintf(fp, "isub\n");
                }
                else if(strcmp(variable.type, "float32") == 0){
                    fprintf(fp, "fload %d\n", _index);
                    fprintf(fp, "swap\n");
                    fprintf(fp, "fcmpl\n");
                }
            }
        }
        fprintf(fp,"ifgt %s%d\n", cmp, labelCount);
            preLabelCount = labelCount;
            fprintf(fp, "iconst_0\n");
            labelCount++;
            fprintf(fp, "goto %s%d\n", cmp, labelCount);
            fprintf(fp, "%s%d\:\n", cmp, preLabelCount);
            fprintf(fp, "iconst_1\n");
            fprintf(fp, "%s%d\:\n", cmp, labelCount);
        if(for_flag == 1){
            fprintf(fp, "ifeq EXIT_%d\n", for_count);
        }
    }
    
    | Expression '<' Expression     { 
        $$ = "bool";
        //boolOperator($1, "iflt");
        if(strcmp($1, "int32") == 0){
            int preLabelCount = 0;
            labelCount++;
            fprintf(fp, "isub\n");
            fprintf(fp,"iflt %s%d\n", cmp, labelCount);
            preLabelCount = labelCount;
            fprintf(fp, "iconst_0\n");
            labelCount++;
            fprintf(fp, "goto %s%d\n", cmp, labelCount);
            fprintf(fp, "%s%d\:\n", cmp, preLabelCount);
            fprintf(fp, "iconst_1\n");
            fprintf(fp, "%s%d\:\n", cmp, labelCount);
        }
        else if(strcmp($1, "float32") == 0){
            int preLabelCount = 0;
            labelCount++;
            fprintf(fp, "fcmpl\n");
            fprintf(fp,"iflt %s%d\n", cmp, labelCount);
            preLabelCount = labelCount;
            fprintf(fp, "iconst_0\n");
            labelCount++;
            fprintf(fp, "goto %s%d\n", cmp, labelCount);
            fprintf(fp, "%s%d\:\n", cmp, preLabelCount);
            fprintf(fp, "iconst_1\n");
            fprintf(fp, "%s%d\:\n", cmp, labelCount);
        }
        if(for_flag == 1){
            fprintf(fp, "ifeq EXIT_%d\n", for_count);
        }
    }
    | Expression EQL Expression     { 
        $$ = "bool";
        boolOperator($1, "ifeq");
    }
    | Expression NEQ Expression     { 
        $$ = "bool";
        boolOperator($1, "ifne");
    }
    | Expression LEQ Expression     { 
        $$ = "bool";
        boolOperator($1, "ifle");
    }
    | Expression GEQ Expression     { 
        $$ = "bool";
        boolOperator($1, "ifge");
    }
    | Expression LOR Expression     { 
        $$ = "bool";
        if((strcmp($1, "int32") == 0) || (strcmp($3, "int32") == 0))
            HAS_ERROR = true;
        else
        {
            if(lookup_symbol($1) == 1)
            {
                if((strcmp(variable.type, "int32") == 0))
                    HAS_ERROR = true;
                else
                {
                    if(lookup_symbol($3) == 1)
                    {
                        if((strcmp(variable.type, "int32") == 0))
                            HAS_ERROR = true;
                    }
                }
            }
        }
        fprintf(fp, "ior\n");  
    }
    | Expression LAND Expression    { 
        $$ = "bool";
        if((strcmp($1, "int32") == 0) || (strcmp($3, "int32") == 0))
            HAS_ERROR = true;
        else
        {
            if(lookup_symbol($1) == 1)
            {
                if(strcmp(variable.type, "int32") == 0)
                    HAS_ERROR = true;
                else
                {
                    if(lookup_symbol($3) == 1)
                    {
                        if((strcmp(variable.type, "int32") == 0))
                            HAS_ERROR = true;
                    }
                }
            }
        }
        fprintf(fp, "iand\n"); 
    }
    | '-' Expression %prec UMINUS   { 
        $$ = $2;
        if(lookup_symbol($2) == 1)
        {
            if(strcmp(variable.type, "int32") == 0)
                fprintf(fp, "ineg\n"); 
            if(strcmp(variable.type, "float32") == 0)
                fprintf(fp, "fneg\n");
        }
        else{
            if(strcmp($2, "int32") == 0)
                fprintf(fp, "ineg\n"); 
            if(strcmp($2, "float32") == 0)
                fprintf(fp, "fneg\n");
        }
        
    }
    | '+' Expression %prec UMINUS    { 
        $$ = $2;
    }
    | '!' Expression %prec UMINUS   { 
        $$ = "bool";
        fprintf(fp, "iconst_1\n");
        fprintf(fp, "ixor\n");  
    }
    | Expression INC                {
        lookup_symbol($1);
        if(strcmp(variable.type, "int32") == 0){
            fprintf(fp, "iload %d\n", _index);
            fprintf(fp, "ldc 1\n");
            fprintf(fp, "iadd\n");
            fprintf(fp, "istore %d\n", _index);
        }
        if(strcmp(variable.type, "float32") == 0){
            fprintf(fp, "fload %d\n", _index);
            fprintf(fp, "ldc 1.0\n");
            fprintf(fp, "fadd\n");
            fprintf(fp, "fstore %d\n", _index);
        }
        
    }
    | Expression DEC                {
        lookup_symbol($1);
        if(strcmp(variable.type, "int32") == 0){
            fprintf(fp, "iload %d\n", _index);
            fprintf(fp, "ldc 1\n");
            fprintf(fp, "isub\n");
            fprintf(fp, "istore %d\n", _index);  
        } 
        if(strcmp(variable.type, "float32") == 0){
            fprintf(fp, "fload %d\n", _index);
            fprintf(fp, "ldc 1.0\n");
            fprintf(fp, "fsub\n");
            fprintf(fp, "fstore %d\n", _index);
        }
    }
    | Literal
;

Literal
    : INT_LIT       { fprintf(fp, "ldc %d\n", $<i_val>1); $<s_val>$ = "int32"; id_flag = 0; str_flag = 0; int_flag = 1; float_flag = 0; }
    | FLOAT_LIT     { fprintf(fp, "ldc %f\n", $<f_val>1); $<s_val>$ = "float32";id_flag = 0; str_flag = 0; int_flag = 0; float_flag = 1;}
    | '"' STRING_LIT '"'   { fprintf(fp, "ldc \"%s\"\n", $<s_val>2); $$ = $2;id_flag = 0; str_flag = 1; int_flag = 0; float_flag = 0;}
    | TRUE          { fprintf(fp, "iconst_1\n"); $<s_val>$ = "TRUE";id_flag = 0; str_flag = 0; int_flag = 0; float_flag = 0;}
    | FALSE         { fprintf(fp, "iconst_0\n"); $<s_val>$ = "FALSE";id_flag = 0; str_flag = 0; int_flag = 0; float_flag = 0;}
    | IDENT         { 
        id_flag = 1; str_flag = 0; int_flag = 0; float_flag = 0;
        if(!for_flag)
        {
            if(lookup_symbol($1) == 0){
                HAS_ERROR = true;
            }
        }
        else{
            lookup_symbol($1);
        }
    }
;

Type
    : INT   { $$ = "int32";}
    | FLOAT { $$ = "float32";}
    | STRING  { $$ = "string";}
    | BOOL    { $$ = "bool";}
;

%%

/* C code section */
int main(int argc, char *argv[])
{
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
    } else {
        yyin = stdin;
    }
    fp = fopen("hw3.j", "w");
    fprintf(fp, ".source hw3.j\n");
    fprintf(fp, ".class public Main\n");
    fprintf(fp, ".super java/lang/Object\n");
    fprintf(fp, ".method public static main([Ljava/lang/String;)V\n");
    fprintf(fp, ".limit stack 100\n");
    fprintf(fp, ".limit locals 100\n");
    yylineno = 0;
    create_symbol();
    yyparse();
    dump_symbol();
	printf("Total lines: %d\n", yylineno);
    fclose(yyin);
    if(!semi)
        fprintf(fp, "EXIT_%d:\n", exitCount);
    fprintf(fp, "   return\n");
    fprintf(fp, ".end method\n");
    fclose(fp);
    if (HAS_ERROR) {
        remove("hw3.j");
    }
    return 0;
}

static void create_symbol() {
    temp = (table *)malloc(sizeof(table));
    temp->next = NULL;
    temp->SymbolNum = -1;
    for(i = 0; i < 10; i++){
        temp->s[i].address = 0;
        temp->s[i].ElementType = "-";
        temp->s[i].lineno = 0;
        temp->s[i].name = "";
        temp->s[i].type = "";
    }
    if (head == NULL){
        head = temp;
        head->pre = NULL;
        tail = head;
    }
    else{
        temp->pre = tail;
        tail->next = temp;
        tail = temp;
    }
    ScopeNum++;
}

static void insert_symbol(char *name, char *type, int address, int lineno, char *ElementType) {
    tail->SymbolNum++;
    tail->s[tail->SymbolNum].name = name;
    tail->s[tail->SymbolNum].type = type;
    tail->s[tail->SymbolNum].address = address;
    tail->s[tail->SymbolNum].lineno = lineno;
    tail->s[tail->SymbolNum].ElementType = ElementType;
}

int lookup_symbol(char *name) {
    for(i = 0; i < 10; i++){
        if(strcmp(tail->s[i].name, name) == 0)
        {
            variable = tail->s[i];
            _index = tail->s[i].address;
            return 1;
        }
    }
    if(decl_flag!=1){
    table *current = tail->pre;
    while(current!=NULL){
        for(i = 0; i < 10; i++){
            if(strcmp(current->s[i].name, name) == 0)
            {
                variable = current->s[i];
                _index = current->s[i].address;              
                return 1;
            }
        }
        current = current->pre;
    }
    }
    return 0;
}

static void dump_symbol() {
    if( tail != NULL){
        temp = tail;
        if(tail->pre != NULL)
            tail = tail->pre;
        tail->next = NULL;
        free(temp);
        ScopeNum--;
    }
}

void printLoad(){
    if(strcmp(variable.type, "int32") == 0)
        fprintf(fp, "iload %d\n", _index);
    else if(strcmp(variable.type, "float32") == 0)
        fprintf(fp, "fload %d\n", _index);
    else if(strcmp(variable.type, "array") == 0 || strcmp(variable.type, "string") == 0)
        fprintf(fp, "aload %d\n", _index);
    else if(strcmp(variable.type, "bool") == 0)
        fprintf(fp, "iload %d\n", _index);
}

void assignOperator(char *name, char *operation){
    if(strcmp(name,"int32") == 0)
        HAS_ERROR = true;
    else if(strcmp(name,"float32") == 0)
        HAS_ERROR = true;
    if(lookup_symbol(name) == 1)
    {
        if(strcmp(variable.type, "int32") == 0)
        {
            fprintf(fp, "iload %d\n", _index);
            fprintf(fp, "swap\n");
            fprintf(fp, "i%s\n", operation);
            fprintf(fp, "istore %d\n", _index);
        }
        else if(strcmp(variable.type, "float32") == 0 && strcmp(operation, "rem") != 0){
            fprintf(fp, "fload %d\n", _index);
            fprintf(fp, "swap\n");
            fprintf(fp, "f%s\n", operation);
            fprintf(fp, "fstore %d\n", _index);
        }
    }
}

void printFunction(char *name, char *function){
    if(strcmp(name, "bool") == 0){
            int preLabelCount = 0;
            labelCount++;
            fprintf(fp, "ifne %s%d\n", cmp, labelCount);
            fprintf(fp, "ldc \"false\"\n");
            preLabelCount = labelCount;
            labelCount++;
            fprintf(fp, "goto %s%d\n", cmp, labelCount);
            fprintf(fp, "%s%d:\n", cmp, preLabelCount);
            fprintf(fp, "ldc \"true\"\n");
            fprintf(fp, "%s%d:\n", cmp, labelCount);
            fprintf(fp, "getstatic java/lang/System/out Ljava/io/PrintStream;\n");
            fprintf(fp, "swap\n");
            fprintf(fp, "invokevirtual java/io/PrintStream/%s(Ljava/lang/String;)V\n", function);
        }
        else{
        fprintf(fp, "getstatic java/lang/System/out Ljava/io/PrintStream;\n");
        fprintf(fp, "swap\n");
        if(id_flag)
        {
            if(lookup_symbol(name) == 1)
            {
                if(strcmp(variable.type, "int32") == 0)
                    fprintf(fp, "invokevirtual java/io/PrintStream/%s(I)V\n", function);
                else if(strcmp(variable.type, "float32") == 0)
                    fprintf(fp, "invokevirtual java/io/PrintStream/%s(F)V\n", function);
                else if(strcmp(variable.type, "string") == 0)
                    fprintf(fp, "invokevirtual java/io/PrintStream/%s(Ljava/lang/String;)V\n", function);
                else
                {
                    if(strcmp(variable.ElementType, "int32") == 0)
                    fprintf(fp, "invokevirtual java/io/PrintStream/%s(I)V\n", function);
                else if(strcmp(variable.ElementType, "float32") == 0)
                    fprintf(fp, "invokevirtual java/io/PrintStream/%s(F)V\n", function);
                else if(strcmp(variable.ElementType, "string") == 0)
                    fprintf(fp, "invokevirtual java/io/PrintStream/%s(Ljava/lang/String;)V\n", function);
                }
            }
        }
        else if(str_flag)
            fprintf(fp, "invokevirtual java/io/PrintStream/%s(Ljava/lang/String;)V\n", function);
        else if(float_flag)
            fprintf(fp, "invokevirtual java/io/PrintStream/%s(F)V\n", function);
        else if(int_flag)
            fprintf(fp, "invokevirtual java/io/PrintStream/%s(I)V\n", function);
        else
            fprintf(fp, "invokevirtual java/io/PrintStream/%s(I)V\n", function);
        }
}

void printId(char *name, char *function){
    if(lookup_symbol(name) == 1){ 
        if(strcmp(variable.type, "int32") == 0)
            fprintf(fp, "iload %d\n", _index);
        else if(strcmp(variable.type, "float32") == 0)
            fprintf(fp, "fload %d\n", _index);
        else if(strcmp(variable.type, "bool") == 0){
            if_bool = true;
            int preLabelCount = 0;
            labelCount++;
            fprintf(fp, "ifne %s%d\n", cmp, labelCount);
            fprintf(fp, "ldc \"false\"\n");
            preLabelCount = labelCount;
            labelCount++;
            fprintf(fp, "goto %s%d\n", cmp, labelCount);
            fprintf(fp, "%s%d:\n", cmp, preLabelCount);
            fprintf(fp, "ldc \"true\"\n");
            fprintf(fp, "%s%d:\n", cmp, labelCount);
        }
        else if(strcmp(variable.type, "array") == 0){
            if(strcmp(variable.ElementType, "bool") == 0){
                if_bool = true;
                int preLabelCount = 0;
                labelCount++;
                fprintf(fp, "ifne %s%d\n", cmp, labelCount);
                fprintf(fp, "ldc \"false\"\n");
                preLabelCount = labelCount;
                labelCount++;
                fprintf(fp, "goto %s%d\n", cmp, labelCount);
                fprintf(fp, "%s%d:\n", cmp, preLabelCount);
                fprintf(fp, "ldc \"true\"\n");
                fprintf(fp, "%s%d:\n", cmp, labelCount);
            }  
        }
        fprintf(fp, "getstatic java/lang/System/out Ljava/io/PrintStream;\n");
        fprintf(fp, "swap\n");
        if(strcmp(variable.type, "int32") == 0)
            fprintf(fp, "invokevirtual java/io/PrintStream/%s(I)V\n", function);
        else if(strcmp(variable.type, "float32") == 0)
            fprintf(fp, "invokevirtual java/io/PrintStream/%s(F)V\n", function);
        else if(strcmp(variable.type, "string") == 0)
            fprintf(fp, "invokevirtual java/io/PrintStream/%s(Ljava/lang/String;)V\n", function);
        else{
            if(strcmp(variable.ElementType, "int32") == 0)
                fprintf(fp, "invokevirtual java/io/PrintStream/%s(I)V\n", function);
            else if(strcmp(variable.ElementType, "float32") == 0)
                fprintf(fp, "invokevirtual java/io/PrintStream/%s(F)V\n", function);
            else if(strcmp(variable.ElementType, "string") == 0)
                fprintf(fp, "invokevirtual java/io/PrintStream/%s(Ljava/lang/String;)V\n", function);
        }
        if(if_bool){
            if_bool = false;
            fprintf(fp, "invokevirtual java/io/PrintStream/%s(Ljava/lang/String;)V\n", function);
        }    
    }         
}

void boolOperator(char *name, char *operation){
    if(lookup_symbol(name) == 1){
        printLoad();
        fprintf(fp, "swap\n");
    }
    labelCount++;
    fprintf(fp, "isub\n");
    fprintf(fp, "%s %s%d\n",operation, cmp, labelCount);
    exitCount++;
    fprintf(fp, "goto EXIT_%d\n", exitCount);
    if(for_count == 0)
        fprintf(fp, "EXIT_%d:\n", exitCount - 1);
    if(semi_count == 0)
        fprintf(fp, "%s%d:\n", cmp, labelCount);
    else if(semi_count > 0)
        fprintf(fp, "L_add_%d:\n", for_count);
}