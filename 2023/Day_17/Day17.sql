drop table if exists AOC_2023_Day17_MapR
drop table if exists AOC_2023_Day17_EdgesR
create table AOC_2023_Day17_MapR
	(ID int,
	X int,
	Y bigint,
	Loss int,
	MaxX int,
	MaxY bigint,
	H tinyint,
	V tinyint
	)
create unique clustered index IX_AOC_2023_Day17_MapR on AOC_2023_Day17_MapR(X, Y, H, V)
create unique index IX_AOC_2023_Day17_MapR_1 on AOC_2023_Day17_MapR(Y, X, H, V) include(Loss, MaxX, MaxY, ID)
create unique index IX_AOC_2023_Day17_MapR_2 on AOC_2023_Day17_MapR(ID)

create table AOC_2023_Day17_EdgesR
	(SourceID int,
	TargetID int,
	Loss int,
	Pth varchar(max),
	IsEnd tinyint
	)
create unique clustered index IX_AOC_2023_Day17_EdgesR on AOC_2023_Day17_EdgesR(SourceID, TargetID)
GO
create or alter function fn_AOC_2023_Day17_TakeSteps(@Routes varchar(max)) returns table
as
return with i as
			(select a.Loss + e.Loss Loss, Steps + 1 Steps, b.ID ID, cast(concat(a.Pth, e.Pth, '>') as varchar(max)) Pth, e.IsEnd, a.MinLoss
				from openjson(@Routes)
					cross apply (select cast(json_value([value], '$.l') as int) Loss
									, cast(json_value([value], '$.s') as int) Steps
									, cast(json_value([value], '$.i') as int) ID
									, cast(json_value([value], '$.p') as varchar(max)) Pth
									, cast(json_value([value], '$.e') as tinyint) IsEnd
									, cast(json_value([value], '$.n') as int) MinLoss
								) a
					inner join AOC_2023_Day17_EdgesR e on e.SourceID = a.ID
					inner join AOC_2023_Day17_MapR b on b.ID = e.TargetID
				where not exists (select *
									from string_split(e.Pth, '>', 0)
									where a.Pth like concat('%>', [value], '>%')
								)
					and a.IsEnd = 0
					and a.Loss + e.Loss < a.MinLoss
			)
			, i1 as
			(select Loss, Steps, ID, Pth, IsEnd
					, min(iif(IsEnd = 1, Loss, MinLoss)) over() MinLoss
					, row_number() over(partition by ID order by Loss) rn
				from i
			)
		select cast((select MinLoss n, Loss l, Steps s, ID i, Pth p, IsEnd e
						from i1
						where rn = 1
						for json path
						) as varchar(max)) Rts
GO
declare @Input varchar(max) =
'2413432311323
3215453535623
3255245654254
3446585845452
4546657867536
1438598798454
4457876987766
3637877979653
4654967986887
4564679986453
1224686865563
2546548887735
4322674655533'

drop table if exists #Input
drop table if exists #Route1
drop table if exists #Route2

select row_number() over(order by c.[value], r.[value]) ID, c.[value] X, r.ordinal Y, cast(substring(r.[value], c.[value], 1) as int) Loss, max(c.[value]) over() MaxX, max(r.ordinal) over() MaxY
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int), cast(1 as int)) c

;with i as
	(select X, Y, 0 Loss, MaxX, MaxY, 0 H, 0 V
		from #Input
		where X = 1
			and Y = 1
		union all
		select X, Y, Loss, MaxX, MaxY, 1 H, 0 V
		from #Input
		where not (X = 1
					and Y = 1)
		union all
		select X, Y, Loss, MaxX, MaxY, 0 H, 1 V
		from #Input
		where not (X = 1
					and Y = 1)
	)
insert into AOC_2023_Day17_MapR
select row_number() over(order by X, Y, H, V) ID, X, Y, Loss, MaxX, MaxY, H, V
from i

alter index all on AOC_2023_Day17_MapR rebuild

insert into AOC_2023_Day17_EdgesR
select a.ID SourceID, b.ID TargetID, b.Loss, Pth, IsEnd
from AOC_2023_Day17_MapR a
	cross apply (select b.ID, sum(b.Loss) over(partition by IsPositive order by Diff) Loss
						, iif(b.X = b.MaxX and b.Y = b.MaxY, 1, 0) IsEnd, Diff
						, IsPositive
					from AOC_2023_Day17_MapR b with (forceseek)
						cross apply (select abs(b.X - a.X) Diff
											, iif(b.X > a.X, 1, -1) IsPositive) r
					where b.Y = a.Y
							and b.X != a.X
							and b.X between a.X - 3 and a.X + 3
							and b.H = 1
							and b.ID != 1
				) b
	cross apply (select string_agg(concat(l.X, '.', l.Y), '>') Pth
						from generate_series(cast(1 as int), cast(Diff as int), cast(1 as int))
							cross apply (select a.X + [value]*IsPositive X, a.Y) l
						) p
where a.H = 0
	and not (a.X = a.MaxX
			and a.Y = a.MaxY
			)
union all
select a.ID SourceID, b.ID TargetID, b.Loss, Pth, IsEnd
from AOC_2023_Day17_MapR a
	cross apply (select b.ID, sum(b.Loss) over(partition by IsPositive order by Diff) Loss
						, iif(b.X = b.MaxX and b.Y = b.MaxY, 1, 0) IsEnd, Diff
						, IsPositive
					from AOC_2023_Day17_MapR b with (forceseek)
						cross apply (select abs(b.Y - a.Y) Diff
											, iif(b.Y > a.Y, 1, -1) IsPositive) r
					where b.X = a.X
							and b.Y != a.Y
							and b.Y between a.Y - 3 and a.Y + 3
							and b.V = 1
							and b.ID != 1
				) b
	cross apply (select string_agg(concat(l.X, '.', l.Y), '>') Pth
						from generate_series(cast(1 as int), cast(Diff as int), cast(1 as int))
							cross apply (select a.X, a.Y + [value]*IsPositive Y) l
						) p
where a.V = 0
	and not (a.X = a.MaxX
			and a.Y = a.MaxY
			)

alter index all on AOC_2023_Day17_EdgesR rebuild

;with rec as
	(select cast((select cast(100000 as int) n, cast(0 as int) l, 0 s, ID i, '>' + P + '>' p, cast(0 as tinyint) e
					from AOC_2023_Day17_MapR
						cross apply (select concat(X, '.', Y) P) i
					where ID = 1
					for json path
				) as varchar(max)) Rts, 0 CurrentStep
		union all
		select s.Rts, CurrentStep + 1 CurrentStep
		from rec r
			cross apply fn_AOC_2023_Day17_TakeSteps(Rts) s
		where s.Rts like '%"e":0%'
	)
select *
into #Route1
from rec

--1
select top 1 json_value(Rts, '$[0].n') Answer1
from #Route1 with (nolock)
order by CurrentStep desc

--2
truncate table AOC_2023_Day17_EdgesR
insert into AOC_2023_Day17_EdgesR
select a.ID SourceID, b.ID TargetID, b.Loss, Pth, IsEnd
from AOC_2023_Day17_MapR a
	cross apply (select b.ID, sum(b.Loss) over(partition by IsPositive order by Diff) Loss
						, iif(b.X = b.MaxX and b.Y = b.MaxY, 1, 0) IsEnd, Diff
						, IsPositive
					from AOC_2023_Day17_MapR b with (forceseek)
						cross apply (select abs(b.X - a.X) Diff
											, iif(b.X > a.X, 1, -1) IsPositive) r
					where b.Y = a.Y
							and b.X != a.X
							and b.X between a.X - 10 and a.X + 10
							and b.H = 1
							and b.ID != 1
				) b
	cross apply (select string_agg(concat(l.X, '.', l.Y), '>') Pth
						from generate_series(cast(1 as int), cast(Diff as int), cast(1 as int))
							cross apply (select a.X + [value]*IsPositive X, a.Y) l
						) p
where a.H = 0
	and b.Diff >= 4
	and not (a.X = a.MaxX
			and a.Y = a.MaxY
			)
union all
select a.ID SourceID, b.ID TargetID, b.Loss, Pth, IsEnd
from AOC_2023_Day17_MapR a
	cross apply (select b.ID, sum(b.Loss) over(partition by IsPositive order by Diff) Loss
						, iif(b.X = b.MaxX and b.Y = b.MaxY, 1, 0) IsEnd, Diff
						, IsPositive
					from AOC_2023_Day17_MapR b with (forceseek)
						cross apply (select abs(b.Y - a.Y) Diff
											, iif(b.Y > a.Y, 1, -1) IsPositive) r
					where b.X = a.X
							and b.Y != a.Y
							and b.Y between a.Y - 10 and a.Y + 10
							and b.V = 1
							and b.ID != 1
				) b
	cross apply (select string_agg(concat(l.X, '.', l.Y), '>') Pth
						from generate_series(cast(1 as int), cast(Diff as int), cast(1 as int))
							cross apply (select a.X, a.Y + [value]*IsPositive Y) l
						) p
where a.V = 0
	and b.Diff >= 4
	and not (a.X = a.MaxX
			and a.Y = a.MaxY
			)

alter index all on AOC_2023_Day17_EdgesR rebuild

;with rec as
	(select cast((select cast(100000 as int) n, cast(0 as int) l, 0 s, ID i, '>' + P + '>' p, cast(0 as tinyint) e
					from AOC_2023_Day17_MapR
						cross apply (select concat(X, '.', Y) P) i
					where ID = 1
					for json path
				) as varchar(max)) Rts, 0 CurrentStep
		union all
		select s.Rts, CurrentStep + 1 CurrentStep
		from rec r
			cross apply fn_AOC_2023_Day17_TakeSteps(Rts) s
		where s.Rts like '%"e":0%'
	)
select *
into #Route2
from rec

select top 1 json_value(Rts, '$[0].n') Answer2
from #Route2 with (nolock)
order by CurrentStep desc



