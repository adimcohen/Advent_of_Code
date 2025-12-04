declare @Input varchar(max) =
'467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..'
drop table if exists #Input
drop table if exists #Numbers
drop table if exists #Parsed
drop table if exists #i
drop table if exists #i2

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

select *
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1)


;with i as
	(select ordinal Y, Num X, Val, IsNum, iif(isnull(IsNum, 0) = 0, row_number() over(partition by ordinal order by Num), null) rn
		from #Input
			inner join #Numbers on Num <= len([value])
			cross apply (select substring([value], Num, 1) Val) v
			cross apply (select case when Val = '.' then null
									when Val between '0' and '9' then 1
									else 0
								end IsNum) n
	)
select *
into #i
from i
option (maxdop 1)

;with i1 as
	(select *, case IsNum
					when 1 then isnull(max(rn) over(partition by Y order by X rows between unbounded preceding and 1 preceding), 0)
					when 0 then -X
				end Grp
		from #i
	)
	, i2 as
	(select Y, min(X) X1, max(X) X2, IsNum, Grp, string_agg(Val, '') within group(order by X) Val
		from i1
		where Val <> '.'
		group by Y, Grp, IsNum
	)
select *
into #i2
from i2

select cast(Val as int) Val, SymbolGrp, Symbol
into #Parsed
from #i2 a
	cross apply (select top 1 b.Val Symbol, concat(b.Y, b.Grp) SymbolGrp
					from #i2 b
					where b.IsNum = 0
						and b.Y between a.Y - 1 and a.Y + 1
						and b.X1 between a.X1 - 1 and a.X2 + 1
				) s
where IsNum = 1
option (maxdop 1)

--1
select sum(Val) Answer1
from #Parsed

--2
;with i as
	(select exp(sum(log(Val*1.))) prod
		from #Parsed
		where Symbol = '*'
		group by SymbolGrp
		having count(*) = 2
	)
select sum(prod) Answer2
from i