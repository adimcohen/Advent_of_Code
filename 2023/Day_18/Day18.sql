declare @Input varchar(max) = 
'R 6 (#70c710)
D 5 (#0dc571)
L 2 (#5713f0)
D 2 (#d2c081)
R 2 (#59c680)
D 2 (#411b91)
L 5 (#8ceee2)
U 2 (#caa173)
L 1 (#1b58a2)
U 2 (#caa171)
R 2 (#7807d2)
U 3 (#a77fa3)
L 2 (#015232)
U 2 (#7a21e3)'

drop table if exists #Input
drop table if exists #Directions
drop table if exists #DiffToActual
drop table if exists #Input1A
drop table if exists #StepsA

select ordinal ID, parsename(Val, 3) Dir, cast(parsename(Val, 2) as int) Steps, replace(replace(parsename(Val, 1), '(', ''), ')', '') Color
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1)
	cross apply (select replace([value], ' ', '.') Val) i

--1
;with Directions as
	(select *
		from(values('R', 1, 0)
					, ('L', -1, 0)
					, ('D', 0, 1)
					, ('U', 0, -1)
			) t(Dir, XDiff, YDiff)
	)
	, DiffToActual as
	(select *
		from (values('R', 'D', 1, -1)
					, ('R', 'U', -1, -1)
					, ('U', 'R', -1, -1)
					, ('U', 'L', -1, 1)
					, ('L', 'D', 1, 1)
					, ('L', 'U', -1, 1)
					, ('D', 'R', 1, -1)
					, ('D', 'L', 1, 1)
			) t(Dir1, Dir2, XDiff, YDiff)
	)
	, i as
	(select *, isnull(lead(Dir) over(order by ID), first_value(Dir) over(order by ID rows between unbounded preceding and unbounded following)) NextDir
		from #Input
	)
	, i1 as
	(select ID, Dir, Steps, XDiff, YDiff
		from i
			left join DiffToActual d on d.Dir1 = i.Dir
										and d.Dir2 = i.NextDir
	)
	, i2 as
	(select ID, 0.5 + sum(i.Steps*d.XDiff) over(order by ID) + i.XDiff*0.5 X, 0.5 + sum(i.Steps*d.YDiff) over(order by ID) + i.YDiff*0.5 Y
		from i1 i
			inner join Directions d on d.Dir = i.Dir
	)
	, i3 as
	(select top 1 0 ID, X, Y
		from i2 i
		order by i.ID desc
	)
	, i4 as
	(select *
		from i3
		union all
		select *
		from i2
	)
select geometry::STGeomFromText(concat(N'POLYGON ((', string_agg(cast(concat(X, ' ', Y) as varchar(max)), ',') within group(order by ID), '))'), 0)
	, geometry::STGeomFromText(concat(N'POLYGON ((', string_agg(cast(concat(X, ' ', Y) as varchar(max)), ',') within group(order by ID), '))'), 0).STArea() Answer1
from i4

--2
;with Directions as
	(select *
		from(values('R', 1, 0)
					, ('L', -1, 0)
					, ('D', 0, 1)
					, ('U', 0, -1)
			) t(Dir, XDiff, YDiff)
	)
	, DiffToActual as
	(select *
		from (values('R', 'D', 1, -1)
					, ('R', 'U', -1, -1)
					, ('U', 'R', -1, -1)
					, ('U', 'L', -1, 1)
					, ('L', 'D', 1, 1)
					, ('L', 'U', -1, 1)
					, ('D', 'R', 1, -1)
					, ('D', 'L', 1, 1)
			) t(Dir1, Dir2, XDiff, YDiff)
	)
	, i_1 as
	(select ID, d.Dir, cast(convert(varbinary(10), left(stuff(Color, 1, 1, '0'), len(Color) - 1), 2) as int) Steps
		from #Input
			cross apply (select case right(Color, 1)
									when '0' then 'R'
									when '1' then 'D'
									when '2' then 'L'
									when '3' then 'U'
								end Dir
						) d
	)
	, i0 as
	(select *, isnull(lag(Dir) over(order by ID), last_value(Dir) over(order by ID rows between current row and unbounded following)) PrevDir
		from i_1
	)
	, i as
	(select *, isnull(lead(Dir) over(order by ID), first_value(Dir) over(order by ID rows between unbounded preceding and unbounded following)) NextDir
		from i0
	)
	, i1 as
	(select ID, Dir, Steps, XDiff, YDiff
		from i
			left join DiffToActual d on d.Dir1 = i.Dir
										and d.Dir2 = i.NextDir
	)
	, i2 as
	(select ID, 0.5 + sum(i.Steps*d.XDiff) over(order by ID) + i.XDiff*0.5 X, 0.5 + sum(i.Steps*d.YDiff) over(order by ID) + i.YDiff*0.5 Y
		from i1 i
			inner join Directions d on d.Dir = i.Dir
	)
	, i3 as
	(select top 1 0 ID, X, Y
		from i2 i
		order by i.ID desc
	)
	, i4 as
	(select *
		from i3
		union all
		select *
		from i2
	)
select geometry::STGeomFromText(concat(N'POLYGON ((', string_agg(cast(concat(X, ' ', Y) as varchar(max)), ',') within group(order by ID), '))'), 0)
	, geometry::STGeomFromText(concat(N'POLYGON ((', string_agg(cast(concat(X, ' ', Y) as varchar(max)), ',') within group(order by ID), '))'), 0).STArea() Answer2
from i4