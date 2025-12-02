declare @Input varchar(max) = '11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124'

drop table if exists #Input
select ordinal, cast(parsename(n1, 2) as bigint) Num1, cast(parsename(n1, 1) as bigint) Num2
into #Input
from string_split(@Input, ',', 1)
	cross apply (select replace([value], '-', '.') n1) n

select sum([value]) Solution1
from #Input
	cross apply generate_series(Num1, Num2)
	cross apply (select cast([value] as varchar(100)) n1) n
	cross apply (select len(n1) l1) l
	cross apply (select left(n1, l1/2) p1, substring(n1, l1/2 + 1, l1/2) p2) p
where l1%2 = 0
	and p1 = p2

;with i as
	(select *, max(len(cast(Num2 as varchar(max)))) over() MaxLen
		from #Input
	)
select sum(v1.[value]) Solution2
from i
	cross apply generate_series(Num1, Num2) v1
	cross apply (select cast(v1.[value] as varchar(100)) n1) n
	cross apply (select len(n1) l1) l
where exists (select *
				from generate_series(cast(1 as int), cast(MaxLen/2 as int)) v2
				where l1 > v2.[value]
					and l1%v2.[value] = 0
					and n1 = replicate(left(n1, v2.[value]), l1/v2.[value])
			)