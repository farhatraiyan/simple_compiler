#ifndef PARSE_TREE_H
#define PARSE_TREE_H

typedef enum {
    NODE_PROGRAM,
    NODE_DECLARATION,
    NODE_TYPE,
    NODE_STATEMENT,
    NODE_OPERATOR,
    NODE_READ,
    NODE_IDENTIFIER,
    NODE_NUMBER,
    NODE_BOOL,
    NODE_CONTAINED_EXPR
} NodeType;

typedef enum {
    IF_STMT,
    ELSE_CLAUSE,
    WHILE_STMT,
    ASSIGN_STMT,
    WRITE_INT_STMT
} StmtType;

typedef enum {
    TYPE_INT,
    TYPE_BOOL
} VarType;

typedef struct Node {
    NodeType type;
    struct Node* left;
    struct Node* right;
    struct Node* next;
    union {
        char* identifier;
        int number;
        int boolean;
        char* opr;
        StmtType stmtType;
        VarType varType;
    } value;
} Node;

Node* createNode(NodeType type);
Node* createIdentifierNode(char* name);
Node* createNumberNode(int value);
Node* createBooleanNode(int value);
Node* createOperatorNode(char* op);

void printTree(Node* node, int depth);

#endif