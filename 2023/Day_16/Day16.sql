--works only with real input
declare @Input varchar(max) = 
'.|...\....
|.-.\.....
.....|-...
........|.
..........
.........\
..../.\\..
.-.-/..|..
.|....-|.\
..//.|....'

use tempdb
drop table if exists AOC_2023_Day16_Map
drop table if exists AOC_2023_Day16_Edges

create table AOC_2023_Day16_Map
	(X tinyint,
	Y tinyint,
	SubID tinyint,
	Symbol char(1),
	MaxX tinyint,
	MaxY tinyint
	) as node

create table AOC_2023_Day16_Edges as edge

create unique clustered index IX_AOC_2023_Day16_Edges on AOC_2023_Day16_Edges($from_id, $to_id)

drop table if exists #Input
drop table if exists #Options
drop table if exists #Directions
drop table if exists #Routes
drop table if exists #Points
drop table if exists #Routes1
drop table if exists #Points1

;with i as
	(select row_number() over(order by r.ordinal, c.[value]) ID, c.[value] X, r.ordinal Y, substring(r.[value], c.[value], 1) Symbol, cast(max(c.[value]) over() as int) maxX, cast(max(r.ordinal) over() as int) MaxY
		from string_split(replace(replace(@Input, '+', '\'), char(10), ''), char(13), 1) r
			cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int), cast(1 as int)) c
		where substring(r.[value], c.[value], 1) != '.'
	)
	, i1 as
	(select 0 ID, X, [value] Y, ' ' Symbol, MaxX, MaxY
		from (select top 1 MaxX, MaxY
				from i
				) m
			cross apply (values(0), (MaxX + 1)) t(X)
			cross apply generate_series(1, MaxY, 1)
		union
		select 0 ID, [value] X, Y, ' ', MaxX, MaxY
		from (select top 1 MaxX, MaxY
				from i
				) m
			cross apply (values(0), (MaxY + 1)) t(Y)
			cross apply generate_series(1, MaxX, 1)
	)
select *
into #Input
from i
union all
select *
from i1

select row_number() over(order by (select 1)) ID, *, dense_rank() over(partition by Symbol order by ToXDir*10 + ToYDir, isnull(FromXDir, FromYDir)) SubID
into #Directions
from (values('\', 1, 1, -1, -1)
			, ('\', -1, -1, 1, 1)
			, ('/', 1, -1, 1, -1)
			, ('/', -1, 1, -1, 1)
			, ('|', 1, 1, null, null)
			, ('|', 1, -1, null, null)
			, ('|', -1, 1, null, null)
			, ('|', -1, -1, null, null)
			, ('-', null, null, 1, 1)
			, ('-', null, null, 1, -1)
			, ('-', null, null, -1, 1)
			, ('-', null, null, -1, -1)
			, (' ', 0, 0, 0, 0)) t(Symbol, FromXDir, ToYDir, FromYDir, ToXDir)


select X, Y, SubID, i.Symbol, MaxX, MaxY, FromXDir, i1.ToYDir, FromYDir, i1.ToXDir
into #Options
from #Input i
	inner join #Directions d on d.Symbol = i.Symbol
	cross apply (select case X
						when 0 then 1
						when MaxX + 1 then -1
						else d.ToXDir
					end ToXDir,
					case Y
						when 0 then 1
						when MaxY + 1 then -1
						else d.ToYDir
					end ToYDir
				) i1
order by 1, 2

insert into AOC_2023_Day16_Map
select distinct X, Y, SubID, Symbol, MaxX, MaxY
from #Options

insert into AOC_2023_Day16_Edges
select s1.$node_id, d1.$node_id
from #Options s
	cross apply (select top 1 *
					from #Options d
					where (s.ToXDir != 0
							and d.Y = s.Y
							and (d.FromXDir = s.ToXDir or d.FromXDir = 0)
							and d.X*s.ToXDir > s.X*s.ToXDir)
					order by d.X*s.ToXDir
				) d
	inner join AOC_2023_Day16_Map s1 on s1.X = s.X
									and s1.Y = s.Y
									and s1.SubID = s.SubID
	inner join AOC_2023_Day16_Map d1 on d1.X = d.X
									and d1.Y = d.Y
									and d1.SubID = d.SubID
union
select s1.$node_id, d1.$node_id
from #Options s
	cross apply (select top 1 *
					from #Options d
					where (s.ToYDir != 0
							and d.X = s.X
							and (d.FromYDir = s.ToYDir or d.FromYDir = 0)
							and d.Y*s.ToYDir > s.Y*s.ToYDir)
					order by d.Y*s.ToYDir
				) d
	inner join AOC_2023_Day16_Map s1 on s1.X = s.X
									and s1.Y = s.Y
									and s1.SubID = s.SubID
	inner join AOC_2023_Day16_Map d1 on d1.X = d.X
									and d1.Y = d.Y
									and d1.SubID = d.SubID

select i.X, i.Y,
	last_value(concat(i1.X, ',', i1.Y)) within group (graph path) LastCo,
	string_agg(cast(concat(i1.X, '.', i1.Y, '.', i1.SubID, '.', i1.Symbol) as varchar(max)), ',') within group (graph path) Rt,
	len(string_agg(cast(i1.Symbol as varchar(max)), '') within group (graph path)) Steps
into #Routes
from AOC_2023_Day16_Map i,
	AOC_2023_Day16_Edges for path e,
	AOC_2023_Day16_Map for path i1
where MATCH(shortest_path(i(-(e)->i1)+))
	and i.X = 0
	and i.Y = 1
	
select distinct X StartX, Y StartY, cast(parsename([value], 4) as int) X, cast(parsename([value], 3) as int) Y, cast(parsename([value], 2) as int) SubID
into #Points
from #Routes
	cross apply string_split(Rt, ',', 0)

;with Maxes as
	(select top 1 MaxX, MaxY
		from AOC_2023_Day16_Map
	)
	, i as
	(select distinct StartX, StartY, least(s.X, d.X) X1, least(s.Y, d.Y) Y1, greatest(s.X, d.X) X2, greatest(s.Y, d.Y) Y2
		from #Points p
			inner join AOC_2023_Day16_Map s on s.X = p.X
											and s.Y = p.Y
											and s.SubID = p.SubID
			inner join AOC_2023_Day16_Edges e on e.$from_id = s.$node_id
			inner join AOC_2023_Day16_Map d on d.$node_id = e.$to_id
	)
	, i1 as
	(select *, iif(X2 > X1, 1, 0) IsHorizontal
		from i
	)
	, i2 as
	(select distinct StartX, StartY, X, Y
		from i1
			cross join Maxes
			cross apply generate_series(cast(iif(IsHorizontal = 1, X1, Y1)as int), cast(iif(IsHorizontal = 1, X2, Y2) as int), cast(1 as int)) n
			cross apply (select iif(IsHorizontal = 1, n.[value], X1) X, iif(IsHorizontal = 1, Y1, n.[value]) Y) n1
		where X between 1 and MaxX
			and Y between 1 and MaxY
	)
select count(*) Answer1
from i2
group by StartX, StartY
order by Answer1 desc

--2
select i.X, i.Y,
	last_value(concat(i1.X, ',', i1.Y)) within group (graph path) LastCo,
	string_agg(cast(concat(i1.X, '.', i1.Y, '.', i1.SubID, '.', i1.Symbol) as varchar(max)), ',') within group (graph path) Rt,
	len(string_agg(cast(i1.Symbol as varchar(max)), '') within group (graph path)) Steps
into #Routes1
from AOC_2023_Day16_Map i,
	AOC_2023_Day16_Edges for path e,
	AOC_2023_Day16_Map for path i1
where MATCH(shortest_path(i(-(e)->i1)+))
	and (i.X in (0, i.MaxX + 1)
		or i.Y in (0, i.MaxY + 1)
		)

select distinct X StartX, Y StartY, cast(parsename([value], 4) as int) X, cast(parsename([value], 3) as int) Y, cast(parsename([value], 2) as int) SubID
into #Points1
from #Routes1
	cross apply string_split(Rt, ',', 0)
	
;with Maxes as
	(select top 1 MaxX, MaxY
		from AOC_2023_Day16_Map
	)
	, i as
	(select distinct StartX, StartY, least(s.X, d.X) X1, least(s.Y, d.Y) Y1, greatest(s.X, d.X) X2, greatest(s.Y, d.Y) Y2
		from #Points1 p
			inner join AOC_2023_Day16_Map s on s.X = p.X
											and s.Y = p.Y
											and s.SubID = p.SubID
			inner join AOC_2023_Day16_Edges e on e.$from_id = s.$node_id
			inner join AOC_2023_Day16_Map d on d.$node_id = e.$to_id
	)
	, i1 as
	(select *, iif(X2 > X1, 1, 0) IsHorizontal
		from i
	)
	, i2 as
	(select distinct StartX, StartY, X, Y
		from i1
			cross join Maxes
			cross apply generate_series(cast(iif(IsHorizontal = 1, X1, Y1)as int), cast(iif(IsHorizontal = 1, X2, Y2) as int), cast(1 as int)) n
			cross apply (select iif(IsHorizontal = 1, n.[value], X1) X, iif(IsHorizontal = 1, Y1, n.[value]) Y) n1
		where X between 1 and MaxX
			and Y between 1 and MaxY
	)
select top 1 count(*) Answer2
from i2
group by StartX, StartY
order by Answer2 desc