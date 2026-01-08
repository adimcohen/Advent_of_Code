drop table if exists AOC_2025_11_Matrix
create table AOC_2025_11_Matrix
	(device1 char(3),
	device2 char(3),
	r int,
	c int,
	v bigint
	)
create unique clustered index IX_AOC_2025_11_Matrix on AOC_2025_11_Matrix(c, r)
create unique index IX_AOC_2025_11_Matrix1 on AOC_2025_11_Matrix(r, c) include(v)
GO
create or alter function fn_AOC_2025_11_MultiplyMatrices(@Matrix varchar(max)) returns table
as
return with Matrix as
			(select parsename([value], 3) r
					, parsename([value], 2) c
					, cast(parsename([value], 1) as bigint) v
				from string_split(@Matrix, ',')
			)
		select string_agg(cast(concat(r, '.', c, '.', val) as varchar(max)), ',') Matrix
		from AOC_2025_11_Matrix m
			cross apply (select sum(v.v*h.v) val
							from AOC_2025_11_Matrix v
								inner join Matrix h on h.r = v.c
							where v.r = m.r
								and h.c = m.c
						) v
		where val > 0
GO
declare @Input varchar(max) =
'aaa: you hhh
you: bbb ccc
bbb: ddd eee
ccc: ddd eee fff
ddd: ggg
eee: out
fff: out
ggg: out
hhh: ccc fff iii
iii: out'

drop table if exists #Input
select parsename(val1, 2) device
	, '["' + replace(parsename(val1, 1), ' ', '","') + '"]' outputs
into #Input
from string_split(replace(@Input, char(13), ''), char(10)) r
	cross apply (select replace([value], ': ', '.') val1) v

;with rec as
	(select 0 steps, j.[value] trgt
		from #Input
			cross apply openjson(outputs) j
		where device = 'you'
		union all
		select steps + 1, j.[value] trgt
		from rec r
			inner join #Input i on i.device = r.trgt
			cross apply openjson(i.outputs) j
	)
select count(*) Solution1
from rec
where trgt = 'out'

--p2
declare @Input1 varchar(max) =
'svr: aaa bbb
aaa: fft
fft: ccc
bbb: tty
tty: ccc
ccc: ddd eee
ddd: hub
hub: fff
eee: dac
dac: fff
fff: ggg hhh
ggg: out
hhh: out'

drop table if exists #Input1
drop table if exists #rec

select parsename(val1, 2) device
	, '["' + replace(parsename(val1, 1), ' ', '","') + '"]' outputs
into #Input1
from string_split(replace(@Input1, char(13), ''), char(10)) r
	cross apply (select replace([value], ': ', '.') val1) v

drop table if exists #Input2
select cast(parsename(val1, 2) as char(3)) device
	, cast(j.[value] as char(3)) trgt
into #Input2
from string_split(replace(@Input1, char(13), ''), char(10)) r
	cross apply (select replace(r.[value], ': ', '.') val1) v
	cross apply openjson('["' + replace(parsename(val1, 1), ' ', '","') + '"]') j

create unique clustered index IX_#Input2 on #Input2(device, trgt)
create unique index IX_#Input2a on #Input2(trgt, device)

;with i as
	(select device
		from #Input2
		union
		select trgt
		from #Input2
	)
	, i1 as
	(select *, row_number() over(order by device) id
	from i
	)
	, i2 as
	(select i1.id id1, i3.id id2, 1 val
		from i1
			inner join #Input2 i2 on i2.device = i1.device
			inner join i1 i3 on i3.device = i2.trgt
	)
insert into AOC_2025_11_Matrix
select a.device device1, b.device device2, a.id r, b.id c, isnull(i2.val, 0) val
from i1 a
	cross join i1 b
	left join i2 on i2.id1 = a.id and i2.id2 = b.id

;with rec as
	(select string_agg(cast(concat(r, '.', c, '.', v) as varchar(max)), ',') Matrix
				, 0 Steps
				, max(r) MaxR
			from AOC_2025_11_Matrix
			where v > 0
		union all
		select m.Matrix
				, Steps + 1
				, MaxR
		from rec r
			cross apply fn_AOC_2025_11_MultiplyMatrices(matrix) m
		where r.Steps <= MaxR
			and m.Matrix is not null
	)
select *
into #rec
from rec
option (maxrecursion 32767)

;with calc as
	(select m.device1, m.device2, sum(r.v) v
		from #rec
			cross apply string_split(matrix, ',')
			cross apply (select parsename([value], 3) r
								, parsename([value], 2) c
								, cast(parsename([value], 1) as bigint) v
						) r
			inner join AOC_2025_11_Matrix m on m.r = r.r and m.c = r.c
		where m.device1 in ('svr', 'fft', 'dac')
			and m.device2 in ('fft', 'dac', 'out')
		group by m.device1, m.device2
	)
select max(iif(device1 = 'svr' and device2 = 'fft',v, 0))*max(iif(device1 = 'fft' and device2 = 'dac',v, 0))*max(iif(device1 = 'dac' and device2 = 'out',v, 0))
	+ max(iif(device1 = 'svr' and device2 = 'dac',v, 0))*max(iif(device1 = 'dac' and device2 = 'fft',v, 0))*max(iif(device1 = 'fft' and device2 = 'out',v, 0)) Solution2
from calc