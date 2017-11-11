next_symbol([1,0|OtherBits], ['.'], [0|OtherBits]).
next_symbol([1,1,0|OtherBits], ['.'], [0|OtherBits]).
next_symbol(AllBits, [-], [0|Bits]) :-
	append(Ones, [0|Bits], AllBits),
	length(Ones,X), X > 1,
	\+(member(0, Ones)).

next_symbol([0,1|OtherBits], [], [1|OtherBits]).
next_symbol([0,0,1|OtherBits],[], [1|OtherBits]).
next_symbol(AllBits, [^], [1|Bits]) :-
	append(Zeroes, [1|Bits], AllBits),
	length(Zeroes, X), X > 1, X < 6,
	\+(member(1, Zeroes)).
next_symbol(AllBits, [#], [1|Bits]) :-
	append(Zeroes, [1|Bits], AllBits),
	length(Zeroes, X), X > 5,
	\+(member(1, Zeroes)).


signal_morse([], []).
signal_morse([1], ['.']).
signal_morse([0],[]).
signal_morse([1,1], ['.']).
signal_morse([0,0],[]).
signal_morse(Ones, [-]) :- length(Ones, X), X > 1, \+(member(0, Ones)).
signal_morse(Zeroes, [^]) :- length(Zeroes, X), (X > 1, X < 6), \+(member(1,Zeroes)).
signal_morse(Zeroes, [#]) :- length(Zeroes, X), X >= 5, \+(member(1,Zeroes)).
signal_morse(Bits, Morse) :-
	next_symbol(Bits, SymbolList, OtherBits),
	append(SymbolList, OtherSymbols, Morse),
	signal_morse(OtherBits, OtherSymbols).

morse(a, [.,-]).           % A
morse(b, [-,.,.,.]).	   % B
morse(c, [-,.,-,.]).	   % C
morse(d, [-,.,.]).	   % D
morse(e, [.]).		   % E
morse('e''', [.,.,-,.,.]). % É (accented E)
morse(f, [.,.,-,.]).	   % F
morse(g, [-,-,.]).	   % G
morse(h, [.,.,.,.]).	   % H
morse(i, [.,.]).	   % I
morse(j, [.,-,-,-]).	   % J
morse(k, [-,.,-]).	   % K or invitation to transmit
morse(l, [.,-,.,.]).	   % L
morse(m, [-,-]).	   % M
morse(n, [-,.]).	   % N
morse(o, [-,-,-]).	   % O
morse(p, [.,-,-,.]).	   % P
morse(q, [-,-,.,-]).	   % Q
morse(r, [.,-,.]).	   % R
morse(s, [.,.,.]).	   % S
morse(t, [-]).	 	   % T
morse(u, [.,.,-]).	   % U
morse(v, [.,.,.,-]).	   % V
morse(w, [.,-,-]).	   % W
morse(x, [-,.,.,-]).	   % X or multiplication sign
morse(y, [-,.,-,-]).	   % Y
morse(z, [-,-,.,.]).	   % Z
morse(0, [-,-,-,-,-]).	   % 0
morse(1, [.,-,-,-,-]).	   % 1
morse(2, [.,.,-,-,-]).	   % 2
morse(3, [.,.,.,-,-]).	   % 3
morse(4, [.,.,.,.,-]).	   % 4
morse(5, [.,.,.,.,.]).	   % 5
morse(6, [-,.,.,.,.]).	   % 6
morse(7, [-,-,.,.,.]).	   % 7
morse(8, [-,-,-,.,.]).	   % 8
morse(9, [-,-,-,-,.]).	   % 9
morse(., [.,-,.,-,.,-]).   % . (period)
morse(',', [-,-,.,.,-,-]). % , (comma)
morse(:, [-,-,-,.,.,.]).   % : (colon or division sign)
morse(?, [.,.,-,-,.,.]).   % ? (question mark)
morse('''',[.,-,-,-,-,.]). % ' (apostrophe)
morse(-, [-,.,.,.,.,-]).   % - (hyphen or dash or subtraction sign)
morse(/, [-,.,.,-,.]).     % / (fraction bar or division sign)
morse('(', [-,.,-,-,.]).   % ( (left-hand bracket or parenthesis)
morse(')', [-,.,-,-,.,-]). % ) (right-hand bracket or parenthesis)
morse('"', [.,-,.,.,-,.]). % " (inverted commas or quotation marks)
morse(=, [-,.,.,.,-]).     % = (double hyphen)
morse(+, [.,-,.,-,.]).     % + (cross or addition sign)
morse(@, [.,-,-,.,-,.]).   % @ (commercial at)

% Error.
morse(error, [.,.,.,.,.,.,.,.]). % error - see below

% Prosigns.
morse(as, [.,-,.,.,.]).          % AS (wait A Second)
morse(ct, [-,.,-,.,-]).          % CT (starting signal, Copy This)
morse(sk, [.,.,.,-,.,-]).        % SK (end of work, Silent Key)
morse(sn, [.,.,.,-,.]).          % SN (understood, Sho' 'Nuff)

morse_word([],[]).
morse_word(Symbols, [Term|Word]) :-
	append(Letter, [^|Rest], Symbols),
	morse(Term, Letter),
	morse_word(Rest, Word).


morse_word(Symbols, [Term]) :-
	append(Letter, [], Symbols),
	morse(Term, Letter).


clean_errors(MessageWithErrors, Message) :-
	append(BeforeError, [error|Rest], MessageWithErrors),
	append(NoError, Error, BeforeError),
	append(Letters, Spaces, Error), length(Letters, NumLetters), NumLetters > 0,
	\+ (member(#, Letters); member(error, Letters)), \+ (append(_, [error], Letters)), \+ (member(S,Spaces), S \== #),
	append(NoError, CleanRest, Message),
	clean_errors(Rest, CleanRest), !.

clean_errors(X, X).


signal_message(Bits, Message) :-
	signal_morse(Bits, Morse),
	signal_message_helper(Morse, MessageWithErrors),
	clean_errors(MessageWithErrors,Message).

signal_message_helper([],[]).
signal_message_helper(Morse, MessageWords) :-
	append(MorseWord, [#|OtherMorseWords], Morse),
	append(Word, [#|OtherMessageWords], MessageWords),
	morse_word(MorseWord, Word),
	signal_message_helper(OtherMorseWords, OtherMessageWords), !.

signal_message_helper(MorseWord, MessageWord) :-
	morse_word(MorseWord, MessageWord).