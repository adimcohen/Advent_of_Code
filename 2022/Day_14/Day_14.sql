drop table if exists AOC_2022_Day14_Input1
create table AOC_2022_Day14_Input1(X int, Y int)
GO
create or alter function fn_AOC_2022_Day14_GetMinValue(@j varchar(max)) returns table
as
return select min(cast([value] as int)) MinValue
		from openjson(@j, '$')
GO
create or alter function fn_AOC_2022_Day14_LandSandInt(@CurrentSand varchar(max),
														@SandX int,
														@SandY int,
														@Floor int) returns table
as
return with Layout as
			(select X, Y
				from AOC_2022_Day14_Input1
				union all
				select cast(json_value([value], '$[0]') as int), cast(json_value([value], '$[1]') as int)
				from openjson(@CurrentSand, '$')
			)
			, rec as
			(select @SandX X, @SandY Y, cast(-1 as int) DownY, cast(0 as int) Step
			union all
			select cast(NewX as int) X
					, cast(NewY as int) Y
					, cast(Down.DownY as int) DownY
					, r.Step + 1 Step
				from rec r
					cross apply (select isnull(MinValue, @Floor) - 1 DownY
									from fn_AOC_2022_Day14_GetMinValue('[' + stuff(
																		(select concat(',', l.Y)
																			from Layout l
																			where l.X = r.X
																				and l.Y > r.Y
																			for xml path('')
																		), 1, 1, '') + ']'
																	)
									) Down
					outer apply (select p.X, p.Y
									from (values(r.X - 1, r.Y + 1)) p(X, Y)
									where not exists (select *
														from Layout l
														where l.X = p.X
															and l.Y = p.Y
													)
								) Lt
					outer apply (select p.X, p.Y
									from (values(r.X + 1, r.Y + 1)) p(X, Y)
									where not exists (select *
														from Layout l
														where l.X = p.X
															and l.Y = p.Y
													)
								) Rt
					cross apply (select iif(Lt.X is null, Rt.X, Lt.X) X, iif(Lt.X is null, Rt.Y, Lt.Y) Y, iif(Lt.X is null, 3, 2) Choice) p
					cross apply (select iif(Down.DownY > r.Y
													, r.X
													, p.X) NewX
										, iif(Down.DownY > r.Y
													, Down.DownY
													, p.Y) NewY
								) n
				where NewX is not null
					and r.DownY is not null
					and (NewY < @Floor
						or @Floor is null)
			)
			, LastStep as
			(select top 1 X, Y, DownY
				from rec
				where Step > 0
				order by Step desc
			)
		select X, Y
		from LastStep
		where DownY is not null
GO
create or alter function fn_AOC_2022_Day14_TrimSand(@CurrentSand varchar(max)) returns table
as
return with AllSand as
			(select X, Y
				from openjson(@CurrentSand, '$')
					cross apply (select cast(json_value([value], '$[0]') as int) X, cast(json_value([value], '$[1]') as int) Y) p
			)
			, Layout as
			(select X, Y
				from AOC_2022_Day14_Input1
				union all
				select *
				from AllSand
			)
			, TopLevel as
			(select *
				from AllSand l
				where (select count(*)
						from Layout l1
						where l1.Y = l.Y - 1
							and l1.X between l.X - 1 and l.X + 1
						) < 3
			)
		select concat('[', string_agg(cast(concat('[', X, ',', Y, ']') as varchar(max)), ','), ']') CurrentSand
		from TopLevel
GO
create or alter function fn_AOC_2022_Day14_RunCycle(@CurrentSand varchar(max),
													@SandUnits int,
													@CycleLength int,
													@Floor int) returns table
as
return with rec as
			(select @CurrentSand CurrentSand, @SandUnits SandUnits
			union all
			select ns.CurrentSand, SandUnits + 1
			from rec r
				cross apply fn_AOC_2022_Day14_LandSandInt(r.CurrentSand, 500, 0, @Floor) n
				cross apply (select cast(json_modify(r.CurrentSand, 'append $', json_query(concat('[', X, ', ', Y, ']'))) as varchar(max)) CurrentSand) ns
			where n.X > -1
				and (r.SandUnits % @CycleLength > 0 or r.SandUnits = @SandUnits)
			)
		select top 1 *
		from rec
		where SandUnits > @SandUnits
		order by SandUnits desc
GO
declare @Str varchar(max) =
'498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9'

drop table if exists #Numbers
--Create a numbers table - never leave home without one
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

;with Input as
	(select PathID, StepID, Co, lead(Co) over(partition by PathID order by StepID) NextCo
		from (select row_number() over(order by (select 1)) PathID, [value] Line
				from string_split(replace(@Str, char(13), ''), char(10))
				) p
			cross apply (select row_number() over(order by (select 1)) StepID, '[' + [value] + ']' Co
							from string_split(replace(Line, ' ->', ''), ' ')
							) s
	),
	XY as
	(select cast(json_value(Co, '$[0]') as int) X1, cast(json_value(Co, '$[1]') as int) Y1
			, cast(json_value(NextCo, '$[0]') as int) X2, cast(json_value(NextCo, '$[1]') as int) Y2
		from Input
		where NextCo is not null
	)
insert into AOC_2022_Day14_Input1
select distinct x.Num X, y.Num Y
from XY
	cross apply (select iif(X2 >= X1, X1, X2) X1,
						iif(Y2 >= Y1, Y1, Y2) Y1,
						abs(X2 - X1) XRange,
						abs(Y2 - Y1) YRange
				) r
	inner join #Numbers x on x.Num between r.X1 and r.X1 + XRange
	inner join #Numbers y on y.Num between r.Y1 and r.Y1 + YRange

create unique clustered index IX_AOC_2022_Day14_Input1 on AOC_2022_Day14_Input1(X, Y)
create unique index IX_AOC_2022_Day14_Input1a on AOC_2022_Day14_Input1(Y, X)

--Takes ~35 seconds
;with rec as
	(select cast('[]' as varchar(max)) CurrentSand, 0 SandUnits
	union all
	select ts.CurrentSand, n.SandUnits
	from rec r
		cross apply fn_AOC_2022_Day14_RunCycle(r.CurrentSand, r.SandUnits, 100, null) n
		cross apply fn_AOC_2022_Day14_TrimSand(n.CurrentSand) ts
	)
select max(SandUnits) Answer1
from rec
option (maxrecursion 32767)

--Takes ~1:10 hours
;with f as
	(select max(Y) + 2 Flr
		from AOC_2022_Day14_Input1)
	, rec as
	(select cast('[]' as varchar(max)) CurrentSand, 0 SandUnits, flr
		from f
	union all
	select ts.CurrentSand, n.SandUnits, flr
	from rec r
		cross apply fn_AOC_2022_Day14_RunCycle(r.CurrentSand, r.SandUnits, 100, Flr) n
		cross apply fn_AOC_2022_Day14_TrimSand(n.CurrentSand) ts
	)
select max(SandUnits) + 1 Answer2
from rec
option (maxrecursion 32767)