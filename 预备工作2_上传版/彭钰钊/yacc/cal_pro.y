%{
/*********************************************
YACC file
要求：
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等空白符，能识别多位十进制整数。
Date:2023/10/10
**********************************************/
// 定义(definations)
#include<stdio.h>
#include<stdlib.h>

#ifndef YYSTYPE
#define YYSTYPE double
#endif

int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}
// 注意先后定义的优先级区别——先定义的优先级低
%token '+' '-' '*' '/' LPATTEN RPATTEN NUMBER
%left LPATTEN
%left '+' '-'
%left '*' '/'
%right UMINUS         
%right RPATTEN

%%
// 规则(rules)
// 定义行和表达式的文法规则：lines、expr

lines   :       lines expr '\n' { printf("%f\n", $2); }
        |       lines '\n'
        |
        ;

// TODO:完善表达式的规则
expr    :       expr '+' expr   { $$=$1+$3; }
        |       expr '-' expr   { $$=$1-$3; }
        |       expr '*' expr   { $$=$1*$3; }
        |       expr '/' expr   { $$=$1/$3; }
        |       LPATTEN expr RPATTEN      { $$ = $2; }
        |       '-' expr %prec UMINUS   { $$=-$2; }
        |       NUMBER { $$ = $1; }
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