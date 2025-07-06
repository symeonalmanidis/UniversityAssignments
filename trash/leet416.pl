
partition2([], 0, 0).

partition2([H|T], S1, S2) :-
    partition2(T, I, S2),
    S1 is I + H.

partition2([H|T], S1, S2) :-
    partition2(T, S1, I),
    S2 is I + H.

canPartition(List) :- 
    HalfSum is sum(List) div 2,
    partition2(List, HalfSum, HalfSum), !.


