create or alter function fn_AOC_2022_Day17_ShiftShape(@Shape geometry,
														@ShiftX int,
														@ShiftY int) returns table
as
return with Input as
			(select row_number() over(order by (select 1)) ID, [value]
				from string_split(trim('POLYGON ((' from @Shape.ToString()), ' ')
			)
		select geometry::STGeomFromText('POLYGON ((' + string_agg(NewValue, ' ') within group (order by ID), 0) ShiftedShape
		from Input
			cross apply (select cast(trim('))' from trim(',' from [value])) as int) Num) n
			cross apply (select case when ID % 2 = 1 and @ShiftX <> 0
										then Num + @ShiftX
									when ID % 2 = 0 and @ShiftY <> 0
										then Num + @ShiftY
									else Num
								end NewNum) nn
			cross apply (select replace([value], Num, NewNum) NewValue) nv
GO
declare @Gas varchar(max) =
'>><<<>><<<<>>><>><>>><<<>>>><>>><<><<<>>>><<<><<<><<><<<>>>><<><<>>><<<<>><<>><<<><<<<>><<<<><>>><<<<>>><<<>>>><<<>>>><<<<>>><<>>><<>>>><<<<>>>><<<<>><>>>><<<<>>><<>><>>><>>><<<<>>><<>>><>><<<>>>><<>>>><<<>>><<<>>>><<<<><<<><<>>><>><<<<>><>><<><<<<>>><<>>><<<>>>><<<<>>><<>>>><<<<>><>><<<><<>><<<>>>><<<>><<<<>>>><<<><<<<>>><<><>>><<>><<<>>><<<<>>><<>>>><<<>>><<<<>>><<>>>><<<<>><<>>>><<<>>>><<>>><<><<<>>><<<<>>>><<<<>>><<<>>>><<<<>><<<>>>><>>><><<>>><<<><<>>>><<<>>>><<><<<<>>>><<<><<>><<<<>>>><<>>><>>>><<<<>><<>>><<>>><<>><>><><<<<>>>><<<>><<>>><<><<<<>>>><<<<><<<<>>>><><<>>><><>>><<>>><>>><>>>><<>><><<>><>>><<>>>><<>>>><<<<><<<>>>><>><>>>><<<<><<<><<<>>>><<><<>><<<>>><<<<>>><<<<><<>>><<<>>>><<><<<<>><<<<>><<<><>><>>>><><<<>>><<<<><<<<>><>>><<<>><<<<><<<>>>><<<>>>><<<>><<>><<<<>><<<<>><>>>><<>>>><<<<>>><<>>>><<>>>><>><<<>>>><<<<>>><<<<><>>>><<><<<>><<<<>>>><<<<>><>>>><<<>>>><<<<>>>><<<<>>><<<<>><>>><<<<><>>>><<><>>>><>><<>>>><>>>><<>><<>>><<<>>>><<><<<>>>><<><<>><<<<>>><<<>>><<<<>><<<><<<>>><<><<>>>><<<>>><<>>><<<><<<<>>><>>>><<<>>><<<>>>><<><><<>>>><<>>>><<>>>><<>>><<>><<><<<>>><>>><<<<>>>><>>>><<<>><>><<<<>>><<<<>>><<>>><<<<><<<>>><>>>><<>><<<<>><<<<>><<<<><>><<<<>>>><<>>><>><<<>><<>><<<<>><<>>><<<<>>><<<<>>><<><<<>>><<><<<><<>>>><>><<><<<<><<>><<<>>>><><<<<><><><>>><<<>>><<>>><<<>>>><<><<>><<>><<<><<<<>>>><>>>><<>>>><<<>>>><<>>>><<<>><>><<<>>><<>>>><<><<>>>><<<><<<<>>><<<>>>><<<>>><<<><>>><<>>><<<>>>><<<>>>><<<>>>><<<>><>><<<>>><<<<>>>><><<<>>>><<>>>><><>>><<>>>><<>><<>>>><<<>><<<>>>><<>>>><<<<>><<<>><<<>><<>><<<>>><<><>>><<><<><>>>><<<>>>><<<<>><<>>>><<<<>><><<<>>><<<<>><<>>><<<>><<>><<>><>>>><<><<>>>><>>>><<><><<<><<<<>>>><<<<>><<><<><<>>>><>>><<<><<<<><<>><<<><<>><><<><<<>>>><>>>><<>>>><>><><><<<><<><<>>><<<<><<>><<<>>>><<><<<<>>>><<<<>><><<<<>><<>><>><<<<>>>><<>>>><<<<><<<>><<>>><<<>>><>>><<>>>><<<><<<<><<>>>><<<<>><<<>>>><<<>><<<<><<<>><<<<>><<<>>>><<>>>><><>>><>>><<<>>>><<>>><<<>><>>>><<<>>>><<<<><<<>>><<<<>><<>><<>><<<><<<<>>><><>><<<><<<>>><<<><<<<>>>><><<<<>><<>><>>><<<>>>><<>>><<<>><<<<>>><<<>><<>><<>><<<<><<>>><>><<>>><<><<<><<<>><<<<>>><>><><<<<>>>><<<><<<>><>><<>>>><<<>>>><<<><<<>>><<>>><><>><<<>><>>>><<<<>>>><<<<>>><<<<>>><<<<>><<<<><><<>><>><<>>><<>><<><<<<>>>><<<<>>>><<>>>><<<<>>>><<>>>><>>>><<>><<><<<><><>><<<><<<<>>>><<<<>><<<>>>><<<<>>>><>>>><><<<<>><>>><<<<><<>>>><>><<<<>><<<><<<>>>><<>><<>>><>>>><<><>>>><<<<><<><<<>>>><<<>>>><<><>><<<>><<<>><<<<><<>>><>><<>>><<>>><>>>><<<>>><<>><<><><<>>>><<<>>><<<>><<<>>><<<>>>><<>>><>>>><>>>><>>><<>>>><<<>><<<<>><<<<>><<>>>><><>>>><<>>>><<<><<<<><<>>>><<<<>><<<<>>>><><<<><>><<<<>>>><>>>><<<<>>>><<><>><<<<><<<>>><<<<>><>><>>>><<>>>><>>><>>>><>><<>>><<<><>><>>>><<<>><<<>><<<<><<<<>>><<<>>><<<>>>><>><>>><<<<>><<<><<>>><>>><<><>>>><<<>>>><<<<>>>><><<<>>><<<<>>><>><>>>><<<>><<>>>><>>><<<<>>>><<<>><<<>>>><<<<>><<<>>><<<<><<<<>>>><><<<>>><<<<>>>><<<<>><<>><<<>>><>>><>><<>>><<<>><><<><>><<>><>><<<><<<<>>><<<>><<<><<<>>>><<>>><<<<><<><<<>>><<<<>>><<>><>>><>>><<<><<>>>><<<>><<<<><<<>><<<<>><>><<>><>>>><>>>><<>>><<<<>>><><><><<<>>><<<>><<>>><<<<>>>><>><<<>>>><<>><<<<>><<>><>><<<>>>><>>><<<<>>><>><<>>><<<>><<<<>>>><<<>><<>><>><<<<>><<<><<<>><>><<<><<<>>>><<<<>>><<><<<<><<<<>>>><<<><>><<><>>><<<><<><<<<>>><<>>>><>><<<<>><<<<>>><<>>>><>>><<<>>><<<>>>><<>>><>>>><<<<><>><<>>>><<<>>><>>><>><<<>>>><<><<<>>>><<><<<<>>>><<<<>>>><><<<<>>>><<<>>>><<><<<>>>><<>><>><>>><<<<><<<>>>><<<<>>>><<<><<>>>><<<><>>>><<<<>>>><>>><<<>><<<<><<>>><<>>><<>>><>>><<<><><><<<>>>><<>>>><<<<><>>>><<<>><<>>>><<><<<<><<<<>><><<<<><<>>>><<<>><<<<>><<>><<><<>>>><<><<<><<<<><<<<>>><<<>>>><<<<>>><><<<>>><>>>><>>><<<<>>><<<>>><<<<><<<<><<>><><<<>>><>>><<><<><<>><<<<>>>><<<>><<<><<<<>>><<<<>>><<>><<<<>><>>>><>><<<><>>>><<<>>><<><<>><<<><<<>><<<<>><<<<>><<<<><>>>><<><<<>><<<><<<>><<<<><<>>>><<<>><<<><<<>>><<<><<<<>>>><<>>>><<<>><<<<>>><<><<<<>>>><<<<>>>><<>><<><<>>><<>>>><<>>><<>>><<<>>>><<>>><<><<>>><<<>><<<<>>><<>>><<<>>><<<>>><>>>><<<>>>><<<<>>>><>>>><<<>>>><<<>>>><>>>><>>>><<<><<>><><>><<>><><<<>>>><><>>>><><<<><>>><<<>>><<<>>><<<<>><<<<><<<>>><<>><<<<>>><<<>><<>>>><<><<<<>>><>><<<>>>><<>><<<<>>><<<<>>><>>>><<><<<>><<<<>>>><<>>>><<<<><<>><<>>><>>><><<<<>><<><<<>>>><<<<>>>><<<>>><<>>><><><<<<>>>><<>><><<<<><<<<>>>><<>>>><><<<><>>><>>>><<<><<<<>><<<<>>>><<<><<>><>>>><<>>>><<>>><<<><<<><<<<><<<<>><<<<><<<>>><><<<>>><<<>>>><<><<<<>>><>><<><<><>>><<>>><<<<>>>><<>>>><><<<<>>>><<><<<>>><<<><<<<><<<<>><<<>><><<>><<<<><<<><><<<>>><>>>><<<<>>>><<>>><<>>>><<>>>><<<<>><<<>><<>>>><>><>><<>>><<<<><>>><<<>>><<<<>>>><<>><>>>><<><<<<><<>>>><<<>><>>>><<>><>><<<<><<<<>>><>>>><><<<<>><<<>>><><<><>>>><<>>><<<<>>><>>>><<<<>>>><><>><>><<<>><<>><<<><>>>><><<<<>>><<><<<>>>><<<>><<>>><<<>><<<>>>><<>>>><>><><<>>><<>><>>><<<><<<>>>><<<<><<>>><<<>>>><<<<><<<<>>>><>><<<>><<><>>>><><<>>>><<><<<<>><<>>><<><<<>>>><>><<<>><<>>><<>><>>><<<>>><<<<>>><<<<>>>><<<>>>><<<><<>><>><<>>><>>><<>>>><<>>><<<<>>><>>>><<<<>><<<<>>>><<<<><<<>>><>>><<<><<<<><<<>>>><>>><>>>><<>>>><<>>>><<<>>>><><<<>><<>>>><<<><<>><<>>><<>>><<<>><<<><<><<>>>><>>>><<<<><<>>>><<><<<<><>>><<>><<>>><<>>>><<<><>>><<>>><<>>><<>><<<>><<>><<<<>>>><<><<<>>>><<<<>>>><<<>>><><>>><<>>><<>><<<<>>><<><>>>><<<<>>><<>>><<<><>>><>>><<<>>><<<<><<<>>>><<<>>>><<<>><<<<>>>><<<<>>>><<>>><<<<>>>><>>>><<<>>><<<<>>>><<><<<>><<<>>><<<>>><<>>><<<<><>>><<<>>>><<>>>><<<>>>><>><<<<><<<<>><<>>>><<<<>>><>><<<>><<<<><<>>>><<<<>>><<<>>><>><<><<<>>>><<<<>>>><<<<>><<<<>>>><<<<>>><<>>><<<>>>><>>><<<<>><<<<>>>><>>>><<<<><<>>><<<><<>>>><>>><<<>>>><<>>>><<>>><<<<><<<<><<>>>><<>>>><><<<<><>><<<<>>>><<<>><<>><<>>>><<><<<><<<<><<<<>>><><<><<<<>><<>>>><<<<>>>><<<<>>>><<>>>><<<>>>><<>>><<<>>>><<<><<>><>>>><><>><>><<<<>>><<<<><<<>>>><<>>><<<>><><<>><<<<>>>><<<><<<>><<<<>>><<<<>><<>><<>>>><<>>>><>>>><>>><<><<>>>><<<>><><<>>>><<<>>><<>>><<<>>><>>><<<<>><<<<><<<>><<>>>><<<>>><>>><<<<>><<<<>>>><<<<>><<<<><<<<><>>>><><<>>>><>>><<<<>>><<<<>>><>>>><<<><<>>><>>>><><<<<><>>>><>><<<><<>>><<><<<<>>><<<<>>><<<>>><<<>>><<>>>><<>>>><<<>><<<><<>>>><<<<>>><>>><<<><<<><>>><<><<>>>><>>>><<<<>><><<>>>><>><<<>>><>><<<<>>>><<<>>>><<<><><<<>>>><<>><<<>>>><<<><<>>><<>>><>>>><<>><<<<>>>><<>><>><<<>>>><>><<<<><<>><>>>><<<<>>>><<><<<>>>><<>>><<<>>><<<>><>>><<<>>><<<><<<>><<<<>>><<<<>><<>>>><>>><<<<>>><<<<>>><>>>><<<<><<>><<<<><><<<<><<<<>><<<<>>><<>>><>><<><<>>>><><<<><<<<><<<>>><>>>><<<<>>><>>>><>>>><<<<>>><<><>>>><<<<>><<<>>><<>>><<<<>>>><>>>><>>><<>><<<>><<<<>>>><<<<>><>>>><<>>><<<><>>>><<<>>><<<><>>>><<<<>><>><<<>>>><>>>><>>><<><<>>>><<>>><<<<>><<<>>><<>>>><<<>>>><<>>>><<<>>><<>><>>><>>>><<>>>><<<<>><<<><>>><<<>>>><<>><<>><>><<>><>>>><>>><<<>>><>><>><<<><>><<<<>>><<<>>>><<<<><<<<><<><<><<<>>><<<><<>><<>><<<>>>><<>>><<>><<<<>><<>><<<<>><>>><<<>>><<>>>><<>>>><<<<><<>><<<<>><<<<><>><<<<><<<<><<<<>>><<<<>><<<<><<<>><>>><>>><<<<>>>><<<<>><<<<>><><<<>><>>><<><<><<<<>>><<>>>><<<<><<<<>><<>><>><<<>>>><<>>><<<<><>>>><<<<>>><<<>>>><<<>>><<<<>><<<<>>><<>>>><><<<<>>><<<<>><<>><<<><><<<><<<><<>>>><<><<<><<>><<<><<<<>>><<<>>><<<<><<>>><<<><<<>>>><><<>>>><<<<><<<<><<<>>><<>>><<<<>>>><<<><>>><<>><<>><<<<>>><<<<><>>><>>><<>>>><><<<<>><><<<<>>><<>><<<<>>>><<<<>><>>>><>><<<<>>>><<>>><<<>>>><<<>><><<>><<<>>><<<>>>><>>>><<<<>><<>><<<>>><<<>>>><<<>>><<<<><<>>>><<<<>><<><<>>>><<<><>>>><<<>>>><>>>><<>>>><<<><<<><<<<>><>>>><<<<>>><><<>><>>><>>><<<>>>><<><>><>><><<<><>><<>><<<<>>><<<>><<<><<>><<<>>>><<<>>><<<<>>><<<>>>><<<>>><<<<>><<<>><>><<<<>>><<<<><<>>><<<<>>><<<>>><>><<><>>><>>>><<<>><<>>><<>>>><<<>>>><>><<><>>>><<<<><<<<><>><<<<>>><<<>>><<<>>><<<<>><<<<>><<<>><>><<>><<<>><<>>><>><<<<>><>><>><<><>><<>>><<><>><>><>><<>>><<<><<><><<>>><<>>>><><<>>><>>>><<<>>><<>>><<<<>>>><>>><<>>>><<><<<>>>><<<<>><>>>><<<<>>>><<<>>>><>>>><<>>><>>>><><><<<><<<<>><>>><<<<><>>>><<<<>>><<<>><<<<><<<<><<<>>>><<>>>><<<><<<>><<>><<<><<>>><<<>>><><<<>>>><<>><<>><>>><<<<>>>><<<<>><>><<<<>>><<<<>>><><<<>>>><<<>>><<<<>><<<><<<<>><<<>>><<<<>><<<>>>><>>><<><<>>>><<<>><<<<>>>><<<>>>><<<<>><<>>>><>>><<<>><<<><<<<><<<>>>><<<<><<>>>><<<<>><<<<>>><>><<<>><<<<>>><>><<><<>>><<<>><<<<>>><><<<>>><<<>>>><<<<>><<>>>><>>><<<<>><<<><>><<<<>>>><<<>><<<><<<>>>><<<>>>><<<<><><>>><<<>><<<<>>>><<<>>>><>><<>><>><>><<<<>>>><<<<>><>><<<<>>>><<<>>><<>>>><<>>><<>><<>>>><<<>>><<>>>><<<>>>><>><<<<>>><<>>>><><<<>>><<<<><>>><>>><<>>>><<>>>><<<>>>><<>>><<<>>>><>>><<><<>>>><<<>><<>><<<><<<<><<<<>>>><<>><>>>><<>>>><>><<><><<><>>><>>>><<<>>><<<>>><<><<<>>>><<>>>><<<<><><>><<>>><<<<>><<<<>>>><>>><<<<>>><<<><<><<>><<>>><<<><<<<>>>><<>><<<>><<<<>>><<<>><<<<><<<>>>><>>><<>>>><<<>>>><<<><>>>><>>><>><<>>><<>>><<<<><>>>><<>>>><<<<><<><<<<>><<><<<>>>><<<<>><<><<<<>>><>><>>>><<<>>>><>><>>>><<<>>><<><<<<>>>><>>>><>>>><<<>><<>>><<<>>><<<><>><<><<<<><<<<>>>><<<<>><<<<><<<><<<<>>>><>>><<<>><<<<><>>><>><<>>><<>><<>><<<>>><><>><<<>>><><<>>><<<<>>><<<<><>><<<>><<<<>><<<<><<<>>><<<<>>>><><<>>><<<>><<><<>><<>>>><<<<><>>>><<>>><>><<<<>><<<<>>><<>>><<<>>><>><<<><<<>><<<>>>><><>>><<<<>>>><<><>>><<>>>><<<<>><<<<>><<<<><<>>><<>>>><<<><<>>><><<<>>><<<<>><><>>>><<<>>>><<>>>><<>>>><<<<>>><<<<>>>><<<><<<<>>><>>><><>><>>><<>>>><>>><<>>>><>>>><><>>><>>><<<<>><<<<>>><<<<><<<<>>><><>>>><<>><<<<>>><<<>>>><<<>><<<>>><<<>>><<<<><><<<<>>>><<<>>>><<><<<>>><<<>>><>><<><>><<<<>>><>>><<<>><><<<>><<<<>>><>><<<<>>><<>><<<>><<<>>>><<<>><<<>>><<>><>><>>><>>>><<<>>><<<<><<<>>>><<<<>><<<>><<<<>>>><<><<<>><<>>>><<<<><<>>><<<<>><>>>><>>>><<<>>>><>>><<<<>><<>>>><>>>><<<>>><<>>><<<<><<<<>><<><<<>>>><<<<>><<>>><>><><<>>><<<<>><<<<>>>><>>>><<>><<><<<<><<<<>><>><<<>><>><><<<<>>>><<<<><<<<><<<>>><>>><>>><<>><<>>>><<>>><<<>><<<<>>><>><>>><>>><>>><<<<>><><<<<>><<>>><<>>><<<<>>>><<<<>>>><>>><>>><>>>><<<>>>><<<>>><>>><<>>>><<<<><<<<>>><<<>>>><<<>>>><>>><<<<>><<<>><>>>><<>>>><<<<>>><<<<>>>><<<>>>><<<>><<>><<<>><<<>><<<<>>><<<<>>><<<<><<<>><<><><<<<>><<<<><<<>>><<<<>>>><>>>><>>><<>><><<<<>><<<<>><><>>>><<<<>>><<>><<>>>><>>><<<><<>>>><<<<>><<<>>>><<<>>><<<<>>><<>>><<<<><<<<>>><<>><<>>><>>>><<<><<><>>><>>>><<<<>>>><<<<>>><<<><><<<>>>><><<<<>>>><<<<>>>><<><<<<>>><><<>>>><<<>>>><<><<>>><<>>><<>>><<<<>>>><<<<><<<<>>>><>>>><>><<>><><<<><<>>>><<>>>><><<<<>><<>>>><<><<<><>>>><<<<>><<<>>>><<<>><>>><<<<>>><<<<>>><>><<>><><<<<>><<>><<<<>><>>>><>>><<<><<<<>><<<<><>><<<>><<<<>'

drop table if exists #Rocks

;with rec as
	(select cast(0 as int) Cycle, cast(0 as int) Turn, cast(0 as int) ShapeID, 1 IsStopped, Layout, cast(null as int) X, cast(null as int) Y, cast(0 as int) MaxY, cast(0 as int) ShapeCount,
			cast(0 as bit) IsGassy, cast(null as int) GasIndex
	from (select geometry::STGeomFromText(N'POLYGON((0 -1, 0 0, 7 0, 7 -1, 0 -1))',0)  Layout) l
	union all
	select r.Cycle + 1 NewCycle
		, NewTurn
		, NewShapeID
		, isnull(FinalIsStopped, NewIsStopped) IsStopped
		, isnull(NewLayout, r.Layout) Layout
		, isnull(RollbackX, ShiftedX) X
		, isnull(RollbackY, ShiftedY) Y
		, iif(NewMaxY > r.MaxY, NewMaxY, r.MaxY) NewMaxY
		, NewShapeCount
		, cast(NewIsGassy as bit) NewIsGassy
		, cast(NewGasIndex as int) GasIndex
	from rec r
		cross apply (select r.Turn + iif(r.IsStopped = 1 or r.IsGassy = 0, 1, 0) NewTurn) t
		cross apply (select iif(r.IsStopped = 1, 2, r.X) NewX,
							iif(r.IsStopped = 1, r.MaxY + 3, r.Y) NewY,
							iif(r.IsStopped = 1, r.ShapeCount + 1, r.ShapeCount) NewShapeCount,
							iif(r.IsStopped = 1 or r.IsGassy = 0, 1, 0) NewIsGassy,
							iif(r.IsStopped = 1, 0, r.IsStopped) NewIsStopped) p
		cross apply (select iif(r.IsStopped = 1, isnull(nullif(NewShapeCount % 5, 0), 5), r.ShapeID) NewShapeID,
							isnull(nullif(t.NewTurn % len(@Gas), 0), len(@Gas)) NewGasIndex) p1
		cross apply (select choose(NewShapeID,
									geometry::STGeomFromText(concat(N'POLYGON((', NewX, ' ', NewY + 1, ', ', NewX + 4, ' ', NewY + 1, ', ', NewX + 4, ' ', NewY, ', ', NewX, ' ', NewY, ', ', NewX, ' ', NewY + 1, '))'),0),
									geometry::STGeomFromText(concat(N'POLYGON((', NewX + 1, ' ', NewY + 3, ', ', NewX + 2, ' ', NewY + 3, ', ', NewX + 2, ' ', NewY + 2, ', ', NewX + 3, ' ', NewY + 2, ', ', NewX + 3, ' ', NewY + 1, ', ', NewX + 2, ' ', NewY + 1, ', ', NewX + 2, ' ', NewY, ', ', NewX + 1, ' ', NewY, ', ', NewX + 1, ' ', NewY + 1, ', ', NewX, ' ', NewY + 1, ', ', NewX, ' ', NewY + 2, ', ', NewX + 1, ' ', NewY + 2, ', ', NewX + 1, ' ', NewY + 3, '))'),0),
									geometry::STGeomFromText(concat(N'POLYGON((', NewX, ' ', NewY, ', ', NewX + 3, ' ', NewY, ', ', NewX + 3, ' ', NewY + 3, ', ', NewX + 2, ' ', NewY + 3, ', ', NewX + 2, ' ', NewY + 1, ', ', NewX + 2, ' ', NewY + 1, ', ', NewX, ' ', NewY + 1, ', ', NewX, ' ', NewY, '))'),0),
									geometry::STGeomFromText(concat(N'POLYGON((', NewX, ' ', NewY, ', ', NewX, ' ', NewY + 4, ', ', NewX + 1, ' ', NewY + 4, ', ', NewX + 1, ' ', NewY, ', ', NewX, ' ', NewY, '))'),0),
									geometry::STGeomFromText(concat(N'POLYGON((', NewX, ' ', NewY, ', ', NewX, ' ', NewY + 2, ', ', NewX + 2, ' ', NewY + 2, ', ', NewX + 2, ' ', NewY, ', ', NewX, ' ', NewY, '))'),0)
									) Shape,
							choose(NewShapeID, 1, 3, 3, 4, 2) ShapeHight,
							choose(NewShapeID, 4, 3, 3, 1, 2) ShapeWidth) s
		cross apply (select iif(NewIsGassy = 1, substring(@Gas, NewGasIndex, 1), '') GasDirection) g
		cross apply (select case when NewIsGassy = 0
									then NewX
									else case when g.GasDirection = '>' and NewX + ShapeWidth + 1 <= 7
												then NewX + 1
											when g.GasDirection = '<' and NewX - 1 >= 0
												then NewX - 1
											else NewX
										end
								end ShiftedX,
							case when NewIsGassy = 0
									then NewY - 1
									else NewY
								end ShiftedY
					) sxy
		outer apply (select ShiftedShape
						from fn_AOC_2022_Day17_ShiftShape(s.Shape, ShiftedX - NewX, ShiftedY - NewY)
						where (NewX <> ShiftedX
							or NewY <> ShiftedY)
					) sf
		outer apply (select iif(ShiftedShape.STOverlaps(Layout) = 1 or ShiftedShape.STWithin(Layout) = 1, 0, 1) IsShiftAccepted
						where ShiftedShape is not null
					) a
		outer apply (select isnull(a.IsShiftAccepted, 1) IsShiftAccepted
					) a1
		outer apply (select iif(NewIsGassy = 0, 1, 0) FinalIsStopped
							, iif(NewIsGassy = 0, Layout.STUnion(s.Shape), Layout) NewLayout
							, iif(NewIsGassy = 0, NewY + s.ShapeHight, r.MaxY) NewMaxY
							, NewX RollbackX
							, NewY RollbackY
						where a1.IsShiftAccepted = 0
					) ni
	where not (r.ShapeCount = 2022
				and r.IsStopped = 1
			)
	)
--Dump results into temp table to be used in Q2
select *
into #Rocks
from rec
where ShapeCount > 0
	and IsStopped = 1
option (maxrecursion 32767)
create unique clustered index IX_#Rocks on #Rocks(ShapeCount)

select top 1 MaxY Answer1
from #Rocks
order by Cycle desc

--Looping to overcome the 32767 SQL maxrecursion limitation - Need to get at least 4 cycles
declare @MaxShapeCount int
set nocount on
while 1 = 1
begin
	;with Anchor as
		(select top 1 cast(0 as int) Cycle, Turn, ShapeID, IsStopped, Layout, X, Y, MaxY, ShapeCount, IsGassy, GasIndex
			from #Rocks
			order by ShapeCount desc
		)
		select *
		from Anchor
		where ShapeCount <= (select max(CycleEstimatedLength)
							from (select ShapeCount - lag(ShapeCount) over(partition by GasIndex order by ShapeCount) CycleEstimatedLength
									from #Rocks
									where ShapeCount <= 2022
								) t
							where CycleEstimatedLength is not null) * 4
		union all
		select r.Cycle + 1 NewCycle
			, NewTurn
			, NewShapeID
			, isnull(FinalIsStopped, NewIsStopped) IsStopped
			, isnull(NewLayout, r.Layout) Layout
			, isnull(RollbackX, ShiftedX) X
			, isnull(RollbackY, ShiftedY) Y
			, iif(NewMaxY > r.MaxY, NewMaxY, r.MaxY) NewMaxY
			, NewShapeCount
			, cast(NewIsGassy as bit) NewIsGassy
			, cast(NewGasIndex as int) GasIndex
		from rec r
			cross apply (select r.Turn + iif(r.IsStopped = 1 or r.IsGassy = 0, 1, 0) NewTurn) t
			cross apply (select iif(r.IsStopped = 1, 2, r.X) NewX,
								iif(r.IsStopped = 1, r.MaxY + 3, r.Y) NewY,
								iif(r.IsStopped = 1, r.ShapeCount + 1, r.ShapeCount) NewShapeCount,
								iif(r.IsStopped = 1 or r.IsGassy = 0, 1, 0) NewIsGassy,
								iif(r.IsStopped = 1, 0, r.IsStopped) NewIsStopped) p
			cross apply (select iif(r.IsStopped = 1, isnull(nullif(NewShapeCount % 5, 0), 5), r.ShapeID) NewShapeID,
								isnull(nullif(t.NewTurn % len(@Gas), 0), len(@Gas)) NewGasIndex) p1
			cross apply (select choose(NewShapeID,
										geometry::STGeomFromText(concat(N'POLYGON((', NewX, ' ', NewY + 1, ', ', NewX + 4, ' ', NewY + 1, ', ', NewX + 4, ' ', NewY, ', ', NewX, ' ', NewY, ', ', NewX, ' ', NewY + 1, '))'),0),
										geometry::STGeomFromText(concat(N'POLYGON((', NewX + 1, ' ', NewY + 3, ', ', NewX + 2, ' ', NewY + 3, ', ', NewX + 2, ' ', NewY + 2, ', ', NewX + 3, ' ', NewY + 2, ', ', NewX + 3, ' ', NewY + 1, ', ', NewX + 2, ' ', NewY + 1, ', ', NewX + 2, ' ', NewY, ', ', NewX + 1, ' ', NewY, ', ', NewX + 1, ' ', NewY + 1, ', ', NewX, ' ', NewY + 1, ', ', NewX, ' ', NewY + 2, ', ', NewX + 1, ' ', NewY + 2, ', ', NewX + 1, ' ', NewY + 3, '))'),0),
										geometry::STGeomFromText(concat(N'POLYGON((', NewX, ' ', NewY, ', ', NewX + 3, ' ', NewY, ', ', NewX + 3, ' ', NewY + 3, ', ', NewX + 2, ' ', NewY + 3, ', ', NewX + 2, ' ', NewY + 1, ', ', NewX + 2, ' ', NewY + 1, ', ', NewX, ' ', NewY + 1, ', ', NewX, ' ', NewY, '))'),0),
										geometry::STGeomFromText(concat(N'POLYGON((', NewX, ' ', NewY, ', ', NewX, ' ', NewY + 4, ', ', NewX + 1, ' ', NewY + 4, ', ', NewX + 1, ' ', NewY, ', ', NewX, ' ', NewY, '))'),0),
										geometry::STGeomFromText(concat(N'POLYGON((', NewX, ' ', NewY, ', ', NewX, ' ', NewY + 2, ', ', NewX + 2, ' ', NewY + 2, ', ', NewX + 2, ' ', NewY, ', ', NewX, ' ', NewY, '))'),0)
										) Shape,
								choose(NewShapeID, 1, 3, 3, 4, 2) ShapeHight,
								choose(NewShapeID, 4, 3, 3, 1, 2) ShapeWidth) s
			cross apply (select iif(NewIsGassy = 1, substring(@Gas, NewGasIndex, 1), '') GasDirection) g
			cross apply (select case when NewIsGassy = 0
										then NewX
										else case when g.GasDirection = '>' and NewX + ShapeWidth + 1 <= 7
													then NewX + 1
												when g.GasDirection = '<' and NewX - 1 >= 0
													then NewX - 1
												else NewX
											end
									end ShiftedX,
								case when NewIsGassy = 0
										then NewY - 1
										else NewY
									end ShiftedY
						) sxy
			outer apply (select ShiftedShape
							from fn_AOC_2022_Day17_ShiftShape(s.Shape, ShiftedX - NewX, ShiftedY - NewY)
							where (NewX <> ShiftedX
								or NewY <> ShiftedY)
						) sf
			outer apply (select iif(ShiftedShape.STOverlaps(Layout) = 1 or ShiftedShape.STWithin(Layout) = 1, 0, 1) IsShiftAccepted
							where ShiftedShape is not null
						) a
			outer apply (select isnull(a.IsShiftAccepted, 1) IsShiftAccepted
						) a1
			outer apply (select iif(NewIsGassy = 0, 1, 0) FinalIsStopped
								, iif(NewIsGassy = 0, Layout.STUnion(s.Shape), Layout) NewLayout
								, iif(NewIsGassy = 0, NewY + s.ShapeHight, r.MaxY) NewMaxY
								, NewX RollbackX
								, NewY RollbackY
							where a1.IsShiftAccepted = 0
						) ni
		where (r.Cycle % 32767 > 0
				or r.Cycle = 0)
		)
	--Dump results into temp table
	insert into #Rocks
	select *
	from rec
	where Cycle > 0
		and IsStopped = 1
	option (maxrecursion 32767)

	if @@rowcount = 0
		return
end

;with i as
	(select ShapeCount, GasIndex, MaxY, ShapeID
		from #Rocks
		where ShapeCount >= (select max(CycleEstimatedLength)
							from (select ShapeCount - lag(ShapeCount) over(partition by GasIndex order by ShapeCount) CycleEstimatedLength
									from #Rocks
									where ShapeCount <= 2022
								) t
							where CycleEstimatedLength is not null) * 2
	)
	, i1 as
	(select *, lag(ShapeID) over(partition by GasIndex order by ShapeCount) LastShapeID,
			ShapeCount - lag(ShapeCount) over(partition by GasIndex order by ShapeCount) CycleShapes,
			MaxY - lag(MaxY) over(partition by GasIndex order by ShapeCount) CycleHeight
		from i
	), Cycle as
	(select top 1 *
		from i1
		where ShapeID = LastShapeID
		order by ShapeCount
	)
select ClosestMaxY + MissingHeight Answer2
from Cycle c
	cross apply (select 1000000000000 MaxShapeCount) m
	cross apply (select floor((MaxShapeCount - ShapeCount) / CycleShapes) MissingCycleCount) t
	cross apply (select ShapeCount + (MissingCycleCount*CycleShapes) ClosestShapeCount,
					MaxY + (MissingCycleCount*CycleHeight) ClosestMaxY
				) t1
	cross apply (select MaxShapeCount - ClosestShapeCount MissingShapeCount) t2
	cross apply (select top 1 MaxY - c.MaxY MissingHeight
					from #Rocks r
					where r.ShapeCount between c.ShapeCount + 1 and c.ShapeCount + MissingShapeCount
					order by r.ShapeCount desc) t3
