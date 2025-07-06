transition(From, Input, To) :-
    member(From, [0,1,2,3,4,5,6]),
    member(To, [0,1,2,3,4,5,6]),
    member(Input, [0,1]),
    To is From * 2 + Input.


