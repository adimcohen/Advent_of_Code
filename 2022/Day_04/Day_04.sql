declare @Str varchar(max) =
'2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8'

drop table if exists #Input
drop table if exists #Numbers

select row_number() over(order by (select 1)) ID, [value] Val
into #Input
from string_split(replace(@Str, char(10), ''), char(13))

--Create a numbers table - never leave home without one
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

select sum(iif(cnt in (i4.p2 - i4.p1 + 1, i6.p2 - i6.p1 + 1), 1, 0)) Answer1
from #Input
	cross apply (select charindex(',', Val, 1) ind) i1
	cross apply (select left(Val, i1.ind - 1) p1, substring(Val, i1.ind + 1, len(Val)) p2) i2
	cross apply (select charindex('-', i2.p1, 1) ind) i3
	cross apply (select cast(left(i2.p1, i3.ind - 1) as int) p1, cast(substring(i2.p1, i3.ind + 1, len(Val)) as int) p2) i4
	cross apply (select charindex('-', i2.p2, 1) ind) i5
	cross apply (select cast(left(i2.p2, i5.ind - 1) as int) p1, cast(substring(i2.p2, i5.ind + 1, len(Val)) as int) p2) i6
	cross apply (select count(*) cnt
					from (select Num
								from #Numbers
								where Num between i4.p1 and i4.p2
								intersect
								select Num
								from #Numbers
								where Num between i6.p1 and i6.p2
						) nn			
					) n1

select sum(iif(cnt > 0, 1, 0)) Answer2
from #Input
	cross apply (select charindex(',', Val, 1) ind) i1
	cross apply (select left(Val, i1.ind - 1) p1, substring(Val, i1.ind + 1, len(Val)) p2) i2
	cross apply (select charindex('-', i2.p1, 1) ind) i3
	cross apply (select cast(left(i2.p1, i3.ind - 1) as int) p1, cast(substring(i2.p1, i3.ind + 1, len(Val)) as int) p2) i4
	cross apply (select charindex('-', i2.p2, 1) ind) i5
	cross apply (select cast(left(i2.p2, i5.ind - 1) as int) p1, cast(substring(i2.p2, i5.ind + 1, len(Val)) as int) p2) i6
	cross apply (select count(*) cnt
					from (select Num
								from #Numbers
								where Num between i4.p1 and i4.p2
								intersect
								select Num
								from #Numbers
								where Num between i6.p1 and i6.p2
						) nn			
					) n1
