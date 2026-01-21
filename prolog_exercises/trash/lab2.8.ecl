	
int_in_range(Min, Max, Min) :-
	Min =< Max.

int_in_range(Min, Max, Out) :-
	Min < Max,
	NextMin is Min + 1,
	int_in_range(NextMin, Max, Out).
 

transition(From, Input, To) :-
	int_in_range(0, 6, From),
	int_in_range(0, 6, To),
	int_in_range(0, 1, Input),
	To is mod(From * 2 + Input, 7).

