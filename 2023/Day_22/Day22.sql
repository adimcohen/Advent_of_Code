use tempdb
drop table if exists AOC_2023_Day22_Children
drop table if exists AOC_2023_Day22_Relationships

create table AOC_2023_Day22_Children
	(ID int,
	x0 int,
	x1 int,
	y0 int,
	y1 int,
	z0 int,
	z1 int,
	ParentID int
	)

create table AOC_2023_Day22_Relationships
	(ID int,
	ParentID int,
	IsSingleParent bit
	)
GO
create or alter function fn_AOC_2023_Day22_GetFloorLevel(@Layout varchar(max)) returns table
as
return select (select c.ID ID, max(p.ground + p.height) + 1 ground, z1 - z0 height
				from openjson(@Layout) j
					cross apply (select cast(json_value(j.[value], '$.ID') as int) ID
										, cast(json_value(j.[value], '$.ground') as int) ground
										, cast(json_value(j.[value], '$.height') as int) height
								) p
					inner join AOC_2023_Day22_Children c on c.ParentID = p.ID
				group by c.ID, c.z0, c.z1
				for json path
			) layout
GO
create or alter function fn_AOC_2023_Day22_GetNewDisintegrated(@Disintegrated varchar(max)) returns table
as
return select string_agg(ID, ',') + ',' NewDisintegrated
		from (select ID
					from AOC_2023_Day22_Relationships s
					where @Disintegrated like concat('%,', s.ParentID, ',%')
						and not @Disintegrated like concat('%,', s.ID, ',%')
					except
					select ID
					from AOC_2023_Day22_Relationships s
					where not @Disintegrated like concat('%,', s.ParentID, ',%')
				) c
GO
declare @Input varchar(max) =
'1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9'

drop table if exists #Input
drop table if exists #Floored

select ordinal, cast(parsename(c0, 3) as int) x0, cast(parsename(c0, 2) as int) y0, cast(parsename(c0, 1) as int) z0,
	cast(parsename(c1, 3) as int) x1, cast(parsename(c1, 2) as int) y1, cast(parsename(c1, 1) as int) z1
into #Input
from string_split(replace(replace(@Input, ',', '.'), char(10), ''), char(13), 1) i
	cross apply (select charindex('~', i.[value], 1) ind) i1
	cross apply (select left(i.[value], ind - 1) c0, substring(i.[value], ind + 1, len(i.[value])) c1) i2

insert into AOC_2023_Day22_Children
select distinct i.ordinal, i.x0, i.x1, i.y0, i.y1, i.z0, i.z1, i1.parent_ordinal_id
from #Input i
	cross apply generate_series(i.x0, i.x1, 1) x
	cross apply generate_series(i.y0, i.y1, 1) y
	cross apply (select top 1 with ties i1.ordinal parent_ordinal_id
					from #Input i1
					where x.[value] between i1.x0 and i1.x1
							and  y.[value] between i1.y0 and i1.y1
							and i1.z1 < i.z0
					order by i1.z1 desc
				) i1

;with rec as
	(select 0 lvl, (select ordinal ID, 1 ground, z1 - z0 height
					from #Input
					where ordinal not in (select ID
											from AOC_2023_Day22_Children
										)
					for json path
					) layout
		union all
		select r.Lvl + 1, n.layout
		from rec r
			cross apply fn_AOC_2023_Day22_GetFloorLevel(layout) n
		where n.layout is not null
	)
select ID, max(ground) ground
into #Floored
from rec
	cross apply openjson(layout) j
	cross apply (select cast(json_value(j.[value], '$.ID') as int) ID
						, cast(json_value(j.[value], '$.ground') as int) ground
				) p
group by ID
option (maxrecursion 32767)

;with i as
	(select i.ordinal, x0, x1, y0, y1, ground z0, ground + z1 - z0 z1
		from #Input i
			inner join #Floored f on f.ID = i.ordinal
	)
	, i1 as
	(select distinct i.ordinal, i.x0, i.x1, i.y0, i.y1, i.z0, i.z1, i1.parent_ordinal_id
		from i
			outer apply (select top 1 with ties i1.ordinal parent_ordinal_id
							from i i1
							where (i1.x0 between i.x0 and i.x1 or i.x0 between i1.x0 and i1.x1)
									and  (i1.y0 between i.y0 and i.y1 or i.y0 between i1.y0 and i1.y1)
									and i1.z1 < i.z0
							order by i1.z1 desc
						) i1
	)
	, i2 as
		(select *, count(*) over(partition by ordinal) Parents
			from i1
		)
insert into AOC_2023_Day22_Relationships
select ordinal, parent_ordinal_id, iif(min(Parents) over(partition by parent_ordinal_id) = 1, 1, 0)
from i2

--1
select count(*) Answer1
from #Input i
where not exists (select *
					from AOC_2023_Day22_Relationships r
					where r.ParentID = i.ordinal
						and r.IsSingleParent = 1
				)

--2
;with rec as
	(select distinct 0 lvl, ParentID, cast(concat(',', ParentID, ',') as varchar(max)) Disintegrated, cast(null as varchar(max)) NewDisintegrated
		from AOC_2023_Day22_Relationships
		where IsSingleParent = 1
			and ParentID is not null
		union all
		select lvl + 1, ParentID, cast(concat(Disintegrated, n.NewDisintegrated) as varchar(max)) Disintegrated, cast(n.NewDisintegrated as varchar(max))
		from rec r
			cross apply fn_AOC_2023_Day22_GetNewDisintegrated(Disintegrated) n
		where n.NewDisintegrated is not null
	)
	, i as
	(select distinct ParentID, last_value(Disintegrated) over(partition by ParentID order by lvl rows between unbounded preceding and unbounded following) Disintegrated
		from rec
	)
select sum(len(Disintegrated) - len(replace(Disintegrated, ',', '')) - 2) Answer2
from i
option (maxrecursion 32767)