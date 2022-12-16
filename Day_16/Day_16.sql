declare @Str varchar(max) =
'Valve OS has flow rate=0; tunnels lead to valves EE, CL
Valve EN has flow rate=0; tunnels lead to valves CL, GV
Valve RR has flow rate=24; tunnels lead to valves FS, YP
Valve VB has flow rate=20; tunnels lead to valves UU, EY, SG, ZB
Valve UU has flow rate=0; tunnels lead to valves OT, VB
Valve WH has flow rate=0; tunnels lead to valves CS, JS
Valve OF has flow rate=25; tunnel leads to valve YM
Valve TY has flow rate=0; tunnels lead to valves AA, GQ
Valve RV has flow rate=0; tunnels lead to valves BT, YX
Valve GK has flow rate=0; tunnels lead to valves GD, AA
Valve EL has flow rate=0; tunnels lead to valves EK, EE
Valve OT has flow rate=9; tunnels lead to valves YR, BJ, OX, UU, HJ
Valve DG has flow rate=11; tunnels lead to valves BN, QE
Valve YR has flow rate=0; tunnels lead to valves OT, YX
Valve GV has flow rate=0; tunnels lead to valves AA, EN
Valve BN has flow rate=0; tunnels lead to valves DG, LU
Valve FS has flow rate=0; tunnels lead to valves TI, RR
Valve DW has flow rate=0; tunnels lead to valves SS, MS
Valve DJ has flow rate=0; tunnels lead to valves KY, GD
Valve BJ has flow rate=0; tunnels lead to valves OT, BT
Valve KY has flow rate=0; tunnels lead to valves EE, DJ
Valve YP has flow rate=0; tunnels lead to valves YM, RR
Valve LU has flow rate=0; tunnels lead to valves BN, CS
Valve OX has flow rate=0; tunnels lead to valves OT, XD
Valve ZB has flow rate=0; tunnels lead to valves VB, PP
Valve CL has flow rate=10; tunnels lead to valves KQ, EN, OS, MQ
Valve XD has flow rate=0; tunnels lead to valves KR, OX
Valve YM has flow rate=0; tunnels lead to valves OF, YP
Valve EY has flow rate=0; tunnels lead to valves MS, VB
Valve KQ has flow rate=0; tunnels lead to valves CS, CL
Valve SS has flow rate=0; tunnels lead to valves AA, DW
Valve SG has flow rate=0; tunnels lead to valves VB, KR
Valve EE has flow rate=22; tunnels lead to valves XR, OS, KY, EL
Valve OI has flow rate=0; tunnels lead to valves RE, MS
Valve QE has flow rate=0; tunnels lead to valves DG, GD
Valve GD has flow rate=3; tunnels lead to valves GK, DJ, MQ, QE, JS
Valve EK has flow rate=23; tunnel leads to valve EL
Valve GQ has flow rate=0; tunnels lead to valves CS, TY
Valve CS has flow rate=7; tunnels lead to valves GQ, WH, KQ, LU
Valve MS has flow rate=4; tunnels lead to valves HJ, EY, DW, OI
Valve XR has flow rate=0; tunnels lead to valves EE, AA
Valve RE has flow rate=6; tunnels lead to valves TI, PP, OI
Valve KR has flow rate=17; tunnels lead to valves XD, SG
Valve BT has flow rate=15; tunnels lead to valves BJ, RV
Valve PP has flow rate=0; tunnels lead to valves RE, ZB
Valve TI has flow rate=0; tunnels lead to valves RE, FS
Valve HJ has flow rate=0; tunnels lead to valves OT, MS
Valve AA has flow rate=0; tunnels lead to valves GK, GV, SS, XR, TY
Valve MQ has flow rate=0; tunnels lead to valves GD, CL
Valve JS has flow rate=0; tunnels lead to valves GD, WH
Valve YX has flow rate=5; tunnels lead to valves YR, RV'

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
create unique clustered index IX_#rec on #rec(ID)

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