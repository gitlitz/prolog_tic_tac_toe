main:-
	current_prolog_flag(argv, [DepthString, NString]),
	atom_number(DepthString, Depth),
	atom_number(NString, N),
	board_init(N, Board),
	run(Board, N, Depth).

run(Board, N, Depth):-
	user_turn(Board, BoardAfterUser),
	ai_turn(BoardAfterUser, N, Depth, BoardAfterAI),
	run(BoardAfterAI, N, Depth).

user_turn(Board, Result):-
	read(X),
	read(Y),
	human(H),
	board_update(Board, X, Y, H, Result).

ai_turn(Board, N, Depth, Result):-
	human(H),
	%	moves([Board, 0, 0, H], [[Result, X, Y, _]|_]),
	minimax([Board, 0, 0, H], [Result, X, Y, _], V, Depth),
	print(X),
	print(Y),
	print(user_error, V),
	flush_output.

moves([Board, _, _, P], PosList):-
	%	\+ is_player_won(Board, P),
	oponent(P, O),
	length(Board, N),
	T is N - 1,
	findall([NewBoard, X, Y, O], 
		(between(0, T, X), between(0, T, Y), board_update(Board, X, Y, O, NewBoard)), 
		PosList),
	% fail for empty lists
	[_|_] = PosList.

board_get(Board, X, Y, P):-
	NX is X,
	NY is Y,
	Y >= 0,
	nth0(NX, Board, R),
	nth0(NY, R, P).

board_update(Board, X, Y, Player, Result):-
	nth0(X, Board, CR, RR),
	nth0(Y, CR, CE, RE),
	empty(CE),
	nth0(Y, ResultRow, Player, RE),
	nth0(X, Result, ResultRow, RR).

board_init(N, Board):-
	length(Board, N),
	length(EmptyRow, N),
	maplist(empty, EmptyRow),
	maplist(=(EmptyRow), Board).


empty(-).
human(x).
computer(o).
oponent(x, o).
oponent(o, x).

is_player_won(Board, P):-
	length(Board, N),
	M is N - 1,
	between(0, M, X),
	between(0, M, Y),
	board_get(Board, X, Y, P),
	(
		% horizontal
		board_get(Board, X+1, Y, P),
		board_get(Board, X+2, Y, P),
		board_get(Board, X+3, Y, P),!;
		% vertical
		board_get(Board, X, Y+1, P),
		board_get(Board, X, Y+2, P),
		board_get(Board, X, Y+3, P),!;
		% diagonal up
		board_get(Board, X+1, Y+1, P),
		board_get(Board, X+2, Y+2, P),
		board_get(Board, X+3, Y+3, P),!;
		% diagonal down
		board_get(Board, X+1, Y-1, P),
		board_get(Board, X+2, Y-2, P),
		board_get(Board, X+3, Y-3, P)
	).


minimax(Pos, BestSucc, Val, Depth) :-
	Depth > 0,
	moves(Pos, PosList), !,
	best(PosList, BestSucc, Val, Depth-1);
	staticval(Pos, Val).

best([Pos], Pos, Val, Depth) :-
	minimax(Pos, _, Val, Depth), !.

best([Pos1|PosList], BestPos, BestVal, Depth) :-
	minimax(Pos1, _, Val1, Depth),
	best(PosList, Pos2, Val2, Depth),
	betterof(Pos1, Val1, Pos2, Val2, BestPos, BestVal).

betterof(Pos0, Val0, Pos1, Val1, Pos0, Val0) :-
	min_to_move(Pos0),
	Val0 > Val1, !
	;
	max_to_move(Pos0),
	Val0 < Val1, !.

betterof(Pos0, Val0, Pos1, Val1, Pos1, Val1).

min_to_move([_, _, _, P]):-
	computer(P).

max_to_move([_, _, _, P]):-
	human(P).

staticval([Board|_], V):-
	human(H),
	computer(O),
	(
		is_player_won(Board, H),
		!,
		V = -99;
		is_player_won(Board, O),
		!,
		V = 99;
		V=0
	).

:- main.
