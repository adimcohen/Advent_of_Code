declare @Input varchar(max) =
'Time:      7  15   30
Distance:  9  40  200'

drop table if exists #Input
;with i as
	(select t.ordinal tid, n.ordinal rid, cast(n.[value] as int) val
		from string_split(replace(@Input, char(10), ''), char(13), 1) t
			cross apply string_split(replace(replace(replace(t.[value], '  ', ' ^'), '^ ', ''), '^', ''), ' ', 1) n
		where n.[value] <> ''
			and n.ordinal > 1
	)
select i.rid Race, i.val Tme, i1.val Distance
into #Input
from i
	inner join i i1 on i1.rid = i.rid
where i.tid = 1
	and i1.tid = 2
option (maxdop 1)

--1
;with i as
	(select count(*) Wins
		from #Input
			cross apply generate_series(1, Tme, 1)
		where (Tme - [value]) * [value] > Distance
		group by Race
	)
select exp(sum(log(Wins*1.))) Answer1
from i
option (maxdop 1)

--2
;with i as
	(select cast(string_agg(Tme, '') within group (order by Race) as bigint) Tme, cast(string_agg(Distance, '') within group (order by Race) as bigint) Distance
		from #Input
	)
select ceiling(abs((-Tme - sqrt(power(Tme, 2) - 4*Distance))*1./2)) - ceiling(abs((-Tme + sqrt(power(Tme, 2) - 4*Distance))*1./2)) Answer2
from i