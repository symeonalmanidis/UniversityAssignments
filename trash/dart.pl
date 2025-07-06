f(List,X,Y) :- f(List,1,X,Y).

f([], _, _, 0).

f([H|T],XP,X,Y) :-
    XX is XP * X,
    f(T,XX,X,YY),
    Y is XP * H + YY.
    

solve(A,B,C,D,E) :-
    A is (115),
    B is (105 - (A + C + D + E)),
    C is (109 - (A + B * 2 + D * 8 + E * 16) ) / 2,
    D is (111 - (A + B * 3 + C * 9 + E * 81)) / 27,
    E is (115 - (A + B * 4 + C * 16 + E * 64)) / 256.