
append([], L, L).
append([H|T], L, [H|R]) :-
    append(T, L, R).

symmetric(List) :- append(X, X, List).
    
end_sublist(Suffix, List) :- append(_, Suffix, List).

twice_sublist(Needle,List) :- append([_, Needle, _, Needle, _], List).

last_element([Last], Last).
last_element([_|T], Last) :-
    last_element(T, Last).


word([p,r,o,l,o,g]).
word([m,a,t,h,s]).

missing_letter(W1W2,X,W1XW2) :- 
    word(W1XW2),
    append(W1, W2, W1W2),
    append([W1, X, W2], W1XW2).


reverse_alt([], []).

reverse_alt([H|T], List2) :-
    reverse_alt(T, RevT),
    append(RevT, [H], List2).
    


rotate_left(0, List, List).

rotate_left(N, [H|T], R) :-
    N > 0,
    NN is N - 1,
    append(T, [H], TH),
    rotate_left(NN, TH, R).


common_suffix(L1, L2, Suffix, Pos) :-
    append(_, Suffix, L1),
    append(_, Suffix, L2),
    length(Suffix, Pos).

split_in_Buckets(B1B2B3, B1, B2, B3) :-
    append(B1, B2B3, B1B2B3),
    append(B2, B3, B2B3),
    sum(B1, Sum),
    sum(B2, Sum),
    sum(B3, Sum).