%% Libraries
:-lib(ic).
:-lib(ic_global).
:-lib(branch_and_bound).
:-lib(ic_edge_finder).
:-lib(ic_sets).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EXEC 1
%% ADD CODE HERE

exams(Starts, Duration) :-
    Starts = [StA, StB,  StC, StD, StE],
    Ends =   [EndA, EndB, EndC, EndD, EndE],

    Starts #:: 0 .. inf,
    Ends #:: 0 .. inf,

    StA + 15 #= EndA,
    StB + 18 #= EndB,
    StC + 23 #= EndC,
    StD + 13 #= EndD,
    StE + 21 #= EndE,
    
    disjunctive([StA, StC], [EndA, EndC]),
    cumulative(Starts, [15, 18, 23, 13, 21], [12, 20, 19, 25, 7], 40),
    ic_global:maxlist(Ends, Duration),
    bb_min(labeling(Starts), Duration, bb_options{strategy:restart}).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EXEC 2
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DO NOT REMOVE THESE!!!
:-dynamic delivery/3.
:-dynamic distance/3.
%%%%%%%%%%%%%%%%%%%%%%%%%%

delivery(a,5,wh1).
delivery(b,2,wh2).
delivery(c,3,wh1).
delivery(d,4,wh2).

distance(port,wh1,15).
distance(port,wh2,20).
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ADD CODE HERE

schedule_trucks(Start, Unload, MakeSpan) :-
    collect_deliveries(TruckNames, Boxes, DeliveryWarehouses),
    collect_warehouses(Warehouses),

    length(TruckNames, DeliveriesLength),
    length(Start, DeliveriesLength),
    length(Unload, DeliveriesLength),

    constraint_start(Start, Unload, Boxes, DeliveryWarehouses, LoadDurations, Resources, UnloadDurations, Ends),

    cumulative(Start, LoadDurations, Resources, 3),

    constraint_warehouses(Warehouses, TruckNames, Unload, UnloadDurations),

    ic_global:maxlist(Ends, MakeSpan),
    bb_min(labeling(Start), MakeSpan, bb_options{strategy:restart}).

    
collect_deliveries(TruckNames, Boxes, Warehouses) :-
    findall(TN, delivery(TN, _, _), TruckNames),
    findall(B, delivery(_, B, _), Boxes),
    findall(W, delivery(_, _, W), Warehouses).

collect_warehouses(Warehouses) :-
    findall(W, distance(_, W, _), Warehouses).

constraint_start([], [], [], [], [], [], [], []).
constraint_start([S|RestS], [U|RestU], [B|RestB], [W|RestW], [LD|RestLD], [1|RestR], [UD|RestUD], [E|RestE]) :-
    S #:: 0 .. inf,
    U #:: 0 .. inf,
    E #:: 0 .. inf,

    LD is B * 4,
    UD is B,
    
    distance(port, W, D),
    U #= S + LD + D,
    E #= U + UD,
    constraint_start(RestS, RestU, RestB, RestW, RestLD, RestR, RestUD, RestE).
    

constraint_warehouses([], _, _, _).
constraint_warehouses([W|RestW], TruckNames, Unload, UnloadDurations) :-
    warehouse_group(W, TruckNames, Unload, UnloadDurations, FilteredUnload, FilteredUnloadDurations),
    disjunctive(FilteredUnload, FilteredUnloadDurations),
    constraint_warehouses(RestW, TruckNames, Unload, UnloadDurations).

warehouse_group(_, [], [], [], [], []).
warehouse_group(W, [T|RestT], [U|RestU], [UD|RestUD], [U|RestFU], [UD|RestFUD]) :-
    delivery(T, _, W),
    !,
    warehouse_group(W, RestT, RestU, RestUD, RestFU, RestFUD).
warehouse_group(W, [_|RestT], [_|RestU], [_|RestUD], RestFU, RestFUD) :-
    warehouse_group(W, RestT, RestU, RestUD, RestFU, RestFUD).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% EXEC 3

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DO NOT REMOVE THESE!!!
:-dynamic client_location/2.
:-dynamic min_distance/2.
%%%%%%%%%%%%%%%%%%%%%%%%%%
 
grid(25).

client_location(c1,(4,3)).
client_location(c2,(12,4)).
client_location(c3,(3,15)).
client_location(c4,(8,21)).
client_location(c5,(14,1)).


min_distance(f1,4).
min_distance(f2,3).
min_distance(f3,2).
%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ADD CODE HERE


placement(_, _, _).