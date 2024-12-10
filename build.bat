cd src
bison -d proj_bison.y
flex proj_flex.l
gcc lex.yy.c proj_bison.tab.c sym_table.c code_gen.c -o compiler