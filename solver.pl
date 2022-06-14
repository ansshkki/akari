:- include("examples/ex10.pl").

:- dynamic light/2, lighted_cell/2, x_cell/2, row/1, column/1.

set_row(0) :- !.
set_row(R):- R > 0, asserta(row(R)), R1 is R - 1, set_row(R1).
set_column(0) :- !.
set_column(C):- C > 0, asserta(column(C)), C1 is C - 1, set_column(C1).

:- initialization(init).
init:- retractall(light(_, _)), retractall(lighted_cell(_, _)), retractall(x_cell(_, _)), retractall(row(_)), retractall(column(_)),
    size(X, Y), set_row(X), set_column(Y), \+mark_0s_neighbours_with_x, nb_setval(current_solution, ""), nb_setval(temp, "").

/* 
 * Main rule
 */
solve:- \+invert_solve.
invert_solve:- \+solved, check_solution_duplication, num_neigbour, \+singles, \+singles_in_row, \+singles_in_column, mark_num_neighbours_with_x, solve.

mark_num_neighbours_with_x:- \+x_neighbours(4), \+x_neighbours(3), \+x_neighbours(2), \+x_neighbours(1).
x_neighbours(N):- wall_num(X, Y, N), neighbour(X, Y, L), lights_count_in(L, C),
    N is C, available_cells(L, L1), mark_x(L1), fail.

num_neigbour:- \+light_neighbours(4), \+light_neighbours(3), \+light_neighbours(2), \+light_neighbours(1).
light_neighbours(N):- wall_num(X, Y, N), neighbour(X, Y, L), lights_count_in(L, C),
    available_cells(L, L1), length(L1, Len), N is C + Len, set_lights_in(L1), fail.

singles:- empty_cell(R, C), row_items(R, C, L1), available_cells(L1, L11), length(L11, 0),
    column_items(R, C, L2), available_cells(L2, L22), length(L22, 0), set_lights_in([[R, C]]), fail.
empty_cell(R, C):- row(R), column(C), \+wall(R, C), \+lighted_cell(R, C), \+light(R, C), \+x_cell(R, C).

singles_in_row:- dimmed_x_cell(R, C), row_items(R, C, L1), available_cells(L1, L11), length(L11, 1),
    column_items(R, C, L2), available_cells(L2, L22), length(L22, 0), set_lights_in(L11), fail.
singles_in_column:- dimmed_x_cell(R, C), row_items(R, C, L1), available_cells(L1, L11), length(L11, 0),
    column_items(R, C, L2), available_cells(L2, L22), length(L22, 1), set_lights_in(L22), fail.
dimmed_x_cell(R, C):- row(R), column(C), \+wall(R, C), \+lighted_cell(R, C), \+light(R, C), x_cell(R, C).

% Helper rules
set_lights_in([]):- !.
set_lights_in([[R, C] | T]):- light_row_and_column(R, C), set_lights_in(T).
light_row_and_column(R, C):- assert(light(R, C)), row_items(R, C, L1), light_cells(L1), column_items(R, C, L2), light_cells(L2).
light_cells([]):- !.
light_cells([[R, C] | T]):- assert(lighted_cell(R, C)), light_cells(T).

available_cells([], []) :- !.
available_cells([[R, C] | T], [[R, C] | T1]) :-
    \+wall(R, C), \+lighted_cell(R, C), \+light(R, C), \+x_cell(R, C), size(X, Y), R > 0, R =< X, C > 0, C =< Y, !, available_cells(T, T1).
available_cells([_ | T], L) :- available_cells(T, L).

mark_0s_neighbours_with_x:- wall_num(X, Y, 0), neighbour(X, Y, L), mark_x(L), fail.
mark_x([]):- !.
mark_x([[R, C] | T]):- assert(x_cell(R, C)), mark_x(T).

check_solution_duplication:- nb_getval(current_solution, S), \+get_current_solution, nb_getval(temp, C), nb_setval(temp, ""), nb_setval(current_solution, C), S \= C.
get_current_solution:- row(R), column(C), nb_getval(temp, T), cell_type(R, C, X), string_concat(T, X, B), nb_setval(temp, B), fail.
cell_type(R, C, "W"):- wall(R, C), !.
cell_type(R, C, "L"):- light(R, C), !.
cell_type(R, C, "C"):- lighted_cell(R, C), !.
cell_type(R, C, "X"):- x_cell(R, C), !.
cell_type(_, _, "D").

% Print Rule
print:- row(R), column(C), print_cell(R, C), size(_, Y), C is Y, nl, fail.
print_cell(R, C):- wall_num(R, C, N), !, write(N), write(N), write(' ').
print_cell(R, C):- wall(R, C), !, write('WW ').
print_cell(R, C):- light(R, C), !, write('LL ').
print_cell(R, C):- lighted_cell(R, C), !, write('-- ').
print_cell(R, C):- x_cell(R, C), !, write('xx ').
print_cell(_, _):- write('   ').


% Checker Rules
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