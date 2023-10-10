%{
/*********************************************
YACC file
实现表达式的赋值功能——符号表
Date:2023/10/10
**********************************************/
// 定义(definations)
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include <stdbool.h>

#ifndef YYSTYPE
#define YYSTYPE double
#endif

// 定义字符串：标识符字符串（id_str）长度为100（没有人会输入比这个更长的标识符或数据字符串吧？！）
char id_str[100];

// 定义符号表
// 定义符号表项的结构
struct SymbolEntry {
    char name[100];
    int value;
}symbolTable[100];
int symbolTableSize = 0;

// 函数用于查找符号表中的变量
bool find_symbol(char* name, double *value) {
    for (int i = 0; i < 100; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            *value = symbolTable[i].value;
            return true;  // 找到了变量
        }
    }
    return false;  // 未找到变量
}

// 函数用于向符号表添加变量
void add_symbol(char* name, double value) {
    for (int i = 0; i < symbolTableSize; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            // 同名变量已存在，更新它的值
            symbolTable[i].value = value;
            return;
        }
    }

    // 如果没有找到同名变量，添加新变量
    if (symbolTableSize < 100) {
        strcpy(symbolTable[symbolTableSize].name, name);
        symbolTable[symbolTableSize].value = value;
        symbolTableSize++;
    } else {
        fprintf(stderr, "符号表已满，无法添加更多变量。\n");
        exit(1);
    }
}

int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}
// 注意先后定义的优先级区别——先定义的优先级低
%token '+' '-' '*' '/' '=' LPATTEN RPATTEN NUMBER ID
%left LPATTEN
%left '+' '-'
%left '*' '/'
%right UMINUS         
%right RPATTEN

%%
// 规则(rules)
// 定义行和表达式的文法规则：lines、expr

lines   :       lines expr '\n' { printf("%f\n", $2); }
        |       lines assignment '\n'
        |
        ;

assignment : ID '=' expr {
    double value = $3;
    add_symbol(id_str, value);
    printf("%s = %f\n", id_str, value);
}


// TODO:完善表达式的规则
expr    :       expr '+' expr   { $$=$1+$3; }
        |       expr '-' expr   { $$=$1-$3; }
        |       expr '*' expr   { $$=$1*$3; }
        |       expr '/' expr   { $$=$1/$3; }
        |       LPATTEN expr RPATTEN      { $$ = $2; }
        |       '-' expr %prec UMINUS   { $$=-$2; }
        |       NUMBER { $$ = $1; }
		|       ID { double value; if (find_symbol(id_str, &value)) $$ = value; else { yyerror("未定义的变量"); $$ = 0; } }
        ;
%%

// programs section
//代码(user code)

int yylex()
{
    // 用于暂存输入字符的变量
    int t;
    
    // 跳过空格和制表符
    while ((t = getchar()) == ' ' || t == '\t') {
        continue;
    }
    
    // 开始识别多位数
    if ((t >= '0' && t <= '9')) {
        int data = t - '0';
        while ((t = getchar()) && (t >= '0' && t <= '9')) {
            data = data * 10 + t - '0';
        }
        yylval = data;
        ungetc(t, stdin);
        return NUMBER;
    }
    
    // 如果是字母或下划线，开始识别标识符
    if ((t >= 'a' && t <= 'z') || (t >= 'A' && t <= 'Z') || t == '_') {
        int index = 0;
        id_str[index++] = t;
        while ((t = getchar()) && ((t >= '0' && t <= '9') || t == '_')) {
            id_str[index++] = t;
        }
        id_str[index] = '\0';
        ungetc(t, stdin);
        return ID;
    }
    
    // 处理其他可能的词法单元，如运算符、括号等
    switch (t) {
        case '+':
            return '+';
        case '-':
            return '-';
        case '*':
            return '*';
        case '/':
            return '/';
        case '(':
            return LPATTEN;
        case ')':
            return RPATTEN;
        default:
            return t;  // 其他字符直接返回
    }
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
    }while(!feof(yyin));
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}