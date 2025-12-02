declare @Str varchar(max) =
'vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw'

drop table if exists #Numbers
drop table if exists #Input

select row_number() over(order by (select 1)) ID, [value] collate SQL_Latin1_General_CP1_CS_AS Val
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

;with CharVal as
	(select row_number() over(order by Num) + 26 Pri, char(Num) collate SQL_Latin1_General_CP1_CS_AS Val
		from #Numbers
		where Num between ascii('A') and ascii('Z')
		union
		select row_number() over(order by Num), char(Num) collate SQL_Latin1_General_CP1_CS_AS
		from #Numbers
		where Num between ascii('a') and ascii('z')
	)
select sum(cv.Pri)
from #Input
	cross apply (select len(Val) l) a
	cross apply (select left(Val, l/2) p1, substring(Val, l/2 + 1, l) p2) b
	cross apply (select distinct t.Chr
					from #Numbers
						cross apply (select substring(p1, Num, 1) collate SQL_Latin1_General_CP1_CS_AS Chr) t
					where Num <= len(p1)
						and p2 like '%' + t.Chr + '%'
					) t
	inner join CharVal cv on cv.Val = t.Chr
option (maxrecursion 32767)

;with CharVal as
	(select row_number() over(order by Num) + 26 Pri, char(Num) collate SQL_Latin1_General_CP1_CS_AS Val
		from #Numbers
		where Num between ascii('A') and ascii('Z')
		union
		select row_number() over(order by Num), char(Num) collate SQL_Latin1_General_CP1_CS_AS
		from #Numbers
		where Num between ascii('a') and ascii('z')
	)
	, i as
	(select *, (ID - 1)/3 GroupID
		from #Input
	),
	i1 as
	(select GroupID, Chr
	from i
		cross apply (select distinct Chr
						from #Numbers
							cross apply (select substring(Val, Num, 1) collate SQL_Latin1_General_CP1_CS_AS Chr) t
						where Num <= len(Val)
					) v
	group by GroupID, Chr
	having count(*) = 3
	)
select sum(Pri)
from i1
	inner join CharVal cv on cv.Val = Chr