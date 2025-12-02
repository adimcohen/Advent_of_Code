--Single-Line table function to keep the query inline
create or alter function fn_Day9_GetNextTailPosition(@HX int,
													@HY int,
													@TX int,
													@TY int) returns @t table(Next_X int, Next_Y int)
as
begin
	insert into @t(Next_X, Next_Y)
	select case when @HX - @TX = 2 or (@HX - @TX = 1 and abs(@HY - @TY) = 2)
							then @TX + 1
						when @TX - @HX = 2 or (@TX - @HX = 1 and abs(@HY - @TY) = 2)
							then @TX - 1
						else @TX
					end,
				case when @HY - @TY = 2 or (@HY - @TY = 1 and abs(@HX - @TX) = 2)
							then @TY + 1
						when @TY - @HY = 2 or (@TY - @HY = 1 and abs(@HX - @TX) = 2)
							then @TY - 1
						else @TY
					end
	return
end
GO
declare @Str varchar(max) =
'R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2'

drop table if exists #Steps
drop table if exists #Numbers

--Number Table
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

--Parse and explode steps
select row_number() over(order by I.ID, Num) StepID, Direction
into #Steps
from (select row_number() over(order by (select 1)) ID, [value]
		from string_split(replace(@Str, char(10), ''), char(13)) i
		) i
	cross apply (select left([value], 1) Direction,
						cast(substring([value], 3, len([value])) as int) StepCount) i1
	inner join #Numbers with (forceseek) on Num <= StepCount
create unique clustered index IX_#Steps on #Steps(StepID)

--Solution #1
;with rec as
	(select cast(0 as int) HX, cast(0 as int) HY, cast(0 as int) TX, cast(0 as int) TY, cast(0 as int) s, cast(null as char(1)) LastDirection
		union all
		select h.New_HX, h.New_HY, t.Next_X, t.Next_Y, cast(s.StepID as int), cast(Direction as char(1))
		from rec r
			inner join #Steps s on s.StepID = r.s + 1
			cross apply (select case Direction
									when 'L' then HX - 1
									when 'R' then HX + 1
									else HX
								end New_HX,
								case Direction
									when 'U' then HY + 1
									when 'D' then HY - 1
									else HY
								end New_HY) h
			cross apply fn_Day9_GetNextTailPosition(New_HX, New_HY, TX, TY) t
	)
	, d as
	(select distinct TX, TY
		from rec
	)
select count(*) Answer2
from d
option (maxrecursion 32767)

--Solution #1
;with rec as
	(select cast(0 as int) HX, cast(0 as int) HY, cast(0 as int) TX, cast(0 as int) TY, cast(0 as int) s, cast(null as char(1)) LastDirection
			, cast(0 as int) K1X, cast(0 as int) K1Y
			, cast(0 as int) K2X, cast(0 as int) K2Y
			, cast(0 as int) K3X, cast(0 as int) K3Y
			, cast(0 as int) K4X, cast(0 as int) K4Y
			, cast(0 as int) K5X, cast(0 as int) K5Y
			, cast(0 as int) K6X, cast(0 as int) K6Y
			, cast(0 as int) K7X, cast(0 as int) K7Y
			, cast(0 as int) K8X, cast(0 as int) K8Y
		union all
		select h.New_HX, h.New_HY, t.Next_X, t.Next_Y, cast(s.StepID as int), cast(Direction as char(1))
			, cast(k1.Next_X as int), cast(k1.Next_Y as int)
			, cast(k2.Next_X as int), cast(k2.Next_Y as int)
			, cast(k3.Next_X as int), cast(k3.Next_Y as int)
			, cast(k4.Next_X as int), cast(k4.Next_Y as int)
			, cast(k5.Next_X as int), cast(k5.Next_Y as int)
			, cast(k6.Next_X as int), cast(k6.Next_Y as int)
			, cast(k7.Next_X as int), cast(k7.Next_Y as int)
			, cast(k8.Next_X as int), cast(k8.Next_Y as int)
		from rec r
			inner join #Steps s on s.StepID = r.s + 1
			cross apply (select case Direction
									when 'L' then HX - 1
									when 'R' then HX + 1
									else HX
								end New_HX,
								case Direction
									when 'U' then HY + 1
									when 'D' then HY - 1
									else HY
								end New_HY) h
			cross apply fn_Day9_GetNextTailPosition(h.New_HX, h.New_HY, K1X, K1Y) k1
			cross apply fn_Day9_GetNextTailPosition(k1.Next_X, k1.Next_Y, K2X, K2Y) k2
			cross apply fn_Day9_GetNextTailPosition(k2.Next_X, k2.Next_Y, K3X, K3Y) k3
			cross apply fn_Day9_GetNextTailPosition(k3.Next_X, k3.Next_Y, K4X, K4Y) k4
			cross apply fn_Day9_GetNextTailPosition(k4.Next_X, k4.Next_Y, K5X, K5Y) k5
			cross apply fn_Day9_GetNextTailPosition(k5.Next_X, k5.Next_Y, K6X, K6Y) k6
			cross apply fn_Day9_GetNextTailPosition(k6.Next_X, k6.Next_Y, K7X, K7Y) k7
			cross apply fn_Day9_GetNextTailPosition(k7.Next_X, k7.Next_Y, K8X, K8Y) k8
			cross apply fn_Day9_GetNextTailPosition(k8.Next_X, k8.Next_Y, TX, TY) t
	)
	, d as
	(select distinct TX, TY
		from rec
	)
select count(*) Answer2
from d
option (maxrecursion 32767)