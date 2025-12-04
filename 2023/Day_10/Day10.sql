declare @Input varchar(max) =
'..F7.
.FJ|.
SJ.L7
|F--J
LJ...'
drop table if exists #Input
drop table if exists #Route

select c.[value] X, r.ordinal Y, substring(r.[value], c.[value], 1) Symbol
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int), cast(1 as int)) c

create unique clustered index IX_#Input on #Input(X, Y)

;with rec as
	(select X, Y, Symbol, 0 Steps, cast(concat('|', X, ',', Y, '|') as varchar(max)) Rt
		from #Input
		where Symbol = 'S'
		union all
		select i.X, i.Y, i.Symbol, Steps + 1, cast(concat(r.Rt, i.X, ',', i.Y, '|') as varchar(max)) Rt
		from rec r
			inner join #Input i on ((i.Symbol = '|' and r.X = i.X and r.Y in (i.Y - 1, i.Y + 1) and r.Symbol not in ('-'))
												or (i.Symbol = '-' and r.Y = i.Y and r.X in (i.X - 1, i.X + 1) and r.Symbol not in ('|'))
												or (i.Symbol = 'L' and ((r.Y = i.Y and r.X = i.X + 1 and r.Symbol not in ('|', 'L', 'F')) or (r.X = i.X and r.Y = i.Y - 1 and r.Symbol not in ('-', 'L', 'J'))))
												or (i.Symbol = 'J' and ((r.Y = i.Y and r.X = i.X - 1 and r.Symbol not in ('|', 'J', '7')) or (r.X = i.X and r.Y = i.Y - 1 and r.Symbol not in ('-', 'L', 'J'))))
												or (i.Symbol = '7' and ((r.Y = i.Y and r.X = i.X - 1 and r.Symbol not in ('|', '7', 'J')) or (r.X = i.X and r.Y = i.Y + 1 and r.Symbol not in ('-', '7', 'F'))))
												or (i.Symbol = 'F' and ((r.Y = i.Y and r.X = i.X + 1 and r.Symbol not in ('|', 'F', 'L')) or (r.X = i.X and r.Y = i.Y + 1 and r.Symbol not in ('-', 'F', '7'))))
												)
												and r.Symbol != '.'
		where r.Rt not like concat('%|', i.X, ',', i.Y, '|%')
	)
select *
into #Route
from rec
option (maxrecursion 32767)

--1
;with i as
	(select X, Y, min(Steps) Steps
		from #Route
		group by X, Y
	)
select max(Steps) Answer1
from i
GO
--2
declare @Input varchar(max) =
'...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........'
drop table if exists #Input
drop table if exists #Route

select c.[value] X, r.ordinal Y, substring(r.[value], c.[value], 1) Symbol
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int), cast(1 as int)) c

create unique clustered index IX_#Input on #Input(X, Y)

;with rec as
	(select X, Y, Symbol, 0 Steps, cast(concat('|', X, ',', Y, '|') as varchar(max)) Rt
		from #Input
		where Symbol = 'S'
		union all
		select i.X, i.Y, i.Symbol, Steps + 1, cast(concat(r.Rt, i.X, ',', i.Y, '|') as varchar(max)) Rt
		from rec r
			inner join #Input i on ((i.Symbol = '|' and r.X = i.X and r.Y in (i.Y - 1, i.Y + 1) and r.Symbol not in ('-'))
												or (i.Symbol = '-' and r.Y = i.Y and r.X in (i.X - 1, i.X + 1) and r.Symbol not in ('|'))
												or (i.Symbol = 'L' and ((r.Y = i.Y and r.X = i.X + 1 and r.Symbol not in ('|', 'L', 'F')) or (r.X = i.X and r.Y = i.Y - 1 and r.Symbol not in ('-', 'L', 'J'))))
												or (i.Symbol = 'J' and ((r.Y = i.Y and r.X = i.X - 1 and r.Symbol not in ('|', 'J', '7')) or (r.X = i.X and r.Y = i.Y - 1 and r.Symbol not in ('-', 'L', 'J'))))
												or (i.Symbol = '7' and ((r.Y = i.Y and r.X = i.X - 1 and r.Symbol not in ('|', '7', 'J')) or (r.X = i.X and r.Y = i.Y + 1 and r.Symbol not in ('-', '7', 'F'))))
												or (i.Symbol = 'F' and ((r.Y = i.Y and r.X = i.X + 1 and r.Symbol not in ('|', 'F', 'L')) or (r.X = i.X and r.Y = i.Y + 1 and r.Symbol not in ('-', 'F', '7'))))
												)
												and r.Symbol != '.'
		where r.Rt not like concat('%|', i.X, ',', i.Y, '|%')
	)
select *
into #Route
from rec
option (maxrecursion 32767)
--2
;with i as
	(select Rt
		from #Route
		where Steps = 0
	)
	, i1 as
	(select top 1 Rt
		from #Route
		order by Steps desc
	)
	, i2 as
	(select geometry::STGeomFromText(concat(N'POLYGON((', replace(replace(stuff(i1.Rt, 1, 1, '')  + replace(i.Rt, '|', ''), ',', ' '), '|', ','), '))'), 0) [Loop]
		from i
			cross join i1
	)
	, i3 as
	(select geometry::STGeomFromText(concat(N'POINT(', X, ' ', Y, ')'), 0).STBuffer(0.1) Point
		from #Input
	)
select count(*) Answer2
from i2
	inner join i3 on [Loop].STContains(Point) = 1