declare @Str varchar(max) =
'1000
2000
3000

4000

5000
6000

7000
8000
9000

10000'

drop table if exists #Input
select row_number() over(order by (select 1)) ID, [value] Val
into #Input
from string_split(replace(@Str, char(10), ''), char(13))

;with i as
	(select ID - row_number() over(order by ID) GrpID, Val
		from #Input
		where Val <> ''
	)
	, i1 as
	(select top 1 sum(cast(Val as int)) Cal
	from i
	where Val <> ''
	group by GrpID
	order by cal desc
	)
select Cal Answer1
from i1

;with i as
	(select ID - row_number() over(order by ID) GrpID, Val
		from #Input
		where Val <> ''
	)
	, i1 as
	(select top 3 sum(cast(Val as int)) Cal
	from i
	where Val <> ''
	group by GrpID
	order by cal desc
	)
select sum(Cal) Answer2
from i1