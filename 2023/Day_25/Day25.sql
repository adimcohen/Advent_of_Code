declare @Input varchar(max) = 
'jqt: rhn xhk nvd
rsh: frs pzl lsr
xhk: hfx
cmg: qnr nvd lhk bvb
rhn: xhk bvb hfx
bvb: xhk hfx
pzl: lsr hfx nvd
qnr: nvd
ntq: jqt hfx bvb xhk
nvd: lhk
lsr: lhk
rzs: qnr cmg lsr rsh
frs: qnr lhk lsr'
drop table if exists AOC_2023_Day25_Nodes
drop table if exists AOC_2023_Day25_Edges
drop table if exists AOC_2023_Day25_Edges1
drop table if exists #Input
drop table if exists #Routes
drop table if exists #TopEdges

create table AOC_2023_Day25_Nodes
	(id int constraint PK_AOC_2023_Day25_Nodes primary key clustered,
	nd varchar(10)
	) as node

create table AOC_2023_Day25_Edges(id int) as edge
create unique clustered index IX_AOC_2023_Day25_Edges on AOC_2023_Day25_Edges($from_id, $to_id)

create table AOC_2023_Day25_Edges1 as edge
create unique clustered index IX_AOC_2023_Day25_Edges1 on AOC_2023_Day25_Edges1($from_id, $to_id)

;with i as
	(select a, i3.[value] b
		from string_split(replace(@Input, char(10), ''), char(13), 0) i
			cross apply (select charindex(':', i.[value], 1) ind) i1
			cross apply (select left(i.[value], ind - 1) a, substring(i.[value], ind + 2, len(i.[value]) + 1) bs) i2
			cross apply string_split(bs, ' ', 0) i3
	)
select *
into #Input
from i
union
select b, a
from i

insert into AOC_2023_Day25_Nodes
select row_number() over(order by a), a
from (select distinct a
		from #Input
	) i

insert into AOC_2023_Day25_Edges
select a.$node_id, b.$node_id, row_number() over(order by i.a, i.b)
from AOC_2023_Day25_Nodes a
	inner join #Input i on i.a = a.nd
	inner join AOC_2023_Day25_Nodes b on b.nd = i.b

alter index all on AOC_2023_Day25_Edges rebuild

;with i as
	(select string_agg(cast(e.id as varchar(max)), ',') within group (graph path) Rt
		from AOC_2023_Day25_Nodes i,
			AOC_2023_Day25_Edges for path e,
			AOC_2023_Day25_Nodes for path i1
		where match(shortest_path(i(-(e)->i1)+))
			and i.id <= 100
	)
select *
into #Routes
from i

select top 3 with ties cast([value] as int) eid, count(*) cnt
into #TopEdges
from #Routes
	cross apply string_split(Rt, ',', 0)
group by [value]
order by count(*) desc

;with ex as
	(select a.nd a, b.nd b
		from AOC_2023_Day25_Edges e
			inner join AOC_2023_Day25_Nodes a on a.$node_id = e.$from_id
			inner join AOC_2023_Day25_Nodes b on b.$node_id = e.$to_id
		where e.id in (select eid
						from #TopEdges
					)
	)
insert into AOC_2023_Day25_Edges1
select a.$node_id, b.$node_id
from AOC_2023_Day25_Nodes a
	inner join #Input i on i.a = a.nd
	inner join AOC_2023_Day25_Nodes b on b.nd = i.b
where not exists (select *
					from ex
					where ex.a in (i.a, i.b)
						and ex.b in (i.a, i.b)
					)

;with i as
	(select a.nd a, b.nd b
		from AOC_2023_Day25_Edges e
			inner join AOC_2023_Day25_Nodes a on a.$node_id = e.$from_id
			inner join AOC_2023_Day25_Nodes b on b.$node_id = e.$to_id
		where e.id in (select eid
						from #TopEdges
					)
	)
	, sides as
	(select distinct n
		from i
			cross apply (values(a)
							, (b)
						) i1(n)
	)
	, i2 as
	(select i.nd, last_value(i1.$node_id) within group (graph path) Connected
		from AOC_2023_Day25_Nodes i,
			AOC_2023_Day25_Edges1 for path e,
			AOC_2023_Day25_Nodes for path i1
		where match(shortest_path(i(-(e)->i1)+))
			and i.nd in (select n from sides)
	)
	, i3 as
	(select distinct top 2 count(*) cnt
		from i2
		group by nd
	)
select round(exp(sum(log(cnt))), 0) Answer1
from i3