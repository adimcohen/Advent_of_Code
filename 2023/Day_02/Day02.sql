declare @Input varchar(max) = 
'Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green'

declare @Check varchar(max) = '12 red cubes, 13 green cubes, and 14 blue cubes'
drop table if exists #Input

select GameID, r.ordinal RoundID
	, isnull(max(case when Color = 'red' then ColorCount end), 0) Red
	, isnull(max(case when Color = 'blue' then ColorCount end), 0) Blue
	, isnull(max(case when Color = 'green' then ColorCount end), 0) Green
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 0) i
	cross apply (select charindex(':', i.[value], 1) ind1) i1
	cross apply (select cast(substring(i.[value], 6, ind1 - 6) as int) GameID, substring(i.[value], ind1 + 2, len([value])) Line) l
	cross apply string_split(Line, ';', 1) r
	cross apply string_split(r.[value], ',', 0) c
	cross apply (select trim(c.[value]) ColorInfo) ci
	cross apply (select charindex(' ', ColorInfo, 1) ind2) i2
	cross apply (select cast(left(ColorInfo, ind2 - 1) as int) ColorCount, substring(ColorInfo, ind2 + 1, len(ColorInfo)) Color) cp
group by GameID, r.ordinal

--1
;with CheckInfo as
	(select isnull(max(case when Color = 'red' then ColorCount end), 0) Red
			, isnull(max(case when Color = 'blue' then ColorCount end), 0) Blue
			, isnull(max(case when Color = 'green' then ColorCount end), 0) Green
		from (select replace(replace(@Check, 'cubes', ''), 'and', '') CheckVal) v
			cross apply string_split(CheckVal, ',', 0) c
			cross apply (select trim(c.[value]) ColorInfo) ci
			cross apply (select charindex(' ', ColorInfo, 1) ind2) i2
			cross apply (select cast(left(ColorInfo, ind2 - 1) as int) ColorCount, substring(ColorInfo, ind2 + 1, len(ColorInfo)) Color) cp
	)
	, GameMaxes as
	(select GameID, max(Red) Red, max(Blue) Blue, max(Green) Green
		from #Input
		group by GameID
	)
select sum(distinct GameID) Answer1
from GameMaxes i
where exists (select *
				from CheckInfo c
				where c.Blue >= i.Blue
					and c.Green >= i.Green
					and c.Red >= i.Red
			)

--2
;with GameMaxes as
	(select GameID, max(Red) Red, max(Blue) Blue, max(Green) Green
		from #Input
		group by GameID
	)
select sum(Red*Blue*Green) Answer2
from GameMaxes i