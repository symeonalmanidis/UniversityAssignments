is_special_perm([_]).
is_special_perm([X,Y|T]) :-
    (0 is mod(X,Y); 0 is mod(Y,X)),
    is_special_perm([Y|T]).


pairwise([X,Y|_], X, Y).
pairwise([X,Y|T], X, Y) :-
    pairwise([Y|T], X, Y).

specialPerm(List, Count) :-
    aggregate_all(count, (permutation(List, Perm), is_special_perm(Perm)), Count).