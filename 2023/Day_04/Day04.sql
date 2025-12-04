declare @Input varchar(max) =
'Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11'

drop table if exists #Input
drop table if exists #Cards
select *
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1)

select i.ordinal CardID, c.ordinal NumType, cast(n.[value] as int) Val
into #Cards
from #Input i
	cross apply string_split(replace(i.[value], ':', '|'), '|', 1) c
	cross apply string_split(trim(c.[value]), ' ', 0) n
where n.[value] not in ('Card', '')
	and c.ordinal in (2, 3)

--1
;with i1 as
	(select power(2, count(*) - 1) Score
		from #Cards m
		where m.NumType = 3
			and exists (select *
						from #Cards w
						where w.NumType = 2
							and w.CardID = m.CardID
							and w.Val = m.Val
						)
		group by CardID
	)
select sum(Score) Answer1
from i1

--2
select CardID, sum(isnull(Mtc, 0)) Score
into #ScoredCards
from #Cards m
	outer apply (select 1 Mtc
				from #Cards w
				where w.NumType = 2
					and w.CardID = m.CardID
					and w.Val = m.Val
				) s
where m.NumType = 3
group by CardID

;with rec as
	(select CardID, Score
		from #ScoredCards
		union all
		select i1.CardID, i1.Score Score
		from rec
			inner join #ScoredCards i1 on i1.CardID between rec.CardID + 1 and rec.CardID + rec.Score
	)
select count(*) Answer2
from rec
option (maxrecursion 32767)