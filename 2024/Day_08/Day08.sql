declare @Input varchar(max) = 
'..........................4..............7..q.....
..........G..42.f......K.........7................
D.t...S......A....................................
..K.................................I.............
G....D...f.tA..H.S..........o................N....
t....f..............4..A........B.........N.....q.
...b...k....f..h..........6.......................
..........b....m................7...............Q.
....h....G.2........K.i...........................
.F...2.....D....H..6..o........I..................
k.......b..................K......I.....e.....B...
.............Sp..o....n....R.............N........
F............d................2...................
.........i........................................
.....ma.....d......p.Q..n.....7....9..........N...
......m..H......S...8......n.....Q...e............
.i..............8......O.....I................c...
..d......k....R.....................9....z........
..p.......m......n...............P................
.......pLb...................W..j................q
.....C..1..........u.....c.....jO...Z..o.........V
..C.....i........X1......9......e....j.....B....c.
......................9...........Q..Z............
.d....h..L...............8........O...............
....C....r..L....R...............6................
...........h.............1.t......P.......V.......
.......L.1........................................
..................................................
X.......................................V.....W...
rx........a.X.......0....l..........6.........z...
..r........a.8.................................z..
................w.........l..............P....A...
..........E....s..w.j........l...............W....
...v...............c..............W..y...V.O......
.....X..g.Y...0w......l...................u.......
.C.......Y...0....................................
...g..UJ...0........v.............................
.U...aY...........................................
....5........Y....MUJ..........B..................
.......g...5M........J.......w.........u..Z.......
................TE................................
..U....r....5.................J..........Z........
.......5...3......s........T......................
.............E.T..............................u...
...........v........y.......................P.....
................s.................................
x............M3........e..........................
........3...v......MT.............................
.............x....................................
....x..........3............y.....................'
drop table if exists #Input

select row_number() over(order by r.ordinal, c.[value]) ID,  c.[value] X, r.ordinal Y, substring(r.[value], c.[value], 1) collate SQL_Latin1_General_CP1_CS_AS Symbol, max(c.[value]) over() MaxX, max(r.ordinal) over() MaxY
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int)) c

;with i as
	(select *
		from #Input
		where Symbol != '.'
	)
	, i1 as
	(select i.X X1, i.Y Y1, i1.X X2, i1.Y Y2, i.MaxX, i.MaxY
		from i
			inner join i i1 on i1.Symbol = i.Symbol
							and i1.ID > i.ID
	)
	, i2 as
	(select *
		from i1
			cross apply (select abs(X1 - X2) DiffX, abs(Y1 - Y2) DiffY) d
	)
	, i3 as
	(select X1 + iif(X1 > X2, 1, -1)*DiffX X, Y1 + iif(Y1 > Y2, 1, -1)*DiffY Y, MaxX, MaxY
		from i2
		union
		select X2 + iif(X2 > X1, 1, -1)*DiffX, Y2 + iif(Y2 > Y1, 1, -1)*DiffY, MaxX, MaxY
		from i2
	)
select count(*) Answer1
from i3
where X between 1 and MaxX
	and Y between 1 and MaxY

;with i as
	(select *
		from #Input
		where Symbol != '.'
	)
	, i1 as
	(select i.X X1, i.Y Y1, i1.X X2, i1.Y Y2, i.MaxX, i.MaxY, i.Symbol
		from i
			inner join i i1 on i1.Symbol = i.Symbol
							and i1.ID > i.ID
	)
	, i2 as
	(select *
		from i1
			cross apply (select abs(X1 - X2) DiffX, abs(Y1 - Y2) DiffY) d
	)
	, i3 as
	(select X1 X, Y1 Y, iif(X1 > X2, 1, -1)*DiffX DiffX, iif(Y1 > Y2, 1, -1)*DiffY DiffY, MaxX, MaxY, Symbol
		from i2
		union
		select X2, Y2, iif(X2 > X1, 1, -1)*DiffX DiffX, iif(Y2 > Y1, 1, -1)*DiffY DiffY, MaxX, MaxY, Symbol
		from i2
	)
	, rec as
	(select X StartX, Y StartY, X, Y, DiffX, DiffY, MaxX, MaxY, 0 Distance, Symbol
		from i3
		union all
		select StartX, StartY, NewX, NewY, DiffX, DiffY, MaxX, MaxY, NewDistance, Symbol
		from rec r
			cross apply (select r.Distance + 1 NewDistance) n
			cross apply (select X + DiffX NewX, Y + DiffY NewY) nxy
		where NewX between 1 and MaxX
			and NewY between 1 and MaxY
	),
	res as
	(select distinct X, Y
		from rec
	)
select count(*) Answer2
from res