declare @Input varchar(max) =
'#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#'

drop table if exists #Input
drop table if exists #Input1
drop table if exists #Parsed
drop table if exists #Modified

select ordinal SetID, [value] Board
into #Input
from string_split(replace(@Input, char(13)+char(10)+char(13)+char(10), '^'), '^', 1) s

select SetID, c.[value] X, r.ordinal Y, replace(replace(substring(r.[value], c.[value], 1), '.', '0'), '#', '1') Symbol, max(c.[value]) over(partition by SetID) MaxX, max(r.ordinal) over(partition by SetID) MaxY
into #Input1
from #Input
	cross apply string_split(replace(Board, char(10), ''), char(13), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int), cast(1 as int)) c

select SetID, X P, max(MaxX) MaxP, max(MaxY) MaxOP, string_agg(Symbol, '') within group(order by Y) Line, 1 Val
into #Parsed
from #Input1
group by SetID, X
union all
select SetID, Y P, max(MaxY) MaxP, max(MaxX) MaxOP, string_agg(Symbol, '') within group(order by X) Line, 100 Val
from #Input1
group by SetID, Y

--1
;with Matches as
	(select i.SetID, i.P P1, i1.P P2, i.Val
		from #Parsed i
			inner join #Parsed i1 on i1.SetID = i.SetID
								and i1.Val = i.Val
								and i1.P = i.P + 1
								and i1.Line = i.Line

	)
select sum(P1*Val) Answer1
from Matches m
	cross apply (select count(*) Cnt, max(iif(i2.Line = i1.Line, 0, 1)) Diff
					from #Parsed i1
						inner join #Parsed i2 on i2.SetID = m.SetID
											and i2.Val = i1.Val
											and i2.P = m.P2 + (m.P1 - i1.P)
					where i1.SetID = m.SetID
							and i1.Val = m.Val
							and i1.P < m.P1
				) p
where Diff is null
	or Diff = 0

select SetID, P, MaxP, iif([value] = 0, 0, 1) IsFixed, iif([value] = 0, Line, stuff(Line, [value], 1, cast(~cast(substring(Line, [value], 1) as bit) as char(1)))) Line, Val
into #Modified
from #Parsed i
	cross apply generate_series(cast(0 as int), cast(MaxOP as int), cast(1 as int)) s

--2
;with rec as
	(select i.SetID, i.P SourceP, i.MaxP, i.P P1, i1.P P2, i.Val, i.IsFixed + i1.IsFixed IsFixed, 0 IsBurned
		from #Modified i
			inner join #Modified i1 on i1.SetID = i.SetID
									and i1.Val = i.Val
									and i1.P = i.P + 1
									and i1.Line = i.Line
									and i1.IsFixed + i.IsFixed < 2
	union all
	select r.SetID, r.SourceP, r.MaxP, i1.P P1, i2.P P2, r.Val, r.IsFixed + i1.IsFixed + i2.IsFixed IsFixed, iif(i2.Line != i1.Line, 1, 0) IsBurned
	from rec r
		inner join #Modified i1 on i1.SetID = r.SetID
								and i1.Val = r.Val
								and i1.P = r.P1 - 1
								and i1.IsFixed + r.IsFixed < 2
		inner join #Modified i2 on i2.SetID = r.SetID
							and i2.Val = r.Val
							and i2.P = r.P2 + 1
							and i2.IsFixed + i1.IsFixed + r.IsFixed < 2
	where r.IsBurned = 0
	)
	, i as
	(select distinct SetID, SourceP*Val Val
		from rec
		where IsBurned = 0
			and IsFixed = 1
			and (P1 = 1
				or P2 = MaxP
				)
	)
select sum(Val) Answer2
from i