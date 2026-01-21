family(Father, Son) :-
    Father \= Son.

job(smith).
job(baker).
job(carpenter).
job(smith).

professions(Smith, SmithSon, Baker, BakerSon, Carpenter, CarpenterSon, Tailor, TailorSon) :-
    Professions = [smith, baker, carpenter, tailor],
    Fathers = [Smith, Baker, Carpenter, Tailor],
    Sons = [SmithSon, BakerSon, CarpenterSon, TailorSon],
    
    permutation(Professions, Fathers),
    permutation(Professions, Sons),
    
    family(Smith, SmithSon),
    family(Baker, BakerSon),
    family(Carpenter, CarpenterSon),
    family(Tailor, TailorSon),

    Baker = CarpenterSon,

    SmithSon = baker.
    
    
    