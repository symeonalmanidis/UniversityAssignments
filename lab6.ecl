seperate_lists(List, Lets, Nums) :-
    findall(X, (member(X, List), not(number(X))), Lets),
    findall(X, (member(X, List), number(X)), Nums).