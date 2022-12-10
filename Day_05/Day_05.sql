declare @Input varchar(max) =
'[Q] [J]                         [H]
[G] [S] [Q]     [Z]             [P]
[P] [F] [M]     [F]     [F]     [S]
[R] [R] [P] [F] [V]     [D]     [L]
[L] [W] [W] [D] [W] [S] [V]     [G]
[C] [H] [H] [T] [D] [L] [M] [B] [B]
[T] [Q] [B] [S] [L] [C] [B] [J] [N]
[F] [N] [F] [V] [Q] [Z] [Z] [T] [Q]
 1   2   3   4   5   6   7   8   9 

move 1 from 8 to 1
move 1 from 6 to 1
move 3 from 7 to 4
move 3 from 2 to 9
move 11 from 9 to 3
move 1 from 6 to 9
move 15 from 3 to 9
move 5 from 2 to 3
move 3 from 7 to 5
move 6 from 9 to 3
move 6 from 1 to 6
move 2 from 3 to 7
move 5 from 4 to 5
move 7 from 9 to 4
move 2 from 9 to 5
move 10 from 4 to 2
move 6 from 5 to 4
move 2 from 7 to 6
move 10 from 2 to 3
move 21 from 3 to 5
move 1 from 3 to 6
move 3 from 6 to 9
move 1 from 8 to 9
move 5 from 4 to 5
move 4 from 9 to 3
move 17 from 5 to 1
move 1 from 6 to 2
move 16 from 5 to 1
move 3 from 3 to 6
move 6 from 6 to 4
move 1 from 2 to 4
move 4 from 1 to 2
move 2 from 6 to 2
move 28 from 1 to 3
move 1 from 9 to 7
move 1 from 8 to 7
move 1 from 5 to 4
move 1 from 2 to 6
move 1 from 3 to 1
move 3 from 2 to 5
move 1 from 6 to 3
move 4 from 4 to 7
move 5 from 5 to 2
move 1 from 5 to 6
move 6 from 1 to 3
move 1 from 6 to 2
move 26 from 3 to 6
move 2 from 7 to 9
move 4 from 7 to 3
move 19 from 6 to 3
move 6 from 2 to 4
move 5 from 3 to 2
move 1 from 9 to 7
move 26 from 3 to 8
move 6 from 4 to 3
move 1 from 3 to 8
move 1 from 6 to 7
move 6 from 3 to 6
move 6 from 6 to 4
move 1 from 9 to 2
move 2 from 4 to 9
move 22 from 8 to 2
move 2 from 6 to 5
move 1 from 9 to 1
move 1 from 6 to 5
move 1 from 7 to 5
move 3 from 6 to 7
move 2 from 6 to 1
move 1 from 1 to 5
move 3 from 5 to 9
move 4 from 8 to 4
move 2 from 1 to 4
move 18 from 2 to 1
move 2 from 7 to 8
move 3 from 9 to 5
move 8 from 1 to 9
move 5 from 9 to 3
move 1 from 9 to 8
move 2 from 9 to 4
move 2 from 7 to 8
move 5 from 5 to 7
move 1 from 9 to 3
move 4 from 8 to 4
move 1 from 7 to 8
move 4 from 4 to 3
move 2 from 8 to 3
move 1 from 8 to 9
move 2 from 1 to 8
move 3 from 4 to 5
move 1 from 8 to 4
move 1 from 9 to 3
move 1 from 8 to 5
move 8 from 1 to 8
move 11 from 2 to 9
move 12 from 3 to 5
move 1 from 3 to 9
move 1 from 8 to 5
move 11 from 9 to 3
move 4 from 5 to 9
move 3 from 8 to 7
move 3 from 7 to 8
move 1 from 5 to 8
move 7 from 4 to 3
move 1 from 4 to 5
move 1 from 2 to 8
move 3 from 7 to 6
move 3 from 4 to 8
move 1 from 7 to 9
move 2 from 4 to 7
move 5 from 8 to 1
move 3 from 6 to 5
move 2 from 4 to 2
move 1 from 9 to 4
move 1 from 8 to 6
move 1 from 2 to 9
move 1 from 8 to 5
move 3 from 8 to 4
move 3 from 4 to 2
move 4 from 3 to 9
move 17 from 5 to 9
move 9 from 9 to 6
move 1 from 9 to 3
move 5 from 6 to 3
move 3 from 6 to 3
move 8 from 9 to 5
move 2 from 8 to 5
move 1 from 4 to 8
move 1 from 5 to 3
move 1 from 8 to 5
move 3 from 2 to 6
move 3 from 1 to 4
move 7 from 5 to 1
move 1 from 2 to 6
move 13 from 3 to 6
move 2 from 7 to 8
move 13 from 6 to 5
move 3 from 5 to 7
move 6 from 5 to 6
move 1 from 7 to 6
move 2 from 7 to 3
move 1 from 6 to 8
move 13 from 3 to 5
move 9 from 5 to 9
move 7 from 5 to 7
move 17 from 9 to 2
move 3 from 4 to 7
move 9 from 2 to 9
move 10 from 9 to 3
move 8 from 7 to 8
move 2 from 5 to 3
move 4 from 2 to 6
move 11 from 3 to 9
move 9 from 6 to 5
move 5 from 9 to 8
move 1 from 3 to 1
move 3 from 9 to 1
move 2 from 5 to 2
move 1 from 7 to 9
move 2 from 9 to 4
move 2 from 9 to 8
move 13 from 1 to 8
move 3 from 8 to 5
move 27 from 8 to 1
move 10 from 5 to 9
move 1 from 7 to 2
move 2 from 4 to 3
move 10 from 9 to 6
move 1 from 8 to 7
move 15 from 1 to 9
move 13 from 9 to 5
move 15 from 5 to 7
move 5 from 1 to 3
move 8 from 7 to 1
move 7 from 7 to 1
move 16 from 1 to 8
move 4 from 3 to 9
move 4 from 1 to 7
move 4 from 9 to 6
move 5 from 2 to 7
move 15 from 8 to 6
move 1 from 9 to 1
move 3 from 3 to 4
move 1 from 9 to 7
move 1 from 2 to 7
move 1 from 2 to 7
move 1 from 8 to 1
move 3 from 4 to 8
move 3 from 8 to 1
move 8 from 6 to 8
move 7 from 1 to 4
move 11 from 6 to 8
move 14 from 6 to 5
move 13 from 8 to 7
move 4 from 7 to 5
move 15 from 7 to 4
move 6 from 5 to 4
move 2 from 5 to 9
move 1 from 5 to 2
move 3 from 8 to 5
move 19 from 4 to 7
move 10 from 5 to 8
move 2 from 6 to 8
move 1 from 4 to 8
move 2 from 7 to 9
move 9 from 7 to 4
move 6 from 4 to 6
move 11 from 4 to 8
move 2 from 5 to 4
move 5 from 6 to 4
move 1 from 6 to 7
move 3 from 9 to 5
move 3 from 8 to 5
move 3 from 7 to 6
move 11 from 8 to 7
move 1 from 9 to 5
move 1 from 6 to 8
move 1 from 2 to 1
move 5 from 4 to 9
move 2 from 4 to 1
move 2 from 1 to 4
move 1 from 1 to 9
move 4 from 5 to 1
move 1 from 4 to 6
move 17 from 7 to 5
move 9 from 8 to 7
move 6 from 9 to 7
move 3 from 1 to 9
move 12 from 7 to 9
move 12 from 9 to 5
move 5 from 7 to 9
move 17 from 5 to 3
move 7 from 3 to 1
move 5 from 1 to 5
move 5 from 9 to 2
move 4 from 3 to 5
move 1 from 4 to 8
move 5 from 2 to 1
move 22 from 5 to 9
move 3 from 7 to 6
move 6 from 6 to 9
move 2 from 5 to 4
move 1 from 6 to 3
move 2 from 4 to 1
move 3 from 8 to 2
move 1 from 3 to 4
move 24 from 9 to 1
move 4 from 3 to 9
move 2 from 2 to 9
move 2 from 3 to 1
move 1 from 8 to 6
move 1 from 6 to 9
move 1 from 8 to 9
move 2 from 7 to 4
move 1 from 8 to 3
move 1 from 4 to 7
move 3 from 9 to 8
move 1 from 2 to 1
move 9 from 9 to 3
move 1 from 8 to 7
move 1 from 4 to 3
move 2 from 9 to 7
move 1 from 9 to 3
move 2 from 8 to 4
move 12 from 3 to 8
move 2 from 1 to 7
move 1 from 4 to 3
move 30 from 1 to 5
move 6 from 5 to 7
move 12 from 7 to 2
move 1 from 3 to 4
move 2 from 1 to 3
move 1 from 4 to 9
move 10 from 5 to 7
move 10 from 2 to 6
move 8 from 8 to 3
move 3 from 1 to 3
move 5 from 6 to 3
move 2 from 8 to 5
move 1 from 9 to 2
move 2 from 8 to 6
move 4 from 7 to 2
move 3 from 2 to 7
move 2 from 7 to 5
move 1 from 4 to 9
move 11 from 3 to 1
move 7 from 6 to 9
move 3 from 2 to 3
move 10 from 1 to 7
move 14 from 7 to 5
move 3 from 7 to 6
move 5 from 9 to 7
move 29 from 5 to 7
move 6 from 3 to 9
move 2 from 9 to 7
move 15 from 7 to 5
move 11 from 5 to 6
move 5 from 9 to 5
move 10 from 5 to 8
move 1 from 2 to 4
move 1 from 8 to 2
move 2 from 4 to 3
move 2 from 5 to 9
move 8 from 8 to 9
move 11 from 9 to 3
move 1 from 1 to 8
move 18 from 7 to 3
move 1 from 9 to 3
move 28 from 3 to 5
move 12 from 6 to 7
move 1 from 2 to 9
move 15 from 7 to 2
move 1 from 8 to 1
move 10 from 2 to 9
move 10 from 5 to 3
move 2 from 2 to 3
move 18 from 3 to 4
move 6 from 9 to 4
move 1 from 1 to 7
move 1 from 6 to 4
move 1 from 8 to 2
move 1 from 9 to 4
move 2 from 9 to 4
move 19 from 4 to 3
move 1 from 7 to 9
move 1 from 9 to 7
move 1 from 6 to 8
move 3 from 2 to 8
move 2 from 9 to 5
move 15 from 3 to 1
move 7 from 5 to 1
move 3 from 4 to 9
move 1 from 7 to 2
move 3 from 3 to 1
move 6 from 5 to 2
move 3 from 3 to 9
move 4 from 9 to 2
move 5 from 5 to 3
move 1 from 3 to 5
move 3 from 5 to 7
move 3 from 8 to 5
move 1 from 7 to 5
move 4 from 5 to 1
move 4 from 4 to 2
move 2 from 7 to 8
move 12 from 1 to 6
move 1 from 8 to 6
move 6 from 2 to 3
move 9 from 3 to 8
move 1 from 3 to 4
move 3 from 6 to 1
move 2 from 9 to 2
move 1 from 4 to 5
move 2 from 8 to 3
move 10 from 2 to 1
move 2 from 4 to 7
move 12 from 1 to 4
move 1 from 5 to 1
move 7 from 4 to 9
move 2 from 3 to 2
move 6 from 9 to 2
move 1 from 9 to 1
move 1 from 7 to 8
move 5 from 6 to 7
move 3 from 6 to 1
move 6 from 2 to 3
move 2 from 4 to 3
move 1 from 6 to 8
move 1 from 6 to 7
move 8 from 3 to 9
move 2 from 4 to 5
move 3 from 2 to 4
move 10 from 8 to 2
move 22 from 1 to 9
move 9 from 2 to 4
move 1 from 1 to 3
move 1 from 3 to 2
move 3 from 2 to 4
move 2 from 7 to 1
move 14 from 4 to 2
move 2 from 1 to 8
move 2 from 4 to 5
move 4 from 7 to 8
move 24 from 9 to 6
move 3 from 5 to 9
move 1 from 9 to 8
move 1 from 5 to 2
move 1 from 6 to 7
move 6 from 9 to 1
move 1 from 7 to 3
move 5 from 8 to 6
move 9 from 6 to 3
move 4 from 1 to 4
move 2 from 1 to 2
move 11 from 6 to 3
move 13 from 3 to 2
move 2 from 9 to 8
move 8 from 3 to 8
move 2 from 8 to 5
move 1 from 7 to 5
move 3 from 6 to 3
move 11 from 8 to 5
move 13 from 2 to 4
move 10 from 5 to 2
move 2 from 3 to 4
move 2 from 5 to 7
move 15 from 4 to 9
move 2 from 7 to 4
move 2 from 4 to 2
move 2 from 4 to 9
move 2 from 4 to 2
move 1 from 3 to 8
move 1 from 8 to 1
move 1 from 1 to 2
move 1 from 6 to 3
move 7 from 2 to 4
move 1 from 5 to 3
move 7 from 9 to 1
move 7 from 1 to 2
move 4 from 6 to 9
move 12 from 9 to 7
move 6 from 7 to 5
move 1 from 3 to 5
move 7 from 4 to 7
move 3 from 7 to 8
move 3 from 8 to 6
move 18 from 2 to 9
move 7 from 2 to 3
move 15 from 9 to 4
move 3 from 3 to 9
move 1 from 3 to 1
move 3 from 5 to 4
move 1 from 1 to 2
move 1 from 9 to 2
move 2 from 6 to 2
move 5 from 7 to 6
move 5 from 2 to 7
move 3 from 3 to 4
move 5 from 5 to 3
move 6 from 7 to 4
move 9 from 4 to 2
move 18 from 4 to 9
move 6 from 2 to 1
move 1 from 1 to 9
move 4 from 7 to 4
move 7 from 2 to 4
move 1 from 2 to 8
move 1 from 4 to 2
move 4 from 3 to 4
move 16 from 9 to 5
move 9 from 9 to 8
move 1 from 9 to 7
move 4 from 1 to 2
move 2 from 5 to 4
move 10 from 5 to 4
move 4 from 2 to 1
move 5 from 1 to 2
move 1 from 8 to 5
move 1 from 6 to 5
move 4 from 8 to 5
move 2 from 6 to 9
move 3 from 6 to 2
move 2 from 9 to 1
move 1 from 7 to 6
move 1 from 3 to 8
move 9 from 5 to 9
move 4 from 8 to 1
move 2 from 8 to 2
move 1 from 5 to 7
move 9 from 9 to 8
move 1 from 7 to 5
move 9 from 8 to 2
move 6 from 1 to 6
move 6 from 2 to 6
move 10 from 2 to 5
move 5 from 2 to 1
move 1 from 3 to 5
move 8 from 5 to 4
move 5 from 1 to 3
move 10 from 6 to 8
move 3 from 6 to 9
move 4 from 3 to 1
move 5 from 8 to 2
move 4 from 5 to 9
move 1 from 3 to 7
move 1 from 7 to 3
move 1 from 8 to 6
move 1 from 6 to 1
move 15 from 4 to 8
move 5 from 9 to 2
move 1 from 9 to 1
move 1 from 1 to 3
move 6 from 4 to 8
move 12 from 8 to 7
move 1 from 3 to 5
move 3 from 1 to 9
move 13 from 4 to 9
move 5 from 7 to 2
move 1 from 5 to 4
move 8 from 9 to 5
move 6 from 2 to 5
move 2 from 5 to 6'

drop table if exists #Numbers
drop table if exists #Crates
drop table if exists #Instructions
drop table if exists #InstructionsEx

--Create a numbers table - won't leave home without one
;with rec as
	(select 1 Num
	union all
	select Num + 1
	from rec
	where Num < 32767
	)
select Num
into #Numbers
from rec
option (maxrecursion 32767)
create unique clustered index IX_#Numbers on #Numbers(Num)

--Parse crates
;with Input as
	(select replace(left(@Input, ind - 3), char(10), '') CratesStr
		from (select charindex(' 1', @Input, 1) ind) i
	),
	Lines as
	(select row_number() over(order by (select 1)) LineID, [value]
		from Input
			cross apply string_split(CratesStr, char(13))
	),
	Crates1 as
	(select LineID, row_number() over(partition by LineID order by Num) ColumnID, substring([value], Num, 1) Crate --row_number() over(partition by i.ID order by b.ID) ColumnID, i.ID, Chr
		from Lines i
			inner join #Numbers on Num <= len([value])
		where (Num - 2) % 4 = 0
	)
select ColumnID, row_number() over (partition by ColumnID order by LineID) CrateID, Crate
into #Crates
from Crates1
where Crate <> ''

--Parse instructions
;with Input as
	(select replace(substring(@Input, ind1 + 4, len(@Input)), char(10), '') InstructionsStr
		from (select charindex(' 1', @Input, 1) ind) i
			cross apply (select charindex(char(13), @Input, ind) ind1) i1
	),
	Lines as
	(select row_number() over(order by (select 1)) LineID, [value]
		from Input
			cross apply string_split(InstructionsStr, char(13))
	)
select LineID InstructionID, cast(parsename(v1, 3) as int) Crates, cast(parsename(v1, 2) as int) src, cast(parsename(v1, 1) as int) dst
into #Instructions
from Lines
	cross apply (select replace(replace(replace([value], 'move ', ''), ' from ', '.'), ' to ', '.') v1) v

--Explode instructions for Q1
select row_number() over(order by InstructionID, Num) InstructionID, src, dst
into #InstructionsEx
from #Instructions i
	inner join #Numbers on Num <= Crates

--Solve Q1
;with rec as
	(select cast(0 as int) InsID, *
		from #Crates
		union all
		select cast(InstructionID as int), NewColumn, NewCrateID, Crate
		from rec n
			inner join #InstructionsEx on InstructionID = n.InsID + 1
			cross apply (select iif(n.ColumnID = src and CrateID = 1, dst, n.ColumnID) NewColumn) nc
			cross apply (select case when ColumnID = src and CrateID > 1
										then CrateID - 1
									when ColumnID = dst
										then CrateID + 1
									else CrateID
								end NewCrateID) nr
	)
select top 1 string_agg(Crate, '') within group (order by ColumnID) Answer1
from rec
where CrateID = 1
group by InsID
order by InsID desc
option (maxrecursion 32767)

--Solve Q2
;with rec as
	(select cast(0 as int) InsID, *
		from #Crates
		union all
		select cast(InstructionID as int), NewColumn ColumnID, NewCrateID, Crate
		from rec n
			inner join #Instructions on InstructionID = InsID + 1
			cross apply (select iif(n.ColumnID = src and CrateID <= Crates, dst, n.ColumnID) NewColumn) nc
			cross apply (select case when ColumnID = src and CrateID > Crates
										then CrateID - Crates
									when ColumnID = dst
										then CrateID + Crates
									else CrateID
								end NewCrateID) nr
	)
select top 1 string_agg(Crate, '') within group (order by ColumnID) Answer2
from rec
where CrateID = 1
group by InsID
order by InsID desc
option (maxrecursion 32767)