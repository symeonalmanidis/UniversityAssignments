sample(2).
sample(5).
sample(14).
sample(7).
sample(26).

less_than_ten(X) :- aggregate_all(count, (sample(Y), Y <  10), X).


set_diff_f(L1, L2, L) :- findall(X, (member(X, L1), not(member(X, L2))), L).

minlist(Min, List) :- setof(X, (member(X, List), member(Y, List), X < Y) ,[Min]).

proper_set_s(List) :- setof(X, member(X,List), List).

double(X,Y) :- Y is X * 2.
square(X,Y) :- Y is X * X.

map_f(Operation, List, Results) :- findall(Y, (member(X, List), call(Operation, X, Y)), Results).

:- dynamic stack/1.
stack([]).

push(X) :-
    stack(OldStack),
    append(OldStack, [X], NewStack),
    asserta(stack(NewStack)),
    retract(stack(OldStack)).
    
pop(X) :-
    stack(OldStack),
    append(NewStack, [X], OldStack),
    retract(stack(OldStack)),
    asserta(stack(NewStack)).

t.
f:-!,fail.

:- op(400, fx, --).
:- op(450, yfx, and).
:- op(450, yfx, nand).
:- op(500, yfx, or).
:- op(500, yfx, xor).
:- op(500, yfx, nor).
:- op(550, yfx, ==>).

Arg1 and Arg2 :-
    Arg1, Arg2.
Arg1 or _Arg2 :- Arg1.
_Arg1 or Arg2 :- Arg2.
-- Arg :- Arg, !, false.
-- _Arg :- true.
Arg1 ==> Arg2 :- -- Arg1 or Arg2.
Arg1 xor Arg2 :- (Arg1 or Arg2) and -- (Arg1 and Arg2).
Arg1 nor Arg2 :- -- (Arg1 or Arg2).
Arg1 nand Arg2 :- -- (Arg1 and Arg2).

%% lab 8 missing
allowed(f).
allowed(t).

model(C) :-
    term_variables(C, Vars),
    call(C).

%% lab 9
seperate_lists(List, Lets, Nums) :-
    findall(X, (member(X, List), \+(number(X))), Lets),
    findall(X, (member(X, List), number(X)), Nums).



less_ten(X) :- X < 10.
less_twenty(X) :- X < 20.

filter(Pred, List, NewList) :- findall(X, (member(X, List), call(Pred, X)), NewList).

