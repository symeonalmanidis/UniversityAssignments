sum_even([], 0).

sum_even([H|T], X) :-
    0 is H mod 2,
    sum_even(T, X1),
    X is X1 + H.

sum_even([H|T], X) :-
    1 is H mod 2,
    sum_even(T, X).