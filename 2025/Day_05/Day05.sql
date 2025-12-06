declare @Input varchar(max) =
'3-5
10-14
16-20
12-18

1
5
8
11
17
32'

drop table if exists #FreshRanges
drop table if exists #Ingredients
select max(ordinal) ordinal, cast(parsename(val, 2) as bigint) v1, cast(parsename(val, 1) as bigint) v2
into #FreshRanges
from string_split(replace(left(@Input, charindex(char(13)+char(10)+char(13)+char(10), @Input, 1)), char(13), ''), char(10), 1) r
	cross apply (select replace([value], '-', '.') val) p
group by cast(parsename(val, 2) as bigint), cast(parsename(val, 1) as bigint)

select cast([value] as bigint) ing
into #Ingredients
from string_split(replace(substring(@Input, charindex(char(13)+char(10)+char(13)+char(10), @Input, 1) + 4, len(@Input)), char(13), ''), char(10), 1) r

select count(*) Solution1
from #Ingredients
where exists (select *
				from #FreshRanges
				where ing between v1 and v2)

;with dedup as
		(select *
			from #FreshRanges r
			where not exists (select *
								from #FreshRanges r1
								where r1.ordinal != r.ordinal
									and r.v1 between r1.v1 and r1.v2
									and r.v2 between r1.v1 and r1.v2
								)
		)
	, i as
	(select v1 val, 1 IsStart
		from dedup
		union
		select v2, -1 IsStart
		from dedup
	)
	, i1 as
	(select *, sum(IsStart) over(order by val, IsStart desc) lvl
		from i
	)
	, i2 as
	(select *
			, row_number() over(order by val, IsStart desc) rn
			, iif(lag(lvl, 1, 0) over(order by val, IsStart desc) = 0, val, null) v1
			, iif(lvl = 0, val, null) v2
		from i1
	)
	, i3 as
	(select last_value(v1) ignore nulls over(order by rn rows between unbounded preceding and current row) v1, v2
		from i2
	)
select sum(v2 - v1 + 1) Solution2
from i3
where v2 is not null