/*
Works for this kind of cube:
   [A][B]
   [C]
[E][D]
[F]
*/

drop table if exists AOC_2022_Day22_Map
drop table if exists AOC_2022_Day22_TransitionRules
drop table if exists AOC_2022_Day22_SideBoundaries

create table AOC_2022_Day22_Map(RowID bigint,
								ColID int,
								MapObjectType char(1),
								RightWall int,
								LeftWall int,
								DownWall bigint,
								UpWall bigint, 
								RightEnd int, 
								LeftEnd int, 
								DownEnd bigint,
								UpEnd bigint)
GO
--Caching transition side rules
;with TransitionRules as
	(select 'A' FromSide, 0 Facing, 'B' NewSide, 101 NewColID, cast(null as int) NewColIDAddToColID, cast(null as int) NewColIDAddToRowID, null NewRowID, cast(null as int) NewRowIDAddToColID, 0 NewRowIDAddToRowID, 0 NewFacing
		union all select 'A', 1, 'C', null, 0, null, 51, null, null, 1
		union all select 'A', 2, 'E', 1, null, null, null, null, -151, 0
		union all select 'A', 3, 'F', 1, null, null, null, 100, null, 0
		union all select 'B', 0, 'D', 100, null, null, null, null, -151, 2
		union all select 'B', 1, 'C', 100, null, null, null, -50, null, 2
		union all select 'B', 2, 'A', 100, null, null, null, null, 0, 2
		union all select 'B', 3, 'F', null, -100, null, 200, null, null, 3
		union all select 'C', 0, 'B', null, null, 50, 50, null, null, 3
		union all select 'C', 1, 'D', null, 0, null, 101, null, null, 1
		union all select 'C', 2, 'E', null, null, -50, 101, null, null, 1
		union all select 'C', 3, 'A', null, 0, null, 50, null, null, 3
		union all select 'D', 0, 'B', 150, null, null, null, null, -151, 2
		union all select 'D', 1, 'F', 50, null, null, null, 100, null, 2
		union all select 'D', 2, 'E', 50, null, null, null, null, 0, 2
		union all select 'D', 3, 'C', null, 0, null, 100, null, null, 3
		union all select 'E', 0, 'D', 51, null, null, null, null, 0, 0
		union all select 'E', 1, 'F', null, 0, null, 151, null, null, 1
		union all select 'E', 2, 'A', 51, null, null, null, null, -151, 0
		union all select 'E', 3, 'C', 51, null, null, null, 50, null, 0
		union all select 'F', 0, 'D', null, null, -100, 150, null, null, 3
		union all select 'F', 1, 'B', null, 100, null, 1, null, null, 1
		union all select 'F', 2, 'A', null, null, -100, 1, null, null, 1
		union all select 'F', 3, 'E', null, 0, null, 150, null, null, 3
	)
select *
into AOC_2022_Day22_TransitionRules
from TransitionRules
GO
select 'A' Side, 51 MinColID, 100 MaxColID, 1 MinRowID, 50 MaxRowID
into AOC_2022_Day22_SideBoundaries
union all select 'B', 101, 150, 1, 50
union all select 'C', 51, 100, 51, 100
union all select 'D', 51, 100, 101, 150
union all select 'E', 1, 50, 101, 150
union all select 'F', 1, 50, 151, 200
GO
create or alter function fn_AOC_2022_Day22_GetDirectionInfoPart2(@RightWall int,
																@LeftWall int,
																@UpWall int,
																@DownWall int,
																@Facing tinyint
															) returns table
as return select *, isnull(nullif(ColGain, 0), RowGain) Gain
			from (values(0, 1, 0, @RightWall) --Right
						, (1, 0, 1, @DownWall) --Down
						, (2, -1, 0, @LeftWall) --Left
						, (3, 0, -1, @UpWall) --Up
				) Directions(Facing, ColGain, RowGain, Wall)
			where Facing = @Facing
GO
create or alter function fn_AOC_2022_Day22_GetFirstSpotOnNewSide(@ColID int,
														@RowID int,
														@Facing tinyint
														) returns table
as return select n.ColID NewColID, n.RowID NewRowID, tr.NewFacing, iif(n.MapObjectType = '.', 1, 0) CanWrap
			from AOC_2022_Day22_SideBoundaries b
				inner join AOC_2022_Day22_TransitionRules tr on tr.FromSide = b.Side
															and tr.Facing = @Facing
				inner join AOC_2022_Day22_SideBoundaries b1 on b1.Side = tr.NewSide
				inner join AOC_2022_Day22_Map n on n.ColID = coalesce(tr.NewColID, abs(@ColID + NewColIDAddToColID), abs(@RowID + NewColIDAddToRowID))
												and n.RowID = coalesce(NewRowID, abs(@ColID + NewRowIDAddToColID), abs(@RowID + NewRowIDAddToRowID))
			where @ColID between b.MinColID and b.MaxColID
				and @RowID between b.MinRowID and b.MaxRowID
GO
create or alter function fn_AOC_2022_Day22_GetNextColRowPart2(@HittingAWall bit,
																@Wall int,
																@ColID int,
																@RowID int,
																@ColGain int,
																@RowGain int,
																@Facing tinyint
																) returns table
as return with bnd as
				(select b.MinColID, b.MinRowID, b.MaxColID, b.MaxRowID
					from AOC_2022_Day22_SideBoundaries b
					where @ColID between b.MinColID and b.MaxColID
						and @RowID between b.MinRowID and b.MaxRowID
				)
			select coalesce(mnCol.PlannedColID
							, mxCol.PlannedColID
							, mnwCol.PlannedColID
							, mnwRow.PlannedColID
							, mxwCol.PlannedColID
							, mxwRow.PlannedColID
							, p.PlannedColID) NewColID
					, coalesce(mnRow.PlannedRowID
							, mxRow.PlannedRowID
							, mnwCol.PlannedRowID
							, mnwRow.PlannedRowID
							, mxwCol.PlannedRowID
							, mxwRow.PlannedRowID
							, p.PlannedRowID) NewRowID
					, coalesce(mnwCol.NewFacing
							, mnwRow.NewFacing
							, mxwCol.NewFacing
							, mxwRow.NewFacing
							, @Facing) NewFacing
					, nullif(coalesce(mnwCol.CarryOverSteps
										, mnwRow.CarryOverSteps
										, mxwCol.CarryOverSteps
										, mxwRow.CarryOverSteps), 0) CarryOverSteps
			from bnd
				cross apply fn_AOC_2022_Day22_GetFirstSpotOnNewSide(@ColID, @RowID, @Facing) ns
				cross apply (select @ColID + @ColGain PlannedColID, @RowID + @RowGain PlannedRowID) p1
				cross apply (select case when @ColGain > 0 and @HittingAWall = 1
											then @Wall - 1
										when @ColGain < 0 and @HittingAWall = 1
											then @Wall + 1
										else p1.PlannedColID
									end PlannedColID,
									case when @RowGain > 0 and @HittingAWall = 1
											then @Wall - 1
										when @RowGain < 0 and @HittingAWall = 1
											then @Wall + 1
										else p1.PlannedRowID
									end PlannedRowID
								) p
				outer apply (select MinColID PlannedColID
								where @HittingAWall = 0
									and CanWrap = 0
									and p.PlannedColID < MinColID
							) mnCol
				outer apply (select MinRowID PlannedRowID
								where @HittingAWall = 0
									and CanWrap = 0
									and p.PlannedRowID < MinRowID
							) mnRow
				outer apply (select MaxColID PlannedColID
								where @HittingAWall = 0
									and CanWrap = 0
									and p.PlannedColID > MaxColID
							) mxCol
				outer apply (select MaxRowID PlannedRowID
								where @HittingAWall = 0
									and CanWrap = 0
									and p.PlannedRowID > MaxRowID
							) mxRow
				outer apply (select ns.NewColID PlannedColID, ns.NewRowID PlannedRowID, ns.NewFacing, abs(MinColID - p.PlannedColID - 1) CarryOverSteps
								where @HittingAWall = 0
									and CanWrap = 1
									and p.PlannedColID < MinColID
							) mnwCol
				outer apply (select ns.NewColID PlannedColID, ns.NewRowID PlannedRowID, ns.NewFacing, abs(MinRowID - p.PlannedRowID - 1) CarryOverSteps
								where @HittingAWall = 0
									and CanWrap = 1
									and p.PlannedRowID < MinRowID
							) mnwRow
				outer apply (select ns.NewColID PlannedColID, ns.NewRowID PlannedRowID, ns.NewFacing, p.PlannedColID - MaxColID - 1 CarryOverSteps
								where @HittingAWall = 0
									and CanWrap = 1
									and p.PlannedColID > MaxColID
							) mxwCol
				outer apply (select ns.NewColID PlannedColID, ns.NewRowID PlannedRowID, ns.NewFacing, p.PlannedRowID - MaxRowID - 1 CarryOverSteps
								where @HittingAWall = 0
									and CanWrap = 1
									and p.PlannedRowID > MaxRowID
							) mxwRow
GO
create or alter function fn_AOC_2022_Day22_CalculateFacing(@CurrentFacing tinyint,
															@Direction char(1)
															) returns table
as
return select cast((@CurrentFacing + DirectionImpact + 4)%4 as tinyint) NewFacing
		from (select iif(@Direction = 'R', 1, -1) DirectionImpact) di
GO
--Works only for the full scale input (ranges are hard coded)
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
			, MinColID LeftEnd
			, MaxColID RightEnd
			, MinRowID UpEnd
			, MaxRowID DownEnd
		from FullMap
			inner join AOC_2022_Day22_SideBoundaries on ColID between MinColID and MaxColID
													and RowID between MinRowID and MaxRowID
	)
select *
from MapInfo

insert into AOC_2022_Day22_Map
select RowID, ColID, MapObjectType
	, iif(RightWall > RightEnd, null, RightWall) RightWall
	, iif(LeftWall < LeftEnd, null, LeftWall) LeftWall
	, iif(DownWall > DownEnd, null, DownWall) DownWall
	, iif(UpWall < UpEnd, null, UpWall) UpWall
	, RightEnd, LeftEnd, DownEnd, UpEnd
from MapInfo
where MapObjectType <> ''

create unique clustered index IX_AOC_2022_Day22_Map on AOC_2022_Day22_Map(ColID, RowID)
create unique index IX_AOC_2022_Day22_Map1 on AOC_2022_Day22_Map(RowID, ColID)

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
		from AOC_2022_Day22_Map
		where MapObjectType = '.'
		order by RowID, ColID
	)
	, rec as
	(select cast(0 as int) MovementID, cast(InstructionID as int) InstructionID, cast(ColID as int) ColID, cast(RowID as int) as RowID, cast(Facing as tinyint) Facing, cast(null as int) CarryOverSteps
		from StartingPoint
		union all
		select MovementID + 1
			, cast(iSteps.ID as int) InstructionID
			, cast(nxt.NewColID as int)
			, cast(nxt.NewRowID as int)
			, cast(case when nxt.CarryOverSteps is not null or iNextDirection.Instruction is null
						then nxt.NewFacing
					else (select NewFacing from fn_AOC_2022_Day22_CalculateFacing(nxt.NewFacing, iNextDirection.Instruction))
				end as tinyint) Facing
			, nxt.CarryOverSteps
		from rec r
			inner join #Instructions iSteps on iSteps.ID = r.InstructionID + iif(CarryOverSteps is null, 2, 0)
			outer apply (select *
							from #Instructions iNextDirection
							where iNextDirection.ID = iSteps.ID + 1
						) iNextDirection
			inner join AOC_2022_Day22_Map m on m.RowID = r.RowID
											and m.ColID = r.ColID
			cross apply (select isnull(CarryOverSteps, cast(iSteps.Instruction as int)) Steps) s
			outer apply fn_AOC_2022_Day22_GetDirectionInfoPart2(RightWall, LeftWall, UpWall, DownWall, r.Facing) d
			cross apply (select r.ColID + ColGain * s.Steps PlannedColID, R.RowID + RowGain * s.Steps PlannedRowID) p
			cross apply (select iif(Wall is not null
									and ((ColGain > 0 and PlannedColID >= Wall)
										or (ColGain < 0 and PlannedColID <= Wall)
										or (RowGain > 0 and PlannedRowID >= Wall)
										or (RowGain < 0 and PlannedRowID <= Wall)
										), 1, 0) HittingAWall) hw
			outer apply fn_AOC_2022_Day22_GetNextColRowPart2(HittingAWall, Wall, r.ColID, r.RowID, ColGain*s.Steps, RowGain*s.Steps, r.Facing) nxt
	)
select top 1 RowID * 1000 + ColID * 4 + Facing Answer2
from rec
order by MovementID desc
option (maxrecursion 32767)