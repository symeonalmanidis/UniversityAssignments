unique_element(X, List) :-
    delete(X, List, NewList),
    not(member(X, NewList)).

proper_set(List) :-
    not((member(X, List), not(unique_element(X, List)))).

seperate_list([], [], []).
    
seperate_list([H|T], Lets, [H|Nums]) :-
    number(H), !,
    seperate_list(T, Lets, Nums).

seperate_list([H|T], [H|Lets], Nums) :-
    seperate_list(T, Lets, Nums).


less_ten(X) :- X < 10.
less_twenty(X) :- X < 20.

filter(_Pred, [], []).

filter(Pred, [H|T], [H|NewList]) :-
    Xex =.. [Pred, H],
    call(Xex),
    !,
    filter(Pred, T, NewList).

filter(Pred, [_H|T], NewList) :-
    filter(Pred, T, NewList).
