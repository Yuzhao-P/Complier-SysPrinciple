#ifndef NFA_STRUCT_THOMPSON_H
#define NFA_STRUCT_THOMPSON_H
#include<stdio.h>
#include<stdlib.h>

// 声明NFA的辅助数据结构：状态节点（node）、状态转换边（edge）
typedef struct NFA_node NFA_node;
typedef struct NFA_edge NFA_edge;
// 定义
struct NFA_edge{
    char symbol;  // 转移输入字符
    NFA_node *src;  // 转移边的起始状态
    NFA_node *tgt;  // 转移边的目标状态
    NFA_edge *next;  // 处理“或”以及“闭包”的情况
};

struct NFA_node{
    int flag;  // 是否为接受状态的标志位，是接受状态则置为1
    int ID;  // 状态唯一标识符
    NFA_edge *edge;  // 状态转移边
};

// 声明NFA数据结构
typedef struct NFA NFA;
// 定义
struct NFA{
    NFA_node *start;  // 开始状态
    NFA_node *accept;  // 接受状态
 };

int StateIDCount=0;  // 状态唯一标识符初始化
NFA resNFA; // 用于存储最终的NFA
#define MAX_SYMBOLS_SIZE 20
#define MAX_STATES_SIZE 50

// NFA操作
// 创建新状态
NFA_node* create_NFA_node(int flag){
    NFA_node *s = malloc(sizeof(NFA_node));
    s->flag = flag;
    s->edge = NULL;
    s->ID = StateIDCount++;
    return s;
}
// 创建状态转换边
void create_NFA_edge(NFA_node* src, NFA_node* tgt, char symbol){
    NFA_edge *e = malloc(sizeof(NFA_edge));
    e->symbol = symbol;
    e->src = src;
    e->tgt = tgt;
    e->next = src->edge;
    src->edge = e;
}
// 最基本的状态1：接受一个字符
NFA create_base1_state(char symbol){
    NFA_node *start = create_NFA_node(0);
    NFA_edge *accept = create_NFA_node(1);
    create_NFA_edge(start, accept, symbol);
    return (NFA) {start, accept};
}
// 最基本的状态2：接受epsilon（空串）
NFA create_base2_state(){
    NFA_node *start = create_NFA_node(0);
    NFA_edge *accept = create_NFA_node(1);
    create_NFA_edge(start, accept, '#');
    return (NFA) {start, accept};
}
// 处理 s|t 的情况
NFA create_union_state(NFA s, NFA t){
    NFA_node *start = create_NFA_node(0);
    NFA_edge *accept = create_NFA_node(1);

    create_NFA_edge(start, s.start, '#');
    create_NFA_edge(start, t.start, '#');
    create_NFA_edge(s.accept, accept, '#');
    create_NFA_edge(t.accept, accept, '#');
    
    s.accept->flag = 0;
    t.accept->flag = 0;

    return (NFA) {start, accept};
}
// 处理 st 的情况：我们采用方法二（参考自老师的PPT）
NFA create_concat_state(NFA s, NFA t){
    NFA_node *start = create_NFA_node(0);
    NFA_edge *accept = create_NFA_node(1);

    create_NFA_edge(start, s.start, '#');
    create_NFA_edge(s.accept, t.start, '#');
    create_NFA_edge(t.accept, accept, '#');
    
    s.accept->flag = 0;
    t.accept->flag = 0;

    return (NFA) {start, accept};
}
// 处理 s* 的情况
NFA create_kleene_state(NFA s){
    NFA_node *start = create_NFA_node(0);
    NFA_edge *accept = create_NFA_node(1);

    create_NFA_edge(start, s.start, '#');
    create_NFA_edge(s.accept, s.start, '#');
    create_NFA_edge(s.accept, accept, '#');
    create_NFA_edge(start, accept, '#');
    
    s.accept->flag = 0;

    return (NFA) {start, accept};
}

// 输出函数
void printNFA(NFA nfa, FILE *f) {
    fprintf(f, "-----  NFA 基本信息  -----\n");
    fprintf(f, "说明：使用符号'#'表示ε\n");
    fprintf(f, "处理 st 的情况，我们采用方法二\n");
    fprintf(f, "NFA 起始状态: %d\n", nfa.start->ID);
    fprintf(f, "NFA 接受状态: %d\n", nfa.accept->ID);
    fprintf(f, "NFA 状态数: %d\n", StateIDCount);
    fprintf(f, "--------------------------\n");
    fprintf(f, "-----  NFA 状态转移  -----\n");
    // 采用BFS：看起来似乎更符合选择，我们到达一个节点后给出可选择的后续节点
    // 参考：https://blog.csdn.net/qq_44918331/article/details/115542177
    // 参考：https://blog.csdn.net/g11d111/article/details/76169861
    NFA_node *state_Q[MAX_STATES_SIZE];  // 状态队列——BFS：使用数组实现
    int visited[MAX_STATES_SIZE] = { 0 }; // 辅助数据结构：标记当前节点是否被访问, 0 - 未访问, 1 - 已访问
    // 标记队首队尾
    int front = 0;
    int rear = 0;
    // 初始状态：起点入队，标记已访问
    state_Q[rear++] = nfa.start;
    visited[nfa.start->ID] = 1;

    while(front != rear){  // 队列不为空则继续搜索
        NFA_node *curr = state_Q[front++];  // 掐头
        fprintf(f, "状态编号: %d(是否为接受状态: %d)\n", curr->ID, curr->flag);
        
        NFA_edge* edge = curr->edge;
        while(edge != NULL){
            fprintf(f, " - 【转移字符】 '%c' -> 目标状态: %d\n", edge->symbol, edge->tgt->ID);

            // 如果目标状态尚未被访问，将其添加到队列中
            if (!visited[edge->tgt->ID]) {
                state_Q[rear++] = edge->tgt;
                visited[edge->tgt->ID] = 1;
            }

            edge = edge->next;
        }
    }
}

#endif NFA_STRUCT_THOMPSON_H