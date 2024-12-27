drop table if exists AOC_2024_Day21_Keypads
create table AOC_2024_Day21_Keypads(KeypadID int,
									r int,
									c int,
									K char(1)
									)
create unique clustered index IX_AOC_2024_Day21_Keypads1 on AOC_2024_Day21_Keypads(KeypadID, K)
GO
create or alter function fn_AOC_2024_Day21_Step(@KeypadID int,
													@FromKey char(1),
													@ToKey char(1)
												) returns table
as
return select case when cDiff > 0
							and exists (select *
											from AOC_2024_Day21_Keypads p 
											where KeypadID = @KeypadID
												and p.r = t.r
												and p.c = f.c
										)
						then v+h
					when exists (select *
									from AOC_2024_Day21_Keypads p 
									where KeypadID = @KeypadID
										and p.r = f.r
										and p.c = t.c
									)
						then h+v
					else v+h
				end Keys
		from AOC_2024_Day21_Keypads f
			inner join AOC_2024_Day21_Keypads t on t.KeypadID = f.KeypadID
												and t.K = @ToKey
			cross apply (select t.r - f.r rDiff, t.c - f.c cDiff) d
			cross apply (select concat(replicate('v', rDiff), replicate('^', -rDiff)) v
								, concat(replicate('>', cDiff), replicate('<', -cDiff)) h
						) hz
		where f.KeypadID = @KeypadID
			and f.K = @FromKey
GO
create or alter function fn_AOC_2024_Day21_GetCodeKeys(@KeypadID int
														, @Code varchar(max)
														) returns table
as
return with rec as
			(select 0 KeyID, cast('A' as char(1)) CurrentKey, cast('' as varchar(max)) Keys
			union all
			select NewKeyID, NewKey, cast(concat(r.Keys, d1.Keys, 'A') as varchar(max))
				from rec r
					cross apply (select KeyID + 1 NewKeyID) n
					cross apply (select cast(substring(@Code, NewKeyID, 1) as char(1)) NewKey) d
					cross apply fn_AOC_2024_Day21_Step(@KeypadID, CurrentKey, NewKey) d1
			)
		select top 1 Keys
		from rec
		order by KeyID desc
GO
create or alter function fn_AOC_2024_Day21_WrapDirGetKeypadCodeKeys(@KeypadID int,
																	@Patterns varchar(max)
																	) returns table
as
return with Calc as
			(select s.[value] + iif(ordinal < max(ordinal) over(partition by j.[key]), 'A', '') Pattern, cnt
				from openjson(@Patterns) j
					cross apply (select json_value(j.[value], '$.p') Pattern
									, cast(json_value(j.[value], '$.c') as bigint) cnt
								) p
					cross apply fn_AOC_2024_Day21_GetCodeKeys(@KeypadID, Pattern) r
					cross apply string_split(Keys, 'A', 1) s
			)
			, grp as
			(select Pattern, cnt*count(*) cnt
				from Calc
				where Pattern != ''
				group by Pattern, cnt
			)
		select (select Pattern p, sum(cnt) c
					from grp
					group by Pattern
					for json path
				) Patterns
GO
create or alter function fn_AOC_2024_Day21_RunMultipleRobots(@KeypadID int,
															@Patterns varchar(max),
															@RobotCount int
															) returns table
as
return with rec as
			(select 0 RobotID, @Patterns Patterns
				union all
				select RobotID + 1, cast(n.Patterns as varchar(max))
				from rec r
					cross apply fn_AOC_2024_Day21_WrapDirGetKeypadCodeKeys(@KeypadID, r.Patterns) n
				where r.RobotID < @RobotCount
			)
			select top 1 Patterns
			from rec
			where RobotID = @RobotCount
GO
declare @Input varchar(max) =
'879A
508A
463A
593A
189A'
	, @NumKePad varchar(max) =
'789
456
123
.0A'
	, @DirPad varchar(max) =
'.^A
<v>'

insert into AOC_2024_Day21_Keypads
select 1 KeypadID, r.ordinal r, c.[value] c, K
from string_split(replace(@NumKePad, char(10), ''), char(13), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int), cast(1 as int)) c
	cross apply (select substring(r.[value], c.[value], 1) K) p
where K != '.'
union all
select 2 KeypadID, r.ordinal r, c.[value] c, K
from string_split(replace(@DirPad, char(10), ''), char(13), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int), cast(1 as int)) c
	cross apply (select substring(r.[value], c.[value], 1) K) p
where K != '.'

select sum(ln*cast(replace([value], 'A', '') as bigint)) Answer1
from string_split(replace(@Input, char(10), ''), char(13), 1)
	cross apply fn_AOC_2024_Day21_GetCodeKeys(1, [value]) r
	cross apply (select (select r.Keys p, 1 c
							from (select 1 a) t
							for json path
						) Patterns
				) p
	cross apply fn_AOC_2024_Day21_RunMultipleRobots(2, p.Patterns, 2) rn
	cross apply (select sum(len(Pattern)*cnt) ln
					from openjson(rn.Patterns) j
					cross apply (select json_value(j.[value], '$.p') Pattern
									, cast(json_value(j.[value], '$.c') as bigint) cnt
								) p
				) l

select sum(ln*cast(replace([value], 'A', '') as bigint)) Answer2
from string_split(replace(@Input, char(10), ''), char(13), 1)
	cross apply fn_AOC_2024_Day21_GetCodeKeys(1, [value]) r
	cross apply (select (select r.Keys p, 1 c
							from (select 1 a) t
							for json path
						) Patterns
				) p
	cross apply fn_AOC_2024_Day21_RunMultipleRobots(2, p.Patterns, 25) rn
	cross apply (select sum(len(Pattern)*cnt) ln
					from openjson(rn.Patterns) j
					cross apply (select json_value(j.[value], '$.p') Pattern
									, cast(json_value(j.[value], '$.c') as bigint) cnt
								) p
				) l