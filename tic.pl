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
	read(X),
	read(Y),
	human(H),
	update_board(Board, X, Y, H, Result).

ai_turn(Board, N, Depth, Result):-
	moves(Board, [[Result, X, Y]|_], N),
	format(X),
	print(Y),
	flush_output.

moves(Board, PosList, N):-
	computer(P),
	T is N - 1,
	findall([NewBoard, X, Y], 
		(between(0, T, X), between(0, T, Y), update_board(Board, X, Y, P, NewBoard)), 
		PosList).


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

minimax(Pos, BestSucc, Val) :-
	moves(Pos, PosList), !,
	best(PosList, BestSucc, Val);
	staticval(Pos, Val).

best([Pos], Pos, Val) :-
	minimax(Pos, _, Val), !.

best([Pos1|PosList], BestPos, BestVal) :-
	minimax(Pos1, _, Val1),
	best(PosList, Pos2, Val2),
	betterof(Pos1, Val1, Pos2, Val2, BestPos, BestVal).

betterof(Pos0, Val0, Pos1, Val1, Pos0, Val0) :-
	min_to_move(Pos0),
	Val0 > Val1, !
	;
	max_to_move(Pos0),
	Val0 < Val1, !.

betterof(Pos0, Val0, Pos1, Val1, Pos1, Val1).

:- main.
