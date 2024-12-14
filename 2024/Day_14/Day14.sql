declare @Input varchar(max) =
'p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3'
	, @MaxX int = 11
	, @MaxY int = 7
drop table if exists #Input

select ordinal RobotID
	, cast(json_value(js, '$.p[0]') as int) RobotX
	, cast(json_value(js, '$.p[1]') as int) RobotY
	, cast(json_value(js, '$.v[0]') as int) VelX
	, cast(json_value(js, '$.v[1]') as int) VelY
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1) r
	cross apply (select replace(replace(r.[value], 'p=', '{"p":['), ' v=', '],"v":[') + ']}' js) j

;with Boundaries as
	(select 101 MaxX, 103 MaxY, 100 Sec)
	, Final as
	(select NewX, NewY
		from #Input
			cross join Boundaries
			cross apply (select (RobotX + Sec * VelX + Sec*MaxX)%MaxX NewX, (RobotY + Sec * VelY + Sec*MaxY)%MaxY NewY) n
	)
	, Quad as
	(select X1, X2, Y1, Y2, row_number() over(order by Y1, X1) ID
		from Boundaries
			cross apply(values(0, MaxX/2 - 1), (MaxX - MaxX/2, MaxX - 1)) qx(X1, X2)
			cross apply(values(0, MaxY/2 - 1), (MaxY - MaxY/2, MaxY - 1)) qy(Y1, Y2)
	),
	Totals as
	(select ID, count(*) cnt
		from Final
			inner join Quad on NewX between X1 and X2
							and NewY between Y1 and Y2
		group by ID
	)
select exp(sum(log(cnt))) Answer1
from Totals

;with Boundaries as
	(select 101 MaxX, 103 MaxY, 10000 MaxSec)
	, i as
	(select [value] Seconds, NewY, count(*) cnt, max(NewX) - min(NewX) XDiff
		from #Input
			cross join Boundaries
			cross apply generate_series(1, MaxSec, 1)
			cross apply (select (RobotX + [value] * VelX + [value]*MaxX)%MaxX NewX, (RobotY + [value] * VelY + [value]*MaxY)%MaxY NewY) n
		group by [value], NewY
		having count(*) = count(distinct concat(NewX, '.', NewY))
	)
select top 1 Seconds Answer2
from i
group by Seconds
order by sum(cnt) desc, min(XDiff), max(XDiff)