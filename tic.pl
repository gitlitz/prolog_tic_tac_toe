%  Programmer   - Yuval Gitlitz, Daniel Orbach
%  File Name    - tic.pl
%  Description  - This program implements an ai for a 4 streak length tic tac toe game.
%  Arguments	- depth n  - Depth is the depth of search in the minimax algorithm. n is the size of
%  		  the board.
%  Input        - The user selection in the format <X>.\n<Y>.\n where <X> and <Y> are the coordinate
%  		  of his selection.
%  Ouptut       - The ai selection in the format <X><Y> where <X> and <Y> are the coordinate of 
%  		  the ai selection.

% entry point
main:-
	current_prolog_flag(argv, [DepthString, NString]),
	atom_number(DepthString, Depth),
	atom_number(NString, N),
	board_init(N, Board),
	run(Board, Depth).

% run the main program loop, where Board is the current board state and Depth is the depth of search in
% the minimax algorithm.
run(Board, Depth):-
	user_turn(Board, BoardAfterUser),
	ai_turn(BoardAfterUser, Depth, BoardAfterAI),
	run(BoardAfterAI, Depth).
% Put a user piece at the given board from stdin and return the new board at Result.
user_turn(Board, Result):-
	read(X),
	read(Y),
	human(H),
	board_update(Board, X, Y, H, Result).

% Put a computer piece at the given Board using minimax algorithm and store the result at Result. 
% Depth is the depth search of the minimax algorithm.
ai_turn(Board, Depth, Result):-
	human(H),
	minimax([Board, _, _, H], [Result, X, Y, _], V, Depth),
	print(X),
	print(Y),
	print(user_error, V),
	flush_output.

% Return all the available moves from the given board and return it at PosList. Fail if there are no
% move.
% PosList is the available moves in the format [NewBoard, X, Y, Piece] where NewBoard is the board after
% adding the new piece, X and Y are the coordinate of the new piece and Piece is what piece was played
% P is the last player's peice.
moves([Board, _, _, P], PosList):-
	\+ is_player_won(Board, P),  % fail if a player already won
	opponent(P, O),
	length(Board, N),
	T is N - 1,
	findall([NewBoard, X, Y, O], 
		(between(0, T, X), between(0, T, Y), board_update(Board, X, Y, O, NewBoard)), 
		PosList),
	% fail for empty lists
	[_|_] = PosList.

% Get a piece from Board at coordinate (X, Y) and return it at P.
board_get(Board, X, Y, P):-
	NX is X,
	NY is Y,
	Y >= 0,
	nth0(NX, Board, R),
	nth0(NY, R, P).
% Set the piece from Board at coordinate (X, Y) and return the new board at Result. Fail if the
% coordinate is already taken
board_update(Board, X, Y, Player, Result):-
	nth0(X, Board, CR, RR),
	nth0(Y, CR, CE, RE),
	empty(CE),
	nth0(Y, ResultRow, Player, RE),
	nth0(X, Result, ResultRow, RR).

% Build an N x N board and store it at Board.
board_init(N, Board):-
	length(Board, N),
	length(EmptyRow, N),
	maplist(empty, EmptyRow),
	maplist(=(EmptyRow), Board).

% True if coordinate is empty.
empty(-).
% True if the given piece is a user piece.
human(x).
% True if the given piece is a computer piece.
computer(o).
% True if first param is the opponent of the second.
opponent(x, o).
opponent(o, x).

% True if a player won the game.
is_player_won(Board, P):-
	all_seq(Board, [P, P, P, P]),
	!.

% Return all the possible 4 length streaks in the given Board and store it at Seq.
all_seq(Board, Seq):-
	length(Board, N),
	M is N - 1,
	between(0, M, X),
	between(0, M, Y),
	board_get(Board, X, Y, P1),
	(
		% horizontal
		board_get(Board, X+1, Y, P2),
		board_get(Board, X+2, Y, P3),
		board_get(Board, X+3, Y, P4);
		% vertical
		board_get(Board, X, Y+1, P2),
		board_get(Board, X, Y+2, P3),
		board_get(Board, X, Y+3, P4);
		% diagonal up
		board_get(Board, X+1, Y+1, P2),
		board_get(Board, X+2, Y+2, P3),
		board_get(Board, X+3, Y+3, P4);
		% diagonal down
		board_get(Board, X+1, Y-1, P2),
		board_get(Board, X+2, Y-2, P3),
		board_get(Board, X+3, Y-3, P4)
	), 
	Seq = [P1, P2, P3, P4].

% minimax algorithm from page 582 with added maximum depth search
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
		hueristic(Board, V)
	).

% hueristic function for a given Board. Stores the output at V.
hueristic(Board, V):-
	human(H),
	computer(C),
	max_player_seq(Board, H, VH),
	max_player_seq(Board, C, VC),
	V is VC - VH.

% Return the maximum pieces player P has out of a 4 sequence where the rest of the pieces
% are empty at the given Board. Sets the output at V.
max_player_seq(Board, P, V):-
	empty(E),
	(
		all_seq(Board, Seq),
		permutation(Seq, [P, P, P, E]),
		V = 3,
		!;
		all_seq(Board, Seq),
		permutation(Seq, [P, P, E, E]),
		V = 2,
		!;
		all_seq(Board, Seq),
		permutation(Seq, [P, E, E, E]),
		V = 1,
		!;
		V = 0
	).


% set main as the entry point
:- main.
