seperate_list([], [], []).
    
seperate_list([H|T], Lets, [H|Nums]) :-
    number(H), !, seperate_list(T, Lets, Nums).

seperate_list([H|T], [H|Lets], Nums) :-
    seperate_list(T, Lets, Nums).