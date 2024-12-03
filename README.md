The idea is to solve the [Advent of Code](https://adventofcode.com) challenges using a single SQL Server T-SQL statement (no loops/cursors/variables), implementing lessons learned from giants, the likes of Itzik Ben-Gan.

For optimization-sake, I'm allowing for the following exceptions that could be inlined as a sub-query/CTE but would most likely take forever for the optimizer to either extrapolate for a plan, or take too long to execute if no spooling takes place:
1. Dumping the input and/or a step into a temp table
2. Using a single-line table (not TVF) function

The input is included in the code. I know it's gross, but I prefer it over bulk insert as it would force the user to input the file location.
I want the code to be copy-paste-run.

I know it's not all as efficient as can be, and would love to get feedback with optimizations to adimcohen@gmail.com.


# Experience Summary
Solving the AoC puzzles using set-based T-SQL was an interesting experience.

As someone with no math or CS background to speak of, it was a new experience for me to put on an algorithmic or a mathematical thinking cap [People who know me well may argue that the act of thinking in general is new to me and I don’t own any thinking caps. They might have a point. I’ll have to think about it].

Just as a note for people who don’t understand the challenge in using T-SQL to implement programming algorithms, the main difference between set-based operations and procedural operations is that with set-based operations everything happens at once, and iterating through an array/result set, one element at a time, isn’t really an option.
To be clear, T-SQL can work in a procedural manner, with variables, loops, cursors, etc. I just chose to stick with set-based operations as a challenge to myself.

The things I’ve learnt from the experience fall neatly into one of these two categories:
- Beyond relational
- Don’t try this at home

### Beyond relational
SQL Server has non-relational features that can help address unique situations in a much more efficient manner than standard relational tables.
Specifically:
- Graph Database – Very efficient in finding the shortest path between 2 nodes. Unfortunately, that’s about it. It can’t give you a list of all indirectly connected nodes, which is a bummer.
- Spatial data types – Great for some of the visual puzzles, like [day 15](https://adventofcode.com/2022/day/15), where we had to find the sensors’ blind spot. Instead of checking whether each of the 4B squares is covered or not, I just created a polygon to represent each of the sensor’s coverage, concatenated them all into a single polygon, compared it to a polygon representing the frame and extracted the difference.
All of this took 15ms to run.
- Using SQL’s json parsing capabilities to parse strings – This I owe to [this](https://github.com/stonebr00k) guy. It is very convenient to replace the unnecessary parts of a string with `[`, `"` and `]` and then just use `json_value` or `json_query` to extract the necessary data.

### Don’t try this at home
This is where I got to make SQL Server to do things it would rather not do, specifically when it comes to Recursive CTE limitations.
For those of you who are unfamiliar with the Recursive CTE functionality, here is a quick rundown.
First of all a CTE (Common Table Expressions) is a way to neaten up code by pre-declaring subqueries and then using them in your main statement.
Here is an extremely pointless example of a CTE:
```
with Emp as
    (select EmpID, [Name]
        from Employees
        where DepartmentID = 15
    )
select *
from Emp e
    inner join Horses h on h.[Name] = e.[Name]
```
Recursive CTE is a way to traverse hierarchical data (typically), where the CTE has 2 parts with a UNION all between them:
- The Anchor - A query returning the base result set.
- The recursive part - A query that references the CTE's name and has access to the data returned in the last iteration.

An example from [Microsoft](https://learn.microsoft.com/en-us/sql/t-sql/queries/with-common-table-expression-transact-sql?view=sql-server-ver16) (hence the all caps thing):
```
WITH DirectReports(ManagerID, EmployeeID, Title, EmployeeLevel) AS
(
    SELECT ManagerID, EmployeeID, Title, 0 AS EmployeeLevel
    FROM dbo.MyEmployees
    WHERE ManagerID IS NULL
    UNION ALL
    SELECT e.ManagerID, e.EmployeeID, e.Title, EmployeeLevel + 1
    FROM dbo.MyEmployees AS e
        INNER JOIN DirectReports AS d
        ON e.ManagerID = d.EmployeeID
)
SELECT ManagerID, EmployeeID, Title, EmployeeLevel
FROM DirectReports
ORDER BY ManagerID;
```
The final result set includes the rows returned from all iterations, which is a serious drag on memory if you need to traverse a large set and all you need is the last row.
Recursive CTEs have some limitations, which I was able to override, mostly by using an inline TVF (Table Valued Function).
For example:
- Can't use aggregations or TOP - Do those in a TVF.
- Can't use OUTER JOINS - Use an OUTER APPLY instead.
- Iterations are limited to 32767 + aforementioned memory drag - Have a TVF with an internal Recursive CTE that returns the last row for a specific scenario, where the external Recursive CTE calls that TVF.
- The CTE can't be referenced more than once in the recursive part - This is a serious limitation when you have a multidimensional changing field, where a certain column in a certain row needs to check values in another row. The workaround here is a truly nasty one and involves concatenating the entire field into a single string, which is passed on to the next iteration, where it's sent to a TVF that parses it, processes it and concatenates the new state into a string to be returned to the main query.
A massive pitfall here is referencing the parsed result set too many times, as for each reference SQL would parse the string again. You have to keep in mind that this isn't a real table with indexes.

#### Please, please, please don't use any of these workarounds in your production environment. Just because SQL can do something, doesn't mean it should do it.
