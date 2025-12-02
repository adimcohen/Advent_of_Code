create or alter function fn_AOC_2022_Day22_GetDirectionInfo(@RightWall int,
																@LeftWall int,
																@UpWall int,
																@DownWall int,
																@RightEnd int,
																@LeftEnd int,
																@UpEnd int,
																@DownEnd int,
																@Facing tinyint
															) returns table
as return select *, isnull(nullif(ColGain, 0), RowGain) Gain
			from (values(0, 1, 0, @RightWall, @RightEnd) --Right
						, (1, 0, 1, @DownWall, @DownEnd) --Down
						, (2, -1, 0, @LeftWall, @LeftEnd) --Left
						, (3, 0, -1, @UpWall, @UpEnd) --Up
				) Directions(Facing, ColGain, RowGain, Wall, EndOfMap)
			where Facing = @Facing
GO
create or alter function fn_AOC_2022_Day22_GetNextColRow(@Gain int,
														@HittingAWall bit,
														@Wall int,
														@PlannedColRow int,
														@CanWrap bit,
														@MapMin int,
														@MapMax int
														) returns table
as return select coalesce(mn.PlannedColRow, mx.PlannedColRow, mnw.PlannedColRow, mxw.PlannedColRow, p.PlannedColRow) PlannedColRow
				, coalesce(mnw.CarryOverSteps, mxw.CarryOverSteps) CarryOverSteps
			from (select case when @Gain > 0 and @HittingAWall = 1
								then @Wall - 1
							when @Gain < 0 and @HittingAWall = 1
								then @Wall + 1
							else @PlannedColRow
						end PlannedColRow
					) p
				outer apply (select @MapMin PlannedColRow
								where @HittingAWall = 0
									and @CanWrap = 0
									and @Gain < 0
									and @PlannedColRow < @MapMin
							) mn
				outer apply (select @MapMax PlannedColRow
								where @HittingAWall = 0
									and @CanWrap = 0
									and @Gain > 0
									and @PlannedColRow > @MapMax
							) mx
				outer apply (select @MapMax PlannedColRow, abs(@MapMin - @PlannedColRow - 1) CarryOverSteps
								where @HittingAWall = 0
									and @CanWrap = 1
									and @Gain < 0
									and @PlannedColRow < @MapMin
							) mnw
				outer apply (select @MapMin PlannedColRow, @PlannedColRow - @MapMax - 1 CarryOverSteps
								where @HittingAWall = 0
									and @CanWrap = 1
									and @Gain > 0
									and @PlannedColRow > @MapMax
							) mxw
GO
create or alter function fn_AOC_2022_Day22_CalculateFacing(@CurrentFacing tinyint,
															@Direction char(1)
															) returns table
as
return select cast((@CurrentFacing + DirectionImpact + 4)%4 as tinyint) NewFacing
		from (select iif(@Direction = 'R', 1, -1) DirectionImpact) di
GO
declare @Str varchar(max) =
'        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5'

drop table if exists #Map
drop table if exists #Instructions
drop table if exists #Numbers

--Number Table
;with rec as
	(select 0 Num
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
	(select left(InputStr, Ind - 1) Map
		from (select replace(@Str, char(13), '') InputStr) i
			cross apply (select charindex(char(10) + char(10), InputStr, 1) Ind) i1
	)
	, rws as
	(select row_number() over(order by (select 1)) RowID, [value] rw
		from Input
			cross apply string_split(Map, char(10))
	)
	, FullMap as
	(select RowID, Num ColID, MapObjectType
		from rws
			inner join #Numbers on Num between 1 and len(rw)
			cross apply (select trim(substring(rw, Num, 1)) MapObjectType) mot
	)
	, MapInfo as
	(select *
			, min(iif(MapObjectType = '#', ColID, null)) over(partition by RowID order by ColID rows between 1 following and unbounded following) RightWall
			, max(iif(MapObjectType = '#', ColID, null)) over(partition by RowID order by ColID desc rows between 1 following and unbounded following) LeftWall
			, min(iif(MapObjectType = '#', RowID, null)) over(partition by ColID order by RowID rows between 1 following and unbounded following) DownWall
			, max(iif(MapObjectType = '#', RowID, null)) over(partition by ColID order by RowID desc rows between 1 following and unbounded following) UpWall
			, max(iif(MapObjectType <> '', ColID, null)) over(partition by RowID) RightEnd
			, isnull(max(iif(MapObjectType = '', ColID, null)) over(partition by RowID order by ColID rows between unbounded preceding and current row) + 1, min(ColID) over(partition by RowID)) LeftEnd
			, max(iif(MapObjectType <> '', RowID, null)) over(partition by ColID) DownEnd
			, isnull(max(iif(MapObjectType = '', RowID, null)) over(partition by ColID order by RowID rows between unbounded preceding and current row) + 1, min(RowID) over(partition by ColID)) UpEnd
		from FullMap
	)
select RowID, ColID, MapObjectType, RightWall, LeftWall, DownWall, UpWall, RightEnd, LeftEnd, DownEnd, UpEnd
into #Map
from MapInfo
where MapObjectType <> ''
create unique clustered index IX_#Map on #Map(ColID, RowID)
create unique index IX_#Map1 on #Map(RowID, ColID)

;with Input as
	(select substring(InputStr, Ind + 2, len(InputStr)) Instructions
		from (select replace(@Str, char(13), '') InputStr) i
			cross apply (select charindex(char(10) + char(10), InputStr, 1) Ind) i1
	)
	, Chrs as
	(select Num ID, substring(Instructions, Num, 1) Chr
	from Input
		inner join #Numbers on Num between 1 and len(Instructions)
	)
	, Chrs1 as
	(select ID, Chr, isnumeric(lead(Chr) over(order by ID)) IsNextCharNumeric
		from Chrs
	)
	, Chr2 as
	(select ID, iif(isnumeric(Chr) = 1, isnull(min(iif(isnumeric(Chr) = 0, ID, null)) over(order by ID rows between 1 following and unbounded following) - 1, ID), ID) ID1, Chr
		from Chrs1
	)
	, Chr3 as
	(select ID1, string_agg(Chr, '') within group (order by ID) Instruction
		from Chr2
		group by ID1
	)
select row_number() over(order by ID1) ID, Instruction
into #Instructions
from Chr3

create unique clustered index IX_#Instructions on #Instructions(ID)

;with StartingPoint as
	(select top 1 ColID, RowID, -1 InstructionID, 0 Facing
		from #Map
		where MapObjectType = '.'
		order by RowID, ColID
	)
	, rec as
	(select cast(0 as int) MovementID, cast(InstructionID as int) InstructionID, cast(ColID as int) ColID, cast(RowID as int) as RowID, cast(Facing as tinyint) Facing, cast(null as int) CarryOverSteps
		from StartingPoint
		union all
		select MovementID + 1
			, cast(iSteps.ID as int) InstructionID
			, NewColID
			, NewRowID
			, case when nxt.CarryOverSteps is not null or iNextDirection.Instruction is null
						then r.Facing
					else (select NewFacing from fn_AOC_2022_Day22_CalculateFacing(r.Facing, iNextDirection.Instruction))
				end Facing
			, nxt.CarryOverSteps
		from rec r
			inner join #Instructions iSteps on iSteps.ID = r.InstructionID + iif(CarryOverSteps is null, 2, 0)
			left join #Instructions iNextDirection on iNextDirection.ID = iSteps.ID + 1
			left join #Map m on m.RowID = r.RowID
							and m.ColID = r.ColID
			cross apply (select isnull(CarryOverSteps, cast(iSteps.Instruction as int)) Steps) s
			outer apply fn_AOC_2022_Day22_GetDirectionInfo(RightWall, LeftWall, UpWall, DownWall, RightEnd, LeftEnd, UpEnd, DownEnd, r.Facing) d
			cross apply (select r.ColID + ColGain * s.Steps PlannedColID, R.RowID + RowGain * s.Steps PlannedRowID) p
			cross apply (select iif(Wall is not null
									and ((ColGain > 0 and PlannedColID >= Wall)
										or (ColGain < 0 and PlannedColID <= Wall)
										or (RowGain > 0 and PlannedRowID >= Wall)
										or (RowGain < 0 and PlannedRowID <= Wall)
										), 1, 0) HittingAWall) hw
			outer apply (select top 1 iif(e.MapObjectType = '.', 1, 0) CanWrap
							from #Map e
							where HittingAWall = 0
								and ((e.RowID = r.RowID
										and ((d.ColGain > 0 and e.ColID = m.LeftEnd)
												or (d.ColGain < 0 and e.ColID = m.RightEnd)
											)
									)
									or (e.ColID = r.ColID
										and ((d.RowGain > 0 and e.RowID = m.UpEnd)
												or (d.RowGain < 0 and e.RowID = m.DownEnd)
											)
									))
						) cw
			outer apply (select nxt.PlannedColRow NewColID, r.RowID NewRowID, nxt.CarryOverSteps
							from fn_AOC_2022_Day22_GetNextColRow(Gain, HittingAWall, Wall, PlannedColID, CanWrap, LeftEnd, RightEnd) nxt
							where ColGain <> 0
							union all
							select r.ColID NewColID, nxt.PlannedColRow NewRowID, nxt.CarryOverSteps
							from fn_AOC_2022_Day22_GetNextColRow(Gain, HittingAWall, Wall, PlannedRowID, CanWrap, UpEnd, DownEnd) nxt
							where RowGain <> 0
						) nxt
	)
select top 1 RowID * 1000 + ColID * 4 + Facing Answer1
from rec
order by MovementID desc
option (maxrecursion 32767)