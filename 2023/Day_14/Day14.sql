drop table if exists AOC_2023_Day14_Rocks
GO
create table AOC_2023_Day14_Rocks
	(X int,
	Y int)
GO
create or alter function fn_AOC_2023_Day14_SplitRolls(@Rolls varchar(max)) returns table
as
return select cast(json_value(j.[value], '$.X') as int) X, cast(json_value(j.[value], '$.Y') as int) Y
		from openjson(@Rolls) j
GO
create or alter function fn_AOC_2023_Day14_TiltVertical(@Rolls varchar(max),
														@IsNorth int,
														@Floor int) returns table
as
return select (select i.X X, isnull(r.Y, @Floor) + @IsNorth*count(*) over(partition by i.X, r.Y order by i.Y * @IsNorth) Y
				from fn_AOC_2023_Day14_SplitRolls(@Rolls) i
					outer apply (select top 1 r.Y
									from AOC_2023_Day14_Rocks r
									where r.X = i.X
										and r.Y*@IsNorth < i.Y*@IsNorth
									order by @IsNorth*r.Y desc
								) r
				for json path
				) Rolls
GO
create or alter function fn_AOC_2023_Day14_TiltHorizontal(@Rolls varchar(max),
															@IsWest int,
															@Floor int) returns table
as
return select (select isnull(r.X, @Floor) + @IsWest*count(*) over(partition by i.Y, r.X order by i.X * @IsWest) X, i.Y Y
				from fn_AOC_2023_Day14_SplitRolls(@Rolls) i
					outer apply (select top 1 r.X
									from AOC_2023_Day14_Rocks r
									where r.Y = i.Y
										and r.X*@IsWest < i.X*@IsWest
									order by @IsWest*r.X desc
								) r
				for json path
				) Rolls
GO

declare @Input varchar(max) =
'O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....'

drop table if exists #Input
drop table if exists #Tilts

select c.[value] X, r.ordinal Y, substring(r.[value], c.[value], 1) Symbol, max(r.ordinal) over() MaxY, max(c.[value]) over() MaxX
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int), cast(1 as int)) c

--1
;with i as
	(select *, iif(Symbol = '#', Y, null) Rock
		from #Input
		where Symbol != '.'
	)
	, i1 as
	(select X, Y, MaxY MaxY, Symbol, isnull(max(Rock) over(partition by X order by Y), 0) Buttom, iif(Symbol = 'O', 1, 0) Roll
		from i
	)
	, i2 as
	(select MaxY - sum(Roll) over(partition by X, Buttom order by Y) - Buttom + 1 Ld
		from i1
		where Symbol = 'O'
	)
select sum(Ld) Answer1
from i2

insert into AOC_2023_Day14_Rocks
select X, Y
from #Input
where Symbol = '#'

;with Maxes as
	(select top 1 MaxX MaxX, MaxY MaxY
		from #Input
	)
	, rec as
	(select 0 Steps, (select X, Y
						from #Input
						where Symbol = 'O'
						for json path
					) Rolls, MaxX, MaxY
		from Maxes
		union all
		select Steps + 1 Steps, e.Rolls, MaxX, MaxY
		from rec r
			cross apply fn_AOC_2023_Day14_TiltVertical(r.Rolls, 1, 0) n
			cross apply fn_AOC_2023_Day14_TiltHorizontal(n.Rolls, 1, 0) w
			cross apply fn_AOC_2023_Day14_TiltVertical(w.Rolls, -1, MaxY + 1) s
			cross apply fn_AOC_2023_Day14_TiltHorizontal(s.Rolls, -1, MaxX + 1) e
		where r.Steps < 200
	)
select *
into #Tilts
from rec
option (maxrecursion 32767)

--2
;with i as
	(select Rolls, Steps, count(*) over(partition by Rolls) Repeats, row_number() over(partition by Rolls order by Steps) rn, min(Steps) over(partition by Rolls) MinSteps
		from #Tilts
	)
	, i1 as
	(select top 2 Rolls, MinSteps, Steps - MinSteps CycleLength
		from i
		where Repeats > 1
			and rn < 3
		order by MinSteps, rn
	)
	, i2 as
	(select top 1 MinSteps + ((1000000000 - MinSteps) % CycleLength) Step
		from i1
		order by CycleLength desc
	)
select sum(MaxY - Y + 1) Answer2
from #Tilts
	cross apply fn_AOC_2023_Day14_SplitRolls(Rolls)
where Steps = (select Step from i2)