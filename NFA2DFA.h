#ifndef NFA2DFA_H
#define NFA2DFA_H
#include<stdio.h>
#include<stdlib.h>
#include"NFA_Struct&Thompson.h"

// 深度优先算法：计算NFA状态集合
void DFS_for_alphabet(NFA_node *state, int *symbolExisted, int *visited, int *index, char *alphabet) {
    // 如果节点已访问则返回
    if (visited[state->ID]) return;

    // 节点未访问——标记
    visited[state->ID] = 1;

    NFA_edge *curr = state->edge;
    while (curr != NULL) {
        if (!symbolExisted[(unsigned char)curr->symbol]){  // 该符号还没有存在于字母表中
            symbolExisted[(unsigned char)curr->symbol] = 1;  // 标记存在
            alphabet[(*index)++] = curr->symbol;
        }
        // 深搜下一个
        DFS_for_alphabet(curr->tgt, symbolExisted, visited, index, alphabet);
        curr = curr->next;
    }
}
void Get_alphabet(NFA* nfa, char* alphabet) {
    int symbolExisted[MAX_STATES_SIZE] = { 0 };
    int visited[MAX_STATES_SIZE] = { 0 };
    int index = 0;

    DFS_for_alphabet(nfa->start, symbolExisted, visited, &index, alphabet);

    alphabet[index] = '\0'; // 结束符号
}

// 声明DFA的辅助数据结构：状态节点（node）、状态转换边（edge）、ε-closure
typedef struct DFA_node DFA_node;
typedef struct DFA_edge DFA_edge;
typedef struct EpsilonClosure EpsilonClosure;

// 定义
struct DFA_edge{
    char symbol;  // 转移输入字符
    DFA_node *src;  // 转移边的起始状态
    DFA_node *tgt;  // 转移边的目标状态
    DFA_edge *next;  // 同一个起点
};
struct DFA_node{
    int flag;  // 是否为接受状态的标志位，是接受状态则置为1
    int ID;  // 状态唯一标识符
    DFA_edge *edge;  // 状态转移边
    EpsilonClosure *nfa_states;  // 对应的NFA状态的ε-closure
};
struct EpsilonClosure{
    NFA_node **states;  // NFA状态指针数组
    int count;          // 状态的数量
};
// 声明DFA数据结构
typedef struct DFA DFA;
struct DFA {
    DFA_node *start;  // DFA状态节点指针数组
    DFA_node **accept_states;  // 接受状态数组
    int num_accept_states;  // 接受状态的数量
};

// 创建状态转换边
void create_DFA_edge(DFA_node* src, DFA_node* tgt, char symbol){
    DFA_edge *e = malloc(sizeof(DFA_edge));
    e->symbol = symbol;
    e->src = src;
    e->tgt = tgt;
    e->next = src->edge;
    src->edge = e;
}

// 深度优先算法：计算ε-closure
void DFS_for_closure(NFA_node *state, int *visited, EpsilonClosure *closure){
    // 如果节点已访问则返回
    if(visited[state->ID]) return;
    // 节点未访问——标记
    visited[state->ID] = 1;
    // 首先包括自己
    closure->states[closure->count++] = state;
    NFA_edge *curr = state->edge;
    while( curr != NULL){
        if( curr->symbol == '#' ){  // ε边
            DFS_for_closure(curr->tgt, visited, closure);
        }
        curr = curr->next;
    }
}
EpsilonClosure* computeEpsilonClosure(NFA_node *state){
    EpsilonClosure *closure = malloc(sizeof(EpsilonClosure));
    closure->states = malloc(MAX_STATES_SIZE * sizeof(NFA_node*));
    closure->count = 0;

    int visited[MAX_STATES_SIZE] = { 0 };
    DFS_for_closure(state, visited, closure);

    return closure;
}

// 创建新状态
DFA_node* create_DFA_node(EpsilonClosure *closure, int ID, NFA* nfa){
    DFA_node *s = malloc(sizeof(DFA_node));
    s->flag = 0;
    s->edge = NULL;
    s->ID = ID;
    s->nfa_states = closure;
    for (int i = 0; i < closure->count; i++){
        if (nfa->accept->ID == closure->states[i]->ID){
            s->flag = 1;  // 包含NFA接受状态的都是DFA的接受状态
            break;
        }
    }
    return s;
}
// 判断状态是否在闭包里
int isStateInClosure(EpsilonClosure* closure, int NFAStateID){
    for (int i = 0; i < closure->count; i++){
        if (closure->states[i]->ID == NFAStateID){
            return 1;  // 存在
        }
    }
    return 0;  // 不存在
}
// move函数
void move(EpsilonClosure* closure, EpsilonClosure* tgt, char symbol){
    for(int i = 0; i < closure->count; i++){
        NFA_node* curr = closure->states[i];
        NFA_edge* e = curr->edge;
        while(e != NULL){
            if (e->symbol == symbol && !isStateInClosure(tgt, e->tgt->ID)){
                tgt->states[tgt->count++] = e->tgt;
            }
            e = e->next;
        }
    }
}
// 计算ε-closure(T)的辅助函数：我们将move和move中的每一个ε-closure合并
void merge(EpsilonClosure* tgtClosure, EpsilonClosure* srcClosure){
    for (int i = 0; i < srcClosure->count; i++){
        if (!isStateInClosure(tgtClosure, srcClosure->states[i]->ID)){
            tgtClosure->states[tgtClosure->count++] = srcClosure->states[i];
        }
    }
}
// 计算ε-closure(T)
EpsilonClosure* computeEpsilonClosure_T(DFA_node* dfaState, char symbol){
    // 初始化
    EpsilonClosure* Closure_T = malloc(sizeof(EpsilonClosure));
    Closure_T->count = 0;
    // move函数计算
    move(dfaState->nfa_states, Closure_T, symbol);
    for (int i = 0; i < Closure_T->count; i++){
        EpsilonClosure* tmpClosure_T = computeEpsilonClosure(Closure_T->states[i]);
        merge(Closure_T, tmpClosure_T);
    }
    return Closure_T;
}
// 判断集合是否一致
// 检查两个ε-closure是否相等
int compareEpsilonClosures(EpsilonClosure* closure1, EpsilonClosure* closure2){
    if (closure1->count != closure2->count){
        return 0;  // 数量不同，肯定不相等
    }

    for (int i = 0; i < closure1->count; i++){
        int found = 0;
        for (int j = 0; j < closure2->count; j++){
            if (closure1->states[i]->ID == closure2->states[j]->ID){
                found = 1;
                break;
            }
        }
        if (!found){
            return 0;  // 存在不同的NFA状态
        }
    }

    return 1;  // ε-closure相等
}

// 输出DFA的函数
void printDFA(DFA* dfa) {
    FILE *f = fopen("DFAoutput", "w");
    fprintf(f, "-----  DFA 基本信息  -----\n");
    fprintf(f, "说明：使用符号'#'表示ε\n");
    fprintf(f, "DFA 起始状态: %d\n", dfa->start->ID);
    fprintf(f, "DFA 接受状态数: %d\n", dfa->num_accept_states);
    fprintf(f, "DFA 接受状态:");
    for (int i = 0; i < dfa->num_accept_states; i++) {
        fprintf(f, " %d", dfa->accept_states[i]->ID);
    }
    fprintf(f, "\n");
    fprintf(f, "--------------------------\n");
    fprintf(f, "-----  DFA 状态转移  -----\n");

    DFA_node* state_Q[MAX_STATES_SIZE];
    int visited[MAX_STATES_SIZE] = {0};
    int front = 0;
    int rear = 0;
    state_Q[rear++] = dfa->start;
    visited[dfa->start->ID] = 1;

    while (front != rear) {
        DFA_node* curr = state_Q[front++];
        fprintf(f, "状态编号: %d(是否为接受状态: %d)\n", curr->ID, curr->flag);

        DFA_edge* edge = curr->edge;
        while (edge != NULL) {
            fprintf(f, " - 【转移字符】 '%c' -> 目标状态: %d\n", edge->symbol, edge->tgt->ID);
            if (!visited[edge->tgt->ID]) {
                state_Q[rear++] = edge->tgt;
                visited[edge->tgt->ID] = 1;
            }
            edge = edge->next;
        }
    }
    fclose(f);
}

#endif NFA2DFA_H