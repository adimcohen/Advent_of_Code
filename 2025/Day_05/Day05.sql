create or alter function fn_AOC_2025_05_DedupRanges(@rng varchar(max)) returns table
as
return with i as
			(select v1, v2, row_number() over(order by v1) rn
				from openjson(@rng)
					cross apply (select cast(json_value([value], '$.v1') as bigint) v1
										, cast(json_value([value], '$.v2') as bigint) v2
								) p
			)
			, f as
			(select least(f1.v1, f2.v1) v1, greatest(f1.v2, f2.v2) v2
				from i f1
					inner join i f2 on f2.rn != f1.rn
									and (f2.v1 between f1.v1 and f1.v2
										or f2.v2 between f1.v1 and f1.v2
										)
				union
				select v1, v2
				from i f1
				where not exists (select *
									from i f2
									where f2.rn != f1.rn
										and (f1.v1 between f2.v1 and f2.v2
											or f1.v2 between f2.v1 and f2.v2
											)
									)
				)
		select (select v1, v2
				from f
				order by v1
				for json path
				) rng
GO
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
drop table if exists #Ingridiants
select max(ordinal) ordinal, cast(parsename(val, 2) as bigint) v1, cast(parsename(val, 1) as bigint) v2
into #FreshRanges
from string_split(replace(left(@Input, charindex(char(13)+char(10)+char(13)+char(10), @Input, 1)), char(13), ''), char(10), 1) r
	cross apply (select replace([value], '-', '.') val) p
group by cast(parsename(val, 2) as bigint), cast(parsename(val, 1) as bigint)

select cast([value] as bigint) ing
into #Ingridiants
from string_split(replace(substring(@Input, charindex(char(13)+char(10)+char(13)+char(10), @Input, 1) + 4, len(@Input)), char(13), ''), char(10), 1) r

select count(*) Solution1
from #Ingridiants
where exists (select *
				from #FreshRanges
				where ing between v1 and v2)

;with anc as
		(select *
			from #FreshRanges r
			where not exists (select *
								from #FreshRanges r1
								where r1.ordinal != r.ordinal
									and r.v1 between r1.v1 and r1.v2
									and r.v2 between r1.v1 and r1.v2
								)
		)
	, rec as
	(select (select v1, v2
				from anc
				order by v1
				for json path
				) rng, 0 step
		union all
		select d.rng, r.step + 1
		from rec r
			cross apply fn_AOC_2025_05_DedupRanges(rng) d
		where d.rng != r.rng
	)
	, lst as
		(select top 1 *
			from rec
			order by step desc
		)
select sum(v2 - v1 + 1) Solution2
from lst
	cross apply openjson(rng)
	cross apply (select cast(json_value([value], '$.v1') as bigint) v1
						, cast(json_value([value], '$.v2') as bigint) v2
				) p