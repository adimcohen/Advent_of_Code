declare @Str varchar(max) =
'Sensor at x=1638847, y=3775370: closest beacon is at x=2498385, y=3565515
Sensor at x=3654046, y=17188: closest beacon is at x=3628729, y=113719
Sensor at x=3255262, y=2496809: closest beacon is at x=3266439, y=2494761
Sensor at x=3743681, y=1144821: closest beacon is at x=3628729, y=113719
Sensor at x=801506, y=2605771: closest beacon is at x=1043356, y=2000000
Sensor at x=2933878, y=5850: closest beacon is at x=3628729, y=113719
Sensor at x=3833210, y=12449: closest beacon is at x=3628729, y=113719
Sensor at x=2604874, y=3991135: closest beacon is at x=2498385, y=3565515
Sensor at x=1287765, y=1415912: closest beacon is at x=1043356, y=2000000
Sensor at x=3111474, y=3680987: closest beacon is at x=2498385, y=3565515
Sensor at x=2823460, y=1679092: closest beacon is at x=3212538, y=2537816
Sensor at x=580633, y=1973060: closest beacon is at x=1043356, y=2000000
Sensor at x=3983949, y=236589: closest beacon is at x=3628729, y=113719
Sensor at x=3312433, y=246388: closest beacon is at x=3628729, y=113719
Sensor at x=505, y=67828: closest beacon is at x=-645204, y=289136
Sensor at x=1566406, y=647261: closest beacon is at x=1043356, y=2000000
Sensor at x=2210221, y=2960790: closest beacon is at x=2498385, y=3565515
Sensor at x=3538385, y=1990300: closest beacon is at x=3266439, y=2494761
Sensor at x=3780372, y=2801075: closest beacon is at x=3266439, y=2494761
Sensor at x=312110, y=1285740: closest beacon is at x=1043356, y=2000000
Sensor at x=51945, y=2855778: closest beacon is at x=-32922, y=3577599
Sensor at x=1387635, y=2875487: closest beacon is at x=1043356, y=2000000
Sensor at x=82486, y=3631563: closest beacon is at x=-32922, y=3577599
Sensor at x=3689149, y=3669721: closest beacon is at x=3481800, y=4169166
Sensor at x=2085975, y=2190591: closest beacon is at x=1043356, y=2000000
Sensor at x=712588, y=3677889: closest beacon is at x=-32922, y=3577599
Sensor at x=22095, y=3888893: closest beacon is at x=-32922, y=3577599
Sensor at x=3248397, y=2952817: closest beacon is at x=3212538, y=2537816'

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


declare @CheckY int = 2000000
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