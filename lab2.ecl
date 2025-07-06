sumn(0, 0).

sumn(N, X) :-
    N > 0,
    NN is N - 1,
    sumn(NN, XX),
    X is N + XX.