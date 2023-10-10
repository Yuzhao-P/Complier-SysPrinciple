%{
/*********************************************
将所有的词法分析功能均放在 yylex 函数内实现，为 +、-、*、\、(、 ) 每个运算符及整数分别定义一个单词类别，在 yylex 内实现代码，能
识别这些单词，并将单词类别返回给词法分析程序。
实现功能更强的词法分析程序，可识别并忽略空格、制表符、回车等
空白符，能识别多位十进制整数。
YACC file
**********************************************/
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
//1、添加标准库
#include <string.h>
#ifndef YYSTYPE
//2、更改返回值类型
#define YYSTYPE char*
#endif
//3、添加存储标识符和数字的数组
char idStr[50];
char numStr[50];
int yylex ();
extern int yyparse();
FILE* yyin ;
void yyerror(const char* s );
%}
%token ADD
%token SUB
%token MUL
%token DEV
%token LPA
%token RPA
%token INT
//4、增加标识符token
%token ID
%left ADD SUB
%left MUL DEV
%right UMINUS

%%


lines : lines expr ';' { printf("%s\n", $2); }
      | lines ';'
      |
      ;
//5、表达式的规则修改
expr : expr ADD expr { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"+ "); }
     | expr SUB expr { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"- "); }
     | expr MUL expr { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"* "); }
     | expr DEV expr { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$,$3); strcat($$,"/ "); }
     | LPA expr RPA { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$2); }
     | SUB expr %prec UMINUS { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,"-"); strcat($$,$2); }
     | INT { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$," "); }
     | ID  { $$ = (char*)malloc(50*sizeof(char)); strcpy($$,$1); strcat($$," "); }
     ;


%%

// programs section
// 将输入的字符串进行词法分析
//修改6
int yylex()
{
    // place your token retrieving code here
    int t;
    while(1){
        t = getchar ();
        if (t == ' ' || t== '\t' || t == '\n'){}
        else if(t>='0' && t<='9'){//如果当前读取的字是数字，
            int ti=0;
            while(t>='0' && t<='9'){//将连续的数字字符组成一个完整的整数字符串
                numStr[ti]=t;
                t=getchar();
                ti++;
            }
            numStr[ti]=0;
            yylval=numStr;
            ungetc(t,stdin);
            return INT;
            //将其赋值给全局变量 numStr。然后将 t 放回输入流，并返回词法记号 INT。
        }
        else if((t>='a' && t<='z')||(t>='A' && t<='Z')||(t=='_')){
            int ti=0;
            while((t>='a' && t<='z')||(t>='A' && t<='Z')||(t=='_')||(t>='0' && t<='9')){
                idStr[ti]=t;
                t=getchar();
                ti++;
            }
            idStr[ti]=0;
            yylval=idStr;
            ungetc(t,stdin);
            return ID;
        }
        else{
            switch(t){
                    case '+':return ADD;
                    case '-':return SUB;
                    case '*':return MUL;
                    case '/':return DEV;
                    case '(':return LPA;
                    case ')':return RPA;
                    default:return t;
            }
        }
    }
}

int main(void)
{
    yyin = stdin;
    do {
        yyparse();
    } while (!feof (yyin));
    return 0;
}
void yyerror(const char* s) {
    fprintf (stderr , "Parse error : %s\n", s );
    exit (1);
}
