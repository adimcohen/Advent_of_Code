declare @Str varchar(max) =
'2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5'

drop table if exists #Input
drop table if exists #Missing
drop table if exists #Exposed
drop table if exists #DirectlyExposed
drop table if exists #Numbers

--Number Table
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

select row_number() over(order by (select 1)) ID,
	cast(json_value(Val, '$[0]') as int) X,
	cast(json_value(Val, '$[1]') as int) Y,
	cast(json_value(Val, '$[2]') as int) Z
into #Input
from string_split(replace(@Str, char(13), ''), char(10))
	cross apply (select '[' + [value] + ']' Val) v

create unique clustered index IX_#Input on #Input(X, Y, Z)

select (select count(*) *6
		from #Input
		)
		-
		(select count(*)
			from #Input a
				inner join #Input b on ((b.X = a.X and b.Y = a.Y and abs(b.Z - a.Z) = 1)
										or (b.X = a.X and b.Z = a.Z and abs(b.Y - a.Y) = 1)
										or (b.Y = a.Y and b.Z = a.Z and abs(b.X - a.X) = 1))
		) Answer1

;with i as
	(select min(X) MinX, max(X) MaxX, min(Y) MinY, max(Y) MaxY, min(Z) MinZ, max(Z) MaxZ
		from #Input
	)
select nx.Num X, ny.Num Y, nz.Num Z
into #Missing
from i
	inner join #Numbers nx on nx.Num between MinX and MaxX
	inner join #Numbers ny on ny.Num between MinY and MaxY
	inner join #Numbers nz on nz.Num between MinZ and MaxZ
except
select X, Y, Z
from #Input

create unique clustered index IX_#Missing on #Missing(X, Y, Z)
create unique index IX_#Missing1 on #Missing(Y, X, Z)
create unique index IX_#Missing2 on #Missing(Y, Z, X)

;with DirectlyExposed as
	(select X, Y, Z
		from #Missing m
		where not exists (select *
							from #Input i
							where (i.X = m.X and i.Y = m.Y and i.Z > m.Z)
						)
			or not exists (select *
							from #Input i
							where (i.X = m.X and i.Z = m.Z and i.Y > m.Y)
						)
			or not exists (select *
							from #Input i
							where (i.Y = m.Y and i.Z = m.Z and i.X > m.X)
						)
			or not exists (select *
							from #Input i
							where (i.X = m.X and i.Y = m.Y and i.Z < m.Z)
						)
			or not exists (select *
							from #Input i
							where (i.X = m.X and i.Z = m.Z and i.Y < m.Y)
						)
			or not exists (select *
							from #Input i
							where (i.Y = m.Y and i.Z = m.Z and i.X < m.X)
						)
	)
select *
into #DirectlyExposed
from DirectlyExposed
create unique clustered index IX_#DirectlyExposed on #DirectlyExposed(X, Y, Z)

;with Maxes as
	(select min(X) MinX, max(X) MaxX, min(Y) MinY, max(Y) MaxY, min(Z) MinZ, max(Z) MaxZ
		from #Input
	)
	, rec as
	(select X, Y, Z, cast(';' + Point + ';' as varchar(max)) Visited, cast(0 as int) Lvl
		from #DirectlyExposed
			cross apply (select concat(X, ',', Y, ',', Z) Point) p
			cross join Maxes
		union all
		select m.X, m.Y, m.Z, r.Visited + Point + ';', r.Lvl + 1
		from rec r
			inner join #Missing m with (forceseek) on ((m.X = r.X and m.Y = r.Y and abs(m.Z - r.Z) = 1)
													or (m.X = r.X and m.Z = r.Z and abs(m.Y - r.Y) = 1)
													or (m.Y = r.Y and m.Z = r.Z and abs(m.X - r.X) = 1))
			cross apply (select concat(m.X, ',', m.Y, ',', m.Z) Point) p
		where r.Visited not like '%;' + Point + ';%'
			and not exists (select *
							from #DirectlyExposed d
							where d.X = m.X
								and d.Y = m.Y
								and d.Z = m.Z
							)
	)
select distinct X, Y, Z
into #Exposed
from rec
option (maxrecursion 32767)

;with Maxes as
	(select X, Y, Z,
		min(X) over(partition by Y, Z) MinX,
		max(X) over(partition by Y, Z) MaxX,
		min(Y) over(partition by X, Z) MinY,
		max(Y) over(partition by X, Z) MaxY,
		min(Z) over(partition by X, Y) MinZ,
		max(Z) over(partition by X, Y) MaxZ
	from #Input
	)
	, Ext as
	(select distinct X, Y, MinZ Z
		from Maxes m
		where not exists (select *
							from #Exposed e
							where e.X = m.X
								and e.Y = m.Y
								and e.Z < MinZ)
		union all
		select distinct X, Y, MaxZ Z
		from Maxes m
		where not exists (select *
							from #Exposed e
							where e.X = m.X
								and e.Y = m.Y
								and e.Z > MaxZ)
		union all
		select distinct X, MinY, Z
		from Maxes m
		where not exists (select *
							from #Exposed e
							where e.X = m.X
								and e.Y < MinY
								and e.Z = m.Z)
		union all
		select distinct X, MaxY, Z
		from Maxes m
		where not exists (select *
							from #Exposed e
							where e.X = m.X
								and e.Y > MaxY
								and e.Z = m.Z)
		union all
		select distinct MinX, Y, Z
		from Maxes m
		where not exists (select *
							from #Exposed e
							where e.X < MinX
								and e.Y = m.Y
								and e.Z = m.Z)
		union all
		select distinct MaxX, Y, Z
		from Maxes m
		where not exists (select *
							from #Exposed e
							where e.X > MaxX
								and e.Y = m.Y
								and e.Z = m.Z)
	)
select (select count(*)
		from Ext
		)
	+ (select count(*)
		from #Exposed a
			inner join #Input b on ((b.X = a.X and b.Y = a.Y and abs(b.Z - a.Z) = 1)
									or (b.X = a.X and b.Z = a.Z and abs(b.Y - a.Y) = 1)
									or (b.Y = a.Y and b.Z = a.Z and abs(b.X - a.X) = 1)
									)
	) Answer2