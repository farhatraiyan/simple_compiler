#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "code_gen.h"

void generateCode(Node* root, FILE* outFile) {
    fprintf(outFile, "#include <stdio.h>\n#include <stdbool.h>\n");
    fprintf(outFile, "int main() {\n");
    generateDeclarations(root->left, outFile);
    generateStatements(root->right, outFile);
    fprintf(outFile, "return 0;\n}\n");
}

void generateDeclarations(Node* declarations, FILE* outFile) {
    Node* current = declarations;

    while (current != NULL) {
        if (current->type == NODE_DECLARATION) {
            char* ident = current->left->value.identifier;
            VarType type = current->right->value.varType;

            if (insertSymbol(ident, type) == -1) {
                fprintf(stderr, "Error: Symbol %s already declared\n", current->left->value.identifier);
                exit(1);
            }

            char* typeStr = type == TYPE_INT ? "int" : "bool";
            fprintf(outFile, "%s %s;\n", typeStr, current->left->value.identifier);
        }
        current = current->next;
    }
}

void generateStatements(Node* statements, FILE* outFile) {
    Node* current = statements;
    
    while (current != NULL) {
        switch (current->value.stmtType) {
            case IF_STMT:
                fprintf(outFile, "if (");
                generateExpression(current->left, outFile);
                fprintf(outFile, ") {\n");
                generateStatements(current->right, outFile);
                fprintf(outFile, "}\n");
                break;
            
            case ELSE_CLAUSE:
                fprintf(outFile, "} else {\n");
                generateStatements(current->left, outFile);
                break;
            
            case WHILE_STMT:
                fprintf(outFile, "while (");
                generateExpression(current->left, outFile);
                fprintf(outFile, ") {\n");
                generateStatements(current->right, outFile);
                fprintf(outFile, "}\n");
                break;

            case ASSIGN_STMT: {
                // Check if value is read
                if (current->right->type == NODE_READ) {
                    fprintf(outFile, "scanf(\"%%d\", &");
                    generateExpression(current->left, outFile);
                    fprintf(outFile, ");\n");
                } else {
                    generateExpression(current->left, outFile);
                    fprintf(outFile, " = ");
                    generateExpression(current->right, outFile);
                    fprintf(outFile, ";\n");
                }
                break;
            }

            case WRITE_INT_STMT:
                fprintf(outFile, "printf(\"%%d\\n\", ");
                generateExpression(current->right, outFile);
                fprintf(outFile, ");\n");
                break;
        }
        current = current->next;
    }
}

void generateExpression(Node* expr, FILE* outFile) {
    if (!expr) return;
    
    switch (expr->type) {
        case NODE_IDENTIFIER: {
            char* leftIdent = expr->value.identifier;
            symbol* sym = getSymbol(leftIdent);

            // Check if symbol is declared
            if (!sym) {
                fprintf(stderr, "Error: Symbol %s not declared\n", leftIdent);
                exit(1);
            }

            fprintf(outFile, "%s", leftIdent);
            break;
        }
            
        case NODE_NUMBER:
            fprintf(outFile, "%d", expr->value.number);
            break;

        case NODE_BOOL:
            fprintf(outFile, "%s", expr->value.boolean ? "true" : "false");
            break;
            
        case NODE_OPERATOR:
            if(expr->left->type == NODE_IDENTIFIER) {
                symbol* ident = getSymbol(expr->left->value.identifier);
                if(!ident) {
                    fprintf(stderr, "Error: Symbol %s not declared\n", expr->left->value.identifier);
                    exit(1);
                }
                if(ident->type != TYPE_INT) {
                    fprintf(stderr, "Error: Symbol %s for operator is not an integer\n", expr->left->value.identifier);
                    exit(1);
                }
            }

            if(expr->right->type == NODE_IDENTIFIER) {
                symbol* ident = getSymbol(expr->right->value.identifier);
                if(!ident) {
                    fprintf(stderr, "Error: Symbol %s not declared\n", expr->right->value.identifier);
                    exit(1);
                }
                if(ident->type != TYPE_INT) {
                    fprintf(stderr, "Error: Symbol %s for operator is not an integer\n", expr->right->value.identifier);
                    exit(1);
                }
            }

            generateExpression(expr->left, outFile);
            fprintf(outFile, " %s ", expr->value.opr);
            generateExpression(expr->right, outFile);
            break;
        
        case NODE_CONTAINED_EXPR:
            fprintf(outFile, "(");
            generateExpression(expr->left, outFile);
            fprintf(outFile, ")");
            break;
    }
}