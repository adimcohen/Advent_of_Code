declare @Input varchar(max) =
'seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4'

drop table if exists #Numbers
drop table if exists #Input
drop table if exists #json
drop table if exists #Maps
drop table if exists #Seeds
drop table if exists #Seeds1
drop table if exists #Route

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

select s.ordinal - 1 SeedOrdinal, cast(s.[value] as bigint) SeedID
into #Seeds
from #Input i
	cross apply string_split([value], ' ', 1) s
where i.ordinal = 1
	and s.ordinal > 1

;with i as
	(select *, isnumeric(left([value], 1)) IsNum
		from #Input
		where [value] != ''
			and ordinal > 1
	)
	, i1 as
	(select *, iif(isnull(lag(IsNum, 1) over(order by ordinal), 0) = 0, 1, 0) IsStart
			, iif(isnull(lead(IsNum, 1) over(order by ordinal), 0) = 0, 1, 0) IsEnd
		from i
	)
select '{'
	+ string_agg(
	iif(IsStart = 0, ',', '')
	+ iif(IsNum = 0
			, concat('"', ordinal, '": [')
			, '[' + replace([value], ' ', ',') + ']' + iif(IsEnd = 1, ']', '')
			)
		, '') within group (order by ordinal)
	+ '}' j
into #json
from i1

;with i as
	(select row_number() over(order by cast([key] as int)) MapType, [value] Ranges
		from #json
			cross apply openjson(j)
	)
select MapType
	, cast(json_value(r.[value], '$[1]') as bigint) SrcStart
	, cast(json_value(r.[value], '$[0]') as bigint) DstStart
	, cast(json_value(r.[value], '$[2]') as bigint) RangeLength
into #Maps
from i
	cross apply openjson(Ranges) r
--1
;with rec as
	(select 0 Lvl, SeedID, SeedID ItemID
		from #Seeds
		union all
		select rec.Lvl + 1 Lvl, rec.SeedID, i.ItemID
		from rec
			outer apply (select *
							from #Maps m
							where m.MapType = rec.Lvl + 1
								and rec.ItemID between m.SrcStart and m.SrcStart + m.RangeLength - 1
						) m
			cross apply (select isnull(m.DstStart + rec.ItemID - m.SrcStart, rec.ItemID) ItemID) i
		where rec.Lvl < 7
	)
select min(ItemID) Answer1
from rec
where rec.Lvl = 7
option (maxdop 1)

--2
;with Seeds as
	(select *, lead(SeedID) over(order by SeedOrdinal) Rng
		from #Seeds
	)
	, rec as
	(select 0 Lvl, SeedID, SeedID ItemID, Rng
		from Seeds
		where SeedOrdinal % 2 = 1
		union all
		select rec.Lvl + 1 Lvl, rec.SeedID, i1.ItemID, i1.Rng
		from rec
			outer apply (select *
							from #Maps m
							where m.MapType = rec.Lvl + 1
								and (m.SrcStart between rec.ItemID and rec.ItemID + rec.Rng - 1
									or m.SrcStart + m.RangeLength - 1 between rec.ItemID and rec.ItemID + rec.Rng - 1
									or rec.ItemID between m.SrcStart and m.SrcStart + m.RangeLength - 1
									)
						) m
			cross apply (select greatest(m.SrcStart, rec.ItemID) SourceItemID) i
			cross apply (select isnull(SourceItemID - m.SrcStart + m.DstStart, rec.ItemID) ItemID
								, iif(m.SrcStart is not null, isnull(nullif(least(m.SrcStart + m.RangeLength - 1, rec.ItemID + rec.Rng - 1) - SourceItemID, 0), 1), rec.Rng) Rng) i1
		where rec.Lvl < 7
	)
select min(ItemID) Answer2
from rec
where rec.Lvl = 7
option (maxdop 1)