declare @Input varchar(max) = '19391-47353,9354357-9434558,4646427538-4646497433,273-830,612658-674925,6639011-6699773,4426384-4463095,527495356-527575097,22323258-22422396,412175-431622,492524-611114,77-122,992964846-993029776,165081-338962,925961-994113,7967153617-7967231799,71518058-71542434,64164836-64292066,4495586-4655083,2-17,432139-454960,4645-14066,6073872-6232058,9999984021-10000017929,704216-909374,48425929-48543963,52767-94156,26-76,1252-3919,123-228'

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
	, i1 as
	(select distinct ordinal, v1.[value]
		from i
			cross apply generate_series(Num1, Num2) v1
			cross apply (select cast(v1.[value] as varchar(100)) n1) n
			cross apply (select len(n1) l1) l
			cross apply generate_series(cast(1 as int), cast(MaxLen/2 as int)) v2
		where l1 > v2.[value]
			and l1%v2.[value] = 0
			and n1 = replicate(left(n1, v2.[value]), l1/v2.[value])
	)
select sum([value])
from i1