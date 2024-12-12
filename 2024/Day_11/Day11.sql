create or alter function fn_AOC_2024_Day11_WorkStones(@Stones varchar(max)) returns table
as
return with i as
		(select isnull(Val1, Val2) Val, count(*)*cnt cnt
			from string_split(@Stones, ',') r
				cross apply (select parsename(r.[value], 2) sVal, cast(parsename(r.[value], 1) as bigint) Cnt) c
				cross apply (select cast(sVal as bigint) Val) s
				cross apply (select len(sVal) lVal) l
				cross apply (select lVal%2 NoSplit) s1
				cross apply (select case when Val = 0 then 1
										when NoSplit = 1 then Val*2024
									end Val1
							) i
				outer apply (select cast(iif([value] = 1, left(sVal, lVal/2), right(sVal, lVal/2)) as bigint) Val2
								from generate_series(1, 2, 1)
								where NoSplit = 0
							) i1
			group by isnull(Val1, Val2), cnt
		)
		, i1 as
		(select concat(Val, '.', sum(cnt)) v
		from i
		group by Val
		)
		select string_agg(cast(v as varchar(max)), ',') Stones
		from i1
GO
declare @Input varchar(max) =
'4022724 951333 0 21633 5857 97 702 6'

drop table if exists #Input
drop table if exists #Final1
drop table if exists #Final2

;with i as
	(select concat(Val, '.', count(*)) v
		from string_split(@Input, ' ', 1) r
			cross apply (select cast([value] as bigint) Val) v
		group by Val
	)
	, i1 as
	(select string_agg(cast(v as varchar(max)), ',') Stones
		from i
	)
	, rec as
	(select Stones, 0 Blinks
	from i1
	union all
	select w.Stones, Blinks + 1
	from rec r
		cross apply fn_AOC_2024_Day11_WorkStones(Stones) w
	where r.Blinks < 25
	)
	, f as
	(select top 1 *
		from rec
		order by Blinks desc
	)
select sum(cnt) Answer1
from f
	cross apply string_split(Stones, ',') r
	cross apply (select cast(parsename(r.[value], 1) as bigint) Cnt) c

;with i as
	(select concat(Val, '.', count(*)) v
		from string_split(@Input, ' ', 1) r
			cross apply (select cast([value] as bigint) Val) v
		group by Val
	)
	, i1 as
	(select string_agg(cast(v as varchar(max)), ',') Stones
		from i
	)
	, rec as
	(select Stones, 0 Blinks
	from i1
	union all
	select w.Stones, Blinks + 1
	from rec r
		cross apply fn_AOC_2024_Day11_WorkStones(Stones) w
	where r.Blinks < 75
	)
	, f as
	(select top 1 *
		from rec
		order by Blinks desc
	)
select sum(cnt) Answer2
from f
	cross apply string_split(Stones, ',') r
	cross apply (select cast(parsename(r.[value], 1) as bigint) Cnt) c