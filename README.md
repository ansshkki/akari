# Akari game (Light Up)

Light Up (Akari) is a logic puzzle with simple rules and challenging solutions.

The rules are simple.Light Up is played on a rectangular grid. The grid has both black cells and white cells in it. The objective is to place light bulbs on the grid so that every white square is lit. A cell is illuminated by a light bulb if they're in the same row or column, and if there are no black cells between them. Also, no light bulb may illuminate another light bulb.
Some of the black cells have numbers in them. A number in a black cell indicates how many light bulbs share an edge with that cell.

Check out more about the game from [https://www.puzzle-light-up.com/](https://www.puzzle-light-up.com/)

## What can this program do for you?

This is a Prolog program that can check for right solution or solve an easy puzzle.
There are two files here, `checker.pl` and `solver.pl`.

### Checker

This part can check for right solution provided to the program as an input.
To specify input file, put its path in the first line.

### Solver

This part can solve the puzzle for you!
Just include the input file (in the checker file).

## How to run

1. First of all, you should install SWI-Prolog, you can get it from its [official site](https://www.swi-prolog.org/).

2. Run SWI-Prolog and open the file you want, or add `swipl` command to PATH and run one of these commands:
```
    swipl checker.pl
    swipl solver.pl
```

3. Now you can run these queries:
- For Checker:
```
    solved.
```
This returns true if the solution provided is acceptable for the puzzle, false otherwise.
- For Solver:
```
    solve.
```
This will try to solve the puzzle, you can check if the program managed to solve the puzzle with ```solved.``` query, or you can print the puzzle board using ```print.``` query.

4. Enjoy!

## How to make an input file

|Fact name|Fact implementation|Example|
|-------------|--------------|---------------|
|Board size|```size(Rows, Columns).```|```size(7, 7).```|
|Wall cell|```wall(Row, Column).```|```wall(1, 2).```|
|Wall cell with number|```wall_num(Row, Column, Number).```|```wall_num(2, 4, 5).```|
|Light cell|```light(Row, Column).```|```light(5, 4).```|

You can check examples in `examples` folder.

NOTE: files with `light` facts can be used with checker, others are to be used with solver.
