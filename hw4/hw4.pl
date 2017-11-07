symbol([1,0|T],'.', T).
symbol([1,1,0|T], '.', T).
symbol([1,1,0|T], -, T).
symbol([1,1,1,0|T], -, T).


signal_morse([],[]).
signal_morse(B,[X|M]) :- symbol(B, '.', C).
