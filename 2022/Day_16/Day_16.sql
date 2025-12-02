declare @Str varchar(max) =
'Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II'

drop table if exists #Input
drop table if exists #ValidRoutes
drop table if exists #rec

--Graph DB tables can't be temp tables
drop table if exists AOC_2022_Day16_Valves
drop table if exists AOC_2022_Day16_Tunnels

create table AOC_2022_Day16_Valves
	(Valve char(2),
	FlowRate int)
as node

create table AOC_2022_Day16_Tunnels as edge

select json_value(Info, '$[0]') Valve, cast(json_value(Info, '$[1]') as int) FlowRate, n.[value] Tunnel
into #Input
from string_split(replace(@Str, char(13), ''), char(10)) s
	cross apply (select '["' + replace(replace(replace(substring(s.[value], 7, len(s.[value])), ' has flow rate=', '", '), '; tunnels lead to valves ', ', "'), '; tunnel leads to valve ', ', "') + '"]' Info) i
	cross apply (select replace(json_value(Info, '$[2]'), ' ', '') Tunnels) t
	cross apply string_split(Tunnels, ',') n


insert into AOC_2022_Day16_Valves
select distinct Valve, FlowRate
from #Input

insert into AOC_2022_Day16_Tunnels
select distinct v.$node_id, v1.$node_id
from #Input i
	inner join #Input i1 on i1.Valve = i.Tunnel
						and i1.Tunnel = i.Valve
	inner join AOC_2022_Day16_Valves v on v.Valve = i.Valve
	inner join AOC_2022_Day16_Valves v1 on v1.Valve = i1.Valve

--Caching all distances to make it easies for the optimizer. Could be inlined, but would cause the query to take X120 time
;with AllRoutes as
	(select v1.Valve FromValve, last_value(v2.Valve) within group (graph path) ToValve,
				last_value(v2.FlowRate) within group (graph path) FlowRate,
				count(v2.Valve) within group (graph path) Steps
		from AOC_2022_Day16_Valves v1,
			AOC_2022_Day16_Tunnels for path t,
			AOC_2022_Day16_Valves for path v2
		where (v1.FlowRate > 0
				or v1.Valve = 'AA')
			and match(shortest_path(v1(-(t)->v2)+))
	)
select *
into #ValidRoutes
from AllRoutes
where FlowRate > 0

--Solution1
;with rec as
	(select Valve, TotalMinutes, TotalMinutes RemainingMinutes, cast(0 as int) as Flow, cast(',' as varchar(max)) Opened, cast(0 as int) Lvl
		from AOC_2022_Day16_Valves
			cross apply (select cast(30 as int) TotalMinutes) t
		where Valve = 'AA'
		union all
		select t.ToValve, r.TotalMinutes, m.RemainingMinutes, r.Flow + f.Flow, r.Opened + t.ToValve + ',', r.Lvl + 1
		from rec r
			inner join #ValidRoutes t on t.FromValve = r.Valve
									and t.Steps < r.RemainingMinutes - 1
									and r.Opened not like '%,' + ToValve + ',%'
			cross apply (select r.RemainingMinutes - t.Steps - 1 RemainingMinutes) m
			cross apply (select (t.FlowRate * m.RemainingMinutes) Flow) f
	)
select max(Flow) Answer1
from rec

--Solution2
--Caching all routes to bring on for a parallel execution plan when finding the best 2-route-combination
;with rec as
	(select Valve, TotalMinutes, TotalMinutes RemainingMinutes, cast(0 as int) as Flow, cast(',' as varchar(max)) Opened, cast(0 as int) Lvl
		from AOC_2022_Day16_Valves
			cross apply (select cast(26 as int) TotalMinutes) t
		where Valve = 'AA'
		union all
		select t.ToValve, r.TotalMinutes, m.RemainingMinutes, r.Flow + f.Flow, r.Opened + t.ToValve + ',', r.Lvl + 1
		from rec r
			inner join #ValidRoutes t on t.FromValve = r.Valve
									and t.Steps < r.RemainingMinutes - 1
									and r.Opened not like '%,' + ToValve + ',%'
			cross apply (select r.RemainingMinutes - t.Steps - 1 RemainingMinutes) m
			cross apply (select (t.FlowRate * m.RemainingMinutes) Flow) f
	)
select *
into #rec
from rec


select max(m.Flow + e.Flow) Answer2
from #rec m
	inner join #rec e on left(m.Opened, 3) <> left(e.Opened, 3)
						and not exists (select [value]
										from string_split(m.Opened, ',')
										where [value] <> ''
											and e.Opened like '%,' + [value] + ',%'
										)

drop table if exists AOC_2022_Day16_Valves
drop table if exists AOC_2022_Day16_Tunnels