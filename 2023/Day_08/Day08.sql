--p2 only works for real input
declare @Input varchar(max) = 
'RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)'

drop table if exists #Input
drop table if exists #Map
drop table if exists #Instructions
drop table if exists #Results

select *
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1)

select row_number() over(order by ordinal) LocID, parsename(Val, 3) Loc, parsename(Val, 2) L, parsename(Val, 1) R
into #Map
from #Input
	cross apply (select replace(replace(replace(replace(replace([value], ' ', ''), '=', ''), '(', '.'), ',', '.'), ')', '') Val) i
where ordinal >= 3

select g.[value] ordinal, cast(substring(i.[value], g.[value], 1) as char(1)) Dir
into #Instructions
from #Input i
	cross apply generate_series(1, cast(len(i.[value]) as int), 1) g
where ordinal = 1

create unique clustered index IX_#Map on #Map(Loc)
create unique clustered index IX_#Instructions on #Instructions(ordinal)

--1
;with i as
	(select count(*) CntIns
		from #Instructions
	)
	, rec as
	(select 0 Turn, Loc, R, L, cast(' ' as char(1)) Dir
		from #Map
		where Loc = 'AAA'
	union all
	select CurrentTurn Turn, m.Loc, m.R, m.L, s.Dir
	from rec
		cross join i
		cross apply (select rec.Turn + 1 CurrentTurn) i1
		inner join #Instructions s on ordinal = isnull(nullif(CurrentTurn % CntIns, 0), CntIns)
		inner join #Map m on (s.Dir = 'R' and m.Loc = rec.R)
							or (s.Dir = 'L' and m.Loc = rec.L)
	where rec.Loc not like 'ZZZ'
	)
select max(turn) Answer1
from rec
option (maxrecursion 32767)
GO
declare @Input varchar(max) = 
'LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)'

drop table if exists #Input
drop table if exists #Map
drop table if exists #Instructions
drop table if exists #Results

select *
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1)

select row_number() over(order by ordinal) LocID, parsename(Val, 3) Loc, parsename(Val, 2) L, parsename(Val, 1) R
into #Map
from #Input
	cross apply (select replace(replace(replace(replace(replace([value], ' ', ''), '=', ''), '(', '.'), ',', '.'), ')', '') Val) i
where ordinal >= 3

select g.[value] ordinal, cast(substring(i.[value], g.[value], 1) as char(1)) Dir
into #Instructions
from #Input i
	cross apply generate_series(1, cast(len(i.[value]) as int), 1) g
where ordinal = 1

create unique clustered index IX_#Map on #Map(Loc)
create unique clustered index IX_#Instructions on #Instructions(ordinal)
--2
;with i as
	(select count(*) CntIns
		from #Instructions
	)
	, rec as
	(select 0 Turn, LocID, Loc, R, L, cast(' ' as char(1)) Dir
		from #Map
		where Loc like '__A'
	union all
	select CurrentTurn Turn, rec.LocID, m.Loc, m.R, m.L, s.Dir
	from rec
		cross join i
		cross apply (select rec.Turn + 1 CurrentTurn) i1
		inner join #Instructions s on ordinal = isnull(nullif(CurrentTurn % CntIns, 0), CntIns)
		inner join #Map m on (s.Dir = 'R' and m.Loc = rec.R)
							or (s.Dir = 'L' and m.Loc = rec.L)
	where rec.Loc not like '__Z'
	)
select LocID, max(Turn) Moves
into #Results
from rec
group by LocID
option (maxrecursion 32767)

;with Nums as
	(select [value] num
		from generate_series(3, cast((select max(Moves) from #Results)/2 as int), 2)
		union all
		select 2
	)
	, Prime as
	(select num
		from Nums a
		where not exists (select *
							from Nums b
							where b.num != a.num
								and a.num % b.num = 0
						)
	)
	, i as
	(select LocID, Moves, num
		from #Results
			inner join Prime on Moves % num = 0
	)
	, i1 as
	(select cast(Moves / exp(sum(log(num))) as bigint) num
		from i
		group by LocID, Moves
		having Moves / exp(sum(log(num))) > 1.1
		union
		select cast(num as bigint)
		from i
	)
select exp(sum(log(num))) Answer2
from i1