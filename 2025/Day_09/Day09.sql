declare @Input varchar(max) =
'7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3'

drop table if exists #Input
drop table if exists #w
drop table if exists #Rectangles

select ordinal rn, x, y
into #Input
from string_split(replace(replace(@Input, char(13), ''), ',', '.'), char(10), 1) r
	cross apply (select cast(parsename(r.[value], 2) as bigint) x, cast(parsename(r.[value], 1) as bigint) y) p

select max((abs(i1.x - i.x) + 1) * (abs(i1.y - i.y) + 1)) Solution1
from #Input i
	inner join #Input i1 on i1.rn != i.rn

--p2
;with i as
	(select *
			, isnull(lead(x) over(order by rn)
					, first_value(x) over(order by rn rows between unbounded preceding and current row)
					) x1
			, isnull(lead(y) over(order by rn)
					, first_value(y) over(order by rn rows between unbounded preceding and current row)
					) y1
		from #Input
	)
	, p
	as
	(select string_agg(cast(concat(x, ' ', y) as varchar(max)), ',') within group(order by rn) pol
		from i
	)
	, w as
	(select geometry::STGeomFromText(concat('POLYGON((', pol
			+ (select concat(',', x, ' ', y)
				from i
				where rn = 1
			), '))'), 0).STBuffer(0.01) Whole
		from p
	)
select *
into #w
from w

select rectangle
	, (abs(i1.x - i.x) + 1) * (abs(i1.y - i.y) + 1) area
into #Rectangles
from #Input i
	inner join #Input i1 on i1.rn != i.rn
	cross apply (select geometry::STGeomFromText(concat(N'POLYGON((', i.x, ' ', i.y, ',', i.x, ' ', i1.y, ',', i1.x, ' ', i1.y, ',', i1.x, ' ', i.y, ',', i.x, ' ', i.y, '))'), 0).MakeValid() rectangle) p

select max(area) Solution2
from #Rectangles
where exists (select *
				from #w
				where Whole.STContains(rectangle) = 1
			)