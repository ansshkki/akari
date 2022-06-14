size(8, 8).

wall(6,2).
wall(7,6).
wall(7,7).
wall(8,3).
wall(4,1).
wall(4,5).
wall(5,4).
wall(5,8).
wall(1,6).
wall(2,2).
wall(2,3).
wall(3,7).

wall_num(5,8,0).
wall_num(6,2,2).
wall_num(7,6,1).
wall_num(1,6,1).
wall_num(2,2,3).
wall_num(3,7,0).
wall_num(5,4,4).

:- dynamic light/2, lighted_cell/2, x_cell/2, row/1, column/1.

set_row(0) :- !.
set_row(R):- R > 0, asserta(row(R)), R1 is R - 1, set_row(R1).
set_column(0) :- !.
set_column(C):- C > 0, asserta(column(C)), C1 is C - 1, set_column(C1).

:- initialization(init).
init:- retractall(light(_, _)), retractall(row(_)), retractall(column(_)), size(X, Y), set_row(X), set_column(Y).

slove:- s.

s:- \+mark_0s, \+light_neighbours(4), \+light_neighbours(3), \+light_neighbours(2), \+light_neighbours(1).

mark_0s:- wall_num(X, Y, 0), neighbour(X, Y, L), mark_x(L), fail.
mark_x([]):- !.
mark_x([[R, C] | T]):- assert(x_cell(R, C)), mark_x(T).

light_neighbours(N):- wall_num(X, Y, N), neighbour(X, Y, L), available_cells(L, L1), length(L1, N), set_lights_in(L1), fail.

neighbour(X, Y, L) :- X1 is X - 1, X2 is X + 1, Y1 is Y - 1, Y2 is Y + 1, L = [[X1, Y], [X, Y1], [X2, Y], [X, Y2]].

available_cells([], []) :- !.
available_cells([[R, C] | T], [[R, C] | T1]) :-
    \+wall(R, C), \+lighted_cell(R, C), \+light(R, C), size(X, Y), R > 0, R =< X, C > 0, C =< Y, !, available_cells(T, T1).
available_cells([_ | T], L) :- available_cells(T, L).

set_lights_in([]):- !.
set_lights_in([[R, C] | T]):- light_row_and_column(R, C), set_lights_in(T).
light_row_and_column(R, C):- assert(light(R, C)), row_items(R, C, L1), light_cells(L1), column_items(R, C, L2), light_cells(L2).
light_cells([]):- !.
light_cells([[R, C] | T]):- assert(lighted_cell(R, C)), light_cells(T).

row_items(R, C, L) :- C1 is C - 1, C2 is C + 1, go_left_in_row(R, C1, L1), go_right_in_row(R, C2, L2), append(L1, L2, L).
column_items(R, C, L) :- R1 is R - 1, R2 is R + 1, go_top_in_column(R1, C, L1), go_bottom_in_column(R2, C, L2), append(L1, L2, L).

go_left_in_row(R, C, []):- wall(R, C), !.
go_left_in_row(_, C, []):- C = 0, !.
go_left_in_row(R, C, [[R, C] | T]):- C1 is C - 1, go_left_in_row(R, C1, T).
go_right_in_row(R, C, []):- wall(R, C), !.
go_right_in_row(_, C, []):- size(_, Y), C > Y, !.
go_right_in_row(R, C, [[R, C] | T]):- C1 is C + 1, go_right_in_row(R, C1, T).

go_top_in_column(R, C, []):- wall(R, C), !.
go_top_in_column(R, _, []):- R = 0, !.
go_top_in_column(R, C, [[R, C] | T]):- R > 0, R1 is R - 1, go_top_in_column(R1, C, T).
go_bottom_in_column(R, C, []):- wall(R, C), !.
go_bottom_in_column(R, _, []):- size(X, _), R > X, !.
go_bottom_in_column(R, C, [[R, C] | T]):- R1 is R + 1, go_bottom_in_column(R1, C, T).

print_puzzle:- row(R), column(C), print_cell(R, C), size(X, Y), C is Y, nl, fail.
print_cell(R, C):- wall_num(R, C, N), !, write(N), write(N), write(' ').
print_cell(R, C):- wall(R, C), !, write('WW ').
print_cell(R, C):- light(R, C), !, write('LL ').
print_cell(R, C):- lighted_cell(R, C), !, write('-- ').
print_cell(R, C):- x_cell(R, C), !, write('xx ').
print_cell(R, C):- write('   ').