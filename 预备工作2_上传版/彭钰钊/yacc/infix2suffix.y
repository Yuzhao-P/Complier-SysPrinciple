%{
/*********************************************
YACC file
中缀表达式 to 后缀表达式
Date:2023/10/10
**********************************************/
// 定义(definations)
#include<stdio.h>
#include<stdlib.h>
#include <string.h>

#ifndef YYSTYPE
#define YYSTYPE char* // 我们这次是要实现字符串的转换，因此需要用字符指针的数据类型
#endif

// 定义两个字符串：标识符字符串（id_str）和数据字符串（data_str），长度均为100（没有人会输入比这个更长的标识符或数据字符串吧？！）
char id_str[100];
char data_str[100];

int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}
// 注意先后定义的优先级区别——先定义的优先级低
%token '+' '-' '*' '/' LPATTEN RPATTEN NUMBER ID
%left LPATTEN
%left '+' '-'
%left '*' '/'
%right UMINUS         
%right RPATTEN

%%
// 规则(rules)
// 定义行和表达式的文法规则：lines、expr
// 我们以加法为例进行说明：$$表示结果
// (char*)malloc(strlen($1) + strlen($3) + 1);动态分配内存来存储两个子表达式以及一个符号
// strcpy($$,$1);将子表达式1放在结果字符串中
// strcat($$,$3); strcat($$,"+");将子表达式2和符号拼接到结果字符串中

lines   :       lines expr '\n' { printf("%s\n", $2); }
        |       lines '\n'
        |
        ;

expr    :       expr '+' expr   { $$ = (char*)malloc(strlen($1) + strlen($3) + 1); strcpy($$,$1); strcat($$,$3); strcat($$,"+ "); }
        |       expr '-' expr   { $$ = (char*)malloc(strlen($1) + strlen($3) + 1); strcpy($$,$1); strcat($$,$3); strcat($$,"- "); }
        |       expr '*' expr   { $$ = (char*)malloc(strlen($1) + strlen($3) + 1); strcpy($$,$1); strcat($$,$3); strcat($$,"* "); }
        |       expr '/' expr   { $$ = (char*)malloc(strlen($1) + strlen($3) + 1); strcpy($$,$1); strcat($$,$3); strcat($$,"/ "); }
        |       LPATTEN expr RPATTEN      { $$ = (char*)malloc(strlen($1) + 1); strcpy($$,$2); }
        |       '-' expr %prec UMINUS   { $$ = (char*)malloc(strlen($1) + 1); strcpy($$,"-");strcat($$,$2); }
        |       NUMBER { $$ = (char*)malloc(strlen($1) + 1); strcpy($$, $1); strcat($$," ");} // 使用空格分隔，下同
		|	    ID { $$ = (char*)malloc(strlen($1) + 1); strcpy($$, $1); strcat($$," ");}
		;
%%

// programs section
//代码(user code)

int yylex()
{
    // 用于暂存输入字符的变量
    char t;
    
    // 跳过空格和制表符
    while ((t = getchar()) == ' ' || t == '\t') {
        continue;
    }
    
    // 如果是数字，开始识别多位数
    if ((t >= '0' && t <= '9')) {
        int index = 0;
        data_str[index++] = t;
        while ((t = getchar()) && (t >= '0' && t <= '9')) {
            data_str[index++] = t;
        }
        data_str[index++] = '\0';
        yylval = data_str;
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
        yylval = id_str;
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