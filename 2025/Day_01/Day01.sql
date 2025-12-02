declare @Input varchar(max) =
'L68
L30
R48
L5
R60
L55
L1
L99
R14
L82'

drop table if exists #Input
select cast(ordinal as int) ordinal, left([value], 1) dir, cast(substring([value], 2, 1000) as int) steps
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1)

;with i as
	(select *
		from #Input
		union all
		select 0, '', 50
	)
	, i1 as
	(select *, sum(iif(dir = 'L', -1, 1)*steps) over(order by ordinal rows between unbounded preceding and current row)%100 FinalPosition
		from i
	)
select count(*) Solution1
from i1
where FinalPosition = 0

;with i as
	(select *
		from #Input
		union all
		select 0, '', 50
	)
	, i1 as
	(select *
			, sum(Mov) over(order by ordinal rows between unbounded preceding and current row) BaseCalc
		from i
			cross apply (select iif(dir = 'L', -1, 1)*(steps%100) Mov) m
	)
	, i2 as
	(select *
			, lag(FinalPosition) over(order by ordinal) LastFinal
		from i1
			cross apply (select (BaseCalc+10000)%100 FinalPosition) f
	)
select sum(iif((LastFinal + Mov not between 1 and 100 and LastFinal != 0) or FinalPosition = 0, 1, 0)) + sum(steps/100) Solution2
from i2