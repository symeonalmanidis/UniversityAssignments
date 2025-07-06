job(smith).
job(baker).
job(carpenter).
job(tailor).

family(Father, Son) :-
    Father \= Son.


professions(Smith, SmithSon, Baker, BakerSon, Carpenter, CarpenterSon, Tailor, TailorSon) :-
    job(Smith),
    job(SmithSon),
    job(Baker),
    job(BakerSon),
    job(Carpenter),
    job(CarpenterSon),
    job(Tailor),
    job(TailorSon),
    
    Smith \= smith,
    SmithSon \= smith,
    Baker \= baker,
    BakerSon \= baker,
    Carpenter \= carpenter,
    CarpenterSon \= carpenter,
    Tailor \= tailor,
    TailorSon \= tailor,

    % 1 clue
    family(Smith, SmithSon),
    Smith \= SmithSon,
    Baker \= BakerSon,
    Carpenter \= CarpenterSon,
    Tailor \= TailorSon,

    % 2 clue
    Baker = CarpenterSon,

    % 3 clue
    SmithSon = baker.



    
    