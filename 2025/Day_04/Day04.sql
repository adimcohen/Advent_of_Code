declare @Input varchar(max) =
'..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.'

drop table if exists #Input
select r.ordinal r, c.[value] c, substring(r.[value], c.[value], 1) chr
into #Input
from string_split(replace(@Input, char(13), ''), char(10), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int)) c

;with i as
	(select i.chr
			, iif(lag(i.chr) over(partition by i.c order by i.r) = '@', 1, 0)
			+ iif(lead(i.chr) over(partition by i.c order by i.r) = '@', 1, 0)
			+ iif(lag(i.chr) over(partition by i.r order by i.c) = '@', 1, 0)
			+ iif(lead(i.chr) over(partition by i.r order by i.c) = '@', 1, 0)
			+ iif(lag(i.chr) over(partition by i.r + i.c order by i.r) = '@', 1, 0)
			+ iif(lead(i.chr) over(partition by i.r + i.c order by i.r) = '@', 1, 0)
			+ iif(lag(i.chr) over(partition by i.r - i.c order by i.r) = '@', 1, 0)
			+ iif(lead(i.chr) over(partition by i.r - i.c order by i.r) = '@', 1, 0) Around
		from #Input i
	)
select count(*) Solution1
from i
where chr = '@'
	and Around < 4

;with anc as
	(select (select r, c, chr h
				from #Input
				order by r, c
				for json path
			) map, 0 step
	)
	, rec as
	(select map, step
		from anc
		union all
		select m.map, step + 1
		from rec r
			cross apply (select (select i.r, i.c, iif((chr = '@'
													and Around < 4
													)
												, '.'
												, i.chr) h
							from (select i.r, i.c, i.chr
									, iif(lag(i.chr) over(partition by i.c order by i.r) = '@', 1, 0)
									+ iif(lead(i.chr) over(partition by i.c order by i.r) = '@', 1, 0)
									+ iif(lag(i.chr) over(partition by i.r order by i.c) = '@', 1, 0)
									+ iif(lead(i.chr) over(partition by i.r order by i.c) = '@', 1, 0)
									+ iif(lag(i.chr) over(partition by i.r + i.c order by i.r) = '@', 1, 0)
									+ iif(lead(i.chr) over(partition by i.r + i.c order by i.r) = '@', 1, 0)
									+ iif(lag(i.chr) over(partition by i.r - i.c order by i.r) = '@', 1, 0)
									+ iif(lead(i.chr) over(partition by i.r - i.c order by i.r) = '@', 1, 0) Around
								from (select cast(json_value([value], '$.r') as int) r
											, cast(json_value([value], '$.c') as int) c
											, json_value([value], '$.h') chr
										from openjson(r.map)
									) i
								) i
							order by r, c
							for json path
							) map
						) m
		where r.map != m.map
	)
	, lst as
	(select top 1 *
		from rec
		order by step desc
	)
select (select count(*)
		from #Input
		where chr = '@'
		)
		-
		(select count(*)
			from lst
				cross apply openjson(map)
			where json_value([value], '$.h') = '@'
		) Solution2
option (maxrecursion 32767)