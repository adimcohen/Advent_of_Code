drop table if exists AOC_2022_Day19_Blueprints
create table AOC_2022_Day19_Blueprints
	(ID int,
	Ore_Ore int,
	Clay_Ore int,
	Obsidian_Ore int,
	Obsidian_Clay int,
	Geode_Ore int,
	Geode_Obsidian int)
GO
create or alter function fn_AOC_2022_Day24_GetBuyingOptions(@BluePrintID int,
															@OreRobots int,
															@ClayRobots int,
															@ObsidianRobots int,
															@Ore int,
															@Clay int,
															@Obsidian int,
															@Minute int,
															@Avoid_Ore bit,
															@Avoid_Clay bit,
															@Avoid_Obsidian bit) returns table
as
return 
		select 0 Ore_Robots, 0 Clay_Robots, 0 Obsidian_Robots, 0 Geode_Robots, @Ore Ore, @Clay Clay, @Obsidian Obsidian, 1 DoNothing
			, iif(Ore_Ore <= @Ore, 1, 0) Avoid_Ore
			, iif(Clay_Ore <= @Ore, 1, 0) Avoid_Clay
			, iif(Obsidian_Ore <= @Ore
					and Obsidian_Clay <= @Clay, 1, 0) Avoid_Obsidian
		from AOC_2022_Day19_Blueprints
		where ID = @BluePrintID
			and not (Geode_Ore <= @Ore
					and Geode_Obsidian <= @Obsidian)
		union all
		select 1 Ore_Robots, 0 Clay_Robots, 0 Obsidian_Robots, 0 Geode_Robots, @Ore - Ore_Ore Ore, @Clay Clay, @Obsidian Obsidian, 0 DoNothing, 0, 0, 0
		from AOC_2022_Day19_Blueprints
		where ID = @BluePrintID
			and Ore_Ore <= @Ore
			and @Avoid_Ore = 0
			and @OreRobots + 1 <= (select max(Ore)
									from (values(Ore_Ore),
												(Clay_Ore),
												(Obsidian_Ore),
												(Geode_Ore)) o(Ore)
									)
		union all
		select 0 Ore_Robots, 1 Clay_Robots, 0 Obsidian_Robots, 0 Geode_Robots, @Ore - Clay_Ore Ore, @Clay Clay, @Obsidian Obsidian, 0 DoNothing, 0, 0, 0
		from AOC_2022_Day19_Blueprints
		where ID = @BluePrintID
			and Clay_Ore <= @Ore
			and @Avoid_Clay = 0
			and @ClayRobots + 1 <= Obsidian_Clay
		union all
		select 0 Ore_Robots, 0 Clay_Robots, 1 Obsidian_Robots, 0 Geode_Robots, @Ore - Obsidian_Ore Ore, @Clay - Obsidian_Clay Clay, @Obsidian Obsidian, 0 DoNothing, 0, 0, 0
		from AOC_2022_Day19_Blueprints
		where ID = @BluePrintID
			and Obsidian_Ore <= @Ore
			and Obsidian_Clay <= @Clay
			and @Avoid_Obsidian = 0
			and @ObsidianRobots + 1 <= Geode_Obsidian
		union all
		select 0 Ore_Robots, 0 Clay_Robots, 0 Obsidian_Robots, 1 Geode_Robots, @Ore - Geode_Ore Ore, @Clay Clay, @Obsidian - Geode_Obsidian Obsidian, 0 DoNothing, 0, 0, 0
		from AOC_2022_Day19_Blueprints
		where ID = @BluePrintID
			and Geode_Ore <= @Ore
			and Geode_Obsidian <= @Obsidian
GO
create or alter function fn_AOC_2022_Day24_GetScenarios(@BluePrintID int,
															@Minute int,
															@Scenarios varchar(max),
															@Minutes int) returns table
as
return with Scenarios as
			(select cast(json_value([value], '$.o_r') as int) Ore_Robots
					, cast(json_value([value], '$.c_r') as int) Clay_Robots
					, cast(json_value([value], '$.b_r') as int) Obsidian_Robots
					, cast(json_value([value], '$.g_r') as int) Geode_Robots
					, cast(json_value([value], '$.o') as int) Ore
					, cast(json_value([value], '$.c') as int) Clay
					, cast(json_value([value], '$.b') as int) Obsidian
					, cast(json_value([value], '$.g') as int) Geode
					, cast(json_value([value], '$.a_o') as bit) Avoid_Ore
					, cast(json_value([value], '$.a_c') as bit) Avoid_Clay
					, cast(json_value([value], '$.a_b') as bit) Avoid_Obsidian
				from openjson(@Scenarios, '$')
			)
			, RankedScenarios as
			(select o_r
					, c_r
					, b_r
					, g_r
					, o
					, c
					, b
					, g
					, max(c_r) over() MaxClayRobots
					, max(b_r) over() MaxObsidianRobots
					, max(g_r) over() MaxGeodeRobots
					, max(c) over() MaxClay
					, max(b) over() MaxObsidian
					, max(g) over() MaxGeode
					, b.Avoid_Ore a_o
					, b.Avoid_Clay a_c
					, b.Avoid_Obsidian a_b
				from Scenarios s
					inner join AOC_2022_Day19_Blueprints p on p.ID = @BluePrintID
					cross apply fn_AOC_2022_Day24_GetBuyingOptions(@BluePrintID, s.Ore_Robots, s.Clay_Robots, s.Obsidian_Robots, s.Ore, s.Clay, s.Obsidian, @Minute, s.Avoid_Ore, s.Avoid_Clay, s.Avoid_Obsidian) b
					cross apply (select s.Ore_Robots + b.Ore_Robots o_r
								, s.Clay_Robots + b.Clay_Robots c_r
								, s.Obsidian_Robots + b.Obsidian_Robots b_r
								, s.Geode_Robots + b.Geode_Robots g_r
								, b.Ore + s.Ore_Robots o
								, b.Clay + s.Clay_Robots c
								, b.Obsidian + s.Obsidian_Robots b
								, s.Geode + s.Geode_Robots g) Calc
			)

		select (select o_r
					, c_r
					, b_r
					, g_r
					, o
					, c
					, b
					, g
					, max(a_o) a_o
					, max(a_c) a_c
					, max(a_b) a_b
					--, max(h) h
				from RankedScenarios s
					inner join AOC_2022_Day19_Blueprints b on b.ID = @BluePrintID
					cross apply (select @Minutes - @Minute RemainingTime) t
				where 1=1
					and not (MaxObsidianRobots > 1 and b_r = 0)
					and (g_r between MaxGeodeRobots - 1 and MaxGeodeRobots)
				group by o_r
					, c_r
					, b_r
					, g_r
					, o
					, c
					, b
					, g
				for json auto
				) NewScenarios
GO
create or alter function fn_AOC_2022_Day24_RunBluePrint(@BluePrintID int,
														@Minutes int) returns table
as
return with rec as
			(select ID
						, 0 Mnt
						, (select 1 o_r
								, 0 c_r
								, 0 b_r
								, 0 g_r
								, 0 o
								, 0 c
								, 0 b
								, 0 g
							from (select 1 a) t
							for json auto) Scenarios
					from AOC_2022_Day19_Blueprints
					where ID = @BluePrintID
					union all
					select r.ID
						, r.Mnt + 1
						, NewScenarios
					from rec r
						inner join AOC_2022_Day19_Blueprints p on p.ID = r.ID
						cross apply fn_AOC_2022_Day24_GetScenarios(r.ID, r.Mnt + 1, r.Scenarios, @Minutes) b
					where r.Mnt < @Minutes
				)
		select top 1 Scenarios
		from rec
		order by Mnt desc
GO
declare @Str varchar(max) = 
'Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 7 clay. Each geode robot costs 2 ore and 19 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 20 clay. Each geode robot costs 4 ore and 18 obsidian.
Blueprint 3: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 20 clay. Each geode robot costs 2 ore and 10 obsidian.
Blueprint 4: Each ore robot costs 3 ore. Each clay robot costs 4 ore. Each obsidian robot costs 2 ore and 19 clay. Each geode robot costs 2 ore and 12 obsidian.
Blueprint 5: Each ore robot costs 3 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 20 clay. Each geode robot costs 3 ore and 14 obsidian.
Blueprint 6: Each ore robot costs 3 ore. Each clay robot costs 4 ore. Each obsidian robot costs 2 ore and 15 clay. Each geode robot costs 3 ore and 7 obsidian.
Blueprint 7: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 2 ore and 19 clay. Each geode robot costs 2 ore and 20 obsidian.
Blueprint 8: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 13 clay. Each geode robot costs 2 ore and 20 obsidian.
Blueprint 9: Each ore robot costs 2 ore. Each clay robot costs 2 ore. Each obsidian robot costs 2 ore and 8 clay. Each geode robot costs 2 ore and 14 obsidian.
Blueprint 10: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 2 ore and 11 clay. Each geode robot costs 3 ore and 14 obsidian.
Blueprint 11: Each ore robot costs 3 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 5 clay. Each geode robot costs 4 ore and 8 obsidian.
Blueprint 12: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 2 ore and 16 clay. Each geode robot costs 2 ore and 18 obsidian.
Blueprint 13: Each ore robot costs 3 ore. Each clay robot costs 4 ore. Each obsidian robot costs 2 ore and 11 clay. Each geode robot costs 2 ore and 10 obsidian.
Blueprint 14: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 2 ore and 14 clay. Each geode robot costs 3 ore and 17 obsidian.
Blueprint 15: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 19 clay. Each geode robot costs 3 ore and 17 obsidian.
Blueprint 16: Each ore robot costs 2 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 20 clay. Each geode robot costs 2 ore and 17 obsidian.
Blueprint 17: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 4 ore and 8 obsidian.
Blueprint 18: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 9 clay. Each geode robot costs 3 ore and 9 obsidian.
Blueprint 19: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 2 ore and 10 clay. Each geode robot costs 3 ore and 14 obsidian.
Blueprint 20: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 2 ore and 13 clay. Each geode robot costs 3 ore and 12 obsidian.
Blueprint 21: Each ore robot costs 4 ore. Each clay robot costs 3 ore. Each obsidian robot costs 4 ore and 15 clay. Each geode robot costs 4 ore and 9 obsidian.
Blueprint 22: Each ore robot costs 3 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 20 clay. Each geode robot costs 2 ore and 12 obsidian.
Blueprint 23: Each ore robot costs 4 ore. Each clay robot costs 3 ore. Each obsidian robot costs 4 ore and 19 clay. Each geode robot costs 4 ore and 12 obsidian.
Blueprint 24: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 15 clay. Each geode robot costs 3 ore and 8 obsidian.
Blueprint 25: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 11 clay. Each geode robot costs 2 ore and 16 obsidian.
Blueprint 26: Each ore robot costs 3 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 17 clay. Each geode robot costs 3 ore and 7 obsidian.
Blueprint 27: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 3 ore and 7 clay. Each geode robot costs 3 ore and 20 obsidian.
Blueprint 28: Each ore robot costs 4 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 10 clay. Each geode robot costs 2 ore and 10 obsidian.
Blueprint 29: Each ore robot costs 4 ore. Each clay robot costs 4 ore. Each obsidian robot costs 4 ore and 17 clay. Each geode robot costs 2 ore and 13 obsidian.
Blueprint 30: Each ore robot costs 4 ore. Each clay robot costs 3 ore. Each obsidian robot costs 4 ore and 20 clay. Each geode robot costs 4 ore and 8 obsidian.'

;with Lines as
	(select row_number() over(order by (select 1)) ID, [value] Blueprint
		from string_split(replace(@Str, char(13), ''), char(10))
	)
	, Input1 as
	(select '[' + string_agg(cast('{"' + replace(replace(replace(replace(replace(replace(stuff(BluePrint, 10, 1, '":'), 'Each ', ''), ' robot costs ', '":["'), ' and ', '", "'), '.', '"]'), '] ', '], "'), ': ore', ', "ore') + '}' as varchar(max)), ',') + ']' js
		from Lines
	)
	, Input2 as
	(select b.*
		from Input1
			cross apply openjson(js, '$') j
			cross apply openjson(j.[value], '$') j1
			cross apply (select j1.[value] BluePrint
								, json_query(j.[value], '$.ore') ore
								, json_query(j.[value], '$.clay') clay
								, json_query(j.[value], '$.obsidian') obsidian
								, json_query(j.[value], '$.geode') geode
						) b
		where j1.[key] = 'Blueprint'
	)
insert into AOC_2022_Day19_Blueprints
select cast(BluePrint as int) ID
	, cast(replace(json_value(ore, '$[0]'), ' ore', '') as int) Ore_Ore
	, cast(replace(json_value(clay, '$[0]'), ' ore', '') as int) Clay_Ore
	, cast(replace(json_value(obsidian, '$[0]'), ' ore', '') as int) Obsidian_Ore
	, cast(replace(json_value(obsidian, '$[1]'), ' clay', '') as int) Obsidian_Clay
	, cast(replace(json_value(geode, '$[0]'), ' ore', '') as int) Geode_Ore
	, cast(replace(json_value(geode, '$[1]'), ' obsidian', '') as int) Geode_Obsidian
from Input2
create unique clustered index IX_AOC_2022_Day19_Blueprints on AOC_2022_Day19_Blueprints(ID)

;with rec as
	(select 0 ID, 24 Mnt, cast(null as varchar(max)) Scenarios
	union all
	select b.ID, Mnt, cast(p.Scenarios as varchar(max))
	from rec r
		inner join AOC_2022_Day19_Blueprints b on b.ID = r.ID + 1
		cross apply fn_AOC_2022_Day24_RunBluePrint(b.ID, 24) p
	where b.ID between 1 and 30
	)
	, Q as
	(select ID * max(Geode) Quality
		from rec with (nolock)
			cross apply (select cast(json_value([value], '$.g') as int) Geode
							from openjson(Scenarios, '$')
						) t
		group by ID
	)
select sum(Quality) Answer1
from Q

;with rec as
	(select 0 ID, 32 Mnt, cast(null as varchar(max)) Scenarios
	union all
	select b.ID, Mnt, cast(p.Scenarios as varchar(max))
	from rec r
		inner join AOC_2022_Day19_Blueprints b on b.ID = r.ID + 1
		cross apply fn_AOC_2022_Day24_RunBluePrint(b.ID, 32) p
	where b.ID between 1 and 3
	)
	, Q as
	(select ID, max(Geode) Geodes
		from rec with (nolock)
			cross apply (select cast(json_value([value], '$.g') as int) Geode
							from openjson(Scenarios, '$')
						) t
		group by ID
	)
select max(iif(ID = 1, Geodes, null))*max(iif(ID = 2, Geodes, null))*max(iif(ID = 3, Geodes, null)) Answer2
from Q