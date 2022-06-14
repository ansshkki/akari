:- include("ex1.pl").

:- dynamic row/1, column/1.
set_row(0) :- !.
set_row(R):- R > 0, asserta(row(R)), R1 is R - 1, set_row(R1).
set_column(0) :- !.
set_column(C):- C > 0, asserta(column(C)), C1 is C - 1, set_column(C1).

:- initialization(init).
init:- retractall(row(_)), retractall(column(_)), size(X, Y), set_row(X), set_column(Y).

solved:- \+any_dimmed_cell, \+any_double_light, \+any_incorrect_count.

any_dimmed_cell:- row(R), column(C), \+is_cell_lighted(R, C), !.
is_cell_lighted(R, C):- wall(R, C), !; light(R, C), !; row_items(R, C, RI), \+no_light_in(RI), !; column_items(R, C, CI), \+no_light_in(CI).

any_double_light:- light(X, Y), row_items(X, Y, L1), \+no_light_in(L1).
any_double_light:- light(X, Y), column_items(X, Y, L2), \+no_light_in(L2).

any_incorrect_count:- wall_num(X, Y, N), neighbour(X, Y, L), lights_count_in(L, C), C \= N.
neighbour(X, Y, L):- X1 is X - 1, X2 is X + 1, Y1 is Y - 1, Y2 is Y + 1, L = [[X1, Y], [X, Y1], [X2, Y], [X, Y2]].

no_light_in([]) :- !.
no_light_in([[R, C] | T]):- not(light(R, C)), no_light_in(T).

lights_count_in([], 0) :- !.
lights_count_in([[X, Y] | T], C):- light(X, Y), !, lights_count_in(T, C1), C is C1 + 1.
lights_count_in([_ | T], C):- lights_count_in(T, C).

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