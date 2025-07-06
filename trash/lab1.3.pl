family(Father, Son) :-
    Father \= Son.


professions(Smith, SmithSon, Baker, BakerSon, Carpenter, CarpenterSon, Tailor, TailorSon) :-

    Professions = [smith, baker, carpenter, tailor],
    Fathers = [Baker, Smith, Carpenter, Tailor],
    Sons = [BakerSon, SmithSon, CarpenterSon, TailorSon],

    permutation(Professions, Fathers),
    permutation(Professions, Sons),
    
    Smith \= smith,
    Baker \= baker,
    Carpenter \= carpenter,
    Tailor \= tailor,
    
    SmithSon \= smith,
    BakerSon \= baker,
    CarpenterSon \= carpenter,
    TailorSon \= tailor,

    % Clue 1: No son has the same profession as his father.
    
    Smith \= SmithSon,
    Baker \= BakerSon,
    Carpenter \= CarpenterSon,
    Tailor \= TailorSon,
    
    % Clue 2: The Baker has the same profession as the Carpenter's son.
    Baker = CarpenterSon,

    % Clue 3: Smith's son is a baker.
    SmithSon = baker.
    
    