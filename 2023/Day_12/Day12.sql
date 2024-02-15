﻿use tempdb
drop table if exists AOC_2023_Day12_Ranges
drop table if exists AOC_2023_Day12_Broken

create table AOC_2023_Day12_Ranges(ID int,
									Lava varchar(max),
									Wiggle int,
									SpringCount int,
									Ordinal int,
									Ln int)
create unique clustered index IX_AOC_2023_Day12_Ranges on AOC_2023_Day12_Ranges(ID, ordinal)

create table AOC_2023_Day12_Broken(ID int,
									Ordinal int,
									Symbol char(1),
									Springs int)
create unique clustered index IX_AOC_2023_Day12_Broken on AOC_2023_Day12_Broken(ID, ordinal)
GO
create or alter function fn_AOC_2023_Day12_ProcessNextSpringSet(@ID int,
																@Ordinal int,
																@Start int,
																@PreviousRow varchar(max)) returns table
as
return with PreviousRow as
			(select Loc, Val
				from openjson(@PreviousRow) l
					cross apply (select cast(json_value(l.[value], '$[0]') as int) Loc
									, cast(json_value(l.[value], '$[1]') as bigint) Val
								) v
			)
		, CurrentRow as
			(select [value] Loc, Ln, cast(case when nxt = '#'
													then -1
												when @Ordinal = 1
														and [value] < min(iif(prv = '#', [value], @Start + Wiggle)) over(order by [value] rows between unbounded preceding and current row)
														and FutureSprings - CurrentSprings = Ln
													then 1
												when @Ordinal > 1
														and isnull(p.Val, 0) > 0
														and prv != '#'
														and FutureSprings - CurrentSprings = Ln
													then p.Val
											end as bigint) Val
				from AOC_2023_Day12_Ranges c
										cross apply generate_series(cast(@Start as int), cast(@Start + c.Wiggle - 1 as int), cast(1 as int)) n
										cross apply (select substring(Lava, [value], 1) sym
														, substring(Lava, [value] - 1, 1) prv
														, substring(Lava, [value] + ln, 1) nxt
													) i1
										cross apply (select Springs FutureSprings
														from AOC_2023_Day12_Broken b
														where b.ID = @ID
															and b.Ordinal = [value] + Ln
														) fs
										cross apply (select Springs CurrentSprings
														from AOC_2023_Day12_Broken b
														where b.ID = @ID
															and b.Ordinal = [value]
														) cs
										left join PreviousRow p on p.Loc + 1 = n.[value]
								where c.ID = @ID
										and c.ordinal = @Ordinal
		)
		, i1 as
		(select Loc, Ln, Val
				, last_value(Val) ignore nulls over(order by Loc rows between unbounded preceding and current row) Val1
				, last_value(iif(Val = -1, Loc, null)) ignore nulls over(order by Loc rows between unbounded preceding and current row) ResetEvent
			from CurrentRow
		)
		, i2 as
		(select Loc, Ln, ResetEvent
			, iif(Val is null, iif(Val1 > 0, 0, Val1), Val) Val
			from i1
		)
		, i3 as
		(select Loc + Ln Loc, iif(Val != -1, sum(iif(Val != -1, Val, 0)) over(partition by ResetEvent order by loc), 0) Val, Ln
			from i2
		)
	select '[' + cast(string_agg(cast(concat('[', Loc, ',', Val, ']') as varchar(max)), ',') as varchar(max)) + ']' Locations
		, @Start + Ln + 1 NextStart
	from i3
	where Val > 0
	group by Ln
GO
declare @Input varchar(max) =
'..?##?.?.??#???#? 3,7
???.##??##???#??.# 1,1,7,1,1,1
?#.??.??#.??#? 1,1,2,2
?????.?#???? 1,2,1,1
??##???.?.???. 6,1,2
#??#.??.?.????.#?? 1,1,1,1,3,1
??.??????.?#? 2,1,3,1
??##?.??#? 4,3
?#?.???#?????# 2,4,1,1
#?#??.??##?#?#?#???? 3,13
??????##??? 1,4
??#????????#??. 7,1
?????##???. 1,2,1
.??..???????## 1,1,7
??#?#?.#??.? 1,1,1,1
?.???????? 3,1
??.??.#?#?#?###? 2,1,9
???.?????? 3,1,1
?#?#?#???.?#?.??#. 6,2,2,3
?.??.#.??????? 1,1,3,1
??#???..??#?.?#. 1,3,1,1,2
??#?#???##?#?#??. 2,6,1,1,1
???????#??.??. 1,2
##??????????#?.????# 9,2,1,2
#?#.#.????#???. 1,1,1,3,1
?#????.???? 3,1
??#??#?????#.??????? 9,1,2,3
#?.?#???#?##???.#.? 1,10,1,1
?..??.?????#??#?. 1,7
?.?#????#?.? 2,4
.?#????.???? 2,1,1,2
??#??.?#???.#?# 3,1,4,3
??.?.??#???? 2,5
??..###.?????#.? 1,3,1,1,1
..??????#??? 1,7
?.?#???#.???# 1,5,4
.??.?.#?#???#? 1,5,1
?#?#??..??#. 1,1,1,3
..??##???????? 7,3
?#??#???#.??.?????#. 9,2,2,1
?.??????..???#??# 1,1,3,7
#?#??.?#?#?#??. 5,5
??.?.?#.??#? 2,1,2
???.????????#? 1,1,1,3
?.#.?#??#?#???. 1,1,7,2
.??#.#?#???#???. 3,5,2,1
???.?#??#???? 2,6
???##???#?????. 1,7,1,1
??????#??#?###?..??? 1,11
???????#.? 1,4
.?????.??. 1,1,1
?#???.?..??##?#?.? 1,1,1,7
????.??#??.? 1,1,4
#..?.??.??? 1,1,3
.?#????..??#?? 6,3
??.??????#?? 1,5
????#???.? 1,6
#???#???#. 1,3,1
.??????.???##?. 2,6
??#?????????.?? 1,2,2,2,1
?.????.??.##??? 2,3
???#???.???.?.#. 5,1,1,1,1
??#??#???.#? 6,1
?..#.??###?#???? 1,9
..??.?#??.????#? 2,1,1,3,1
.???#?##?????? 1,6,2
.#????.??? 1,3
???#????#???. 2,6
??#???#????#?..?#?#? 2,3,4,3
.??.?????#?????###?# 1,1,1,3,6
?.??#?..????? 3,4
??#..???.? 2,1
?###???#???#? 5,4,1
.?##?##?.?###. 6,3
?????.#????. 1,1,1,5
..???????#.???#. 1,3,1,2
???#?..??#????.???? 1,3,6,1
.#?????#?? 1,5
?????.????#?? 2,1,1,3
???.???.??#?#?? 2,1,1,6
??????#???.#?????# 2,3,2,1,3,1
??#?#?#?????#?.# 1,1,8,1
???###??.#?? 1,4,1,1
?#???..?..?.? 5,1
??.?.???#?#. 1,1,3,1
.##??#?#?.????# 2,5,3
#.??#?.??## 1,3,4
..??..?.??.#.?#??#? 2,1,2,1,4
.?#??#?#?#?? 2,6,1
.?##.?.?#? 3,1
?????#?..#??.##? 7,1,1,2
?????..?????#???? 3,3,2
.????.??#?? 3,2
????.?.????? 1,1,1,1
?#.???.?#?.??.#? 2,1,3,1,1
.#????##???# 2,4,1
????#.?.?#?#? 1,1,5
??????????# 4,1,2
.?.?#????#?#??. 1,6,2
???#???#???# 1,3,1
#??#??#??? 2,4,1
???.?##?#?.?..??.. 1,1,2,1,1,2
.?.#??##?##? 1,2,6
??#.?.?#???#.?# 1,1,5,2
.??..????#??#??.??? 2,3,1,2,3
?.#????#???.. 1,5
?#?##??..?????#. 5,1,3,1
??????.?#??#???. 4,1,7
????##??.##??#?##?? 3,9
?#??.??????? 3,1
?.?????#?#???? 5,3
?..???.#??? 2,3
????#???#.??#?# 1,5,2,1
?###??#???#??.?#??? 12,2
??#??#????????#?. 5,7
????#.##???? 1,1,2,1
...???????????#??.? 2,1,4
??????????##??? 1,11
#..???.?#? 1,1,2
?#?????#?????? 4,2,2,1
??????.###???? 1,3,4,1
.?.?????#??#?. 1,5,2
???.??.?.. 1,1
???????#..??#?#?? 2,2,1,5,1
.#????#??? 1,1,1
.???.????#??? 1,3
.???????#??? 1,6,1
.?.?????#??#? 2,3,1
???????????.?.?# 9,1
#????..?..#?#?# 4,1,1,3
??#?.?#?#?#??#?????? 1,13
??#.?.????#?# 1,2,1,1
#???.????##??. 2,1,1,4
.####?????#.???##??? 10,2,3
..??.???.? 1,1,1
???????.#??#? 5,1,2,1
..?##??#?? 3,1
??????.?..##?####?.? 4,8
#??.??????#???#????. 3,2,1,1,3,2
#??#?#????.???. 1,3,1,1,3
.???.??.??#. 3,2
#??#?#?#.??.?????.? 6,1,1,1,1,1
.???#??.?#? 4,2
?#.??##????.# 1,6,1,1
.???####????.?.????? 11,3
.?.?#??..???##???#. 1,3,8
?????.??????#?.?# 2,7,2
??.#.#????#? 1,1,6
..??.#??????? 1,2,1,1
??.??#??#?. 2,1,3
.??????.?.? 2,1,1
????##?????? 1,3,2
???##.?#?#??#?#.?.? 2,2,3,1,1
???.?#?..? 1,2,1
#??????#?#???.?? 1,1,2,2,1
.##..??.#???.#? 2,1,4,1
.????????#??#?#???? 6,8
???#????#??? 1,3,1
?#???#????? 5,2
???#.??????????##? 4,4,6
?##??.???#.??#? 4,1,3
????????#?.#???.. 6,4
????#.?.???#?####? 5,1,1,7
????????#??#??#?. 1,9
??.????????#??.????? 2,1,6,2,1
???.????????????#.? 2,1,4
???#??#???#.?#??##.? 7,1,1,2,2,1
.?#.??##.??.??? 1,3,1,1,1
?.?#.?#?.?.#? 2,1,1,1
????#????#???.??.? 1,3,6,1
##.??##.?? 2,3
?????.???#. 2,1,3
??...#.?????##?? 2,1,9
????.?.?#. 3,1,1
??.#??#?#?.?? 1,6,1
???##??#?#???? 3,7
???#????#?#? 2,4,3
??????.?#?#?.?? 4,5
??##?#?????#. 6,2
.???###?????#?#??? 12,4
#.???.?????.?#?.? 1,1,1,2,3
??#???????????#? 6,1,1,1
.???#???#?##???. 2,9
..#????###??..#??# 1,1,5,2,1
#?????#??#?##????..? 5,11,1
.???????.?. 1,1,1
??...???????????? 4,1
#??##??#??.?##? 8,1,3
?..??.??????.? 1,1,6
.??#?.?#???? 1,2,1,2
??????.????? 1,1,1
?#???###?.#. 2,5,1
#???.#??#?.##???? 1,1,5,3,1
?###??##???.??#????? 9,5,1
?##.??##?.?. 3,3,1
?.???.#??????##.?#? 1,1,1,9,1
..?#.?.????##?? 2,3,2
?#?.?##.???? 1,2,1,1
.#?????#?##### 1,1,9
??#..???#?#????????? 1,6
#.??????##??#?#.??#? 1,5,7,1,1
.?.?#????#???????? 1,3,2,1,3
.#???.????# 4,1,2
#???##??#????. 6,1,1
?.???????.???? 6,1
??#?#??#?..??????. 4,3,2,3
???#?.??.? 5,1,1
??.?#????? 1,1,1
??????????#??.?.?# 1,1,1,6,1,1
.??#?#???#??# 1,1,2,5
?#??##.??????? 5,6
??.??.?????#?#????? 1,1,10
..?????#.?.?..???? 6,2
?##??#.???.#?#???? 6,2,3,2
#?#?#?..??? 3,2,1
.#?#?##???.## 7,2
#???..???#?#?????# 4,1,9
?.?#????##?.???? 9,1,1
.????????? 2,2
#????????????. 1,2,2,1
??.???#.#?? 1,2,2
?????????? 1,1,3
.?.?????#?? 1,2
??#???.???#?##??#? 5,1,6,1
.#???.???? 4,1,1
.#??###???.????##??? 7,5
#???#??#????.?. 1,4,1
???##?##??????#?? 1,6,6
???#?????#????#? 5,9
.?.?..?.???.#???. 1,3
??#?.???.????? 2,3
.#?.##??#.?? 2,2,2,1
#.??????????.?.? 1,4,2,1,1
?.?####??????#.??? 11,1
.????.????? 1,2,1
??#.?????##?##? 2,7,2
?.??????????#?# 1,1,2,1,3
????#.?#?###. 1,6
???????#????#?? 1,1,4,2
.?#?#?#?????#. 9,2
?.????#??.? 4,1
?#?????.???#???.??? 1,2,1,3,1,3
?#???????#?.#.????? 1,7,1,1,3
.#??.???.??#??????# 3,3,9
#????..???#..#? 5,3,2
?.?.#?????.?? 1,6,1
.??..#??#?. 1,1,3
??###???#????##??? 10,3
??#??#?#?#?..??#???? 9,4
???#???????#? 4,6
?.#.?##?.??????##?? 1,4,6
??#???.?#??#? 2,1,6
??????##??.????? 8,1,1
?????#..?. 5,1
##.???.?...?? 2,1,1,1
????????##?#?# 1,7,1,1
??????????????? 8,1,1
???.??###? 1,1,5
????????????????##.? 1,4,1,3,3,1
??????????#?#? 1,3,4
.????.?.???#.???#?.? 4,1,4,2,2,1
.??#?#??#. 1,3,1
??.##.???#?#?.?#. 1,2,2,1,2
???#????#???.???#?? 4,2,1,3
.???.#?????..?? 1,6,1
..#?#????.. 1,2,1
??#?.?##?##? 4,5
?#?.?.???? 2,1
???????.#??#??#? 1,1,3,1,5
??.?.#.?????#??? 1,1,1,4
??#?.?#?????#?.??? 2,4,1,2
??????.??##?#??#?. 2,10
?????????#? 2,1,4
..??#????? 3,2
?????????###?? 1,7
#.?????????..????## 1,3,1,1,1,4
???#??.#.?.??? 1,3,1,1
??????#?#.#???#? 8,1,1
?#??????#? 1,3
.???.?.????##??#? 2,7
?#??#?????.?# 1,2,1,1
???#.#???#??.?##?.? 1,7,3
.?#?.#?.#?? 3,1,1
##?##????????? 7,1,1
..?#?###?????? 2,3,1,2
???.??..????..#?#?? 2,1,4,5
.?.?????????? 4,1
.????#?#?.?. 1,3
??#?##???.#??..? 7,2
????#????? 1,6
.#??????##??#?.?#?. 1,10,2
?#??#?.??#???.???#? 5,3,4
.????????#?????. 10,3
??#???#??#?.? 6,1
??.????#????#??? 1,1,4,1,1
??.?.???##.? 1,5,1
??.###????#??## 8,2
???#???????.?????.? 9,1,1,1
.????#??#??#???## 4,1,6
????..##?.?.?..???? 1,1,3,1,3
?.??.?#?#.?#?##??#?? 1,2,4,6,1
.????#???..????# 1,4,1,3
?##?.?.???#?#???.? 2,6,1,1
.??.??#???? 1,3
?#?.?????#????##??? 1,11
?#??##?#????? 1,5,3
.#?#.#.#.??#?#?? 1,1,1,1,7
#?#???#?###?##??#? 3,9,2
???.????##???????? 1,1,7,1
.?###?????.???##?#? 6,7
.#?#.#???#?????##?# 1,1,1,5,1,4
?????????#?#?#??? 1,2,4,1,3
?.???.#?#??? 1,3,1
#?#??#??.#.#???.. 6,1,4
?#????##?#????.? 10,2
????#????? 1,3,1
??.???.?.. 2,1
?.#???#???????? 2,2,2,2
?.?#??????#?. 1,7
.?????.??? 2,2
?#??.??#?? 2,3
?????#???.??.?..??. 1,1
??..???##???.?. 1,7,1
??#?????#. 1,1,4
#.?#.?##.#????? 1,2,2,2,1
??#??#?##.???# 6,2,1,1
??#??????##. 6,2
.#???.##.?. 1,1,2
??.?????#?.??#??#??? 2,1,2,7
?.??#.??.?.?.??.?. 3,1
??#??#.?#.#? 2,2,1,1
?#?????#?.? 3,3,1
??.#?.??#??.#??. 2,1,3
.???#?#??##.? 5,2
..???#????###?#??#? 4,1,3,1,1
?.???#?.????.?????. 4,2
.#??#?????# 1,1,2
.???#????#?? 1,8
#????????.####? 1,1,1,1,4
??##??????????? 9,2
?.??#?#????? 4,2
?..?????.?.#??? 3,1,3
#??.?#???. 2,1,1
?.#??????????? 1,7,1,1
?.???.?#?#? 2,5
???.?#???#??#??? 1,2,8
???#??#?.?#???? 1,1,3,1,1
???.?#?.?????#????## 3,2,2,4,2
##.???.?#??? 2,1,1,3
?.????.?.??.? 3,2
.??.?.?##????.???? 1,6,3
???.?#???? 2,3
?.???????. 1,2,1
.#???????#.???????. 3,2,5
..??.???#?..???#???. 2,2
???.??.#???##?#?? 1,2,1,6
?#?????#?? 2,3
??..??#??##?.?# 2,8,1
????????##??#??.??#? 13,1
???###.?##.??? 5,3,2
??#..??.????.#?. 3,1,4,2
?.?#?.??#? 1,2,4
?#???#?#?.# 8,1
?#?.??.???? 3,1,3
??##????#?? 3,1,2
?????????##??????? 1,12,2
??#??##??????##??#?. 8,7
??.??.???.? 2,1
???..#???????? 1,6
??.???##?? 1,5,1
#?.???.?#.?#???.#?? 1,2,1,1,1,3
??#????.?##?#???#?. 5,9
...#.???????? 1,5
?.?????????#?#????? 1,1,3,6,1
##?.#??.????.??# 2,3,3,3
??##????..??? 7,1
.??#.?.???.?.?#?..?? 3,1
??#????##??.? 1,5
#?????#.?#????.??? 1,4,1,2,1
#??..???.??.#??#? 3,2,1,4
.?#??#?..#?.#? 6,1,1
???##?#?#?.?# 3,4,1
???.#.?..??.#.???# 3,1,1,1,1,2
?.?.#.????? 1,1,2
???.??????#?# 1,2,5
????????.?????.?# 1,2,4,2
???????????#??? 8,1
?..#?.????#???##?# 1,1,10,1
..####??..?? 5,1
???#?###?#?.???? 9,1,1
.??.?????????..? 1,1,6
.?##?.?#.? 2,1
#??#??.??#..?.??.?? 6,2,2,1
??#??#?.?? 5,1
..#####?#???????? 8,4
?????#?#??.???# 6,1,2
?#?#????####????##. 5,1,10
??.??..?##??? 2,3
?.?###...?#?#. 3,3
?????????? 4,1
##.?.?#.??#? 2,2,1,2
??????#.??.#? 6,1
.?#???.??#?? 4,4
????#???#?#?#??#???. 5,12
?#..?.#???.??. 2,4,2
#.??#?#??.?#?#??#. 1,4,1,4,1
#.?..?.?#.?????????# 1,1,1,1,10
?##??##????###???? 3,2,1,5
?#??.#?????.???#?.?? 2,3,5
?.??.????? 2,1
??????##???.?? 2,2,1
??.#???#??#??.??##.? 2,3,5,3,1
?#?##????????? 5,1,1
???##??##???##???.? 14,1
??#.??????..## 2,1,1,2
.?#???.??? 2,3
.#????.???#.??#???. 3,3,5
???.?#?#??#??..??? 1,9,2
???#???????#???#??? 1,4,4,1,2
.?.?????????????#?.? 1,15
??#?#?.?????..? 3,1,3
???.??#?#?# 1,7
.??#??.???#.. 4,1,1
.??????.#????.????. 3,4,2
??#.##.#.?.#??.??##. 2,2,1,1,1,3
#.?.?..????? 1,1,1,2
???.##?.#.?##???#??? 1,3,1,4,2
##.??##??#. 2,3,1
..???#???????.??.? 8,1
#?.??.?????? 1,1,1,1
?###.?..??.#???#? 3,1,1,1,2
?#??????.?? 4,1,1
??.???.?.? 1,1
????????#???????.# 9,1,1,1
???.?#?#?#??? 2,7
#..??.?.?? 1,1,1
.??#????##??.????#? 9,5
??????.???#?? 1,2,1,1
..???..??#??#?#?? 1,9
????.#..##??#? 3,1,6
???????.... 2,1
##.???..?? 2,2,1
##??#???#????????#?. 5,4,5
.??..??#????? 1,1,2,1
.?????.##??? 3,3
?????#??#?##? 3,1,5
.#????.??.??.?????. 1,2,1,2,1,1
???.?.?#????..?##??? 1,1,1,1,3,6
???##?#?????#? 1,2,4,1
???##???????##??? 1,5,8
?#???????##????## 5,1,8
??.#?.?#?? 1,1
?????????????? 1,3,1,4
?#.???#??#?##???# 1,1,1,8
???.????##?. 1,1,1,5
?##..#???.??#. 3,3,1,1
?#?##?.?????.??## 5,1,4
?.???????.?. 1,1
.?.??.??## 1,1,2
??#?????.?# 5,1
?.?#.??????##.?#? 1,1,8,1
?#???.?.???? 4,1
???#?#??##??.?? 1,7,1
???..#????#??#?? 1,10
???????#???????##.# 2,1,2,1,6,1
?.?#??#.???? 1,1,2,1
..??##?.#???#??#??? 1,2,2,3,1,1
???????#?.##?# 8,2,1
?????..??? 2,1,1
#??.#.??#?# 1,1,3
??#?#?#???#.? 6,1
??#????##????? 4,5,2
???#??#??#.?#?##??? 2,7,5,1
.????#???? 4,1
.####?##?#??.#? 9,1
?????.?#?####? 2,8
?.?????#??#???#??? 1,1,1,1,6,1
?#?????#?#????? 3,3,1,3
##??#..?#?.???. 5,2,3
??##?????? 1,4,2
#?.???.?#?#? 1,1,1,1
#.??????????#????#?? 1,2,8
?#?#???#?? 3,1
??#?##??????#.???. 11,1
??..##???? 1,2,1
????#??#?????#???? 2,1,9,1
#???#???.???#??? 1,2,1,1,3
?#??????#.???? 6,1,2
???????????? 1,1,1,2
???.??????.??? 1,1,1,2
?.#???.???##.?.? 3,5
#?????#?##?#??#????# 13,2,2
?.??????.??#? 1,1,2,1
.??.???#??##?#? 1,1,1,6
???????????. 6,1
.????.????#.. 3,4
?.?#?????#?? 4,2
?#?#???????#?#?????? 10,1,1,2,1
???????????? 1,1,5
?????????# 1,5
..?#?###.##.??# 6,2,2
??#????##?#???? 2,3,3
#?#?????.??#?#? 1,2,6
.#??.#.???????.?..?? 1,1,1,7,1,1
????#??##??#?#?#?# 3,1,5,1,1,1
??..???####???????? 1,7,1,1,1
???...#.?? 2,1,1
.?.??#?..#???#?.??#? 3,6,2
?#??????#?? 5,1
?#??..????#?#???? 3,7,1
??.???#?.? 1,2,1
???#??.???#??? 3,1,2
???##???????#?. 1,3,1,3
???#?????#?..#?#? 1,5,3,3
??.?.?#?#??##?#? 1,1,4,4
.###???????#?# 3,8
.#??.?.???#?# 3,1,4
#?.???.???#. 2,1,2
##??#?.??. 2,2,2
#...???#?##?..#? 1,1,1,3,1
?..?#?#?#?.?????? 6,4
#?#????#????#.?.??? 1,9,1,1,2
#..??#.?????#???##? 1,3,3,7
.????.???#??###?? 1,8
?##?#????#? 3,2,2
????.??..#? 1,1
?.????###????? 1,6
??#?#.???#?#?? 4,3
?##?#??#?..???.#?. 8,2,2
?.#????#????#?.#???# 1,2,3,4,2,1
?#?.#????. 2,3
.??##??###???# 10,1
??#??##???...?? 6,1,1
#?????.?..#.? 5,1,1
?????#??????. 2,4,3
????#????? 1,1,2
?.?#???##? 1,1,5
#????.?.?????? 4,1,4
.??????????? 1,3,2
?.??????#??? 1,4,1
?.?#?????? 1,3,1
?.??.###???##????#?. 1,1,3,7
?#??????#.#. 2,1,1,1
.?##?.?????##??## 3,10
????.???#?? 1,2,1
??#????.?#?? 6,2
??.?.#?????.#.?? 2,1
?.??.?#?#?? 2,1,1
?##?.???#? 4,3
?#??.???#?.?? 2,1,4,1
.???????????.# 1,3,4,1
?#???.??#?????.? 1,2,1,6
??#?#?#??.#??. 2,4,1,1
??.?.??#???#?.??.?.? 1,1,6,2,1
#.#?.#???#?#?????#? 1,1,14
.???.#???#??? 2,2,3
##????????#??.?#..? 2,2,2,1,1
?#???#?..?. 1,2,1
??#???#?????#???.?? 3,5,4,1
#??????????#?#?? 1,3,7
?#???#??#?#?? 6,5
??????????? 1,6
#?????????????#? 1,2,6,2
????#??.#.??#. 1,2,1,3
?#????###?.?#.#??. 4,3,2,2
#????#??##????? 1,1,8,1
????.???????#?#? 4,8
?????#??#???#?.?? 6,3,3,1
?????.???..?#.??? 1,1,3,2,1
.?#??#?..???# 4,3
???...###?. 1,4
?#?.?????? 2,3
#?..?????. 2,1,1
????##???? 1,4,2
????????##???#?? 1,1,1,8
??.?..?##?.?#?##?.? 2,1,4,2,3,1
????.???.? 1,2
???????###? 2,5
???.#?.#.?##?? 1,1,1,5
?#????#???.?.? 9,1,1
????.??????##? 1,1,4
.???##.???..#? 5,3,1
?#?##?#?###????????? 5,1,7,1
#..#?.?#????##. 1,1,1,1,3
?.???#???????#???# 4,4,2,3
??.?.??###???????? 1,11
????#?????.??? 2,2,3,1
.?????????####...? 3,6
##??#?##??..??# 10,2
????#?#??.#??? 8,3
#.?????.??#?##?#? 1,1,1,8
#?.??####????.???#? 2,6,1,3
?#?????#.??? 3,2,2
???.##?#.?????????? 3,2,1,1,2,4
??##?##?????..??? 10,1
??.???????#??????? 4,8
###?.???#??? 4,1,2
##????#??#. 4,2,1
.?#?#???.??###?#??# 4,2,1,3,1,1
??????.?..#?.??# 2,2,2,3
.???????#?. 2,5
#?#??????? 4,2,1
.#?.???#??#??????#.? 2,11,1,1
??.????..##??..?### 1,3,2,1,4
???.?????#??? 1,6,1
???.?#??#? 1,4
#??.?????#?. 3,6
??#.#??.??????###? 1,3,8
.???.#????.??? 1,1,5,2
.#??????????? 1,2,2,4
#..?#??#??? 1,8
????#????? 1,1,5
?.???.?????.?????#? 2,4,7
#.?..?##??..??#??? 1,1,4,1,1,1
.???????#????. 2,8
###?..#.??????.?? 4,1,1,1,2
???.??.?### 1,4
???#.?#??.???. 2,4,2
.?#????#?.#???? 1,4,1,1,1
?.??##??#??? 4,5
##????#?#?. 2,4,1
.???#?#??#??#?.#?#? 10,4
.?#?#???.?#.??# 2,1,1,1,1
??.?????#..#??.??? 1,3,1,1,1,1
?...#?#?????????.. 4,3
.?#??????#???#?##.?? 11,4,1
?#???##...?.?????.?? 6,1,3
?#?.?#?#?? 2,1,2
?????##??#.????.???? 8,2,1
.???????#????##???.? 7,1,6,1
??##?????# 5,2
??##..#.?. 4,1,1
????##???? 1,2,2
???#????#?##???#??? 12,1,1
.???????#??.??? 8,3
?#?.##????? 1,7
??????.?.?# 4,2
??#???.#?#?#??? 1,1,1,3,1
???#???#?#???. 1,1,4,1
.???#?????#?..#???.# 4,5,1,1,1
???.??.#???#?. 1,2,1
..????.??##?? 1,6
??#?.?.?#??.??#. 1,1,1,2,3
#????.?#????#???#?. 1,1,1,4,1,1
????????????. 6,1
??.??#??#????.????# 2,7,5
#???????###.?.????. 1,1,6,3
???#?#???#?###? 6,7
????.#?#.??#?.???.? 1,1,3,3,2
#?????.???#???? 5,5
#??#??.#.?????#?. 1,2,1,7
?????#???. 5,2
????????##???.??.? 2,6,1
#?????????? 3,2
.??#????..??????#?? 2,1,7
????????#?##?? 9,2
#?.??????.??? 1,3,1,2
?????.????#?.?? 2,1,1,2,1
#???.??#???? 1,1,3,1
????.??#?. 4,1
???????#.???????? 6,5,1
??.???#??#??????. 1,7,3
???#??##??#????????? 1,13
.#?????????.#???.? 6,1,1,2,1
?????????.. 2,1
??????#????? 1,2,2
#?#????..????#?? 1,4,1,2
?.?.?#????#. 1,1,2,3
#??###??.?#????#???? 8,8
.#.?#????# 1,1,4
?#???#????? 1,6
????.?#???#.?. 2,2,3,1
??.?#?#????? 2,1,3
##???.??.?##????. 2,1,2,4,1
?????#?..?#?#?. 5,3
??#????#????. 10,1
????????????#.?? 1,2,6,1,1
#.?#??.???? 1,2,4
#..???#??? 1,4,1
?????#????#? 4,2
???.##???.. 1,3
?.##?#.?????.?. 4,3,1
??##??.?.??# 4,1,3
?#???#.?.??#??.??. 2,3,1,1,2,1
#??##????#???. 10,1
.??###?#???#?##?.#.? 14,1
?###???????????? 3,1,1,1,2
#?.???????.???#? 2,1,4,4
?#???#???? 1,3,1
????#?#????# 1,5,1
???###????????? 9,1
??????????#????????. 2,10,2
?#.??##???.?? 2,3,2
#?.???.??##? 1,1,1,4
???#???####???????# 11,1,1
##?.#??.?????.?#??#? 3,2,5,1,2
#?.??????###.?#?# 1,9,2,1
??#??##??.#####?. 9,6
?#?.???#?#.?????? 3,5,1,1,1
???##.#???####?.?? 3,9
????.?.###??.?#?? 2,1,3,1,4
.?#??.?####.# 4,5,1
.????.?????#?? 1,3,1
?.##????.???#? 3,1,4
????.###?????.? 2,4,3,1
?.?#.?#?????#??? 1,1,8,1
?#?????????.????? 2,5,2
..#????#?#?..#?????# 1,7,2,2
#????..???#??# 1,1,7
???.??.?#?.?? 3,1,2,1
?#??#?#??##?#??#?. 3,1,11
????#?#?###? 1,8
?#????.???#.? 4,1,1
.?#??????????. 1,2,5
.??#??#??. 2,2
???###?????#???#??#. 7,2,4
??.???.?.????? 2,2
???#??#??# 1,7
???#?.??.????#?##??. 4,2,10
#??.??#??????#???# 2,1,8
????#?????#????#? 1,5,1,4
?.#?##??????? 1,5,1,1
#??.?#??????? 1,6,1
?..?##??######??.?? 1,11,1
??#??#.?#?#???????? 1,4,2,1,2,3
??????????##???.. 2,4
.???????#.#? 1,1,2,2
???????#??##.? 1,1,1,5
???.??#??? 1,5
.#?#.?#?#?# 3,4,1
.?#?.??.?#???? 2,1,2
.?.#?#????#???? 3,3,1
#?????????#..##?#? 1,2,1,1,4
??##??????.?? 4,1,1
.??????#?#? 3,4
?#.?.?..?#?. 2,2
?#??.?#?#??.??????# 2,2,2,1,1,2
?##???##??????..# 8,5,1
??.?#?????????#?? 2,1,9
????.???.. 1,1,1
???#?.???? 3,1
??.??????#???????? 2,6
??#???##???.#?#?. 3,5,4
##???????? 3,2,2
.??#????#?? 2,4
??????.??# 2,2,2
##..#??..??#???. 2,2,6
..?.#?#??.???????? 3,6
##??????#??????? 2,1,1,6
???#??..???? 4,2
.?#?#??..?????.?? 4,3
#??#????.#?? 8,1
.???##.??.?? 4,1
??????#??##?????? 2,13
##???..?.?? 5,1
?.?#?#???..##? 1,6,3
??.????#.?#??# 1,4,1,1
.#?????????#??.??#?. 5,5,2
??.?..#.#??? 1,1,2
??#?.?#??###??? 4,8
??#??#?##???. 2,8
#.#????#???? 1,1,1,1
#???##?#??#??#????? 2,8,1,4
?????????#??## 1,10
??#???#???#??????. 1,15
?###??.??????## 5,3,4
?#???#?.?? 6,1
?.????.???#?###???? 1,8
?##??????..???? 3,1
??##??#..?#?. 5,1
.###?????#?? 6,2,1
??.#??.#?#. 2,1,1
.??.?##???##.#???# 1,8,2,1
?#?#????.##????? 4,3,2,1
?????????.??.? 3,1
##?.???????#???#? 2,10
??#..#???#???#?. 1,1,7
?.#?#..?##?..?? 3,3
??#???????#??#. 1,1,7
#..?.#???#??# 1,1,2,5
.????##???. 1,6
???#???.???#???? 4,5
??##????#. 3,1
??.?#.??.?. 1,1,1
.??.????#??? 1,1,1,1
?.###?.????.? 4,2
???##????.?.?.?.?##? 4,1,1,1,4
???##?#??#?#.# 1,5,3,1
?.?????#?????? 1,1,4,1
..#??##?#?.?#?.? 7,3
#..??#????????????? 1,3,2,4,1
?#.?#??.#?#?????? 1,4,5,1
#???????##..#????? 10,6
..???.#??? 2,2
??#??.?.#??. 2,2
?.?#??.?.?#..?? 3,2
???#?????? 3,3
????????.????..?# 3,2,1,1,1
?????????#?.# 1,1,4,1
#?#.?..?#?.?. 3,2
???.??##????????. 2,9
??#.#.????#.??? 2,1,1,2,2
????.?#.??? 1,2,1
#???????.???.?. 1,1,2,2,1
???.????##????? 2,3,1
?????..??#? 1,2,2
.#?.?#???? 2,1,2
#?????????? 5,2,1
???#?#?..?#????#??.. 6,9
.#???.?????#????. 1,2,4,5
????.??.#???? 2,1,1,1
#?.???##??? 2,1,2
??.?###??.????#?.??? 1,6,4,1,1
#?..?#?##?.? 2,5,1
?????.#????.???# 1,1,4,1,2
#?#??#????#????# 3,2,2,4
???.?????####.##?.? 2,3,5,3
??????..#.? 1,2,1
#????.#???.#?##?? 2,2,5
.??.?#?###?????#??? 1,13
?.??#.??????#?? 3,7
#???.#.????#?.#?#??? 1,1,1,4,3,2
????.#????. 3,1,1
?.???????#??#??.?? 1,4,3,1
#?.#???..??? 2,1,1,2
.?#?#????.? 2,5
??##??#??# 7,1
????##.??##?? 1,2,3
???????????#??? 1,3,2,1,1
??????##?..#?#??.?.? 9,1,1,1,1,1
.???.???.?? 1,1
#?.??.?#???????..? 1,1,1,4,1,1
?.?#?#?.???#?. 5,3
?????????.??..#?.? 5,2,1,1
?#???.???##?????? 3,10
?##??.#?????#.??#? 4,4,2,1,2
.#.?.??.?? 1,1,1
???#?.???.?.???? 2,3,2
?#.?#??.?? 1,1,1
#??##.?.?#?#?????# 1,2,10
?.????###????.? 8,1
?##???????? 4,4
??.?.#?.?#?.###???#? 2,1,2,1,8
?##?#??????.?.??#?# 6,3,1,1,3
?.?.#??##???#?#? 1,1,5,1,1
????.???#?#???#? 3,6,1
..#??###??????### 6,7
.???????.??#. 1,1
?#????????#???#??? 2,2,4,2
.#??#?#?????. 1,2,2,2
??..?.?????##????. 2,1,3,2,1,1
??.?#.?.#?? 1,1,2
?????????? 7,1
#??????.?..??????? 6,1,1,1,1
??.#???#?????.?????? 1,8,1,1,1
.#.#????????. 1,1,5
???#?#..##??## 4,1,3,2
.#???#????????.# 1,9,1,1
?##???????? 3,1
??#????#.#? 1,1,1
.??###.?#???#??#???? 5,3,6
.???#?#???####??#?? 7,8
???.?.??????????? 1,10
#.??.?.#?..# 1,2,1,1
????#.??#... 4,2
#?????..??.? 1,1,1,1
#?????##???.? 1,1,3,1
????????.??? 1,1,1,3
.??####?.?#??#??? 4,5
?#?#???..? 1,2,1
??#???????###??. 5,7
?.?#?#?##?.?#?##. 7,4
###.##????#???.?# 3,2,2,1,2
..??#?..?#??.##?#?## 1,1,3,2,1,2
?#????????????##???? 1,1,3,1,6,2
???.?#??.??? 1,3,1
???##???????.??##?? 4,1,2,4
.?.?.?#??## 1,5
?.##??????.???.? 6,1,2
.?????.?###? 1,5
????.?????. 2,1,1
#?????.?????.#??.?#? 1,1,1,1,2,3
????????.#?.. 6,2
?.#???.????.?.??#? 1,1,2,1,1,2
?#????#?#????#?..?. 14,1
#..??#?#???? 1,1,6
?.?#?#?????? 4,1
????##?#?.#?. 5,1
?????###??.#?#??.? 1,7,5
#??????.???? 1,1,1,3
??#????????. 1,5
...#??#..????. 4,1,2
?#??#??#?.? 5,2,1
??#??.?#??????????. 3,6,3
?.#?#?????? 5,2
???#???##?.??. 8,2
..?.#??????.? 1,1,1
???#.##??#? 3,5
?.????#???????.#? 1,1,4,1,1
?#?????.??? 2,2,2
?.?#?.?????.?. 1,1,1,2
?????.??????.??????? 3,2,1,1,1,2
#?????#??..#??#??. 9,5
..#?????.. 1,1,1
?..???#??#?????#?#?? 5,4
##??????##????.?? 13,1
????##???#????. 1,6,1
???.#?#??????# 1,4,2
.???.??### 2,3
?.#??????####?#??? 1,1,1,1,7,1
?.?#.?.?????##.? 2,1,1,3
??#??.###?? 4,3
..????#???????? 2,7
.??????????. 2,1,1,1
?#.???#?#????? 2,1,4,2
#?##???.?#.?.#. 5,1,2,1,1
#.?#.?#?#? 1,1,4
??.???##?. 1,1,3
????#.???#?## 2,1,2,4
???#?#?#??##??#??#? 1,15
#?.????#?????.????#? 2,1,6,1,2
.?????.#??? 1,1,4
#?.???###?#???. 1,1,8
?.??#?#????????# 1,5,1,1,2
.????.???##?#.??#?? 1,1,7,3
.####.#??# 4,1,2
?#?????.#.?.?## 2,1,1,1,3
??#?.??????# 1,1,2,3
????.#??????? 4,5
#..???.?.???##.??? 1,3,1,1,2,1
.?#??..?.?##?????#? 4,1,2,2,1
??#.??.?.??# 2,1,1,1
#???#???????? 9,2
.?#.????#???? 1,2,2
#.??.?#.???.??? 1,1,1,2,1
?????##????.?.?? 10,1,1
?????#?.#???.?????? 6,1,1,1,1
?#???????. 1,1,1
????#??????##???.? 2,1,2,2,1,1
???.?##??????#???.? 3,3,7
?.#?.???.#?? 2,1
?..??#????.?.?..##?? 7,3
?#?#?#?????????# 4,1,3,2,1
?.#.#?.?????? 1,1,1,2
#??.?##??..?????.? 3,4,2,1
????.#????##??..?#? 3,1,3,1,2
??#?..???#?? 3,1,1
???..?#???### 3,1,1,3
.??????..???## 5,3
##??????.???? 4,1
?#????##?#?.???? 1,5,3
..?##?#??????##.??#? 9,2,1
..#??.?.??. 1,1
.???.?#???????#??? 1,5,1,1,1
.???.??#?? 3,3
??#?##??#?.?#? 10,2
?.???.???.?? 1,1,2,1
????.????# 2,2,1
??????.?????? 2,3,1
??.?#..#?#??.?# 2,1,5,1
?????#?.?#???..???? 2,3,2,1,1,1
??.??####?##.??. 1,8
?#????##?##.##??? 2,7,5
.#???#..???#?#???#?? 2,1,11
?##??#?.????? 6,2,1
#???.?#??..??? 1,4,2
???????###? 4,3
??.??#??## 1,1,5
?.?#??.?#?#???. 2,6
#??.?????#?##?#??? 1,1,1,1,9
?#??#.??#??####??? 5,9,1
#??.??????. 3,5
#???#??#.??#? 1,6,1
.?.???##??.?#????. 5,3,1
?#?##??????##???#??. 1,10,3
.?????????.?? 1,1,2,1
?.???#???. 3,1
????????#?#?? 5,4
?.?????##.????#????? 1,1,2,1,5
??#???#?#??.. 1,1,5
??##??##?.#...??.?? 4,4,1,1,1
?#??##?##?##?#???. 11,2,1
?..????#???. 1,1,3
????#???????. 3,2
?###.?#??.???#.?#? 4,2,1,1,1,3
?#?#?????.?#?? 7,1,1,1
???????#???. 1,2,1
#?##??#?..?#?.?# 7,2,2
???#.#??.??#?. 3,3,4
.???..##?? 2,3
#.?.?.?..??##?? 1,1,1,5
.?#??#??#? 2,1,1
?#?##??.#??? 2,3,1,1
#???#????.????????#? 6,1,3,4
.#..????????#? 1,1,1,3
????.#??..??.? 1,2
#??#..?#??#????? 4,1,5
#?#????.????#.???. 7,1,1,1,1
.?????????? 1,2,1
????#?.??? 1,3,1'
drop table if exists #Input
drop table if exists #Input2

select ordinal ID, Lava, Nums, len(Lava) - SpringSum - SpringCount + 1 Wiggle, SpringCount, len(Lava) LavaLen
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1) r
	cross apply (select charindex(' ', r.[value], 1) ind) i
	cross apply (select left(r.[value], ind - 1) + '.' Lava, substring(r.[value], ind + 1, 1000) Nums) i1
	cross apply (select sum(cast(c.[value] as int)) SpringSum, count(*) SpringCount
					from string_split(Nums, ',', 1) c
				) s

insert into AOC_2023_Day12_Ranges
select i.ID, i.Lava, i.Wiggle, i.SpringCount, n.ordinal, ln
from #Input i
	cross apply string_split(Nums, ',', 1) n
	cross apply (select cast(n.[value] as int) ln) i2

;with i as
	(select ID, [value] Ordinal, Symbol, iif(lag(Symbol, 1, '.') over(partition by ID order by [value]) != '.', 1, 0) val
		from #Input
			cross apply generate_series(cast(1 as int), cast(LavaLen + 1 as int), cast(1 as int))
			cross apply (select substring(Lava, [value], 1) Symbol) s
	)
insert into AOC_2023_Day12_Broken
select ID, Ordinal, Symbol, sum(val) over(partition by ID order by Ordinal) Springs
from i
	
--1
;with rec as
	(select ID, cast(0 as int) Ordinal, 1 NextStart, cast(null as varchar(max)) Locations, SpringCount
		from AOC_2023_Day12_Ranges
		where Ordinal = 1
		union all
		select r.ID, NewOrdinal Ordinal, c.NextStart, c.Locations, r.SpringCount
		from rec r
			cross apply (select r.Ordinal + 1 NewOrdinal) n
			cross apply fn_AOC_2023_Day12_ProcessNextSpringSet(ID, NewOrdinal, NextStart, r.Locations) c
	)
select sum(Solution) Answer1
from rec r
	cross apply (select top 1 cast(json_value(j.[value], '$[1]') as bigint) Solution
					from openjson(Locations) j
					order by cast(json_value(j.[value], '$[0]') as int) desc
				) j
where r.Ordinal = r.SpringCount
option (maxrecursion 32767)

select ID, n.Lava, n.Nums, len(n.Lava) - SpringSum - s.SpringCount + 1 Wiggle, s.SpringCount, len(n.Lava) LavaLen
into #Input2
from #Input
	cross apply (select cast(stuff(replicate('?' + left(Lava, LavaLen - 1), 5), 1, 1, '') + '.' as varchar(1000)) Lava
						, stuff(replicate(',' + Nums, 5), 1, 1, '') Nums
				) n
	cross apply (select sum(cast(c.[value] as int)) SpringSum, count(*) SpringCount
					from string_split(n.Nums, ',', 1) c
				) s

truncate table AOC_2023_Day12_Ranges
insert into AOC_2023_Day12_Ranges
select i.ID, i.Lava, i.Wiggle, i.SpringCount, n.ordinal, ln
from #Input2 i
	cross apply string_split(Nums, ',', 1) n
	cross apply (select cast(n.[value] as int) ln) i2

truncate table AOC_2023_Day12_Broken
;with i as
	(select ID, [value] Ordinal, Symbol, iif(lag(Symbol, 1, '.') over(partition by ID order by [value]) != '.', 1, 0) val
		from #Input2
			cross apply generate_series(cast(1 as int), cast(LavaLen + 1 as int), cast(1 as int))
			cross apply (select substring(Lava, [value], 1) Symbol) s
	)
insert into AOC_2023_Day12_Broken
select ID, Ordinal, Symbol, sum(val) over(partition by ID order by Ordinal) Springs
from i

--2
;with rec as
	(select ID, cast(0 as int) Ordinal, 1 NextStart, cast(null as varchar(max)) Locations, SpringCount
		from AOC_2023_Day12_Ranges
		where Ordinal = 1
		union all
		select r.ID, NewOrdinal Ordinal, c.NextStart, c.Locations, r.SpringCount
		from rec r
			cross apply (select r.Ordinal + 1 NewOrdinal) n
			cross apply fn_AOC_2023_Day12_ProcessNextSpringSet(ID, NewOrdinal, NextStart, r.Locations) c
	)
select sum(Solution) Answer2
from rec r
	cross apply (select top 1 cast(json_value(j.[value], '$[1]') as bigint) Solution
					from openjson(Locations) j
					order by cast(json_value(j.[value], '$[0]') as int) desc
				) j
where r.Ordinal = r.SpringCount
option (maxrecursion 32767)