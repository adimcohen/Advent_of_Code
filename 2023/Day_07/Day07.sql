declare @Input varchar(max) =
'32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483'

drop table if exists #Input

select ordinal Hand, c.[value] CardID, replace(replace(replace(replace(replace(substring(json_value(j, '$[0]'), c.[value], 1), 'T', '10'), 'J', '11'), 'Q', '12'), 'K', '13'), 'A', '14') CardVal, json_value(j, '$[1]') Bid
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1) s
	cross apply (select '["' + replace(s.[value], ' ', '",') + ']' j) i
	cross join generate_series(1, 5, 1) c
order by ordinal, c.[value]

--1
;with i as
	(select Hand, CardVal, count(*) ValueCount
		from #Input
		group by Hand, CardVal
	)
	, i1 as
	(select Hand, ValueCount, sum(iif(ValueCount > 1, 1, 0)) SameCount
		from i
		group by Hand, ValueCount
	)
	, i2 as
	(select Hand, max(ValueCount) MaxValCount, sum(SameCount) SumSame
		from i1
		group by Hand
	)
	, i3 as
	(select Hand,
			case when MaxValCount = 5 then 7
				when MaxValCount = 4 then 6
				when MaxValCount = 3 and SumSame = 2 then 5
				when MaxValCount = 3 then 4
				when MaxValCount = 2 and SumSame = 2 then 3
				when MaxValCount = 2 then 2
				else 1
			end HandValue
		from i2
	)
	, i4 as
	(select Bid * row_number() over(order by HandValue, Cards) HandWorth
		from i3
			cross apply (select string_agg(char(CardVal), '') within group (order by CardID) Cards, Bid
							from #Input i
							where i.Hand = i3.Hand
							group by Bid
						) i
	)
select sum(HandWorth) Answer1
from i4

--2
;with i as
	(select Hand, CardID, iif(CardVal = 11, 1, CardVal) CardVal, Bid
		from #Input
	)
	, i1 as
	(select Hand, CardVal, count(*) ValueCount
		from i
		group by Hand, CardVal
	)
	, i2 as
	(select Hand, iif(CardVal > 1, ValueCount, 0) ValueCount, sum(iif(ValueCount > 1, 1, 0)) SameCount, sum(iif(CardVal = 1, ValueCount, 0)) JokerCount
		from i1
		group by Hand, iif(CardVal > 1, ValueCount, 0)
	)
	, i3 as
	(select Hand, max(ValueCount) MaxValCount, sum(SameCount) SumSame, sum(JokerCount) JokerCount
		from i2
		group by Hand
	)
	, i4 as
	(select Hand,
			case when MaxValCount + JokerCount = 5 then 7
				when MaxValCount + JokerCount = 4 then 6
				when MaxValCount + JokerCount = 3 and SumSame = 2 then 5
				when MaxValCount + JokerCount = 3 then 4
				when MaxValCount + JokerCount = 2 and SumSame = 2 then 3
				when MaxValCount + JokerCount = 2 then 2
				else 1
			end HandValue
		from i3
	)
	, i5 as
	(select Bid * row_number() over(order by HandValue, Cards) HandWorth
		from i4
			cross apply (select string_agg(char(CardVal), '') within group (order by CardID) Cards, Bid
							from i
							where i.Hand = i4.Hand
							group by Bid
						) i
	)
select sum(HandWorth) Answer2
from i5