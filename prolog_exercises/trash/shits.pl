scan([X], [X]).
scan(Predicate, [X,Y|Tail], [X | NewList]) :- 
    call(Predicate, X, Y, XY),
    scan(Predicate, [XY|Tail], NewList).


reduce(_, [Acc], Acc).
reduce(Predicate, [X,Y|Tail], Acc) :- 
    call(Predicate, X, Y, XY),
    reduce(Predicate, [XY|Tail], Acc).


first([H|_], H).

last([Last], Last).
last([_|Tail], Last) :-
    last(Tail, Last).

length([], 0).
length([H|T], Length) :-
    length(T, Length1),
    Length is Length1 + 1.

shape([], [0]).

shape(X, []) :-
    integer(X).
     
shape([H|T], [Length|Rest]) :-
    length([H|T], Length),
    shape(H, Rest).


select([], _, []).

select(Index, List, Element) :-
    integer(Index),
    nth0(Index, List, Element).

select([IndexH|IndexT], List, [ElementH|ElementT]) :-
    select(IndexH, List, ElementH),
    select(IndexT, List, ElementT).
