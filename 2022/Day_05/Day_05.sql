declare @Input varchar(max) =
'    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2'

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