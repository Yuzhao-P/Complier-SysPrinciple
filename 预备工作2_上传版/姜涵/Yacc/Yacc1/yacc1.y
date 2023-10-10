%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#ifndef YYSTYPE
#define YYSTYPE double
#endif
int yylex();
extern int yyparse();
FILE* yyin;
void yyerror(const char* s);
%}

//TASK:给每个符号定义一个单词类别
%token ADD
%token SUB
%token MUL
%token DIV
%token LBRA
%token RBRA
%token INT
%left ADD SUB MUL DIV


%%


lines   :       lines expr ';' { printf("%f\n", $2); }
        |       lines ';'
        |
        ;
//TASK:完善表达式的规则
expr    :       expr ADD expr { $$=$1+$3; }
        |		expr SUB expr { $$=$1-$3; }
        |		expr MUL expr { $$=$1*$3; }
        |		expr DIV expr { $$=$1/$3; }
        |       LBRA expr RBRA { $$=$2; }
        |       INT { $$=$1; }
        ;

%%

// programs section

int yylex()
{
    int t;
    while(1){
        t=getchar();
        if(t==' '||t=='\t'||t=='\n'){//识别并忽略空格、制表符、回车空白符
            //do noting
        }else if(isdigit(t)){
            //TASK:解析多位数字返回数字类型 
            yylval = 0;//存储从输入中识别的标记的值,初始化为0
            while(isdigit(t))
            {
                yylval = yylval*10+t-'0';
                t=getchar();//从输入流中获取下一个字符，并将其存储在变量 t 中
            }
            ungetc(t,stdin);//将最后一个读取的字符 t 放回输入流，以便后续的处理可以再次读取它，确保只读取了整数部分，不会意外地读取下一个标记的一部分。
            return INT;//当整数已经被成功地识别并存储在 yylval 中后，函数返回一个标记 INT，表示一个整数标记。
        }else
        {
            switch(t){
                case '+' : return ADD;
                case '-' : return SUB;
                case '*' : return MUL;
                case '/' : return DIV;
                case '(' : return LBRA;
                case ')' : return RBRA;
                default : return t;//其他符号
            }
        }
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
