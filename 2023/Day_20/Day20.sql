use tempdb
drop table if exists AOC_2023_Day20_Modules
create table AOC_2023_Day20_Modules(ID bigint,
									SModuleType char(1),
									SModule varchar(20),
									TModuleList varchar(max),
									TModuleListStr varchar(max))
GO
create or alter function fn_AOC_2023_Day20_Step(@OnModules bigint
												, @Sources varchar(max)
												, @Conjunctions varchar(max)
												) returns table
as
return with i as
			(select SourceOrdinal, sp.ordinal TargetOrdinal, SourceID, IsHighWave, t.ID TargetID, t.SModuleType
					, cast(iif(t.SmoduleType = '%'
								, iif(sl.IsHighWave = 0
										, iif(row_number() over(partition by t.ID, sl.IsHighWave order by sl.SourceOrdinal)%2 = 1
												, ~BaseIsOn
												, BaseIsOn
											)
										, null)
								, null
							) as bit) IsFlipFlopOn
					, iif(t.SModuleType = '&'
							, iif(lag(sl.IsHighWave, 1, ~sl.IsHighWave) over(partition by s.ID, t.ID order by sl.SourceOrdinal) = sl.IsHighWave
									, 0
									, iif(sl.IsHighWave = 1
											, iif(HighSources & s.ID = 0
													, s.ID
													, 0
												)
											, iif(HighSources & s.ID > 0
													, -s.ID
													, 0
												)
										)
								)
							, null
						) ConjValue
					, TotalSources
					, HighSources
					, sum(iif(IsHighWave = 0, 1, 0)) over() LowWaves
					, sum(iif(IsHighWave = 1, 1, 0)) over() HighWaves
				from (select cast(j.[key] as int) SourceOrdinal, cast(j1.[key] as bigint) SourceID, cast(j1.[value] as bit) IsHighWave
						from openjson(@Sources) j
							cross apply openjson(j.[value]) j1) sl
					inner join AOC_2023_Day20_Modules s on s.ID = sl.SourceID
					outer apply string_split(s.TModuleList, ',', 1) sp
					left join AOC_2023_Day20_Modules t on t.ID = cast(sp.[value] as bigint)
					outer apply (select cast(iif(@OnModules & t.ID > 0, 1, 0) as bit) BaseIsOn
									where t.SModuleType = '%'
								) o
					left join (select cast(j.[key] as bigint) ID, json_value(j.[value], '$[0]') TotalSources, json_value(j.[value], '$[1]') HighSources
								from openjson(@Conjunctions) j) c on c.ID = t.ID
			)
			, i1 as
			(select SourceOrdinal
					, TargetOrdinal
					, TargetID
					, IsFlipFlopOn
					, SModuleType
					, IsHighWave
					, @OnModules + sum(iif(sModuleType = '%' and IsHighWave = 0
												, iif(IsFlipFlopOn = 1
														, 1
														, -1)*TargetID
												, 0
											)
										) over(order by SourceOrdinal, TargetOrdinal) OnModules
					, iif(SModuleType = '&'
							, HighSources + sum(ConjValue) over(partition by TargetID order by SourceOrdinal)
							, null
						) HighSources
					, TotalSources
					, LowWaves
					, HighWaves
				from i
			)
			, i2 as
			(select SourceOrdinal
					, TargetOrdinal
					, SModuleType
					, IsHighWave
					, TargetID
					, last_value(HighSources) over(partition by TargetID order by SourceOrdinal, TargetOrdinal rows between unbounded preceding and unbounded following) HighSources
					, TotalSources
					, isnull(IsFlipFlopOn, iif(TotalSources = HighSources, 0, 1)) IsNewHighWave
					, last_value(OnModules) over(order by SourceOrdinal, TargetOrdinal rows between unbounded preceding and unbounded following) OnModules
					, LowWaves
					, HighWaves
				from i1
			)
			, i3 as
			(select max(OnModules) OnModules
					, '[' + string_agg(cast(iif((SModuleType = '&' or IsHighWave = 0) and TargetID is not null
												, concat('{"', TargetID, '":', IsNewHighWave, '}')
												, null
											) as varchar(max)), ',') within group(order by SourceOrdinal, TargetOrdinal) + ']' Sources
					, max(LowWaves) LowWaves
					, max(HighWaves) HighWaves
				from i2
			)
			, i4 as
			(select distinct TargetID, TotalSources, HighSources, 1 IsNew
				from i2
				where TotalSources is not null
				union all
				select cast(j.[key] as bigint) TargetID, json_value(j.[value], '$[0]') TotalSources, json_value(j.[value], '$[1]') HighSources, 0 IsNew
				from openjson(@Conjunctions) j
			)
			, i5 as
			(select *, row_number() over(partition by TargetID order by IsNew desc) rn
				from i4
			)
			, i6 as
			(select '{' + string_agg(cast(concat('"', TargetID, '":[', TotalSources, ',', HighSources, ']') as varchar(max)), ',') + '}' Conjunctions
				from i5
				where rn = 1
			)
		select OnModules, Sources, Conjunctions, LowWaves, HighWaves
		from i3
			cross join i6
GO
create or alter function fn_AOC_2023_Day20_Push(@Conjunctions varchar(max),
												@OnModules bigint) returns table
as
return with rec as
			(select 0 Step, cast(1 as bigint) LowWaves, cast(0 as bigint) HighWaves, @OnModules OnModules, cast('[{"0":0}]' as varchar(max)) Sources
					, cast(@Conjunctions as varchar(max)) Conjunctions, cast('' as varchar(max)) AllSources
				union all
				select r.Step + 1 Step, r.LowWaves + p.LowWaves LowWaves, r.HighWaves + p.HighWaves HighWaves, p.OnModules, p.Sources, p.Conjunctions
					, r.AllSources + isnull(',' + p.Sources, '') AllSources
				from rec r
					cross apply fn_AOC_2023_Day20_Step(r.OnModules, r.Sources, r.Conjunctions) p
				where (r.Sources != ''
						or r.Step = 0
					)
			)
		select top 1 cast(LowWaves as bigint) LowWaves, cast(HighWaves as bigint) HighWaves, OnModules, Conjunctions, AllSources
		from rec
		order by Step desc
GO
declare @Input varchar(max) =
'%qm -> mj, xn
&mj -> hz, bt, lr, sq, qh, vq
%qc -> qs, vg
%ng -> vr
%qh -> sq
&bt -> rs
%hh -> qs, bx
%gk -> cs, bb
%js -> mj
%pc -> mj, mr
%mb -> rd, xs
%tp -> qs, ks
%xq -> tp, qs
%bx -> sz
%mn -> cs, md
%cv -> rd
%rh -> rd, sv
%md -> cs
%pz -> mj, vq
%bz -> rd, hk
%jz -> vk
%sz -> jz
%lr -> pz, mj
%xs -> cv, rd
%kl -> rd, mb
%hz -> pc
%hk -> rz, rd
%vk -> qc
%bh -> zm
%vq -> qm
%ks -> qs, nd
&qs -> dl, jz, bx, vk, vg, hh, sz
&dl -> rs
%lf -> rh, rd
&fr -> rs
%xn -> mj, qh
%hf -> qs, xq
%sv -> rd, ng
&rs -> rx
&rd -> ng, fr, rz, lf, vr
%cj -> ss, cs
broadcaster -> hh, lr, bp, lf
%zs -> cs, mn
%vr -> bz
%nd -> qs
%jb -> cj, cs
&rv -> rs
%bp -> cs, lx
%ss -> zs
%lx -> gk
&cs -> lx, ss, rv, bh, bp
%bb -> bh, cs
%mf -> mj, hz
%zm -> cs, jb
%mr -> mj, js
%rz -> kl
%vg -> hf
%sq -> mf'

drop table if exists #Pushes
drop table if exists #Cycles

;with i as
	(select power(cast(2 as bigint), row_number() over(order by i4.SModule) - 1) ID, iif(SModuleType in ('%', '&'), SModuleType, '') SModuleType, i4.SModule, TModuleList
		from string_split(replace(@Input, char(10), ''), char(13), 0) i
			cross apply (select charindex(' -> ', [value], 1) ind1) i1
			cross apply (select left(i.[value], ind1 - 1) SModule
							, replace(substring(i.[value], ind1 + 4, len(i.[value])), ' ', '') TModuleList
						) i2
			cross apply (select left(SModule, 1) SModuleType) i3
			cross apply (select iif(SModuleType in ('%', '&'), stuff(SModule, 1, 1, ''), SModule) SModule) i4
	)
insert into AOC_2023_Day20_Modules
select i2.ID, i.SModuleType, i.SModule, i1.TModuleList, i.TModuleList TModuleListStr
from i
	cross apply (select string_agg(i1.ID, ',') within group (order by ordinal) TModuleList
					from string_split(TModuleList, ',', 1)
						inner join i i1 on i1.SModule = [value]
				) i1
	cross apply (select iif(i.SModule = 'broadcaster', 0, i.ID) ID) i2

;with InitialStatus as
	(select cast('{' + string_agg(concat('"', ID, '":[', TotalSources, ',', 0, ']'), ',') + '}' as varchar(max)) Conjunctions
		from AOC_2023_Day20_Modules i
			cross apply (select sum(i1.ID) TotalSources
							from AOC_2023_Day20_Modules i1
							where ',' + i1.TModuleList + ',' like concat('%,', i.ID, ',%')
						) i1
		where i.SModuleType = '&'
	)
	, rec as
	(select 0 Pushes, cast(0 as bigint) LowWaves, cast(0 as bigint) HighWaves, cast(0 as bigint) OnModules, Conjunctions, cast(null as varchar(max)) AllSources
		from InitialStatus i
		union all
		select r.Pushes + 1 Pushes, r.LowWaves + p.LowWaves LowWaves, r.HighWaves + p.HighWaves HighWaves, p.OnModules, p.Conjunctions, p.AllSources
		from rec r
			cross apply fn_AOC_2023_Day20_Push(Conjunctions, r.OnModules) p
		where 
		--(r.Pushes = 0
		--		or r.OnModules > 0
		--	)
		--	and 
			r.Pushes < 10000
	)
select *
into #Pushes
from rec
where Pushes > 0
option (maxrecursion 32767)

--1
select LowWaves*HighWaves Answer1
from #Pushes
where Pushes = 1000

;with i as
	(select ID Lvl0ID
		from AOC_2023_Day20_Modules
		where ','+ TModuleListStr + ',' like '%,rx,%'
	)
	, i1 as
	(select ID
		from i
			inner join AOC_2023_Day20_Modules m on ',' + TModuleList + ',' like concat('%,', Lvl0ID, ',%')
	)
select Pushes
into #Cycles
from i1
	cross apply (select top 1 Pushes
					from #Pushes
					where AllSources like concat('%"', ID, '":1%')
					order by Pushes
				) p

--2	
;with Nums as
	(select [value] num
		from generate_series(3, cast((select max(Pushes) from #Cycles) as int), 2)
		union all
		select 2
	)
	, Prime as
	(select num
		from Nums a
		where not exists (select *
							from Nums b
							where b.num != a.num
								and a.num % b.num = 0
						)
	)
	, i as
	(select Pushes, num
		from #Cycles
			inner join Prime on Pushes % num = 0
	)
	, i1 as
	(select cast(Pushes / exp(sum(log(num))) as bigint) num
		from i
		group by Pushes
		having Pushes / exp(sum(log(num))) > 1.1
		union
		select cast(num as bigint)
		from i
	)
select exp(sum(log(num))) Answer2
from i1