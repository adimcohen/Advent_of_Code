declare @Str varchar(max) =
'mjqjpqmgbljsphdztnvjfqwrcgsmlb'

drop table if exists #Numbers
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

select top 1 Num Answer1
from #Numbers n
	cross apply (select 4 Cnt) c
where Num between Cnt and len(@Str)
	and exists  (select *
					from #Numbers n1
					where n1.Num between n.Num - Cnt + 1 and n.Num
					having count(distinct substring(@Str, n1.Num, 1)) = count(*)
					)
order by Num

select top 1 Num Answer2
from #Numbers n
	cross apply (select 14 Cnt) c
where Num between Cnt and len(@Str)
	and exists  (select *
					from #Numbers n1
					where n1.Num between n.Num - Cnt + 1 and n.Num
					having count(distinct substring(@Str, n1.Num, 1)) = count(*)
					)
order by Num