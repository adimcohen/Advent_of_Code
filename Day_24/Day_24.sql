drop table if exists AOC_2022_Day24_Blizzards
create table AOC_2022_Day24_Blizzards(X tinyint,
										Y tinyint,
										Direction char(1),
										XLength tinyint,
										YLength tinyint
										)
GO
create or alter function fn_AOC_2022_Day24_MoveBlizzards(@Minute int) returns table
as
return select distinct n.X, n.Y
		from AOC_2022_Day24_Blizzards b
			cross apply (select *
							from (values('^', X, (YLength - @Minute%YLength + Y) % YLength)
										, ('v', X, (@Minute + Y) % YLength)
										, ('>', (@Minute + X) % XLength, Y)
										, ('<', (XLength - @Minute%XLength + X) % XLength, Y)
								) BM(Dir, X, Y)
							where Dir = Direction
						) n
GO
create or alter function fn_AOC_2022_Day24_GetMovementOptions(@X tinyint,
																@Y smallint,
																@XLength tinyint,
																@YLength tinyint) returns table
as
return select X, Y
		from (values(@X, @Y)
					, (@X, @Y - 1)
					, (@X, @Y + 1)
					, (@X + 1, @Y)
					, (@X - 1, @Y)
			) n(X, Y)
		where X between 0 and @XLength - 1
			and (Y < @YLength or (X = @XLength - 1 and Y = @YLength))
			and (Y >= 0 or (X = 0 and Y = -1))
GO
create or alter function fn_AOC_2022_Day24_GetNewScenarios(@Scenarios varchar(max)
															, @Minute int
															, @StartingX tinyint
															, @StartingY smallint
															, @EndX tinyint
															, @EndY smallint
															, @StartingMinute int) returns table
as
return with Maxes as
			(select top 1 XLength, YLength
				from AOC_2022_Day24_Blizzards
			)
			, Scenarios as
			(select cast(json_value([value], '$.X') as int) X
					, cast(json_value([value], '$.Y') as int) Y
				from openjson(@Scenarios, '$')
			)
			, FilteredScenarios as
			(select X, Y
				from Scenarios
					cross apply (select abs(X - @StartingX) + abs(Y - @StartingY) DistanceCovered,
										@Minute - @StartingMinute MinutesPassed) d
				where MinutesPassed - DistanceCovered < 30
			)
			, Moves as
			(select m.X, m.Y, iif(m.X = @EndX and m.Y = @EndY, 1, 0) IsOver
				from Scenarios s
					cross join Maxes
					cross apply fn_AOC_2022_Day24_GetMovementOptions(X, Y, XLength, YLength) m
					left join fn_AOC_2022_Day24_MoveBlizzards(@Minute) b on b.X = m.X
																and b.Y = m.Y
				where b.X is null
			)
			, Moves1 as
			(select distinct X, Y
					, max(IsOver) over() IsOver
				from Moves
			)
		select cast((select distinct X, Y
						from Moves1
						where IsOver = 0
						order by X desc, Y desc
						for json path
						) as varchar(max)) NewScenarios
GO
create or alter function fn_AOC_2022_Day24_GoSomewhere(@StartingX tinyint
														, @StartingY smallint
														, @EndX tinyint
														, @EndY smallint
														, @StartingMinute int
														) returns table
return with rec as
			(select cast((select @StartingX X, @StartingY Y
							from (select 1 a) t
							for json path
							) as varchar(max)) Scenarios
					, @StartingMinute Mnt, @StartingX StartingX, @StartingY StartingY, @EndX EndX, @EndY EndY, @StartingMinute StartingMinute
				union all
				select NewScenarios, Mnt + 1, StartingX, StartingY, EndX, EndY, StartingMinute
				from rec
					cross apply fn_AOC_2022_Day24_GetNewScenarios(Scenarios
																	, Mnt + 1
																	, StartingX
																	, StartingY
																	, EndX
																	, EndY
																	, StartingMinute)
				where NewScenarios is not null
			)
		select max(Mnt) + 2 LastMinute
		from rec
GO
declare @Str varchar(max) =
'#.####################################################################################################
#>^<.v^^v>>^>vv..<><v.<^<^<v.^>>^<>>><><<>^v^>.^<>><<^vv><^<>>vv^v.<.^v><<<>.<v><<^v<v^<>.<vv<>vv<<v>#
#<v<vv><^>v<><.<<^^<>^>v<^vvvv^<<v<<^.^.^>.<><^><<^v<^><<v>vv<<>>>^.^<>>>^vvv^><^v^^>>><<vvv>><<><><.#
#>.vv^^^<^>v>vvv>^.<v<>...v^<>v<><<..vvv<^<<v>^>^<^v^>><^^v.v>>><^.^>vv^^v>v<^^.vv<v<v<>>^^>v>vvv^v><#
#.<v>^^<^v^^<^>>^>><v>^vv>^<v<v^^<>^v><v<^<>>.v^>^.v^><vvv^.^.>vvv^.v.>.>^<^.<^>><^><v<<v>^^>><><^^^<#
#<^<<v^vvv>>><>^^>>v.v.v^^>^<>><^>>^^><v>v<^.^.v<..>>>.>>.<^<^^^>.<>^^.v^>>>v>v>^^v>^><>><<.^.^>vv^^.#
#<^^>^v><..v^v<^.<vv^v<.<>.<>.^v^>^^>>v^^v.<.^><>^v.^^v>v<^^vv<<^^v<>><>^<v>>^<><v^.>>>>^v.>v.><.>v>>#
#<>.<<v.><^><<>>v><><>^..^v^<v>v<v.<>^<>>^v.^^>>.v^.<v>v>.v.v<>v.<.vv<<^<>^^^^>>.<vv<><<>vv>^>.v^<^>>#
#<.^<vv<><v^^<^v^.<><>v>>>.<<v<<v>>v^..v<<>^>^v>>.<>>v<^>^>^<vvv<><<<..v><<<v>><v<^v^<<^vvv>^>^<v<vv<#
#>^>^v>><<>>.^<>>^.^<v>^>>.<v^>v<<>vv><.v<.^^^>v<v>.v^v^.>>^^^vvvv<^<^<v>^.^<>v<^.^<>v>>vv<>>^^^>v>><#
#>><^<<v<>>^<^>v>v^v><v<v><^v>v>^>^<>>^v>vv^>^v<vv^v>.<^><.vv^^^<^><..<<<>^>^.^>>>^<>.^<^>^<>^^v>v<v>#
#><<><v><v^v>.v>^.<^><^^v><<<<<.^>>.^^<v>v>>^<^<>.^.>>>.>>.^v>v.<^^v^<^<>v<>^^<v^><<^^^<><v^>v>v<^.v<#
#<v>.v<<><vvv^<>^^^<<v<v^v^><v.><<.^^>vvv^>^v>v><><<.v>v<<<><..>>v>>v><^^>^^.^>v.v..>^><^.<>^<<^<<v<<#
#<vv<<vvv<vv>v><<.v<v<><.>^vv.^<<<<<<<v<^<^v^v>.v><vv<v^>^^^.^vv<<v>.<<><>>><^<^.^<>^>^<>v.v.v^><v<<.#
#.>^.>vv<v<><vv^v.^v<.^.v<><>^^>^.>v^<><v<<><vv<<^v>^>v<>^v>v>>v<>^<v.<v^^<<v><<.^<^>.vv.>>^.vv<><v><#
#>>v>>>.v<v<^^>><^^v^>>v>v^>>^<v^^^^.vv.^vv<vv><v^v<>^v<>>>>^^v>^<v<v^<>><>.v>>v..^>..<v<<>.v<<.<^>v<#
#<><^>>v^<^^vv>v<v.>.v.<^v.^>vvv<^>v><^>v><><.v>>.^^>><<>.v^<<^.<.^^.<v><v.^.v<^^^^<^<^>vv<v<.v<<v<^>#
#<<^^<<^vvv<<<<.^vv^.><<vv>v^><>..^.^^v>v>^^<<v>^v.v>^v><>>^v><<.v>v<>^v<v<>v<^v^.^<vv>>^>v>^><<v><.<#
#<<>v.v>...^^.<<^>>.<>^^^v>^<^><v<<<><<vv^.v^>.v^.>>^<v>>^<v^^<v>>vv<<>.>>.v^v><.^v.>^>^><^^v^^v<v>^<#
#<^vv^<><<<v^^<^>>v><^<<v^^v^>>^>v<>.<>>v>v<><v.>v<><<<<.<<.<<>>>><><vv><^v<<<^>v<^<^^<v^><^<..v>.vv>#
#><^>>>.^.>v<^^>>vv<v><^<<v.<.>^<^<^v>vv>v^^><.^.^>>.v.>v^.>>^<>^^^>vvv>..v^vv<^v>>v<><><<<^^<<v>^^<>#
#>^<vv>^v<<.<<v>^><><>>v.>.^<>^^vv<<>>>v^<>>><<v.v>>^<<vv<^vvv><><.v><.vv^v^.v.>vv^<><.v^>vv.<<<v<><<#
#>v<^>>.>>v>v>><^>^>^.^>^>vv>^<<><^v.<vvv<^.><>>v>v>^<>><^>^^<>v>v>.<^v^>>>v^>vvv.>.>^<><>.v^vv><>^>>#
#>><>v^>^>>^>^^>^>^<^>>vv>>>>>>vvv.v>.^v<v<vvv<<>.<^v.vv.v>^>>vv<<v^>^^^^>>^v.^v>>v<vvv<.<>^^<^v<<<.<#
#<>vv<^v>v^<v>>^<<>v^>vvvv>v^><^>^v<v^^^>><^><<.^>v^vv.v<<<>..v<^<.vv>.v>^>>>^^v^v^<^v^<^^<<vv>.>.>><#
#<<<v><>v.><v>><v^<^>><>^<vv><<.<<<<.v^v>v>v>.><>.<v><^.<^>^^><v>vv.<v>.v.>>.^>^>v<^vvvv>><>^^v<^>v>.#
#>.^>^>.<v.v<.<>vv<v<>^v<.>^>v<^v^>.>^<^..v<>>v.v>^.v<^>>^^^<v.<>v><v.^v^.>vv<<^<v^<.^^^.^>>.v>.vv.^.#
#<^v><>.<^v<v<^v<vv^^>.>v^^<v>^<.<^^<<.^>vv^^<^>v<v<^<v^^>vv^v>v^^>>..v^>.<v>v>v<v^<>^<^><.>^>>><<v.<#
#>>^<vv.<<>v.<>v.^>>^^vv^<^>vv<^>v.v>>.^.v^.v<v>^<>^.>><^>v>.>>v^<^>.>>^v<<v<<^^<vvvvv><^>^>v^^^^>^v>#
#<^.>^v>^<>>^.^<>.>..><>.<v^v^vv^>v^..v<<><>>^.^><^^<^^<^v<<^<^>.<><^.>^<^vv^>>>>^^>>><v<<<<^><.>^>.<#
#.v<>><^^vv^<<v^v><<<v<<<v><>><>>v^>v>^^^v<<<<<<>.^v<>.^<><<^vv<^>>v.^><v>v<^v>^v><v>>v<^^>vv.^<^>.>.#
#>^<.>v^^^><<v><>^.>vvv>v^<^>v><<<><><.^>>.>vv.^<<<<<^<^>^>v<^^<^<><v<.<>v<<><<v<^>>v>>>^<>>>.<<^<^<<#
#>^^>.vv^><.>v<vv>^><>v><^<v.<v^>.^><v<v>v^>^<v^v>v<<v^^<^>.^<v<vv<.>>v>v^v.<vv^^^^><v>^<>^v^>vv>>vv>#
#><>^<^^>^>v<^^<vv^<<^>v<>>v^>^v.v.v>^^><^<<<<>v>vv<v>^^<v>>.v<><<^><^^<<>>>>^>v>^>><><^>v><^^><v^^>>#
#><<<v<v><>^vv.^<>^>><v>vv^v^v<<v.v<v^>>vvvv^v<^<v^.><^^v><><v<^^<>><<>v^vv<^>v><>><<<^>>^^<^>><>v<v<#
#>^v><>v<>>^v>^<v^<vv><>^^>>>>v><v^v^>>>v<^<<<<<v<^<>>v><^<<^^^<^<>v<>^<v><^.>>><<^v.<>v^^.>>^^.^>^v<#
####################################################################################################.#'

drop table if exists #Numbers

--Number Table
;with rec as
	(select 1 Num
	union all
	select Num + 1
	from rec
	where Num <= 32767
	)
select Num
into #Numbers
from rec
option (maxrecursion 32767)
create unique clustered index IX_#Numbers on #Numbers(Num)

;with rws as
	(select row_number() over(order by (select 1)) - 2 Y, [value] rw
		from string_split(replace(@Str, char(13), ''), char(10))
	)
	, xy as
	(select Y, Num - 2 X, substring(rw, Num, 1) Direction, len(rw) - 2 XLength, max(Y) over() YLength
		from rws
			inner join #Numbers on Num between 2 and len(rw) - 1
		where Y > - 1
	)
insert into AOC_2022_Day24_Blizzards
select X, Y, Direction, XLength, YLength
from xy
where Y < YLength
create unique clustered index IX_AOC_2022_Day24_Blizzards on AOC_2022_Day24_Blizzards(X, Y)

select GoThere.LastMinute Answer1
from (select top 1 0 StartingX, -1 StartingY, XLength - 1 EndX, YLength - 1 EndY, 0 StartingMinute
		from AOC_2022_Day24_Blizzards) sp 
	cross apply fn_AOC_2022_Day24_GoSomewhere(StartingX
											, StartingY
											, EndX
											, EndY
											, StartingMinute) GoThere
option (maxrecursion 32767)

select GoThereAgain.LastMinute Answer2
from (select top 1 0 StartingX, -1 StartingY, XLength - 1 EndX, YLength - 1 EndY, 0 StartingMinute
		from AOC_2022_Day24_Blizzards) sp 
	cross apply fn_AOC_2022_Day24_GoSomewhere(StartingX
											, StartingY
											, EndX
											, EndY
											, StartingMinute) GoThere
	cross apply fn_AOC_2022_Day24_GoSomewhere(EndX
											, EndY + 1
											, StartingX
											, StartingY + 1
											, GoThere.LastMinute) GoBack
	cross apply fn_AOC_2022_Day24_GoSomewhere(StartingX
											, StartingY
											, EndX
											, EndY
											, GoBack.LastMinute) GoThereAgain
option (maxrecursion 32767)