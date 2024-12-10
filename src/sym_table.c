#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "sym_table.h"

symbol* symbolTable = NULL;

symbol* createSymbol(char* name, VarType type) {
    symbol* sym = (symbol*)malloc(sizeof(symbol));
    sym->name = name;
    sym->type = type;
    return sym;
}

int insertSymbol(char* name, VarType type) {
    symbol* sym = getSymbol(name);

    // Symbol already exists
    if(sym)
    {
        return -1;
    }

    sym = createSymbol(name, type);
    HASH_ADD_KEYPTR(hh, symbolTable, sym->name, strlen(sym->name), sym);
    return 0;
}

symbol* getSymbol(char* ident) {
    symbol* found = NULL;
    HASH_FIND(hh, symbolTable, ident, strlen(ident), found);
    return found;
}