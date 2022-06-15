:- include("checker.pl").

:- initialization(init_solver).
init_solver:- retractall(light(_, _)), retractall(lighted_cell(_, _)), retractall(x_cell(_, _)), retractall(row(_)), retractall(column(_)),
    size(X, Y), set_row(X), set_column(Y), \+mark_0s_neighbours_with_x, nb_setval(current_solution, ""), nb_setval(temp, "").

:- dynamic light/2, lighted_cell/2, x_cell/2.

/* 
 * Main rule
 */
solve:- \+invert_solve.
invert_solve:- \+solved, check_solution_duplication, num_neigbour, \+singles, \+singles_in_row, \+singles_in_column, mark_num_neighbours_with_x, solve.

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

mark_num_neighbours_with_x:- \+x_neighbours(4), \+x_neighbours(3), \+x_neighbours(2), \+x_neighbours(1).
x_neighbours(N):- wall_num(X, Y, N), neighbour(X, Y, L), lights_count_in(L, C),
    N is C, available_cells(L, L1), mark_x(L1), fail.

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