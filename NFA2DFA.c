#include"NFA2DFA.h"
#include<string.h>

DFA* NFA_to_DFA(NFA* resNFA){
    char resNFAalphabet[MAX_SYMBOLS_SIZE];
    Get_alphabet(resNFA, resNFAalphabet);

    // 初始化DFA
    DFA* dfa = malloc(sizeof(DFA));
    dfa->start = NULL;
    dfa->accept_states = malloc(MAX_STATES_SIZE * sizeof(DFA_node*));
    dfa->num_accept_states = 0;

    // 创建NFA的起始状态的ε-closure
    EpsilonClosure* startClosure = computeEpsilonClosure(resNFA->start);

    // 创建DFA的起始状态
    DFA_node* startState = create_DFA_node(startClosure, 0, resNFA);
    dfa->start = startState;

    DFA_node* stateQueue[MAX_STATES_SIZE];
    int stateQueueFront = 0;
    int stateQueueRear = 0;
    stateQueue[stateQueueRear++] = startState;

    int stateID = 1;

    while (stateQueueFront < stateQueueRear) {
        DFA_node* currentState = stateQueue[stateQueueFront++];

        for (int i = 0; i < strlen(resNFAalphabet); i++) {
            char symbol = resNFAalphabet[i];

            EpsilonClosure* closure_T = computeEpsilonClosure_T(currentState, symbol);

            if (closure_T->count == 0) {
                continue;
            }

            // Check if the new state is already in the DFA
            int stateExists = 0;
            for (int j = 0; j < stateQueueRear; j++) {
                if (compareEpsilonClosures(closure_T, stateQueue[j]->nfa_states) == 1) {
                    create_DFA_edge(currentState, stateQueue[j], symbol);
                    stateExists = 1;
                    break;
                }
            }

            if (!stateExists) {
                // Create a new DFA state
                DFA_node* newState = create_DFA_node(closure_T, stateID++, resNFA);
                create_DFA_edge(currentState, newState, symbol);
                stateQueue[stateQueueRear++] = newState;
            }
        }
    }

    // Identify and store accept states in DFA
    for (int i = 0; i < stateQueueRear; i++) {
        if (stateQueue[i]->flag == 1) {
            dfa->accept_states[dfa->num_accept_states++] = stateQueue[i];
        }
    }

    return dfa;
}

int main(){
    FILE *file = fopen("data.dat", "rb");
    if (file != NULL) {
        fread(&resNFA, sizeof(struct NFA), 1, file);
        fclose(file);
    }
    printf("1");
    DFA *dfa = NFA_to_DFA(&resNFA);
    printDFA(dfa);
    return 0;
}
