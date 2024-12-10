#ifndef SYM_TABLE_H
#define SYM_TABLE_H

#include "uthash.h"
#include "parse_tree.h"

#define SYMTBL_ITER(sym) symbol* sti_tmp; HASH_ITER(hh, symbolTable, (sym), sti_tmp)

typedef struct symbol {
    char* name;
    VarType type;

    UT_hash_handle hh;
} symbol;

extern symbol* symbolTable;

int insertSymbol(char* name, VarType type);
symbol* getSymbol(char* ident);

#endif