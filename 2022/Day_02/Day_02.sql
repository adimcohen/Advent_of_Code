declare @Str varchar(max) =
'A Y
B X
C Z'

;with Winner(A, B, Score) as
	(select 'A', 'X', 3
		union all select 'A', 'Y', 6
		union all select 'A', 'Z', 0
		union all select 'B', 'X', 0
		union all select 'B', 'Y', 3
		union all select 'B', 'Z', 6
		union all select 'C', 'X', 6
		union all select 'C', 'Y', 0
		union all select 'C', 'Z', 3
	)
	, ScoresPerSign(Sgn, Score) as
	(select 'X', 1
		union all select 'Y', 2
		union all select 'Z', 3
		union all select 'A', 1
		union all select 'B', 2
		union all select 'C', 3
	)
select sum(w.Score + s.Score) Answer1
from string_split(replace(@Str, char(10), ''), char(13)) rw
	cross apply (select charindex(' ', [value], 1) ind) i1
	cross apply (select left([value], ind - 1) p1, substring([value], ind + 1, len([value])) p2) i2
	inner join Winner w on A = p1 and B = p2
	inner join ScoresPerSign s on Sgn = B

;with Winner(Op, Me, Result) as
	(select 'A', 'A', 'Y'
		union all select 'A', 'B', 'Z'
		union all select 'A', 'C', 'X'
		union all select 'B', 'A', 'X'
		union all select 'B', 'B', 'Y'
		union all select 'B', 'C', 'Z'
		union all select 'C', 'A', 'Z'
		union all select 'C', 'B', 'X'
		union all select 'C', 'C', 'Y'
	)
	, ScoresPerSign(Sgn, Score) as
	(select 'X', 1
		union all select 'Y', 2
		union all select 'Z', 3
		union all select 'A', 1
		union all select 'B', 2
		union all select 'C', 3
	)
	, Scores(res, Score) as
	(select 'X', 0
		union all select 'Y', 3
		union all select 'Z', 6
	)
select sum(sp.Score + s.Score) Answer2
from string_split(replace(@Str, char(10), ''), char(13)) rw
	cross apply (select charindex(' ', [value], 1) ind) i1
	cross apply (select left([value], ind - 1) p1, substring([value], ind + 1, len([value])) p2) i2
	inner join Winner w on w.Op = p1 and w.Result = p2
	inner join ScoresPerSign sp on sp.Sgn = Me
	inner join Scores s on s.res = w.Result