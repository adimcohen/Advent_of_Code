The idea is to solve the [Advent of Code 2022](https://adventofcode.com/2022) challenges using a single SQL Server T-SQL statement (no loops/cursors/variables), implementing lessons leared from giants, the likes of Itzik Ben-Gan.

For optimization-sake, I'm allowing for the following exceptions that could be inlined as a sub-query/CTE but would most likely take forever for the optimizer to either extrapolate for a plan, or take too long to execute if no spooling takes place:
1. Dumping the input and/or a step into a temp table
2. Using a single-line table (not TVF) function

The input is included in the code. I know it's gross, but I prefer it over bulk insert as it would force the user to input the file location.
I want the code to be copy-paste-run.

I know it's not all as efficient as can be, and would love to get feedback with optimizations to adimcohen@gmail.com.


*LoL... just realized I've mispelled the repo's name. Oops. Hope the code is solid though.*
