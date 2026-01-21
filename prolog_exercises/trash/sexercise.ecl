:-lib(ic).
:-lib(ic_global).
:-lib(branch_and_bound).
:-lib(ic_edge_finder).
:-lib(ic_sets).

ram([2,8,8,16,2,4]).
price([30,35,20,38,44,65]).
vcpu([4,8,8,4,4,8]).

select_providers(X, Y, Price) :-
    ram(Rams),
    price(Prices),
    vcpu(VCPUs),

    X #:: 0 .. inf,
    Y #:: 0 .. inf,

    element(X, Rams, XRam),
    element(X, Prices, XPrice),
    element(X, VCPUs, XVCPU),
    element(Y, Rams, YRam),
    element(Y, Prices, YPrice),
    element(Y, VCPUs, YVCPU),

    XRam #>= 4, YRam #>= 4,
    12 #= XVCPU + YVCPU,
    Price #= XPrice + YPrice,
    bb_min(labeling([X,Y]), Price, _).
    