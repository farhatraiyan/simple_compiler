%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parse_tree.h"
#include "code_gen.h"

int yylex(void);
int yyerror(char *);
Node* root = NULL;
%}

%error-verbose

%union {
    char* sval;
    int ival;
    int bval;
    Node* node;
}

%token PROGRAM VAR AS INT BOOL WRITEINT READINT
%token <sval> IDENTIFIER OP2 OP3 OP4
%token <ival> NUM
%token <bval> BOOLLIT
%token LP RP ASGN SC IF THEN ELSE BEGIN_TOK END WHILE DO

%type <node> Procedure Declarations Type Statements Statement
%type <node> Assignment IfStatement ElseCaluse WhileStatement WriteIntStatement
%type <node> Expression SimpleExpression Term Factor

%left OP2
%left OP3
%left OP4

%start Procedure
%%

Procedure:
    PROGRAM Declarations BEGIN_TOK Statements END
    {
        $$ = createNode(NODE_PROGRAM);
        $$->left = $2;
        $$->right = $4;
        root = $$;
    }
    ;

Declarations:
    VAR IDENTIFIER AS Type SC Declarations
    {
        $$ = createNode(NODE_DECLARATION);
        $$->left = createIdentifierNode($2);
        $$->right = $4;
        $$->next = $6;
    }
    | /* empty */ { $$ = NULL; }
    ;
    
Type:
    INT { 
        $$ = createNode(NODE_TYPE);
        $$->value.varType = TYPE_INT;
    }
    | BOOL { 
        $$ = createNode(NODE_TYPE);
        $$->value.varType = TYPE_BOOL;
    }
    ;

Statements:
    Statement Statements
    {
        $$ = $1;
        $$->next = $2;
    }
    | /* empty */ { $$ = NULL; }
    ;

Statement:
    Assignment
    | IfStatement
    | WhileStatement
    | WriteIntStatement
    ;

Assignment:
    IDENTIFIER ASGN READINT SC
    {
        $$ = createNode(NODE_STATEMENT);
        $$->value.stmtType = ASSIGN_STMT;
        $$->left = createIdentifierNode($1);
        $$->right = createNode(NODE_READ);
    }
    | 
    IDENTIFIER ASGN Expression SC
    {
        $$ = createNode(NODE_STATEMENT);
        $$->value.stmtType = ASSIGN_STMT;
        $$->left = createIdentifierNode($1);
        $$->right = $3;
    }
    ;

IfStatement:
    IF Expression THEN Statements ElseCaluse END SC
    {
        $$ = createNode(NODE_STATEMENT);
        $$->value.stmtType = IF_STMT;
        $$->left = $2;
        $$->right = $4;

        // Find the last statement and append the else clause to it
        Node* last = $4;
        while (last->next != NULL) {
            last = last->next;
        }
        last->next = $5;
    }
    ;

ElseCaluse:
    ELSE Statements
    {
        $$ = createNode(NODE_STATEMENT);
        $$->value.stmtType = ELSE_CLAUSE;
        $$->left = $2;
    }
    | /* empty */ { $$ = NULL; }
    ;

WhileStatement:
    WHILE Expression DO Statements END SC
    {
        $$ = createNode(NODE_STATEMENT);
        $$->value.stmtType = WHILE_STMT;
        $$->left = $2;
        $$->right = $4;
    }

WriteIntStatement:
    WRITEINT Expression SC
    {
        $$ = createNode(NODE_STATEMENT);
        $$->value.stmtType = WRITE_INT_STMT;
        $$->right = $2;
    }
    ;

Expression:
    SimpleExpression
    | SimpleExpression OP4 SimpleExpression
    {
        $$ = createOperatorNode($2);
        $$->left = $1;
        $$->right = $3;
    }
    ;

SimpleExpression:
    SimpleExpression OP3 Term
    {
        $$ = createOperatorNode($2);
        $$->left = $1;
        $$->right = $3;
    }
    | Term
    ;

Term:
    Factor OP2 Term
    {
        $$ = createOperatorNode($2);
        $$->left = $1;
        $$->right = $3;
    }
    | Factor
    ;

Factor:
    IDENTIFIER {
        $$ = createIdentifierNode($1);
    }
    | NUM {
        $$ = createNumberNode($1);
    }
    | BOOLLIT {
        $$ = createBooleanNode($1);
    }
    | LP Expression RP
    {
        $$ = createNode(NODE_CONTAINED_EXPR);
        $$->left = $2;
    }

%%

Node* createNode(NodeType type) {
    Node* node = (Node*)malloc(sizeof(Node));
    node->type = type;
    node->left = NULL;
    node->right = NULL;
    node->next = NULL;
    return node;
}

Node* createOperatorNode(char* op) {
    Node* node = createNode(NODE_OPERATOR);
    node->value.opr = strdup(op);
    return node;
}

Node* createIdentifierNode(char* name) {
    Node* node = createNode(NODE_IDENTIFIER);
    node->value.identifier = strdup(name);
    return node;
}

Node* createNumberNode(int32_t value) {
    Node* node = createNode(NODE_NUMBER);
    node->value.number = value;
    return node;
}

Node* createBooleanNode(int value) {
    Node* node = createNode(NODE_BOOL);
    node->value.boolean = value;
    return node;
}

int yyerror(char *s) {
    printf("yyerror : %s\n", s);
    exit(1);
}

void printTree(Node* node, int depth) {
    if (node == NULL) return;

    for (int i = 0; i < depth; i++) printf("  ");

    switch (node->type) {
        case NODE_PROGRAM:
            printf("Program\n");
            break;
        case NODE_DECLARATION:
            printf("Declaration\n");
            break;
        case NODE_TYPE:
            printf("Type: %s\n", node->value.varType == TYPE_INT ? "int" : "bool");
            break;
        case NODE_STATEMENT:
            printf("Statement: ");
            switch (node->value.stmtType) {
                case ASSIGN_STMT:
                    printf("Assignment\n");
                    break;
                case IF_STMT:
                    printf("If\n");
                    break;
                case ELSE_CLAUSE:
                    printf("Else\n");
                    break;
                case WHILE_STMT:
                    printf("While\n");
                    break;
                case WRITE_INT_STMT:
                    printf("WriteInt\n");
                    break;
            }
            break;
        case NODE_OPERATOR:
            printf("Operator: %s\n", node->value.opr);
            break;
        case NODE_READ:
            printf("Read\n");
            break;
        case NODE_IDENTIFIER:
            printf("Identifier: %s\n", node->value.identifier);
            break;
        case NODE_NUMBER:
            printf("Number: %d\n", node->value.number);
            break;
        case NODE_BOOL:
            printf("Boolean: %d\n", node->value.boolean);
            break;
    }

    printTree(node->left, depth + 1);
    printTree(node->right, depth + 1);
    printTree(node->next, depth);
}

int main(void) {
    FILE* outFile = fopen("output.c", "w");

    printf("\nParsing...\n");
    yyparse();
    
    if (root != NULL) {
        printf("Parse Tree Complete.\n");
        printTree(root, 0);
        printf("Generating Code...\n");
        generateCode(root, outFile);
        printf("Code generation complete\n");
    }
    
    fclose(outFile);
    return 0;
}

int yywrap() {
    return 1;
}