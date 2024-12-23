drop table if exists AOC_2024_Day21_KeypadMap
create table AOC_2024_Day21_KeypadMap(FromKey Char(1),
										ToKey char(1),
										Dir char(1)
										)
create unique clustered index IX_AOC_2024_Day21_KeypadMap on AOC_2024_Day21_KeypadMap(FromKey, ToKey)
GO
create or alter function fn_AOC_2024_Day21_ScoreCode(@Code varchar(max)) returns table
as
return select E + S + W + N Score
			from (select len(@Code) ln) l
				cross apply (select (ln - len(replace(@Code, '>', '')))*-1 W
								, (ln - len(replace(@Code, '<', '')))*3 E
								, (ln - len(replace(@Code, '^', '')))*-1 N
								, (ln - len(replace(@Code, 'v', '')))*2 S
							) d
GO
create or alter function fn_AOC_2024_Day21_NavigateKeypad(@CurrentKey char(1)
																, @TargetKey char(1)
																, @MaxSteps int
																, @Top int
																, @WithTies bit
																) returns table
as
return with rec as
			(select 0 Step, @CurrentKey CurrentKey, cast('' as varchar(max)) Keys, cast(concat(',', @CurrentKey, ',') as varchar(max)) Rt
				union all
				select Step + 1, ToKey, cast(Keys + Dir as varchar(max)), concat(Rt, ToKey, ',')
				from rec r
					cross apply (select Step + 1 NewStep) n
					inner join AOC_2024_Day21_KeypadMap on FromKey = CurrentKey
				where Rt not like '%,' + ToKey + ',%'
					and r.CurrentKey != @TargetKey
					and r.Step < @MaxSteps
			)
			, Final as
			(select top(@Top) with ties Keys
				from rec
				where CurrentKey = @TargetKey
				order by Step
			)
			, rn as
			(select Keys, Score
				from Final
					cross apply fn_AOC_2024_Day21_ScoreCode(Keys) 
			)
		select *
		from (select top(@Top) with ties Keys
				from rn
				order by Score
			) t
		where @WithTies = 1
		union all
		select *
		from (select top(@Top) Keys
				from rn
				order by Score
			) t
		where @WithTies = 0
GO
create or alter function fn_AOC_2024_Day21_GetKeypadCodeKeys(@Code varchar(max)
															, @StartChar char(1)
															, @MaxSteps int
															, @Top int
															, @WithTies bit
																	) returns table
as
return with rec as
			(select 0 DigitID, cast(@StartChar as char(1)) CurrentDigit, cast('' as varchar(max)) Keys, cast('' as varchar(max)) Keys1
			union all
			select NewDigitID, Digit, cast(concat(r.Keys, d1.Keys, 'A') as varchar(max)), cast(d1.Keys as varchar(max))
				from rec r
					cross apply (select DigitID + 1 NewDigitID) n
					cross apply (select cast(substring(@Code, NewDigitID, 1) as char(1)) Digit) d
					cross apply fn_AOC_2024_Day21_NavigateKeypad(CurrentDigit, Digit, @MaxSteps, @Top, @WithTies) d1
			)
			, Final as
			(select top(@Top) with ties Keys
				from rec
				order by DigitID desc
			)
			, rn as
			(select Keys, Score
				from Final
					cross apply fn_AOC_2024_Day21_ScoreCode(Keys) 
			)
		select *
		from (select top(@Top) with ties Keys
				from rn
				order by Score
			) t
		where @WithTies = 1
		union all
		select *
		from (select top(@Top) Keys
				from rn
				order by Score
			) t
		where @WithTies = 0
		--select *
		--from (select top(@Top) with ties Keys
		--		from rec
		--		order by DigitID desc
		--	) t
		--where @WithTies = 1
		--union all
		--select *
		--from (select top(@Top) Keys
		--		from rec
		--		order by DigitID desc
		--	) t
		--where @WithTies = 0
GO
create or alter function fn_AOC_2024_Day21_BreakCodeToPatters(@Code varchar(max)) returns table
as
return select (select Pattern p, count(*) c
				from (select [value] + iif(ordinal < max(ordinal) over(), 'A', '') Pattern
						from string_split(@Code, 'A', 1)
					) p
				where Pattern != ''
				group by Pattern
				for json path
				) Patterns
GO
create or alter function fn_AOC_2024_Day21_WrapDirGetKeypadCodeKeys(@Patterns varchar(max)
																	, @StartChar char(1)
																	, @MaxSteps int
																	, @Top int
																	, @WithTies bit
																		) returns table
as
return with Calc as
			(select s.[value] + iif(ordinal < max(ordinal) over(partition by j.[key]), 'A', '') Pattern, cnt
				from openjson(@Patterns) j
					cross apply (select json_value(j.[value], '$.p') Pattern
									, cast(json_value(j.[value], '$.c') as bigint) cnt
								) p
					cross apply fn_AOC_2024_Day21_GetKeypadCodeKeys(replace(Pattern, 'A', @StartChar), 'B', @MaxSteps, @Top, @WithTies) r
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
create or alter function fn_AOC_2024_Day21_RunMultipleRobots(@Patterns varchar(max)
															, @RobotCount int
															, @Top int
															, @WithTies bit
															) returns table
as
return with rec as
			(select 0 RobotID, @Patterns Patterns
				union all
				select RobotID + 1, cast(n.Patterns as varchar(max))
				from rec r
					cross apply fn_AOC_2024_Day21_WrapDirGetKeypadCodeKeys(r.Patterns, 'B', 3, @Top, @WithTies) n
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

drop table if exists #Numeric
drop table if exists #Input
select [value] K
into #Numeric
from generate_series(0, 10, 1)

;with nm as
	(select a.K FromK, b.K ToK, 'v' Dir
		from #Numeric a
			inner join #Numeric b on b.K = a.K - 3
		where a.K between 4 and 9
		union all
		select a.K FromK, b.K ToK, '^' Dir
		from #Numeric a
			inner join #Numeric b on b.K = a.K + 3
		where b.K between 4 and 9
		union all
		select a.K FromK, b.K ToK, '>' Dir
		from #Numeric a
			inner join #Numeric b on b.K = a.K + 1
									and (b.K - 1)/3 = (a.K - 1)/3
		where a.K > 0
		union all
		select a.K FromK, b.K ToK, '<' Dir
		from #Numeric a
			inner join #Numeric b on b.K = a.K - 1
									and (b.K - 1)/3 = (a.K - 1)/3
		where b.K > 0
		union all select 0, 2, '^'
		union all select 10, 3, '^'
		union all select 2, 0, 'v'
		union all select 3, 10, 'v'
		union all select 0, 10, '>'
		union all select 10, 0, '<'
	)
insert into AOC_2024_Day21_KeypadMap
select cast(isnull(nullif(cast(FromK as varchar(10)), '10'), 'A') as char(1)) FromK
	, cast(isnull(nullif(cast(ToK as varchar(10)), '10'), 'A') as char(1)) ToK
	, Dir
from nm
union all select '<', 'v', '>'
union all select 'v', '<', '<'
union all select 'v', '>', '>'
union all select '>', 'v', '<'
union all select 'v', '^', '^'
union all select '^', 'v', 'v'
union all select '^', 'B', '>'
union all select 'B', '^', '<'
union all select 'B', '>', 'v'
union all select '>', 'B', '^'

;with Codes as
	(select ordinal CodeID, [value] Code
		from string_split(replace(@Input, char(10), ''), char(13), 1)
	)
select CodeID, Code, row_number() over(partition by CodeID order by (select 1)) SolutionID, Patterns
into #Input
from Codes
	cross apply fn_AOC_2024_Day21_GetKeypadCodeKeys(Code, 'A', 5, 1, 1) r
	cross apply fn_AOC_2024_Day21_BreakCodeToPatters(r.Keys)


select sum(cast(replace([value], 'A', '') as bigint)*ln) Answer1
from string_split(replace(@Input, char(10), ''), char(13), 1)
	cross apply (select top 1 ln
					from fn_AOC_2024_Day21_GetKeypadCodeKeys([value], 'A', 5, 1, 1) r
						cross apply fn_AOC_2024_Day21_BreakCodeToPatters(r.Keys) b
						cross apply (select sum(cnt*len(p.Pattern)) ln
										from fn_AOC_2024_Day21_RunMultipleRobots(b.Patterns, 2, 1, 0) rn
											cross apply openjson(rn.Patterns)
											cross apply (select json_value([value], '$.p') Pattern
														, cast(json_value([value], '$.c') as bigint) cnt
														) p
									) l
					order by ln
				) l