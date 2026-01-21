
from([H|_], H).

from([_|T], X) :-
    from(T, X).


max(List, X, Max) :-
    from(List, X),
    from(List, Max),
    X < Max.