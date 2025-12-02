drop table if exists #Input
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

select cast(ordinal as int) ordinal, left([value], 1) dir, cast(substring([value], 2, 1000) as int) steps
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1)

;with rec as
	(select cast(0 as int) step, cast(50 as int) loc
		union all
		select cast(i.ordinal as int), FinalPosition
		from rec r
			inner join #Input i on i.ordinal = r.step + 1
			cross apply (select cast(loc + iif(i.dir = 'L', -1, 1)*(i.steps%100) as int) BaseCalc) b
			cross apply (select (BaseCalc+100)%100 FinalPosition) f
	)
select count(*) Solution1
from rec
where loc = 0
option (maxrecursion 32767)

;with rec as
	(select cast(0 as int) step, cast(50 as int) loc, 0 Points
		union all
		select cast(i.ordinal as int), FinalPosition, iif((BaseCalc not between 1 and 99) and loc != 0, 1, 0) + i.steps/100
		from rec r
			inner join #Input i on i.ordinal = r.step + 1
			cross apply (select cast(loc + iif(i.dir = 'L', -1, 1)*(i.steps%100) as int) BaseCalc) b
			cross apply (select (BaseCalc+100)%100 FinalPosition) f
	)
select sum(Points) Solution2
from rec
option (maxrecursion 32767)