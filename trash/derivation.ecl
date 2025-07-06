
%%% derivative/3
%%% derivative(FUN,X,DFUN)
%%% Succeeds if DFUN is the first derivative of FUN
%%% wrt variable X.

derivative(X,X,1).

derivative(sin(X),X,cos(X)).

derivative(cos(X),X,-sin(X)).

derivative(C,X,0):-
	atomic(C),
	C\=X.

derivative(U*V,X,U*DV+V*DU):-
	derivative(U,X,DU),
	derivative(V,X,DV).

derivative(U+V,X,DU+DV):-
	derivative(U,X,DU),
	derivative(V,X,DV).