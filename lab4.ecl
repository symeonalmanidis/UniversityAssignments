split_in_Buckets(B1B2B3, B1, B2, B3) :-
    append(B1, B2B3, B1B2B3),
    append(B2, B3, B2B3),
    sum(B1, Sum),
    sum(B2, Sum),
    sum(B3, Sum).