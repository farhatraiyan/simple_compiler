#ifndef CODE_GEN_H
#define CODE_GEN_H

#include "parse_tree.h"
#include "sym_table.h"

void generateCode(Node* root, FILE* outFile);
void generateDeclarations(Node* declarations, FILE* outFile);
void generateStatements(Node* statements, FILE* outFile);
void generateExpression(Node* expr, FILE* outFile);

#endif