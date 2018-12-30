main:-
	current_prolog_flag(argv, [DepthString, NString]),
	atom_number(DepthString, Depth),
	atom_number(NString, N),
	build_board(N, Board),
	run(Board, N, Depth).


run(Board, N, Depth):-
	user_turn(Board, BoardAfterUser),
	ai_turn(BoardAfterUser, N, Depth, BoardAfterAI),
	run(BoardAfterAI, N, Depth).

user_turn(Board, Result):-
	get_single_char(XR),
	get_single_char(YR),
	X is XR - "0",
	Y is YR - "0",
	human(H),
	update_board(Board, X, Y, H, Result).

ai_turn(Board, N, Depth, Result):-
	moves(Board, [Result, X, Y], N),
	print(X),
	print(Y).

moves(Board, PosList, N):-
	computer(P),
	T is N - 1,
	between(0, T, X),
	between(0, T, Y),
	update_board(Board, X, Y, P, NewBoard),
	PosList = [NewBoard, X, Y].

update_board(Board, X, Y, Player, Result):-
	nth0(X, Board, CR, RR),
	nth0(Y, CR, CE, RE),
	empty(CE),
	nth0(Y, ResultRow, Player, RE),
	nth0(X, Result, ResultRow, RR).

build_board(N, Board):-
	length(Board, N),
	length(EmptyRow, N),
	maplist(empty, EmptyRow),
	maplist(=(EmptyRow), Board).


empty(-).
human(x).
computer(o).

:- main.
