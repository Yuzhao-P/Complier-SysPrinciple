.PHONY: test1, test2, clean
test1:
	yacc RE2NFA.y 
	gcc y.tab.c -o RE2NFA
	./RE2NFA
test2:
	gcc NFA2DFA.c -o NFA2DFA
	./NFA2DFA
clean:
	rm -fr *.out