%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EXEC 1
%%% Place your code here
delete_unique(List, Result) :-
    delete(X, List, NewList),
    not(member(X, NewList)),
    !,
    delete_unique(NewList, Result).

delete_unique(List, List).

delete_unique_alt(List, Result) :-
    findall(X, (delete(X, List, NewList), once(member(X, NewList))), Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EXEC2
%%% Place your code here

evaluate(R, _Vars, R) :- number(R).
evaluate(Var, Vars, Value) :- member((Var, Value), Vars).

evaluate(Expr, Vars, R) :-
    compound(Expr),
    Expr =.. [Op,SubExpr1,SubExpr2],
    evaluate(SubExpr1, Vars, Value1),
    evaluate(SubExpr2, Vars, Value2),
    NewExpr =.. [Op,Value1,Value2],
    R is call(NewExpr).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EXEC 3
%%% Clobber
%%% The following predicates define the opposite color (b-black,w-white).
%%% You might find them interesting.
other(b,w).
other(w,b).

%%% board/2
%%% board(Size,Board)
%%% Do not delete this predicate!
board(4,[b,w,b,w]).
board(5,[b,w,b,w,b]).
board(6,[b,w,b,w,b,w]).
board(7,[b,w,b,w,b,w,b]).
board(8, [b, w, b, w, b, w, b, w]).
board(9, [b, w, b, w, b, w, b, w, b]).
board(10, [b, w, b, w, b, w, b, w, b, w]).

%%% Place your code here
move(b, [b,w|T], [e,b|T]).
move(b, [w,b|T], [b,e|T]).
move(w, [b,w|T], [w,e|T]).
move(w, [w,b|T], [e,w|T]).

move(Color, [H|Board], [H|NewBoard]) :- move(Color, Board, NewBoard).


run_game_clobber(Board, Color, N, Board) :-
    not(move(Color, Board, _NewBoard)),  
    findall(X, (member(X, Board), member(X, [b, w])), BWS),
    length(BWS, N).
    

run_game_clobber(Board, Color, N, FinalBoard) :-
    move(Color, Board, NewBoard),
    other(Color, NewColor),
    run_game_clobber(NewBoard, NewColor, N, FinalBoard).
    

best_solution(BN, N, FinalBoard) :-
    board(BN, Board),
    run_game_clobber(Board, _, N, FinalBoard), 
    not((run_game_clobber(Board, _, Y, _), Y < N)).

