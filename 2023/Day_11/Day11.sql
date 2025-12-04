declare @Input varchar(max) =
'...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....'

drop table if exists #Input
drop table if exists #Expanded

select c.[value] X, r.ordinal Y, substring(r.[value], c.[value], 1) Symbol
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int), cast(1 as int)) c

;with i as
	(select *, iif(min(Symbol) over(partition by X) = '.', 1, 0) AddX, iif(min(Symbol) over(partition by Y) = '.', 1, 0) AddY
		from #Input
	)
	, i1 as
	(select X + sum(AddX) over(partition by Y order by X) X, Y + sum(AddY) over(partition by X order by Y) Y, Symbol
		from i
	)
	, Expanded as
	(select row_number() over(order by Y, X) ID, X, Y
		from i1
		where Symbol = '#'
	)
select sum(abs(i1.X - i.X) + abs(i1.Y - i.Y)) Answer1
from Expanded i
	inner join Expanded i1 on i1.ID > i.ID

;with i as
	(select *, iif(min(Symbol) over(partition by X) = '.', 999999, 0) AddX, iif(min(Symbol) over(partition by Y) = '.', 999999, 0) AddY
		from #Input
	)
	, i1 as
	(select X + sum(AddX) over(partition by Y order by X) X, Y + sum(AddY) over(partition by X order by Y) Y, Symbol
		from i
	)
	, Expanded as
	(select row_number() over(order by Y, X) ID, X, Y
		from i1
		where Symbol = '#'
	)
select sum(abs(i1.X - i.X) + abs(i1.Y - i.Y)) Answer2
from Expanded i
	inner join Expanded i1 on i1.ID > i.ID