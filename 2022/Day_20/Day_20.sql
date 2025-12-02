create or alter function fn_AOC_2022_Day20_WrapIndex(@Index bigint, @NumberCount int) returns table
as
	return select iif(@Index >= 0,
						ActualNumber,
						@NumberCount - ActualNumber%ModNumber)%ModNumber WrappedIndex
			from (select iif(@Index >= 0, @Index, @NumberCount - @Index) ActualNumber) a
				cross apply (select iif(ActualNumber > @NumberCount, @NumberCount, @NumberCount - 1) ModNumber) m
GO
declare @Str nvarchar(max) =
'1
2
-3
3
-2
0
4'
drop table if exists #Input
drop table if exists #rec

;with Input as
	(select row_number() over(order by (select 1)) - 1 InitialIndex, cast([value] as bigint) Num
		from string_split(replace(@Str, char(13), ''), char(10))
	)
select InitialIndex, Num
into #Input
from Input

;with Info as
	(select count(*) NumberCount
		from #Input
	)
	, rec as
	(select (select Num, InitialIndex, InitialIndex CurrentIndex
				from #Input
				for json auto) Numbers, cast(0 as int) Ind
	union all
	select NewNumbers, Ind + 1
	from rec r
		cross join Info
		cross apply (select (select Num, InitialIndex,
										case when CurrentIndex = MoverIndex
												then NewIndex
											when NewIndex >= MoverIndex and CurrentIndex between MoverIndex and NewIndex
												then (select WrappedIndex from fn_AOC_2022_Day20_WrapIndex(CurrentIndex - 1, NumberCount))
											when CurrentIndex between NewIndex and MoverIndex
												then CurrentIndex + 1
											else CurrentIndex
										end CurrentIndex
									from (select Num, InitialIndex, CurrentIndex, max(MoverIndex) over() MoverIndex, max(NewIndex) over() NewIndex
											from openjson(r.Numbers, '$') j
												cross apply (select cast(json_value(j.[value], '$.Num') as int) Num
																, cast(json_value(j.[value], '$.InitialIndex') as int) InitialIndex
																, cast(json_value(j.[value], '$.CurrentIndex') as int) CurrentIndex
															) t
												cross apply (select iif(InitialIndex = Ind, CurrentIndex, null) MoverIndex
																, iif(InitialIndex = Ind, (select WrappedIndex from fn_AOC_2022_Day20_WrapIndex(CurrentIndex + Num, NumberCount)), null) NewIndex) t1
										) t
									for json auto
								) NewNumbers
					) t
		where r.Ind < NumberCount
	)
	, Lst as
	(select top 1 Ind, Numbers
	from rec
	order by Ind desc
	)
	, FinalNumbers as
	(select CurrentIndex, Num
		from Lst
			cross apply openjson(Numbers, '$') j
			cross apply (select cast(json_value(j.[value], '$.Num') as int) Num
							, cast(json_value(j.[value], '$.InitialIndex') as int) InitialIndex
							, cast(json_value(j.[value], '$.CurrentIndex') as int) CurrentIndex
						) t
	)
select sum(Num) Answer1
from FinalNumbers
	cross join Info
	cross apply (values(1000), (2000), (3000)) n(v)
	cross apply (select top 1 CurrentIndex ZeroPosition
					from FinalNumbers
					where Num = 0
				) z
	cross apply fn_AOC_2022_Day20_WrapIndex(ZeroPosition + v, NumberCount)
where CurrentIndex = WrappedIndex
option (maxrecursion 32767)

--Solution2
/*
Had to loop to overcome the 32767 maxrecursion limit, and if I'm already looping, might as well loop per iteration and store only the last line to reduce memory consumption.
Could have probably reached the same with a recursion in a TVF called by an external recursion, but I didn't :)
*/
select cast(0 as int) Iteration
	, cast((select Num*811589153 Num, InitialIndex, InitialIndex CurrentIndex
				from #Input
				for json auto) as varchar(max)) Numbers
	, cast(0 as int) Ind
into #rec

declare @i int = 1
while @i <= 10
begin
	;with Info as
		(select count(*) NumberCount
			from #Input
		)
		, rec as
		(select top 1 Numbers Numbers, 0 Ind
		from #rec
		order by Iteration desc
		union all
		select cast(NewNumbers as varchar(max)), Ind + 1
		from rec r
			cross join Info
			cross apply (select (select Num, InitialIndex,
											case when CurrentIndex = MoverIndex
													then NewIndex
												when NewIndex >= MoverIndex and CurrentIndex between MoverIndex and NewIndex
													then (select WrappedIndex from fn_AOC_2022_Day20_WrapIndex(CurrentIndex - 1, NumberCount))
												when CurrentIndex between NewIndex and MoverIndex
													then CurrentIndex + 1
												else CurrentIndex
											end CurrentIndex
										from (select Num, InitialIndex, CurrentIndex, max(MoverIndex) over() MoverIndex, max(NewIndex) over() NewIndex
												from openjson(r.Numbers, '$') j
													cross apply (select cast(json_value(j.[value], '$.Num') as bigint) Num
																	, cast(json_value(j.[value], '$.InitialIndex') as bigint) InitialIndex
																	, cast(json_value(j.[value], '$.CurrentIndex') as bigint) CurrentIndex
																) t
													cross apply (select iif(InitialIndex = Ind, CurrentIndex, null) MoverIndex
																	, iif(InitialIndex = Ind, (select WrappedIndex from fn_AOC_2022_Day20_WrapIndex(CurrentIndex + Num, NumberCount)), null) NewIndex) t1
											) t
										for json auto
									) NewNumbers
						) t
			where r.Ind < NumberCount
		)
	insert into #rec
	select top 1 @i, *
	from rec
	order by Ind desc
	option (maxrecursion 32767)

	set @i += 1
end

;with Info as
	(select count(*) NumberCount
		from #Input
	)
	, Lst as
	(select top 1 Numbers
	from #rec
	order by Iteration desc
	)
	, FinalNumbers as
	(select CurrentIndex, Num
		from Lst
			cross apply openjson(Numbers, '$') j
			cross apply (select cast(json_value(j.[value], '$.Num') as bigint) Num
							, cast(json_value(j.[value], '$.InitialIndex') as int) InitialIndex
							, cast(json_value(j.[value], '$.CurrentIndex') as int) CurrentIndex
						) t
	)
select sum(Num) Answer2
from FinalNumbers
	cross join Info
	cross apply (values(1000), (2000), (3000)) n(v)
	cross apply (select top 1 CurrentIndex ZeroPosition
					from FinalNumbers
					where Num = 0
				) z
	cross apply fn_AOC_2022_Day20_WrapIndex(ZeroPosition + v, NumberCount)
where CurrentIndex = WrappedIndex