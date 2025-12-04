declare @Input varchar(max) =
'0 3 6 9 12 15
1 3 6 10 15 21
10 13 16 21 30 45'

drop table if exists #Input
drop table if exists #Step1

select s.ordinal SeqID, cast('[' + replace(s.[value], ' ', ',') + ']' as varchar(max)) Nums
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1) s

;with rec as
	(select 1 Gen, SeqID, Nums
		from #Input
		union all
		select r.Gen + 1, r.SeqID, i.Nums
		from rec r
			cross apply (select cast(replace(replace(
								(select cast(i1.[value] as int) - cast(i.[value] as int) v
									from openjson(r.Nums) i
										inner join openjson(r.Nums) i1 on cast(i1.[key] as int) = cast(i.[key] as int) + 1
									order by cast(i.[key] as int)
									for json path
								)
								, '{"v":', ''), '}', '') as varchar(max)) Nums
						) i
		where exists (select *
						from openjson(r.Nums) j
						where j.[value] != '0'
					)
	)
select *, len(Nums) - len(replace(Nums, ',', '')) MaxKey
into #Step1
from rec

--1
;with i as
	(select *, max(Gen) over(partition by SeqID) MaxGen
		from #Step1
	)
	, rec as
	(select Gen, SeqID, cast(0 as int) NewNumber
		from i
		where Gen = MaxGen
		union all
		select s.Gen, r.SeqID, LastVal + NewNumber NewNumber
		from rec r
			inner join #Step1 s on s.SeqID = r.SeqID
									and s.Gen = r.Gen - 1
			cross apply (select cast([value] as int) LastVal
							from openjson(s.Nums) j
							where j.[key] = s.MaxKey
						) j
	)
select sum(NewNumber) Answer1
from rec
where Gen = 1

--2
;with i as
	(select *, max(Gen) over(partition by SeqID) MaxGen
		from #Step1
	)
	, rec as
	(select Gen, SeqID, cast(0 as int) NewNumber
		from i
		where Gen = MaxGen
		union all
		select s.Gen, r.SeqID, j.LastVal - r.NewNumber NewNumber
		from rec r
			inner join #Step1 s on s.SeqID = r.SeqID
									and s.Gen = r.Gen - 1
			cross apply (select cast([value] as int) LastVal
							from openjson(s.Nums) j
							where j.[key] = 0
						) j
	)
select sum(NewNumber) Answer2
from rec
where Gen = 1