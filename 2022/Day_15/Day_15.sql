declare @Str varchar(max) =
'Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3'

drop table if exists #Numbers
--Create a numbers table - never leave home without one
;with rec as
	(select 1 Num
	union all
	select Num + 1
	from rec
	where Num < 32767
	)
select Num
into #Numbers
from rec
option (maxrecursion 32767)
create unique clustered index IX_#Numbers on #Numbers(Num)

drop table if exists #Input
drop table if exists #Covered
select cast(json_value(js, '$[0][0]') as bigint) SensorX, cast(json_value(js, '$[0][1]') as bigint) SensorY, cast(json_value(js, '$[1][0]') as bigint) BeaconX, cast(json_value(js, '$[1][1]') as bigint) BeaconY
into #Input
from string_split(replace(@Str, char(13), ''), char(10))
	cross apply (select '[' + replace(replace(replace([value], 'Sensor at x=', '['), 'y=', ''), ': closest beacon is at x=', '],[') + ']' + ']' js) j


declare @CheckY int = 10
;with Input as
	(select row_number() over(order by (select 1)) ID, i.*, Distance
		from #Input i
			cross apply (select abs(SensorX - BeaconX) + abs(SensorY - BeaconY) Distance) d
	)
	, Polygons as
	(select ID, geometry::STGeomFromText(concat(N'POLYGON((', NorthX, N' ', NorthY, N',', EastX, N' ', EastY, N',', SouthX, N' ', SouthY, N',', WestX, N' ', WestY, N',', NorthX, N' ', NorthY, '))'), 0) Pol
		from Input
			cross apply (select SensorX NorthX, SensorY - Distance NorthY,
								SensorX SouthX, SensorY + Distance SouthY,
								SensorX - Distance EastX, SensorY EastY,
								SensorX + Distance WestX, SensorY WestY
						) Points
	)
	, rec as
	(select ID, Pol
	from Polygons
	where ID = 1
	union all
	select p.ID, r.Pol.STUnion(p.Pol)
	from rec r
		inner join Polygons p on p.ID = r.ID + 1
	)
	, Lst as
	(select top 1 Pol
		from rec
		order by ID desc
	),
	MinMaxX as
	(select min(SensorX - Distance) MinX, max(SensorX + Distance) MaxX
		from Input
	)
select round(abs(Pol.STIntersection(CrossLine).STPointN(1).STX - Pol.STIntersection(CrossLine).STPointN(Pol.STIntersection(CrossLine).STNumPoints()).STX), 0) Answer1
from Lst
	cross join MinMaxX
	cross apply (select geometry::STGeomFromText(concat(N'LINESTRING(', MinX, N' ', @CheckY, N',', MaxX, N' ', @CheckY, N')'), 0) CrossLine) l

declare @Min int = 0,
		@Max int = 4000000,
		@Multiplier int = 4000000
;with Polygons as
	(select row_number() over(order by (select 1)) ID, geometry::STGeomFromText(concat(N'POLYGON((', NorthX, N' ', NorthY, N',', EastX, N' ', EastY, N',', SouthX, N' ', SouthY, N',', WestX, N' ', WestY, N',', NorthX, N' ', NorthY, '))'), 0) Pol
		from #Input
			cross apply (select abs(SensorX - BeaconX) + abs(SensorY - BeaconY) Distance) d
			cross apply (select SensorX NorthX, SensorY - Distance NorthY,
								SensorX SouthX, SensorY + Distance SouthY,
								SensorX - Distance EastX, SensorY EastY,
								SensorX + Distance WestX, SensorY WestY
						) Points
	)
	, rec as
	(select ID, Pol
	from Polygons
	where ID = 1
	union all
	select p.ID, r.Pol.STUnion(p.Pol)
	from rec r
		inner join Polygons p on p.ID = r.ID + 1
	)
	, Lst as
	(select top 1 Pol
		from rec
		order by ID desc
	)
select top 1 cast(round(X, 0) as bigint)*cast(@Multiplier as bigint) + cast(round(Y, 0) as bigint) Answer2
from Lst
	cross apply (select geometry::STGeomFromText(N'MULTIPOLYGON(' + string_agg(Pol, ',') + ')', 0).MakeValid() MultiPol
					from (select row_number() over(order by (select 1)) ID, iif(left([value], 1) = ',', '(' + stuff([value], 1, 2, ''), replace([value], 'POLYGON ', ''))+ '))' Pol
							from string_split(Pol.ToString(), ')')
							where [value] <> ''
						) t
					where ID > 1
				) s
	inner join #Numbers n on n.Num between 1 and MultiPol.STNumGeometries()
	cross apply (select MultiPol.STGeometryN(n.Num).STCentroid() Point) p
	cross apply (select Point.STX X, Point.STY Y) xy
where X between @Min and @Max
	and Y between @Min and @Max
	and round(MultiPol.STGeometryN(n.Num).STArea(), 0) >= 1
order by abs(cast(X as decimal(36, 20)) - cast(round(X, 0) as int)),
	abs(cast(Y as decimal(36, 20)) - cast(round(Y, 0) as int))