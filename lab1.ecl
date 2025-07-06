
%%%% ADD %%%%%%%%%%%%%%%%%%%%%%%%%

command(add_r1, 
        state(acc(X  ), reg1(Y), reg2(R2), reg3(R3)),
        state(acc(X+Y), reg1(Y), reg2(R2), reg3(R3))).

command(add_r2, 
        state(acc(X  ), reg1(R1), reg2(Y), reg3(R3)),
        state(acc(X+Y), reg1(R1), reg2(Y), reg3(R3))).

command(add_r3, 
        state(acc(X  ), reg1(R1), reg2(R2), reg3(Y)),
        state(acc(X+Y), reg1(R1), reg2(R2), reg3(Y))).



%%%% SUB %%%%%%%%%%%%%%%%%%%%%%%%%

command(subtract_r1, 
        state(acc(X  ), reg1(Y), reg2(R2), reg3(R3)),
        state(acc(X-Y), reg1(Y), reg2(R2), reg3(R3))).

command(subtract_r2, 
        state(acc(X  ), reg1(R1), reg2(Y), reg3(R3)),
        state(acc(X-Y), reg1(R1), reg2(Y), reg3(R3))).

command(subtract_r3, 
        state(acc(X  ), reg1(R1), reg2(R2), reg3(Y)),
        state(acc(X-Y), reg1(R1), reg2(R2), reg3(Y))).



%%%% STORE %%%%%%%%%%%%%%%%%%%%%%%

command(store_r1, 
        state(acc(A), reg1(_), reg2(R2), reg3(R3)),
        state(acc(A), reg1(A), reg2(R2), reg3(R3))).

command(store_r2, 
        state(acc(A), reg1(R1), reg2(_), reg3(R3)),
        state(acc(A), reg1(R1), reg2(A), reg3(R3))).

command(store_r3, 
        state(acc(A), reg1(R1), reg2(R2), reg3(_)),
        state(acc(A), reg1(R1), reg2(R2), reg3(A))).



% LOAD %%%%%%%%%%%%%%%%%%%%%%%%

command(load_r1, 
        state(acc(_ ), reg1(R1), reg2(R2), reg3(R3)),
        state(acc(R1), reg1(R1), reg2(R2), reg3(R3))).

command(load_r2, 
        state(acc(_ ), reg1(R1), reg2(R2), reg3(R3)),
        state(acc(R2), reg1(R1), reg2(R2), reg3(R3))).

command(load_r3, 
        state(acc(_ ), reg1(R1), reg2(R2), reg3(R3)),
        state(acc(R3), reg1(R1), reg2(R2), reg3(R3))).

findOps(O1, O2, O3) :-
    S0 = state(acc(c1), reg1(0), reg2(c2), reg3(c3)),
    command(O1, S0, S1),
    command(O2, S1, S2),
    command(O3, S2, S3),
    S3 = state(acc(_), reg1((c1-c2)+c3), reg2(_), reg3(_)).
    