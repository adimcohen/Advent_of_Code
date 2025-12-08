create or alter function fn_AOC_2025_07_GetBeams(@Line varchar(max)
												, @Beams varchar(max)
												) returns table
as
return select (select cast(string_agg(t.[value], ',') as varchar(max))
				from (select distinct [value]
							from string_split(Beams, ',')
						) t
				) Beams, SplitCount
		from (select cast(string_agg(s.NewBeam, ',') as varchar(max)) Beams, cast(count(distinct iif(h.chr = '^', b.[value], null)) as int) SplitCount
				from string_split(@Beams, ',') b
					cross apply (select substring(@Line, cast(b.[value] as int), 1) chr) h
					cross apply (values(b.[value], '.')
										, (b.[value] + 1, '^')
										, (b.[value] - 1, '^')
										) s(NewBeam, chr)
				where s.chr = h.chr
				) s
GO
create or alter function fn_AOC_2025_07_GetBeams_p2(@Line varchar(max)
													, @Beams varchar(max)
													) returns table
as
return select string_agg(cast(concat(NewBeam, '.', cnt) as varchar(max)), ',') Beams
		from (select NewBeam, sum(cnt) cnt
				from string_split(@Beams, ',') b
					cross apply (select cast(parsename(b.[value], 2) as int) beam, cast(parsename(b.[value], 1) as bigint) cnt) p
					cross apply (select substring(@Line, beam, 1) chr) h
					cross apply (values(beam, '.')
										, (beam + 1, '^')
										, (beam - 1, '^')
										) s(NewBeam, chr)
				where s.chr = h.chr
				group by NewBeam
			) s
GO
declare @Input varchar(max) =
'.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............'
drop table if exists #Input

select r.ordinal r, r.[value] Val
into #Input
from string_split(replace(@Input, char(13), ''), char(10), 1) r

;with rec as
	(select r, cast(charindex('S', Val, 1) as varchar(max)) Beams, cast(0 as int) SplitCount
		from #Input
		where Val like '%S%'
		union all
		select i.r, s.Beams, s.SplitCount
		from rec r
			inner join #Input i on i.r = r.r + 1
			cross apply fn_AOC_2025_07_GetBeams(i.Val, r.Beams) s
	)
select sum(SplitCount) Solution1
from rec r
option (maxrecursion 32767)

;with rec as
	(select r, cast(concat(charindex('S', Val, 1), '.1') as varchar(max)) Beams
		from #Input
		where Val like '%S%'
		union all
		select i.r, s.Beams
		from rec r
			inner join #Input i on i.r = r.r + 1
			cross apply fn_AOC_2025_07_GetBeams_p2(i.Val, r.Beams) s
	)
	, lst as
	(select top 1 *
		from rec
		order by r desc
	)
select sum(cnt) Solution2
from lst
	cross apply string_split(Beams, ',') b
	cross apply (select cast(parsename(b.[value], 1) as bigint) cnt) p
option (maxrecursion 32767)