create or alter function fn_AOC_2025_08_MakeConnections(@Connections varchar(max),
														@Ordinal1 int,
														@Ordinal2 int
													) returns table
as
return with c as
			(select [value]
				from string_split(@Connections, '|') c
			)
			select cast(string_agg(Connections, '|') as varchar(max)) Connections
			from (select case when c.[value] like concat('%,', @Ordinal1, ',%')
									and c.[value] not like concat('%,', @Ordinal2, ',%')
								then concat(c.[value], @Ordinal2, ',')
							when c.[value] like concat('%,', @Ordinal2, ',%')
									and c.[value] not like concat('%,', @Ordinal1, ',%')
								then concat(c.[value], @Ordinal1, ',')
							else c.[value]
						end Connections
					from c
					union all
					select concat(',', @Ordinal1, ',', @Ordinal2, ',')
					where @Connections not like concat('%,', @Ordinal1, ',%')
						and @Connections not like concat('%,', @Ordinal2, ',%')
				) t
GO
create or alter function fn_AOC_2025_08_ConsolidateConnections(@Connections varchar(max),
																@FirstOrdinal varchar(10)
																) returns table
as
return with s as
			(select *
				from string_split(@Connections, '|', 1) o
			)
			, i as
			(select r.[value]
				from s i
					cross apply string_split(i.[value], ',') r
				where i.[value] like ',' + @FirstOrdinal + ',%'
					and r.[value] != ''
			)
			, j as
			(select o.ordinal, o.[value]
				from s o
				where o.[value] not like ',' + @FirstOrdinal + ',%'
					and exists (select *
									from i
									where o.[value] like concat('%,', i.[value], ',%')
								)
			)
		select string_agg(cast(iif(s.[value] like ',' + @FirstOrdinal + ',%'
								, u.[value]
								, s.[value]
							) as varchar(max)), '|') Connections
		from s
			outer apply (select concat(',', string_agg(u.[value], ',') within group(order by iif(u.[value] = @FirstOrdinal, 0, cast(u.[value] as int))), ',') [value]
							from (select distinct u.[value]
									from string_split(concat([value], (select string_agg(j.[value], ',')
																		from j
																		)
															), ',') u
									where u.[value] != ''
									) u
							where s.ordinal = 1
							) u
		where s.ordinal not in (select j.ordinal
								from j
								)
GO
declare @Input varchar(max) =
'162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689'

declare @ConnectionCount int = 1000

drop table if exists #Input
drop table if exists AOC_2025_Day08_Map
drop table if exists AOC_2025_Day08_Edges
drop table if exists #Routes
drop table if exists #Routes1
drop table if exists #UniqueOrdinals

create table AOC_2025_Day08_Map
	(ordinal int,
	x bigint,
	y bigint,
	z bigint
	) as node
create table AOC_2025_Day08_Edges as edge
create unique clustered index IX_AOC_2025_Day08_Map on AOC_2025_Day08_Map(ordinal)
create unique clustered index IX_AOC_2025_Day08_Edges on AOC_2025_Day08_Edges($from_id, $to_id)

;with input as
	(select r.ordinal, cast(parsename(point, 3) as bigint) x, cast(parsename(point, 2) as bigint) y, cast(parsename(point, 1) as bigint) z
		from string_split(replace(@Input, char(13), ''), char(10), 1) r
			cross apply (select replace(r.[value], ',', '.') point) p
	)
select i.ordinal, i.x, i.y, i.z, i1.ordinal ordinal1, i1.x x1, i1.y y1, i1.z z1, row_number() over(order by diff) rn, diff
into #Input
from Input i
	inner join Input i1 on i1.ordinal > i.ordinal
	cross apply (select sqrt(power(i1.x - i.x, 2) + power(i1.y - i.y, 2) + power(i1.z - i.z, 2)) diff) d

create unique clustered index IX_#Input on #Input(rn)

;with i as
	(select top(@ConnectionCount) *
		from #Input
		order by diff
	)
	, i1 as
	(select ordinal, x, y, z
		from i
		union
		select ordinal1, x1, y1, z1
		from i
	)
insert into AOC_2025_Day08_Map
select distinct ordinal, x, y, z
from i1

;with i as
	(select top(@ConnectionCount) *
		from #Input
		order by diff
	)
insert into AOC_2025_Day08_Edges
select a.$node_id, b.$node_id
from AOC_2025_Day08_Map a
	inner join i on i.ordinal = a.ordinal
	inner join AOC_2025_Day08_Map b on b.ordinal = i.ordinal1
union all
select a.$node_id, b.$node_id
from AOC_2025_Day08_Map a
	inner join i on i.ordinal1 = a.ordinal
	inner join AOC_2025_Day08_Map b on b.ordinal = i.ordinal

select i.ordinal,
	last_value(i1.ordinal) within group (graph path) last_ordinal
into #Routes
from AOC_2025_Day08_Map i,
	AOC_2025_Day08_Edges for path e,
	AOC_2025_Day08_Map for path i1
where match(shortest_path(i(-(e)->i1)+))

select ordinal, concat(ordinal, ',', string_agg(last_ordinal, ',')) Rt
into #Routes1
from #Routes
group by ordinal

;with i as
	(select *
		from #Routes1 r
		where not exists (select *
							from #Routes1 r1
							where r1.ordinal > r.ordinal
								and exists (select *
											from string_split(r.Rt, ',')
											intersect
											select *
											from string_split(r1.Rt, ',')
											)
						)
	)
	, i1 as
	(select top 3 *
		from i
			cross apply (select len(Rt) - len(replace(Rt, ',', '')) Ln) l
		order by Ln desc
	)
select exp(sum(log(Ln))) Solution1
from i1

--p2
;with u as
	(select ordinal
		from #Input
		union
		select ordinal1
		from #Input
	)
select count(*) Ordinals
into #UniqueOrdinals
from u

;with rec as
	(select rn, cast(concat(',', ordinal, ',', ordinal1, ',') as varchar(max)) Connections, i.ordinal, i.ordinal1, cast(ordinal as varchar(10)) first_ordinal
		from #Input i
		where rn = 1
		union all
		select i.rn, c.Connections, i.ordinal, i.ordinal1, r.first_ordinal
		from rec r
			inner join #Input i on i.rn = r.rn + 1
			cross apply fn_AOC_2025_08_MakeConnections(r.Connections, i.ordinal, i.ordinal1) m
			cross apply fn_AOC_2025_08_ConsolidateConnections(m.Connections, first_ordinal) c
		where not exists (select *
							from string_split(r.Connections, '|')
							where len([value]) - len(replace([value], ',', '')) - 1 >= (select Ordinals from #UniqueOrdinals)
						)
	)
	,  lst as
	(select top 1 ordinal, ordinal1
		from rec
		order by rn desc
	)
select i.x*i.x1 Solution2
from lst l
	inner join #Input i on i.ordinal = l.ordinal
					and i.ordinal1 = l.ordinal1
option (maxrecursion 32767)