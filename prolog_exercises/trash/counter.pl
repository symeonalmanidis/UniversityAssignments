:- dynamic(func/2).

func(0, [1]) :- !.
func(X, [Y1, Y2]) :-
    Pow is floor(log10(X)) + 1,
    0 is Pow mod 2, !,
    Y1 is X div 10**(Pow div 2),
    Y2 is X mod 10**(Pow div 2).

func(X, [Y]) :- Y is X * 2024, !.

some_counter([(3, 1), (386358, 1), (86195, 1), (85, 1), (1267, 1), (3752457, 1), (0, 1), (741, 1)]).

add_to_counter((Key, Count), AccList, [(Key,NewCount)|AccListD]) :-
    member((Key, PrevCount), AccList), !,
    delete(AccList, (Key, PrevCount), AccListD), 
    NewCount is PrevCount + Count.
add_to_counter((Key, Count), AccList, [(Key,Count)|AccList]).

lemma_once(Goal):-
    call(Goal),
    (not( clause(Goal,!) )->
    asserta((Goal:-!));true).
    
transform((Key, Count), Result) :-
    lemma_once(func(Key, NewKeys)),    
    findall((NewKey, Count), member(NewKey, NewKeys), Result).

iterate(List, Result) :- 
    maplist(transform, List, TransformedList),
    append(TransformedList, ChainedList),
    foldl(add_to_counter, ChainedList, [], Result).


iterate_n(List, 0, List) :- !.
iterate_n(List, Times, NewList) :-
    Times > 0,
    iterate(List, IteratedList),
    NewTimes is Times - 1,
    iterate_n(IteratedList, NewTimes, NewList).


do1(Result) :-
    some_counter(X),
    iterate_n(X, 25, Y),
    findall(Count, member((_, Count), Y), Counts),
    sum_list(Counts, Result).



start_state([3-1, 386358-1, 86195-1, 85-1, 1267-1, 3752457-1, 0-1, 741-1]).

transform2(Key-Count, Result) :-
    lemma_once(func(Key, NewKeys)),    
    findall(NewKey-Count, member(NewKey, NewKeys), Result).

iterate2(List, Result) :- 
    maplist(transform2, List, TransformedList),
    append(TransformedList, ChainedList),
    group_pairs_by_key(ChainedList, Groups),
    pairs_keys_values(Groups, Keys, Counts),
    maplist(sum_list, Counts, SummedCounts),
    pairs_keys_values(Result, Keys, SummedCounts).
    

iterate2_n(List, 0, List) :- !.
iterate2_n(List, Times, NewList) :-
    Times > 0,
    iterate2(List, IteratedList),
    NewTimes is Times - 1,
    iterate2_n(IteratedList, NewTimes, NewList).

do2(Result) :-
    start_state(X),
    iterate2_n(X, 25, Y),
    pairs_values(Y, Counts),
    sum_list(Counts, Result).
    
    
:- dynamic sex/1.
sex(3-1). 
sex(386358-1). 
sex(86195-1).
sex(85-1).
sex(1267-1). 
sex(3752457-1).
sex(0-1).
sex(741-1).

sexy_time(Key-Count) :- 
    sex(Key-PrevCount), 
    retract(sex(Key-PrevCount)),
    NewCount is PrevCount + Count, 
    asserta(sex(Key-NewCount)), 
    !.
sexy_time(Key-Count) :- asserta(sex(Key-Count)).

iterate() :-
    bagof(NewKey-Count, (sex(Key-Count), retract(sex(Key-Count)), func(Key, NewKeys), member(NewKey, NewKeys)), Result),
    maplist(sexy_time, Result), fail.

iterate() :- !.

iterate_n(0) :- !.
iterate_n(Times) :-
    Times > 0,
    iterate(),
    NewTimes is Times - 1,
    iterate_n(NewTimes).

do3(Result) :-
    iterate_n(75),
    aggregate_all(sum(Z), sex(_Key-Z), Result).