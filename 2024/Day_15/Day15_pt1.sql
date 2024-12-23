drop table if exists AOC_2024_Day15_Rocks
create table AOC_2024_Day15_Rocks(r int,
									c int
								)
create unique clustered index IX_AOC_2024_Day15_Rocks on AOC_2024_Day15_Rocks(r, c)
GO
create or alter function fn_AOC_2024_Day15_Move(@r int,
												@c int,
												@Boxes varchar(max),
												@Dir char(1),
												@MaxRow int,
												@MaxCol int
											) returns table
as
return with Boxes as
			(select p.*
				from string_split(@Boxes, ',')
					cross apply (select cast(parsename([value], 2) as int) r, cast(parsename([value], 1) as int) c) p
			)
			, i1 as
			(select *
					, lag(c, 1, -1) over(partition by r order by c) NextWest
					, lead(c, 1, 9999) over(partition by r order by c) NextEast
					, lag(r, 1, -1) over(partition by c order by r) NextNorth
					, lead(r, 1, 9999) over(partition by c order by r) NextSouth
				from Boxes
			)
			, i2 as
			(select r, c
					, max(WestEnd) over(partition by r order by c) WestEnd
					, min(EastEnd) over(partition by r order by c desc) EastEnd
					, max(NorthEnd) over(partition by c order by r) NorthEnd
					, min(SouthEnd) over(partition by c order by r desc) SouthEnd
				from i1
					cross apply (select iif(NextWest < c - 1, c, null) WestEnd
										, iif(NextEast > c + 1, c, null) EastEnd
										, iif(NextNorth < r - 1, r, null) NorthEnd
										, iif(NextSouth > r + 1, r, null) SouthEnd
								) e
			), i3 as
			(select b.r + case Dir
								when '^' then -1
								when 'v' then 1
								else 0
							end r
					, b.c + case Dir
								when '<' then -1
								when '>' then 1
								else 0
							end c
					, Dir
				from i2 b
					left join AOC_2024_Day15_Rocks r on (@Dir = '^' and r.r = NorthEnd - 1 and r.c = b.c)
													or (@Dir = 'v' and r.r = SouthEnd + 1 and r.c = b.c)
													or (@Dir = '<' and r.r = b.r and r.c = WestEnd - 1)
													or (@Dir = '>' and r.r = b.r and r.c = EastEnd + 1)
					cross apply(select iif(r.r > 0, 1, 0) Rock
									, iif((@Dir = '^' and @r = SouthEnd + 1 and @c = b.c)
												or (@Dir = 'v' and @r = NorthEnd - 1 and @c = b.c)
												or (@Dir = '<' and @r = b.r and @c = EastEnd + 1)
												or (@Dir = '>' and @r = b.r and @c = WestEnd - 1)
											, 1, 0) Robot
									, iif((@Dir = '^' and NorthEnd = 1)
											or (@Dir = 'v' and SouthEnd = @MaxRow)
											or (@Dir = '<' and WestEnd = 1)
											or (@Dir = '>' and EastEnd = @MaxCol)
													, 1, 0) Wall
								) r1
					cross apply (select iif(Robot = 1
												, iif(Rock = 1 or Wall = 1, '', @Dir)
												, null
											) Dir
								) d
				)
			, i4 as
			(select string_agg(cast(concat(r, '.', c) as varchar(max)), ',') Boxes, iif(max(Dir) = '', '', isnull(max(Dir), @Dir)) Dir
				from i3
			)
		select Boxes
			, @r + case when Dir = '^' and @r > 1 and Rock = 0 then -1
						when Dir = 'v' and @r < @MaxRow and Rock = 0 then 1
						else 0
					end r
			, @c + case when Dir = '<' and @c > 1 and Rock = 0 then -1
						when Dir = '>' and @c < @MaxCol and Rock = 0 then 1
						else 0
					end c
		from i4
			left join AOC_2024_Day15_Rocks r on (@Dir = '^' and r.r = @r - 1 and r.c = @c)
											or (@Dir = 'v' and r.r = @r + 1 and r.c = @c)
											or (@Dir = '<' and r.r = @r and r.c = @c - 1)
											or (@Dir = '>' and r.r = @r and r.c = @c + 1)
			cross apply(select iif(r.r > 0, 1, 0) Rock
						) r1
GO
declare @Input varchar(max) =
'##################################################
#......O.O..O......O......O..OO...O..O.O.O..O..O.#
#....O.O..#.O....O#.#.#......O.O#O.O#O#..O.O.....#
#.........O..#O......O...OO..O..O..O#....O.......#
#.O.O......O#.#..#.#.........O...OOO.O..O..O....O#
#..O......O.......O..O.#O......OO.O.O#..O.OO..O..#
#O.O.....O.O......O....O..OO...#.#...O##OO#O.....#
#O..O....OOOO...#.O.O.O#.....##.....O#.##..O.....#
#O..O.O....O.#..O.O.OO#O.#..#.O....O..O.#.....O..#
##..OOOO..O..#O.#.O....O...............OO.....O..#
#O.O#.........OO..O..#..O.....O..O...O#.....O....#
#..#O#O#...#....O...OOOO..O.....#O.......O.......#
#..........O...O.....#OOOO#O..#..O..#O.........O.#
##..O.OO.O......#...#OOO.OO..O.O.O.OO#.#OO..O.OO.#
#....O.O..OO.O.OOO..OO...O...O..O.O.O....O...O...#
#O..#OO.........O#......OOO....O.....O.OO.#.O.##.#
#.O.OOO.....O....O...#O.O.O.#.O.O..........O...OO#
#.OO.OO...O...O..#........O.O...O.O...#OO.O....O.#
#OO...O.OO.#O.....OOO.#O#.O.#......OO.....OO#..O.#
#..O......O.....#...#O.....O.....OOO.....O.#OO...#
#.....#O..O..#...OOO.#O.O..O.O#...#OO.O......O..##
#..OO.OOO#.O.....OO..#.OO......OO.O....O...O.....#
#.O.OO..............#..O.....O.O...OO.....#.O#...#
#......OO.....OOO.O..O#OO...OO..O#..O..O.OO......#
#.#O....O....O..#O..O..O@..#..#...#......O.......#
#.#..O.O.OO...O.O#....O..#..O...OOOOO...#.OOO#...#
##O..O.O....#O....OO#O.#O......O.....O..O...#O...#
#...O...........O.#O..O.#...#.O.O.O...........#.##
#O#O.......O..O.....OO.#O.O.#OOOO#.O.O.O.O.......#
##O.O..OO...#.O..#.O.O..OOO.O.O#.....O.O..#.O.O.O#
#..OO...O..#O.O.#.OOO.....OO........#..OO.#...O.##
#O.#.#..#.O.O...O..O.#O..O.O.OO......O.OO.O...O.##
#.O.OO...OO.........#....O.OO.OO..O#O.#O........##
#.......O.......OO#...#....#.OOO#.#........#.O...#
#...O.O.#.O.O.........OOO.O.O...O....O....#...O#.#
#....O.O.......#.......#..O##.O.O.....O...O.O...O#
#.O.O.O..O#.O.O...##O#O...O.....#OO#O.O....O..O..#
#O.O.O.#..O...O.O.......#.OO..#..........O...O.O.#
#...O...O.....O....##......#..OO....##.O..OO.....#
#..OO..O..O..OOO.....#O..OO.O.OOOO.#.O...O.#.....#
#...O...O.O.O...O.#O.#.O...O#.#......O..OO..O.##O#
#...O.O#......OO.#.O.....OO..O.......#...#.O...#.#
##OO..#O.....OO..............#...O#..O#......OOO.#
##OOOO..O.#..O.O....O....O..O#.O#....O....O.O....#
#.....#......O...OOO.O........O....#O.OO.....OO.O#
#O.#....OO#....OO.O....#O#........#.#.OO.#.O...OO#
#.O.....O.OO.....OO...#O..OOO.O...OO....O.O##O...#
##O..OO.OO..#..O.O.O.##O......O..#....OOO....OO..#
#O..O....O.........OO#.#......OO...##.O.......O..#
##################################################

>v><^>^v^v^^v><><>^><>>v<><<^<><>>v<^><^>><<<^v<>v>^<v>>><<<<^^<<^v>vv><>>v^<^>^^^^>v<<^<<>v<^^>v^v>>^v^v<<vv>^v^>v^v^^^>>vv<<><^^v<v^v<<<v^<v><<^>>^v<>vv^v<v<vv><<^^vvv<<^^v>^vv>v<v>>v>^v<^<^>^>><>><^>><>^>>v<vv<v^^<>^vv><v^<><>^vv^<<^>><<<>v^>^vv<v<^^^^^^<><v<<^vv^><>^<vv^<>v<>v<v<^<><<>^<v>v><<>^<<<^>vv<<^v^<<v>v<<v^v<v>v>v^<>^v<<v^><^>v^<>vv<v^^>>>>^v<v^><<vv^><v<>v^<^>^>v>>>>^^<<^<<<^^>>^><<v^>>^^^vv>^<<vvv<>v^<v^vv>vvv^<^>v>^<>>vv^^^><v>v<<vv<^<^vv>>>^v>>^>>^^^v<>^vv<<^<>vv>^<vv^>^<>v<^<<^>><>v><>vv<^v^>^v>>><<>^^<<<^><<^^^^>vv^^v^><<v^^v^v>v>^<^^<>v^><v^>^<>^<>>^<><^^<>><>^^^^v^v<<><^><^^v>v>>>>^^^>^^>^>vvv<>^>>v><vv<>^v>>^>^^v^v>^>^v^^>^<<<>v>vv<<<>><^><>><v^<><>>><>>>>>^<v><<>><>^><v><<>>^><^v><v>^<v>>v<vv>>>>vv^^^v^v<<<vv>^>vv^v^^^v><v^<>v<^^<^^>^<v^^<<>>v<^v^<v>^>^<<^<>^>v^^<vv<>^><>>vv^>v<vv><>>^v<<>^^>vvv>v^v<>^<^v^>>v>v^^<^>v>^^^<><>^^v^^>vv>^>v>^v<><<><<><>v>v><^>v^<>v<><^><><<>>>>^v^>><^><<>><>><vv^v>vv^^<<>>>>^v<^vv>>v>v<>^>^v^^<>>^>>v>v>^^><^<^^<^^><v^^<v<<^^<^<>^^v<<
v<<<v><>vv^v<>vv<>>>><v^^v>^<<><^<^v<>>^^<^^<>>>><^v<^>^^^v^^<>>v>^>>vvvv^<>>>^<><<><><>^^<<><v<>v<<>^v<^v>>^<^v<v<v>>^^<<vv<><<^^^>v<<v><^^<><<<v<^vv^>>v<vv><vv>>v>><^v>>v<>>v<vv<v>>^<^^<>>^<v^>^><^>v><^<<^<^^<<>^<<v^^v^<^<v^><<<v>>^v><<v^^^vv<>>^^^v^>^^^^^>><><<<<^^^^<v^v><<<<v^>>^v>v^>>^>>^<v^<v><>^<<^v<^<>^^><v<>><<<^><vv^>^><vv<^>v<<<^<<<>v<^>>v^>v>>^<^^^v^>>v^<v<><>>^>>v^vv<v^v>><<<v<^^<vv>vvv>>>v^v<<>^^v>^>^<>vv^^<^<<>>^^>^v^>v^v^v><><^v<>>vvv<^>^>v^^<^>^^>v^^^v^v^><>v<><^^<>>^vv^>^^^<^<v<<>^<>vv<><^<>>^>^^>^>vv><v^>v>vv>^v^^v>v>^>^^^^^<<<v>vv>>^vv^v<<><^vv>>>><v<>^vv^<>^>^vv<vv>v^^v><v>v<<v<^^vvv>>^^v<<v>>v><>^v>^v<>^<v>>v<<<^<^<<v^v<><>v^<<>v>>^vv>v^vv<vv^^<><^^^^<^^>v><^<>>v>v>><<<v<<^^^<<>v>>><v<v^vv<v<v<<<^<>^^>^><v><^v><<vv>^^v^v<v>>v^>v>v<<^<^<><vv<<<^<<^^^<>>v<^^v^<<>^>^v<vv<<>>v>>v^v<^vv^>v^v<v>>>^v>>^<<^^<v^v^^<^>^^^v<v>^<^v<><vv^^v<<v>>v>v^>v^^<<<<^^<>^vvv<v<vvv^v><v<>^>^<^v><<^v<^<^>^v>^<<<<^>v^v^<vv<>>v<v^v^<v>>^<v^v^^v^>v<<<^>v<^<v<>>vvvv<<^v<>^^^>v<^vvvvv>><^^>>>^
>>v<<^><>vv^v>vv<<><>><<vv<^<^^v^<<<>v^^v<^<^><v^><<>vv^>^vvv<^<v<v<>>^<><<<^v^><v>^v<v^^>><v<<>v<<<<>v<>^>v<v<<<v>>^>>><^vvv<^<>>^<^<vv<vvv^^<^^v<^<v>^>vv>v<<<>^>>v>>><^<^<^<<>>^v<>>>v>>^<^v>v>v^^><><^<<>v<>vv>^<<<^>><>v^^v<^vv^^vv<>v><^^v^<^<<^vv<<v>>v><<<v<vvv>^^>^<<>^^^^^v<^>^>^^^^^<^>v^<^^^v^^vv^v^<vvvv<vv<vvv^<vvv^v<>^^^<>v^<>>^<vv>>vvvv^<v^><^^>v^^>v^^<v>>>v>^^^<v^<v^^>>^^v^<^>^vv<>><><<<<>>><<<><v^>^<>^<>>>>v><vv><<<v<<^>>^^>><<^^v>>^>v>v^^<<>^<v>^vv^^<>vvv>v<^v^<^^^v><vv<>^<<<>^v^>^^>>v^vv<vv>vv>vv>v<>>v<<^^v>^<^v><^v<<<>^^v^<<^^>^><>^>^^<^>v^vv<<^><>vvv<^<^<<<vv^v>v^><<v><v>>^v^><>^>vv><<>^<^>>^<<<<<^v<v<^^v^^^v>vv>^v^<<>v>vv^>^><vv^v^><v^>><>^vvv>>^<^>^>^><<>>vvvvvvv>^v^<<<v<^v<v^v^><<^v>v^<v<<v><v<<<<><^^v><<<<><v<><^<^>^v^>v<>>v<^>^^>v>>^>>^<^^^>^^>>><vv^<>^<>>><^<>^>>v>>vv>v<vv^>v<><<^>v<><>^<><v<<>^><>^>>^vv>v<v>^><v>v>>^v<<>^>v>>^><><^<><<<>v^<^^^v^^>v<><<vv^<^^>v^v>>>>>v<<>>^>v<>vv>v>>v>>v<v>^<^><v^><>v><^^<<<^<<^v<^v^^^<<v^>>^<v>^^v>v^>>>>v>^v<^<<<v><<>v^<<>v<>vvvv>v^
><v^^^<vv^<v><><^^vv>vv><v^>>^v^>^v<^^^<v><>vv>^v>^vvvv>v^>v<v<v<v<>vv^^v^v^v<v>^v>^><^>v^^<>><^vvv<v^^>>v<<^^<>><<v^v<<<<<^<<<>^^^>v^v^>>^<>vvv>^<>><<<v>v^v^v>^^<^v^>>>^^>>><>^>^vv><<^^^>vvv^^>>^^<<^v<<v>>vv^^<vvv<vv<<<<>>><<v^v>^><>^^>v^^><^^<v<<^^<^^^^v^<<>>><v<vvv<<>^v>>v>v<v^v<vv<><>^><v<v^<^^>v^<v<^>>vv^v^>^>>>^>>^<vvvv<<v>^v<<vvv>^v<<vvv<<<<>vv>v>>^><>^^>^^>v<^<v<>v>>v<>v<<vvv<>><><^>^vv><v^v>>>^^<^^><<><<v^^^>><><<>>v<v<^>>>>>>>^<>^<^<<v^v^^vvv^v>v>^v<^<<>><v<v^>vv^<v<>><<^<><v^^vvv<<vv>><<^v<>v<^^>>>v^vv>>>><<<^v>^^vv^<>^>^^^><>v^<>v^>v<v^v>>>^<v^^v^>^>^^^v<v^<><>>v^^>>>v<vv<v>v>>v^v>^vv<v^<>><><<v<v^>>v^>^>>^<><>v>>^<<<>>vv<>>>vv<v<<v^v>v<<<^<^^>v>^v>v<<^vv<^^v<><v^>^v<<v<^v^>>^<>v>v>><v<>vv>^^v>^^v<><<<^>>^<v>><^>^^^<^<<v<^^<><vv^<>v>^v<<<^<v<vv>>>v<<<v^<><^<><^<v^vv<v>v<>^><^^v><^v><>>^>v<<>>^>^v<>>^v>>v>v<<^<<>><<vv<>><<>>^>^<<><<><vv>^vv>^>v<^>v^^>v>>>>v<^>v>^v>>>v>vvvvvv<v^<v<^<^><vvv><>>><v>v<<<^^^^><^v>>vv>>^v>v<^>^^>v<><<^vv^vv>v^<v>v>v<v><v<^<v>^v><><<>^^>>vv<v>><<>>
^v><>v^^<^>>>vv^>^^>^v>^^<v<v<>^<<^>^>vvv>><^v<^^><>^v>>^^>v<<^>><<>^<v>^><<>vv<^>>^<>v<vv^v>^>vvvv>v<>^<<^^<v<vv<^^v^v^^^<>^<^<v<>>v<>>^<<v<^vv^>^v^^>>^^^^<<^vvv<><<^>>><v<<v>^<^<>^<v^><<v^^^vv<<v^<vv>v<<><^^>>><^><<^^v><<^^>><>>^vv<v^v>^v<>v^v^<<<v^>^><<<^v>^>^^>^^>^vv<^vv^>><^^^<<<<v<v>^v^vv^<>><>^<vv<^^<v^^v^^<>v^v^^vvv^>>^^>vv>>><><<<<^v>>>^v<v<v<vvv<v^><<>>>>>><^^<^<^<v<v<vv^<v><v^^><v<^<<^^>>>>^^<><<^><><vv<^>v^v<<><<v>><><v><v><^><v<vvv>^v^^^^^<v<<>^<<^<^<>^><v<v>v><><vv>v^<v>><>v^^<>^^<v>^<^v<>>^^v^<v^<v>v^^^v<<<v^v^>v>v>v><v<<><v^<<<<<<vv>>^v^>^<v>>^^<v>>^<^<><>v><v>v>^<<v<v<v^<>><>>^^^<^v^<v<><v<v<^v<^vv>v>>^vv^><v<>^^>v^^>^>vvv<^v>^^>^<><>^<>v<<>><^<<<^v>^v^<vvv<><>>v^>^v<<<>v<><>><<vv^<>^<<<^^v>>^>v^<v^><^^vv>v<<>v^>vv^<><<^>v><>>^><^^^<v>>^>>v<^><<vvv^^<^>^^<v>vvv<<^v><v^^><^<<>v>v><<v^<>^<^v>>^^<<<>^>v>v^^^^<^<<<>vv<^vvv^^v<v>^><<<><^>vv^><v^>>>v<<>v>vv^^^><^<vv>>^><>^^>>v<v<>v<>>^>^>^<<v<<>v<v<^^v^<<v<><^v^^>>v^^><v><>^<^>>v><^<<<v>>^vv^<>>>^^><v^><<><v^<>>^vv^v^>^^v<^>
^^^v^>vv^<<>^<^>>>^<<^vvv^>>>>><vv<>^<><vvvvv>v>v<<>^v<^v<v<v>^<v<<^><<^<^vv<<^v<>v<^<v>>>^v>><v<^^>v><^<v>^><<v<v<<<<^^>vvvvv^v>^^vv<<>^^v>v>vv><<<^^^^>^>vv>>v>>^vv<^<<><>v><v^^v<v^^>v><>^<>v^>vv<v^>v^>v>>v<v^>>vvv>v<><^vv<<vv>^>^<v^v^>v^><^<^>^<v^vvv>v<<^^>>v^>vvvvv<^^^><v^^>^<<v<v^>v<<<^^<<>v>v<<>^<^<v><v^<<^>><>^v<<^v<>^<<v>v>^<<>v<v^vv^>^>^^<v<<^<^^<<<v^>^>^v<^vv>v<<^v<>v<^vv<^^>>><^^^^<>><<^v<^<^<>>v<v<v<<>^^v^v^^v^<^^^>vv>>>^vvv<^>>^v><>v<^^v<><>v^^><^<^v<<>>^^<>^>^>v>><<v><><<<v<>v<v<>vv^vv^v<<<^^v^vv>^>^<^<>^>v>>><v<^^<v<<<^<<v>^<<^^v<^<<^^>vv<^^^^>>^^>^v><><^v<v^^^v<><>>v<<>^>^^v<^v^^>^<v^v<<<>^>>>v>^<<vv^><>^^><<^<>^>^^><<^<>^>^v>^^<^<>>^^v^v>v^>v^<^v^>v>v^^<^><v<vv^>^^>><<^v>^<<^^<^^<<^^>vv^>>^^v<>><<v^v<<<>^<>><^v^^^<<^vvv><^>>^>^>>v>^<><^<<^v>^<vvvv<>>^^^vv<^^v^<v^>>v>^^^>^>^v^<>v>>vv<^><>v><vv<<v<^^vv>^^><<><<v<^^^>>>vv><vv^^v<>>vv>^>>>^<<<>v^v>^vv^<<>>v<>v^<<v>>v^>>v<<^>^vv<>v^v^<v<^<vv>>><<v>v>^v>^v>^><^^v>>vv<>v^^v>><>>^^<^v^>^<vv>v><>^v<^^>v^^<>v^^v^>>^^>^<<<<^^>><^^
<^<><<v^>>^<v^^<><><<>><^v<^<^<><v>>v<^^<<>><<>><v^>vv<vv^<>v^>v^v><^v^>>>^<^^><^<>><^>v^<v<<>v>^<v>v<^>^^<v><^<^^vv^>^^v<<>><<>>v^<>vv<<>^v><^<^^v<v<<<v<v>^^<><v^v^<<v^vv<v>v>v><^v>>^>^^>vv>>^v<<^^^^>^<<>>^>>^>^v^>^v<<^<>^v<<<^>><<v^<v<^v<><<>^v^>v>^^v>^^v>>v^>><<<^<^^>><^<><^v<^v<<v<>^v^v^>>v^^^<^<v<><vv>>v^<vvvv^v^v<v^>^<vv>><>v<<v<vv^^>>^>^vv^^v>><<>^^<^^v><>v^^v^>v<^^>>^<v>^vv^^^^^^vvv<>^v<^^><<<><<<^>v^>>^vv><>v><>vv^^^v><v^v^^>>>vvv>v><<<^<^^<^>^>v^<v^^v^v><v^v<>v^vv><v><<vvvv>>v>^^vv><v^<v<>^^v>><v<^^>^^v^v^vv^v>^v>^<v<>><><>^^<^<>>>><^>^v^^<><>v>^<^><><^<<vv^^vv<>^<v>>>vv<^<<^>><<^^^^>>v<v<<^>^v<^>v<<<v<v^<<v><<<<^v<<>v<^<^<^v<><<><^v<^^v><>v^^<>>>v^^v^>>>v^vvv>vv<^^^^><<^>v>>>^<v>v<v^v<<v>v<v^^>>>v^v>^v^<v^^v<^<<^>>^<><v><<^<^><^^^>vv^<v<v<><^v<>v>>^v<>^^^vv^^<<^^<<vv>^^^>v>>v>>v^><><>>^>vv^<v<<>><>vvvv<v<<^vv<<v<>v^v^^>>v<>v<<v^><^<^v<<<v^v<<^v<v^>v<<<^v>>>v^<<<<<<>v>^^>><^>>^<^><^>^<<<v^<<<>>^<>>>>vv>v<>^^v>>^v<^^<>v^v>^<v>^<<>^v^v^v^<<<^vv^^<><vv>vv^v^<><v<v>^<>^v><^^v<<vv
v^<v<v<<^><><<v^>v<<v^<v<>^^>>v^>^v><<v^<v><<vv>><>^v^v><<v<^><^><<<><<^<^^>v><^v<v<v><v^^v^><^><>v<^>^v<v^><<^vv>>v<<v<^v><v^v^v><>v<v><v>>>^v>v^^^><^<v^v<vvvv<v^<v<v<><^^<v<<<^v<vv>>v^<<<^^>vv^vvv<<<<vvvv<<^>^<v<^<>^>>v<<v>vvvv>v>>^>>v<>v^vvv<><^^^>^<^>v^<<^<^v<<<vvv<^vvvvvv^<>v^^>^<^<<>^<v<^>^<^<^<<^v><v>vv<v>v^><^vv><^<<>vv^<>^>^v<<>>^v^<^^<><>^v<^><v<<vv<^><<><<v^><v<>><^v^v^v<<^>^v<>>^vv>^>>v^^vv>>>v^^^>vv>^<<<<>><>>^<<>^^^<<>>v^><^^>v^>^><^v<^^><^^^v^^v^<v<<^<<<<>>>><<<^<v^^>><>^^<^v<>^^^<><>vv>>^<><>>^v>v>>v^v^^^v>><><>><>>^><v^>^v><<v>>v^v^v<v><>v<vvvv^v<><v^>v>v>>>v<<<<>><><v><<v<>v<>v^<^^v^<^<>v^><<^>vv>>v<v>>>>^<>^^v>>^^^<>^<^v^>^v^>v><vv<><^^v>><><>>v^<<vv^>^><><^<vv^>^^<>^>v^^^v<vv><^v^>^v>>v>^vv^^><v>^^>>vv<^v^>^<>>>>>><>><>v>v><<v<<v>><><<^<v^^^^<^v>v^>v<>^<>vv<>v<<><v><^>v^><^>v^><<<>^><><^<^^^v^<<>^^<vv>>><^vv>>^v>><>v<v>^^v>v<^^><^<^>v<v^^vv>^<v<v<v<v^<^><v^<><><><>>><^^vvvvv^>>^^^<<>><>>v>>v>^^<<^^v>^^^v^v>><>>^<v>>^v^v><^>v><vv^^<vv>^v>v^<^^<>>^<<><>>>>>vvv>^><<^^v
^><v<^<v^>v>^v<^^v^<><^<vv<>v>v^>vv^<v<<<^<v<<>^>>>v>vv^v><<><<v>>>^>><^>^<><>vv^^^>^<<^^>^^v<<v<^vv><v^vv<<v>^^^v>><v<^v>^<><^>^^vv>><>v>v^>><^^^>v>>>>v^>^>^^<^<^>>>>^v>v^>^<>v<<vv><<^<v^<^v>^v>^<v>v^><^>^v^<v>vvvv^<<v><<v<<<<v<^vv<vv>^v><>^^v>>^vv<v<v>><v<>>^^^v>>v<^>^><^vvv><<<^^^v^v<>v>>^>>>v^>>>^^>vv>>v^<<><<<<<v><^^^><><<><<v>vv<>>>^><vv^<><v<<^^^v>^v^v^>vv<>>v>^><^^^<vvv>^<v<<vvv><<<<<vv<<^><<v<v>^<^^v<^>^<>>^v>vv>>vv>v><<<<<>v<<v<^<<<^v<<v<>^<<v>^v^^>v<v>>>v<^^><>>^<^v<>^><>^^><<>v<vv>v>><^>v>>v<>>v^<v^>vvv^^^vvv<>^>>^v>v^<<v><v^^<^>vv><>v<>^>^<<><vv>^<<>^^>v><>^>><^><^><<v^^><vv>vvvvv<v>^<><vvv><vv<vv^v>^<v<v>>^vv<<v<><>>>><>^><v<v>^v><<^^^^<v>v^v^<v<<><v<>>><<>><v>^^^<><^v^^^^^v<^vv>vv<<^>>>>^v<^<v<>vvv>>v>>v^v>^<^v^vv<>^v^<<^<^>^<^<^^^^<^><^>>^vv>vv>^<v><<^v^^^^^<v>v>>v^>^<v>v<<v<>v><>v^^>v^<<^^>^><v^><>^>^v>v<<<<><<<vvv<><><<>^v<<<^>>v<<>^v>^<^^>>v^>^>vv<<><<^^v^vv>^^>v^^><v<^<<<^v>><<v^><^<<<v><<<<><v>><<v<>^><^><v>>vv^^<v<^><>v^^<>^vv>^v>^^v^^^^^<>^<>>>v<v<^><<<^>>v^<<<^<
>^^<v>^^>vvv^^<^<<>>vv<^<<<^<vv><>^^<^^^<^^vvv<^v<>>v>^><v^>^^^v<<<^v>>^v>vv<^v^v<v><^>vv<>vvv^vvv<>^<<v><>>>^>v^>><^^^^v<v<<v>vvv>v^v>vvvv><v<^v<v<<<^v><<^^^<>v>^v^v^<>v^>v<<<><^^^<v>vv>^>^v>v><<v<>^^v<vv>v<><>v<vv<vvv>>>^<<^vv<<><<v^<vvv>v<<>vv^<^>^v^>^v<v^v>v>>vv^<v<v<<<^>>vv<<^<v>^<>v^>^>^^>v>v^<v<v^^<v<v>>v^>^v><^^><<^<^^<^^<^v><v<^>^>v>>^<<><>>v>v<^<^<v<^>>^v<^^<<<>^^v<^>>^v<>><^<<^<<<<>>>>v^^^^<>^>v<v>^>>>vv^v>v<><>v><vvv^>^v>><vvv^<<v^v>^vv^<<^v>>^<v<>>^v<><^v<v>><^><<^<^>v^>^^^v>^<^>^>^^><<>^><^>^^>v<>><v<<^<>>>>>v>><>^<^^^^<>>v<><>>><^<<>v^^<<vv>^^><<>><>^<>^^^<vvv^<v^^^^^>>^^<vv<<<v<<^v^<<v^><v>^^^><>v<^>>>^>>v<><v>v>>>v<>v<><vv^^><^<>^<><vv>vv>>vvv^v<>vv>><^>v<v>v<><><v<<v<vv^<>>v>>^v><<^>><^>>^<>><><<>v^<^>v<^^v>><<><>v^v<>>vv>>><vv<v^^<v^^>v^^vv>><^vvv^vv>>vv^^><<^^<v>v<^<<<<v^<<^<vv<^v^v>v^^^v<v>v><<<^>>v>><v>>vv<>>>>>^<<>v>v^>vv^>^^>>v<<v<^<><^>v>^vv><>^vv^<^>v>>vv<<vv>vvv>v^v<^^>^v>>^<><^v<^>^vv^^vvv>v<v>>v>^>>>^^<>vv><^v<vv>^><^><<<^^>v<<<><<v>^v<vv<vvv>^^<v<>v><<^<^<
<v><<^vv>v<<>vv<v<<v^<>>>>^^^v^<^vv^><^<><v^<><^v^>^<^^<v><v>^>^v<>^<<><<^^<v<v<>^<>>>><<>>vvv^<v>^<v>vvv^^>><v<<^^>>^<v>^>^^<v>^>^<<<>^vv>^<<<^>^v<^v<v<>v^>^<<>^^v^v<<>>><^^>v>v<^^>>^><<v^><<>v^>^vv^>^>>>^<v<<^>><^vv<><^^<<>>v<><<v>vv>^v>v<vv>><<>><^<^<^^v<<^v<^>^><v^>v>>^><^^^^v<><v<^v<<><^>v<^vv<<>v>>>>^^<^^><>v^^<<^>^^^^>^>>><v<>v^>v^<>v^v^vv<<>v^<<><^<^<^>>>^<v^v>^v^>>>^^>^v><>vv<vv^<<v<vv><<<^v<vvv^<^^^vv<<v<v<>v^^v<>vv>v>v<>><^v>>v^<>v>>vv<^<>v^^<<^<>^<><<>vv>^>v>>^<<>v>v^v<>^>vv^<<vv<<^>>^vv^v<vvvv^v>^vvv<<v>><>^^v^<<^<v^v>v^<>^<>>vv>>>^^>><>v<^v^v^^<^>^>^v>>><<^^v><v>^v<v^>v>^vv<>^<<v<<<^vv^<^v<vvv>v^>><^><^^<v<>^v<v><vvv>vv<^>v^>>^v<<<^>>>v<^vv<^<v^>>><v^^v^<<v<^v>vv>v>v^^>^<<^><><v<>>v<v<^<>>^v<^^<>>^>^<v<v<^vvv^^<<v<^^^<v<>>>^^^<v<>v>^^v><<^<>><<>>vv>v<>^^><<^v>><<vv><v>^^>v<>>^v>vvv>>v<^<v>v^v^vvv^^vv<^>>v>^v^<<<v<>v<>^^vv^<<^^><<v>^v<^v<^>vv<vv>^<>v^>^v<<^<^>v<^<^v^><<>vvv><v><vv><v><v^v<^><>^^<v<<><v<<>^<>^<<^v^^>v<v>><^vvv^>>vvv^^^>>>^<<vv^><vvv><<^<>vv>vv>v<>>vvv<><><<
^<><v^<vv^vv^vv^<v>^vv<>vvv<^<vv<<><^<vv^<<><>v^v^^vv^v>>v^v><<^^>v<><<^<>vv^<<^vvv>v^<^>^<^>^^><^vv>v^>v<>^vv^<^><v^^v<^^>v<>>v<^^><<>>><vv>v^^^v<<>v<<<v^v^^>v><<vvv>^<<^<<^>^v<v><v^v<>v^^v^v<><<<^<<^vv^v^<<<^vv>^<^<vv<v><<v<vv>v<<<v>>><v^<><^>v>^^^v<<<>>><^>v<v<<<^<<^^^>^^^<v>>>v^^<^v^^><>^<v^>v>v<^vvv^><>><^^^v><^<v>><>>v<^v^^<>>vv<<<>>>^^^^>>^^^>v>^><<>v>v<><^v^vvvvv><>vvv>^v><v>v>vvv>>vv<^<v>v>v^^v^>>^<<vvvv<vvv>>v<^<<<>v<><>^^v^<v<v<>>v<<<>>^v>^^<^>>v<^v^>v>^>>^vv><v>vvv<^>^^vv^^<>vv<><<v>^vv^>v><>v>^>v^<v<<v^<^v^v^vv^>^v>^v<^vv<>v^><^^><<^>^vv<vv><>vv<<<<<^vvv>^>^<vv^<><^v>vv><^>vvv>vvv>^vv^<^<><^^^<<<<vv>^<<<<<v^>>^<^<>>^<>>>v<<^^>vvv^^<<<><<<><>v^vv^<<vv^>>v><><<^<<^^<<^^>><v^>^v^vv<>>vvv^vvv<^<v><v>>v<<>>^v><v^v<><>><>v>^^>>>><<<>v<<>v^v>vv>><v<>^^^<>^^v<<^>>v<vv><v<v^v<^<>>vv>v<v<v<><>>v^v>^<^^^v<v^<vv<>^v>^>>>^^^<^>vv^>^^<>><^<>><>^><<^^^v<^^<<v<>^^<v^v<v<>^v<v<v>v^<<^>^<v>^><v^vv<<v>v><v<v>^<v<<^^^^v<^<^<vv<><v<><<vv><^^^<<>>vvv><^>>v<>vvv<v>v><<v^^^>^>^<<<v^>><v^>^<^^<v^>
vv^<^^v>^<<^v>vvv<v<v^v^><<<v>^>^vvv>v>>>^<>^vvvvvvvv^<<>^>><v^^>v><v<>v^v><>>>>v><vv>^v<><vvv^vv^><>vv><<>>>v<v<<>vv>^v^>>^vv>vv^><^<><v^^v<v>v>^^>v>>>>v>v>^v^<>v>>v^><>>^<<>v><^^v>^^^vv^<^>^>>v^<^v>^v><>^<^^^^<>vv^^v^^^>^^><vv^^vv>^vv^<>>^<<>^v<v<<^vv<<>^^<^><>v<>^^v^^>vv<<v<>^<v>^<^^<>^><vv<><<>vv^^v^><>vv<<^^>>v>vv>^vv<v<<v<v>>^<^^<v^<^>^><>v>v>v>>>^v<>^^<^>v<v>>^v>>^v>>^^^v>^vvv^^v<>^<>^<^v<^<v>vv^<^<<^v><^vv><^^>vvvv<<<<>^>^>>^v>>><>><<v^^vv^^vv^<><>^>v^>^<^><<v^v<<^>><vv<><v>v^<vv^><^^^>v^><^^^<v<v>v^<>><<v>^<<^>v^<v^>^>>^vvv>>>v^v^<v>^<v<><<<>^v^^<v^vvv^^^>vv^v<^<v>v<vv^>^<<^^v^v^<v>vv><<>>v^<<vv>>>v^<>v^<>v<v<>^<>^v<>>^>>^<^v^>v^>^v<^^v<<v>>><>v>v<v^v>^^v^<^v^<>^^>>>v><>v<<<<^v>v>>^^<^>^<^<v<^<^>>^^>^<>v^><<^^v^<vv^><><><<^v<>v<><><vv^<>>^><>>vvv^<^^^^>^v<>v<^v<v><v><>><^<<<><>^^<>>^vv>>>v><^<^>><v^^>v><<><^><v<^v><>vv^v^^^^<^v<v>>^>>vv>v>>^^v<vvv^>^>v^>^<>v^vvv^^^<^vv^v^v>>vv^><^<^>>vv<^<vvv^>v^<<v><v<>^^vvvv>v>^^v^>>vv^^^<^>v<<<>^>v<>v^vv^><v^^>vv<>v>v^v>><^<><>v>>v>>^><v<^<
v<vvvv<^>>v^v^>^<>>><v><><>v<^^v>v<>vv>^<><>^^v><<^v<>^<^>>^<>><<v>v^<>v>^<v>v<v<v<<>^<^v>>v<>^^<^<<^v<<>vv>v<<^<v>^v><v^^v>^^<^>>>v^<v^^v<^v<<v>v<v^<^^v<vvv>^><>v>^<v<<>^<vvv<vvvv^>^v>vv^^^><^>v>v<<^vv^<^^>^^vv^v<<^<<>>^>^v^v<v><><^v>v^v^<<^<v>^^<>^<^>^><><<>^>^^v^v<<><>v<>v^v>v<^<>^vv^^^vvv<v^>>>vvv>>v^>>>^^<^^><<>^v<>>^<^v^<><><vv^>^>^<^^>v>>^^v^vv^>>vv^^v><<v>><v<<<<>v<<<>>v<v^^v^^^^v>^vv>><>^>>>>><v<>>v<v^<vv<v>><<<^v>>>vv>v^<^<<^<v^>v^<>^^^<>>v<v<v<><>v>v<><>v<<v><^<>v^><>^vv<v^^<<<>^>>vv^^>^^<^<><vv<><^^><v<^v<>^>>><>^><vvv><^<<v^<>v^v<><<<^^>><<><v^<^vvv^v>><^^^><v^vvv>^v><^<<v^>^>v<v>>vv>^<^vv<<>v^<v>>^^^>^<<<^<v^>^^v<vvv^^>^<<^>><><v^vvv><><^^<<^<>^<>^v^v<<>^>^>>vv<v>>v>>v<vv<vv<v<^<v^v<<<^^>^v<<><>v^>vv<<vv^^^<>><v>^v>v<<vv<<^v^<^^^vv><vv^^^^^^vv<<>^v^vv>>><>^<>><<>>v>v^>>v>>v<<>v>^^v^^^<^v^^v>v>^>>v>><<v><^>><^<^>^>^<v^v^<<^>^v^<>^>v<>>^<>vv>v^<v<<vv><<v^v<<><<><vv><^>>v^><^v>^><<^>>><>>^<v><v^>v>v>>>>>vv<vvv<<>v>^^>v^^>v<v>^<^^<^>>^^>v><<v<<>^><^^><v>^^>>v<><^>v<v<><<>^v>v
>vv>>>>v><<^v>^^vvvvv><^v<>^<<>^^<^vv^>^<^^<>^vv<<^<v>^v<^<><<v><<^<v<<<v<<vv^v<v^>^v<>><<^<<><<<>^vv<v><v<>^<^><>vv>v^v<v><^v<vv>^>^^^v>^^<<^v>v>^<<^^^v<v>v^<<^<<<>>>^>^v><<>v>^<^<<^vv>><<^<^^><<>^v<^^><vv^>><v><<v^v<<<><v>^<^<vv^>v<>>^vvv^^v>^v^^v>^>^^^^<>><vv>vv>>>vv<<^vv<>>><v><<^^<><<<>>^^^v>^v>v<^<^v^^<<^<^vv<<<<<<vv<^>v^vv^>v>v^<^^<vv<>^><v^^^v^>^><<^<^>^<<^<<>><v>^<^>^^><^v^^^^v>>v<>^^<><^<^^><>vv>>><vv<^<>^v>>vv>^^><vvv>v<>^>>>>>><<<^<>>^<^>^<^<v>v^v^^v^^^>>^<<>v>>v>>>v^<<v^><v>^>v>v>^>vvv<<<>v<^<>v<>>>^<v><<^<v><v>>vv>>><^v^<<<<<^v<^^vv>^vvv<^v>v^^<^^v>>^<<<>^>>^^>^>>>>^v>v^<^^><>v<<<<^<v>v>^>^>>v><<^^^>v>><vv>^><>>^vv^^^<^<>v^^<>^v>^<>>^^v^>^^^v<><v^>>^><<>^^>>v<>>^<>vvvv>>>^vvv>^vv><><>v^v<v<^vv^v<>>v>>vv><<<>vv<^v>v>^v><v^<<^^^^v<^<>^<><v>^>v<<^v^<v<^<vv>v^^v>^<<<>^v<v<^v^<v^<^^v^^>>v>v>v>^^v<<v>^v>v^>^<v>>^^<>^>^><^<><>^>v>^>><^^^vv^<><<<<^>>>><^^^>vv><^<>>><<v><^v>v<<^v^vv>><>v<><^v>v^v>><v<^^^^>^>v>v<>^^<>vv>>v><<>v>><^<^v<<^>vvvv<<v<<^^<v<^^<>>^v<>^^v<>^^>v<<<>>^^>vvv<
>^v^v^>>vv><<^<>v>v^v^><<<>v<<^v<v<>v^^<^>^>^vv<<>v^>>^>v<^>^v>^<>v>v^><v><>>^<v<^>>v^<v^v^^^^v<<^>>>^>>><>v^v^>^>>vv^<^>v<>>v^^>>^><<<<^>>v><<<vvv>><^v^^><>v>vv^>v<<<<^^>>>><^>^>>>>^v<<><^^v^<v><^>>>>^>>v><^<><>>>>v><v>v>>>>v^^<v>>^v<<v<<>>^<v^<>>>^<<>>v>^><>v^^>^<<><^<>>>>v<vv^^v^v>^v^v>^><^<^v^v<^v^^>^^>><v><^>^>^>>^^>>^<>vv>><>v><^>>v<<^><<^<^>v^<v>vv>v^v^^>^>>v><^<>v^><>>>^^v>v^^>>>^v<><<<<<^v^><^>>^^vv^>><^<v>v><<v^><^>^>v<^^v^vv<<^>^<>^<v><v>v^vv^<>v<vv^vv>v>^><v>>vv>>^^>^<v<<v<<^^vvv<v<v<<<<<v>^^<>^v^><v>vv>^^^v^<<>^><v<<<<>^><vv^vvv^<<^vv><v^^<<<^<>><v<<^>vv>^^>v<<v>vvvv^<<<<<v>^^>^<>v><^<>v^>^<<>v^>><>>>^^<v>^<>v^>>>^^>><^<v><^<<>^<<<v>v^><<^v<v<><v^<^<><v^^<v^vv^>v^<v<v^><><<vv<>^v<<<^vv<>v^>^^v>><<<v<><vv><<v>^<v^^<>^<>vv<<v<<<><v><<v^^<v^><>^^^^v^vv^<>v>>>>v<>>><v>v>v>^>v^v>vvv^<<<>^^v>vv<v<v<><<>>^<>v<vv>>>^<<>^<v^>><v<v^vv>^^<<^v^v<<<<<<^>^^<<>v<<><<<^v><<<v^<^<v^><v<>>><>^><^<><vvv^v>v<^v><v>>vv<<>v^v<<^<^>^>^v<v<<v<v>><v^<^<^v>v<<<>^>^<>^<v^<v^v^v>^^^v^vv^v>^>vv><^<<>>
^v><>v<^^^<>>>><>>>^v<vv<<^^<><<^<^>v>>^<<v>><v<<>><^>>v^v^^>v^>v^><^<vv^>><v<>v>vvv<<>v><^vvv>^^vv^<^>><v<>^vvv>^^^>^v^^vv^v^<>^^<>^<v>^^<<v>><<^^<<^<<<>^>v<v^<>>^>^v^^<>^><vvv^<vv<>v<^<vv><^^v<<<vv>^^^>v^^<v^^>v>><<<^<<><<<><><vv^v>>^^>^<<>>><<^>vv><v>^vv^<>^>><>^^<><><<><>^^<><^<>v>^^<<v>v^<<>>v>^>^^>vv^^v<^vv><<vv^^^^^<<<<v<^<<>v^^v^<v>v><<<<<>>v^>^>><<>^^><>v>>v^<^^^^>>v><<v>>^v<<v><vv>>v^<<^>>><^<^v<>vvv<<vv<^<v^v>v<v<<v^^v><<>v<v<>^<>><^>^^^>^v^<<>v^v^^>>v>^v>v<><<^>v^<><<<v^>>>>>vvv^v<>^^>^^^<vvv<vv^^>v<v><v<vv^><^v>>v<v^^>^vvv^^>>vvvv^><^vv^^vvv<<>>^>v^v^v><^^^^vv^^><^<<><<<<v><<^v<^<>>^^vv<><^^><v^<^><^>v^^^<^^>>vv^^>><v<<^<>>><v<^<<v<v>v>>^>>>>><v>v<><^^>^<v<^^vv><<<^<><v^<^v^^v<<<v<<<vvv>><>>>vvvv^<^^v<v^v^vv^v^<v^<<>v>><^^^v><^v^<v^^><vv^<><^^<^<<<<vvv<v><>>>v^<v>v>vvv>><vv>^>^<^><^v>vvv^v><><>>><^<v<v<<<>v<v<<v^>^<v^v<vvvvv>>^><v>>v>>>>vv^<vvv^v^v>>v>v^><<>v^vv^><^>^<vv^v<<v><vv<<^v<>^><v^<^>v>vv^<^vv<v^>^<vv<v^><^>vvv<v^<^<>^v<v^^>><^^<vv^>>vv><^>>^><>>v><>><<<^>>v>^^<<^
>>^vv>^>^><>>>v>^><^<><>><<<<><<^<^<v^v^v>>>><><vv>>^<>v<v^>v<<^>>v^v>^>^>v<^v>>v<vv^vvv<<^^^<^v<vv<>>^^><<><<^v><^^v>><v>^<v<><^>>v><v^v<^<v^>>v>>>^v<^v><<>v>^<^^^<^vv><<<><>^v^v^^>^v>>v<v<^<<v^^><<^vv>v>^vv<^>v<><<^<<^<^^v^<vv>^<>vv<^>>^^^<^v><>vv^>vv^^vvvv^>v>^v>^<><v^^>v<><vv^><>^>v<>><v<<>^^>^<>vv<>^vvv>><^^v<>>^<v<v^>>v^>>>vvv<<vv^^^^>>^^<<>vv<<>>>v<>v>v^^v<vvv<><><<<^v^>^v^^^v>>v^>v>^v<>v^><>^><v^vv<^<^v^^v<><vv<<^^><v>>^<>^<v>v<<v^^v<v><<>^><>>><><><<>^^<^>vvvv<<v<^<^v><^<<>>vvv^^vvvv>vv<<v<>^^<><<><>^<^v<^v>^^<><>>v><^>><v<v>v>>vv<<v<v<vv>^v^<>>^v^<><<<vv^^>v^<<v^v<^v^>><vv><>^^>><<^>><<v>^<>^>v<^^^vv^<<<<^vv>><vv^><^><^<^^<><v<<^>^^><v>^>^vv><vv><^v>v<vv>^><v^<vv>>vv^v>v>><v^^><^<vvv<v^^<<v^>^<^^^vvv<^>^>^><^^<v^<>v^vvv>^<<v<^^v>v>>>><>vv<>^v<<v>>^<^<<<<^v>^^>>vv>>v>v<vv^><^^v<<<v<<<<^>v^<^v<^^^><^v>^><v^^<^<>>>v^^<^v^<v<^^>vvv>^<<^v<>>^v<<^^v^<v<v<<v^v^<<>v>^^^<v>>^>>^^>>v^>v><>vv^<v<vv^v<vv^^vv>^^>>v<^>>v>v^<>>v^^v>>>v<<>vvvvv>><><>^^<<v>^<>v^^^<><^>><^^v^v^^<^<v><><<<v><<>
vv>>^v<v<^v<<<<^v<>v<<^v^<vv><>>v<<><v<<><<^vvvv<<^<<v<>v<v>>^^>^<<^v<^v<^<>v><<vv^<vv<v^>v><<>vv^v><vv<<<>><^<v<<><<>v>>v><>>^^<>>>^<>v><><>v^<v>v>>^v>v>^<>><>^^<<^v><>^<^><^>>v^^<^<v^<>^^v>>v<^v><v^>^>vvv>v<<vvv^<v<v>v>v>^^vv<<>v>><^v^v^^v<^vv<<><>>>^^^v>v^^^>v^<><^<>^><v>><<>v^>^>v>><v>v>><^v^v<<>^v<>>v^v^v^^v^^>>v>^<^>>><^v^<<^>^>^>>v>>^>vvvv>>>^^^<<vv>^v<v<^^<v<<>^v>^<^>>v<><<v>v><v>v^<><^<<^v^<^<<^^v>^<v<<>v>v^<><^v^^>><>^<^^><<v^^^v^>>>v>vv^v^v<<<>^v<>^^vv<>^v><^vv<^vv^<<<^<<^^><<><<>^v^<v>v<vv^^^^>vv^^>^<<v<><^>^<<<v<><vv><^v<<>>v>>>><^^>^>^>>>>^<vv>^^v^^>v<^^<^vv>>^^^^vv<^>v<><vv<^^v><<><><^v^><^^>>^^>vv><v^<>v^v>v>^<<v><<^v^v>v>^<v^>><v^<<^<>>^^>>><vv<vv<<>>v<<^<^>><v<v>v><>v^<v^v>^vv>>><^^>>v^^>^>^<^>^v<v<^^>v>v<<vv>>^<>v>v^<v^<<vvv>^^<>vv>>^^>>><<^v<<v>vvv><v>^>v^vvvv^>>^<^<>v<vv>^<v^><<<v^v^>vv><>^<<vv^>>^>>^^v<><v<v^>>v^^v^><^><v^>^^v<^>^v^>^<>>^^>vv^vv<^^v<<<<^<vv<<<^vv>^^<vv^<v<v^><^>v>v^<<>^<^^^^^v>^^>^>vv>>v><^v^^>v<^>v^>><v<<v^>^>>^^v><>>^><<v<>v<><^^v>^v>^>v<v<^v<>^
>^vv>^<vvvv>v<><<vv>><vv<>v^<<>>v>v<^><>^v<><>>^<<<v>^>vvvvv^>vv^^<>><^<>v>^^><v<>^<>>vv^vv^^v^>vv^<v>v^>>vv>>v^><<<>>^<<^>vv>v>^<>>>^^<v^^>><v^v<v^><<v>^v<>>^vv<>v<vv>^^>>><^<^^>>>vvv><><vv<v>v^<^^<^><>>^<<><<>>v>v^^^><^>v<<>^^<<vv<>>>v>>v^v<<><<^v^^<<vvv^v^^<>v><<^v>>^v<>^^^^v>^>>^>>v^>^>>v>>><^><<^v><>><><v^<v<<>><^v<^>vv<v^<>v^<<^><<<^^>>v<^>>v>>v>>>^<v^v<v<<>v>^><<vv>vv><^>v>^v<v^v><^<^vv^<vv<^^v>^^v^v<v<>>>>>^v>>^>^>v<>^>^<v^<>>^^v>v<>^<><^^<v<v^><<^v>v><>v>^>^<>><>>^>v^<v>v<<<>^><^v<><v>^^^^v<><^^v^^<^v>^<<v^>^>><^v><><<^^^v>><^^<<^>^vv<<^<>>v<<>>><v>>>^<<v<<><v<^v<v^v<>>^>v<<v^<><<>v<^v^<vv>><vvv>v<^^<<^v<<^v><>^vv>v<><v^><v<^^<<<>v<<<^^v^><^^^^<^^v<<^<>v><>>v<vv<vv<v^v<<>><v^v>^v<><v<><v>v><>><^>^^^<v<<^^>>v<<<<v<<^v^vv>>v^>vv<><<<^^><v>^^>^^v<^>^^^v<^^>>>^<^<>v<vv<<^^><^^v^vv<v<v^<^v<<v><^^^<v<>v<^<<v><^><><>v^v>>>^vv^<<^v<<><<<><^^^>>^<^v^v<<>v<v<^<^v^<<^<^>^v^v>v><^^>^>>^<<><v^><<^<<<>v^><>><^<v^v>>^<^<^v^<<<^>^<>^^<>>^<^v^v>v^><v^<>v^>>vv>>>^<>vv<><>^>>^><>>v><^>>>^><^v<vv'

drop table if exists #Maze
drop table if exists #Moves
drop table if exists #Final

;with i as
	(select r.ordinal - 1 r, c.[value] - 1 c, Symbol, max(r.ordinal) over()  - 2 MaxRow, max(c.[value]) over() - 2 MaxCol
		from (select left(@Input, charindex(concat(char(13), char(10), char(13), char(10)), @Input, 1) - 1) Maze) m
			cross apply string_split(replace(Maze, char(10), ''), char(13), 1) r
			cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int), cast(1 as int)) c
			cross apply (select substring(r.[value], c.[value], 1) Symbol) s
	)
select *
into #Maze
from i
where Symbol != '.'
	and r not in (0, MaxRow + 1)
	and c not in (0, MaxCol + 1)

insert into AOC_2024_Day15_Rocks
select r, c
from #Maze
where Symbol = '#'

select c.[value] ord, cast(substring(Moves, c.[value], 1) as char(1)) Dir
into #Moves
from (select replace(replace(substring(@Input, charindex(concat(char(13), char(10), char(13), char(10)), @Input, 1) + 4, len(@Input)), char(13), ''), char(10), '') Moves) m
	cross apply generate_series(cast(1 as int), cast(len(Moves) as int), cast(1 as int)) c

create unique clustered index IX_#Moves on #Moves(ord)

;with Rob as
	(select r, c, MaxRow, MaxCol
		from #Maze
		where Symbol = '@'
		)
	, Starting as
	(select r, c, Boxes, MaxRow, MaxCol
		from Rob
			cross join (select string_agg(cast(iif(Symbol = 'O', concat(r, '.', c), null) as varchar(max)), ',') Boxes
							from #Maze
							where Symbol = 'O'
						) m
	)
	, rec as
	(select cast(r as int) r, c, Boxes, MaxRow, MaxCol, 0 Steps, cast(null as char(1)) Dir
		from Starting
		union all
		select cast(m.r as int), m.c, m.Boxes, r.MaxRow, r.MaxCol, n.NewSteps, v.Dir
		from rec r
			cross apply (select Steps + 1 NewSteps) n
			inner join #Moves v on ord = NewSteps
			cross apply fn_AOC_2024_Day15_Move(r, c, Boxes, v.Dir, MaxRow, MaxCol) m
	)
select top 1 *
into #Final
from rec
order by Steps desc
option (maxrecursion 32767)

select sum(100*p.r + p.c) Answer1
from #Final f
	cross apply string_split(Boxes, ',')
	cross apply (select cast(parsename([value], 2) as bigint) r, cast(parsename([value], 1) as bigint) c) p