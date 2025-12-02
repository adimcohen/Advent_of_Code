declare @Str varchar(max) =
'addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop'

drop table if exists #Instructions

--Parse Input
select row_number() over(order by (select 1)) ID, cast(V as int) V
into #Instructions
from string_split(replace(@Str, char(10), ''), char(13)) i
	cross apply (select charindex(' ', [value], 1) ind) i1
	outer apply (select substring([value], ind + 1, len([value])) V
					where ind > 0) i2

--Solution #1
;with rec as
	(select cast(0 as int) CycleID, cast(0 as int) InsID, cast(1 as int) X, cast(null as int) V, cast(null as tinyint) AddV
	union all
	select CycleID + 1, cast(i.ID as int), r.X + iif(r.AddV = 2, r.V, 0) X, i.V, cast(case when AddV < 2
																							then AddV + 1
																						when i.V is not null
																							then 1
																						end as tinyint) AddV
	from rec r
		inner join #Instructions i on i.ID = r.InsID + iif(isnull(AddV, 2) = 2, 1, 0)
	where CycleID + 1 <= 220
	),
	s as
	(select *, CycleID * X SignalStrength
		from rec
		where (CycleID - 20) % 40 = 0
	)
select sum(SignalStrength) Answer1
from s
option (maxrecursion 32767)

--Solution #2
;with rec as
	(select cast(0 as int) CycleID, cast(0 as int) InsID, cast(1 as int) X, cast(null as int) V, cast(null as tinyint) AddV
	union all
	select CycleID + 1, cast(i.ID as int), r.X + iif(r.AddV = 2, r.V, 0) X, i.V, cast(case when AddV < 2
																							then AddV + 1
																						when i.V is not null
																							then 1
																						end as tinyint) AddV
	from rec r
		inner join #Instructions i on i.ID = r.InsID + iif(isnull(AddV, 2) = 2, 1, 0)
	where CycleID + 1 <= 240
	),
	s as
	(select RowID, CursorPosition, iif(CursorPosition - SpriteStart <= 2 and CursorPosition >= SpriteStart, '#', '') Symbol
		from rec
			cross apply (select (CycleID - 1)/40 RowID,
								isnull(nullif(CycleID%40 - 1, -1), 39) CursorPosition,
								X - 1 SpriteStart) s
		where CycleID > 0
	)
select [0] [ ], [1] [ ], [2] [ ], [3] [ ], [4] [ ], [5] [ ], [6] [ ], [7] [ ], [8] [ ], [9] [ ], [10] [ ],
		[11] [ ], [12] [ ], [13] [ ], [14] [ ], [15] [ ], [16] [ ], [17] [ ], [18] [ ], [19] [ ], [20] [ ],
		[21] [ ], [22] [ ], [23] [ ], [24] [ ], [25] [ ], [26] [ ], [27] [ ], [28] [ ], [29] [ ], [30] [ ],
		[31] [ ], [32] [ ], [33] [ ], [34] [ ], [35] [ ], [36] [ ], [37] [ ], [38] [ ], [39] [ ]
from s
	pivot (max(Symbol) for CursorPosition in ([0], [1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20],
												[21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31], [32], [33], [34], [35], [36], [37], [38], [39])) p
order by RowID
option (maxrecursion 32767)