%{
/*********************************************
YACC file
RE2NFA：正则表达式转NFA
**********************************************/
// 定义(definations)
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include"NFA_Struct&Thompson.h"

int quit_flag = 0;
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}
%union {
    char charval;
    NFA nfaval;
}
// 注意先后定义的优先级区别——先定义的优先级低
%token '|' '*' '(' ')'
%token <charval> CHAR EPSILON
%type <nfaval> regex concat kleene base

%%
// 规则(rules)
// 正则表达式文法

regex   :       regex '|' concat    { $$ = create_union_state($1, $3); resNFA = $$; }
        |       concat              { $$ = $1; resNFA = $$; }
        ;

concat  :       concat kleene   { $$ = create_concat_state($1, $2); }
        |       kleene          { $$ = $1; }
        ;

kleene  :       base '*'    { $$ =create_kleene_state($1); }
        |       base        { $$ = $1; }
        ;
base    :       CHAR            { $$ = create_base1_state($1); }
        |       EPSILON         { $$ = create_base2_state(); }
		|       '(' regex ')'   { $$ = $2; }
        ;
%%

// programs section
//代码(user code)

int yylex()
{
    // 用于暂存输入字符的变量
    char t;
    t = getchar();

    switch(t) {
        case '|': return '|';
        case '*': return '*';
        case '(': return '(';
        case ')': return ')';
        case '\n':  // 自定义结束条件：回车结束输入，输出NFA信息
        {
            quit_flag = 1;
            return -1;
        }
        case '#': 
        {
            yylval.charval = t;
            return EPSILON;  // 使用符号#表示空串
        }
        default:
            if (isalnum(t)) {
                yylval.charval = t;
                return CHAR;
            }
    }
    return t;
}

int main(void)
{
    yyin=stdin;
    do{
        yyparse();
        if(quit_flag)break;
    }while(!feof(yyin));
    // 将文件输出至 result
    FILE* file = fopen("result", "w");
    if (file) {
        printNFA(resNFA, file);
        fclose(file);
    } else {
        fprintf(stderr, "无法打开文件...\n");
    }
    // 将结构体数据写入文件
    FILE *f = fopen("data.dat", "wb");
    fwrite(&resNFA, sizeof(struct NFA), 1, f);
    fclose(f);
    return 0;
}
void yyerror(const char* s){
    fprintf(stderr,"Parse error: %s\n",s);
    exit(1);
}