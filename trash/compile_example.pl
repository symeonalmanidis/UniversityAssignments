operation(+, X, X+1).
    
transition(To, To, []) :- !.

transition(From, To, [Op|Rest]) :-
    operation(Op, From, From1),
    transition(From1, To, Rest).