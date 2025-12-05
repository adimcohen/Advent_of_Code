--Only works for real input
declare @Input varchar(max) =
'19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3'
	, @FrameMin bigint = 200000000000000
	, @FrameMax bigint = 400000000000000

drop table if exists #Input

select ordinal id, cast(parsename(p, 3) as bigint) x, cast(parsename(p, 2) as bigint) y, cast(parsename(p, 1) as bigint) z
	, cast(parsename(v, 3) as int) vx, cast(parsename(v, 2) as int) vy, cast(parsename(v, 1) as int) vz
into #Input
from string_split(replace(replace(replace(@Input, ',', '.'), ' ', ''), char(10), ''), char(13), 1) i
	cross apply (select charindex('@', i.[value], 1) ind) i1
	cross apply (select left(i.[value], ind - 1) p
					, substring(i.[value], ind + 1, len(i.[value])) v
				) vp

--1
;with FramePoly as
	(select geometry::STGeomFromText(concat(N'POLYGON((', @FrameMin, ' ', @FrameMin, ',', @FrameMin, ' ', @FrameMax, ',', @FrameMax, ' ', @FrameMax, ',', @FrameMax, ' ', @FrameMin, ',', @FrameMin, ' ', @FrameMin, '))'), 0) fp
	)
	, i as
	(select id, x x1, y y1, x + vx*duration x2, y + vy*duration y2
		from #Input
			cross apply (select cast(greatest((@FrameMin - x)/vx, (@FrameMax - x)/vx, (@FrameMin - y)/vy, (@FrameMax - y)/vy) as decimal(20, 5)) duration) d
	)
	, i2 as
	(select id, geometry::STGeomFromText(concat(N'LINESTRING(', x1, ' ', y1, ',', x2, ' ', y2, ')'), 0) line
		from i
	)
select count(*) Answer1
from i2 a
	inner join i2 b on b.id > a.id
					and b.line.STIntersects(a.line) = 1
where exists (select *
				from FramePoly
				where fp.STContains(a.line.STIntersection(b.line)) = 1
			)

--2
;with x as
	(select top 1 [value] vx, count(*) over(partition by [value]) cnt
		from #Input a
			inner join #Input b on b.id > a.id
								and b.vx = a.vx
			cross apply (select b.x - a.x diff) i
			cross join generate_series(-1000, 1000, 1)
		where abs(a.vx) > 100
			and [value] != a.vx
			and Diff % ([value] - a.vx) = 0
		order by cnt desc
	)
	, y as
	(select top 1 [value] vy, count(*) over(partition by [value]) cnt
		from #Input a
			inner join #Input b on b.id > a.id
								and b.vy = a.vy
			cross apply (select b.y - a.y diff) i
			cross join generate_series(-1000, 1000, 1)
		where abs(a.vy) > 100
			and [value] != a.vy
			and Diff % ([value] - a.vy) = 0
		order by cnt desc
	)
	, z as
	(select top 1 [value] vz, count(*) over(partition by [value]) cnt
		from #Input a
			inner join #Input b on b.id > a.id
								and b.vz = a.vz
			cross apply (select b.z - a.z diff) i
			cross join generate_series(-1000, 1000, 1)
		where abs(a.vz) > 100
			and [value] != a.vz
			and Diff % ([value] - a.vz) = 0
		order by cnt desc
	)
	, r as
	(select vx, vy, vz
		from x
			cross join y
			cross join z
	)
select i2.x + i3.y + i4.z Answer2
from r
	cross join (select top 1 *
				from #Input
				order by ID
				) a
	cross join (select top 1 *
				from #Input
				order by ID desc
				) b
	cross apply (select cast(cast((a.vy - r.vy) as decimal(18, 10))/(a.vx - r.vx) as decimal(18, 16)) ma
						, cast(cast((b.vy - r.vy) as decimal(18, 10))/(b.vx - r.vx) as decimal(18, 16)) mb
				) i
	cross apply (select cast(a.y - (ma*a.x) as decimal(20, 2)) ca
						, cast(b.y - (mb*b.x) as decimal(20, 2)) cb
				) i1
	cross apply (select cast(round((cb-ca)/(ma-mb), 0) as bigint) x) i2
	cross apply (select i2.x, cast(round(ma*i2.x + ca, 0) as bigint) y
						, (i2.x - a.x)/(a.vx-r.vx) t) i3
	cross apply (select a.z + (a.vz - r.vz)*t z) i4