declare @Str varchar(max) =
'abaacccccccccccccaaaaaaaccccccccccccccccccccccccccccccccccaaaaaa
abaaccccccccccccccaaaaaaaaaaccccccccccccccccccccccccccccccccaaaa
abaaaaacccccccccaaaaaaaaaaaaccccccccccccccccccccccccccccccccaaaa
abaaaaaccccccccaaaaaaaaaaaaaacccccccccccccccccdcccccccccccccaaaa
abaaaccccccccccaaaaaaaaccacacccccccccccccccccdddcccccccccccaaaaa
abaaacccccccccaaaaaaaaaaccaaccccccccccccciiiiddddcccccccccccaccc
abcaaaccccccccaaaaaaaaaaaaaaccccccccccciiiiiijddddcccccccccccccc
abccaaccccccccaccaaaaaaaaaaaacccccccccciiiiiijjddddccccaaccccccc
abccccccccccccccaaacaaaaaaaaaaccccccciiiiippijjjddddccaaaccccccc
abccccccccccccccaacccccaaaaaaacccccciiiippppppjjjdddddaaaaaacccc
abccccccccccccccccccccaaaaaaccccccckiiippppppqqjjjdddeeeaaaacccc
abccccccccccccccccccccaaaaaaccccckkkiippppuupqqjjjjdeeeeeaaccccc
abccccccccccccccccccccccccaaccckkkkkkipppuuuuqqqjjjjjeeeeeaccccc
abccccccccccccccccccccccccccckkkkkkoppppuuuuuvqqqjjjjjkeeeeccccc
abcccccccccccccccccccccccccckkkkooooppppuuxuvvqqqqqqjkkkeeeecccc
abccaaccaccccccccccccccccccckkkoooooopuuuuxyvvvqqqqqqkkkkeeecccc
abccaaaaacccccaaccccccccccckkkoooouuuuuuuxxyyvvvvqqqqqkkkkeecccc
abcaaaaacccccaaaacccccccccckkkooouuuuxxxuxxyyvvvvvvvqqqkkkeeeccc
abcaaaaaaaaaaaaacccccccccccjjjooottuxxxxxxxyyyyyvvvvrrrkkkeecccc
abcccaaaacaaaaaaaaacaaccccccjjoootttxxxxxxxyyyyyyvvvrrkkkfffcccc
SbccaacccccaaaaaaaaaaaccccccjjjooottxxxxEzzzyyyyvvvrrrkkkfffcccc
abcccccccccaaaaaaaaaaaccccccjjjooootttxxxyyyyyvvvvrrrkkkfffccccc
abcaacccccaaaaaaaaaaaccccccccjjjooottttxxyyyyywwvrrrrkkkfffccccc
abaaacccccaaaaaaaaaaaaaacccccjjjjonnttxxyyyyyywwwrrlllkfffcccccc
abaaaaaaaaaaacaaaaaaaaaaccccccjjjnnnttxxyywwyyywwrrlllffffcccccc
abaaaaaaaaaaaaaaaaaaaaaaccccccjjjnntttxxwwwwwywwwrrlllfffccccccc
abaaccaaaaaaaaaaaaaaacccccccccjjjnntttxwwwsswwwwwrrlllfffccccccc
abaacccaaaaaaaacccaaacccccccccjjinnttttwwsssswwwsrrlllgffacccccc
abccccaaaaaaccccccaaaccccccccciiinnntttsssssssssssrlllggaacccccc
abccccaaaaaaaccccccccccaaccccciiinnntttsssmmssssssrlllggaacccccc
abccccaacaaaacccccccaacaaaccccciinnnnnnmmmmmmmsssslllgggaaaacccc
abccccccccaaacccccccaaaaacccccciiinnnnnmmmmmmmmmmllllgggaaaacccc
abaaaccccccccccccccccaaaaaacccciiiinnnmmmhhhmmmmmlllgggaaaaccccc
abaaaaacccccccccccaaaaaaaaaccccciiiiiiihhhhhhhhmmlgggggaaacccccc
abaaaaaccccaaccccaaaaaaacaacccccciiiiihhhhhhhhhhggggggcaaacccccc
abaaaaccccaaaccccaaaacaaaaacccccccciiihhaaaaahhhhggggccccccccccc
abaaaaaaacaaacccccaaaaaaaaaccccccccccccccaaaacccccccccccccccccaa
abaacaaaaaaaaaaaccaaaaaaaaccccccccccccccccaaaccccccccccccccccaaa
abcccccaaaaaaaaacccaaaaaaaccccccccccccccccaacccccccccccccccccaaa
abccccccaaaaaaaaaaaaaaaaacccccccccccccccccaaacccccccccccccaaaaaa
abcccccaaaaaaaaaaaaaaaaaaaaaccccccccccccccccccccccccccccccaaaaaa'

--Graph DB tables can't be temp tables
drop table if exists AOC_2022_Day12_Input
drop table if exists AOC_2022_Day12_Edges
drop table if exists #Numbers

--Create a numbers table - never leave home without one
;with rec as
	(select 1 Num
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

create table AOC_2022_Day12_Input
	(X int,
	Y int,
	Elevation char(1) collate SQL_Latin1_General_CP1_CS_AS,
	ElevationNum tinyint) as node

create table AOC_2022_Day12_Edges as edge

insert into AOC_2022_Day12_Input
select Num X, dense_rank() over(order by i.ID desc) Y, Elevation,
	case Elevation
		when 'S' then ascii('a')
		when 'E' then ascii('z')
		else ascii(Elevation)
	end ElevationNum
from (select row_number() over(order by (select 1)) ID, [value]
		from string_split(replace(@Str, char(10), ''), char(13)) i
	) i
	inner join #Numbers on Num <= len([value])
	cross apply (select cast(substring([value], Num, 1) as char(1)) collate SQL_Latin1_General_CP1_CS_AS Elevation) e

insert into AOC_2022_Day12_Edges
select i.$node_id, i1.$node_id
from AOC_2022_Day12_Input i
	inner join AOC_2022_Day12_Input i1 on ((i.Y = i1.Y and (i.X = i1.X + 1 or i.X = i1.X - 1))
							or (i.X = i1.X and (i.Y = i1.Y + 1 or i.Y = i1.Y - 1))
							)
						and i1.ElevationNum <= i.ElevationNum + 1

;with Rt as
	(select last_value(i1.Elevation) within group (graph path) LastElevation,
			len(string_agg(cast(i1.Elevation collate SQL_Latin1_General_CP1_CI_AS as varchar(max)), '') within group (graph path)) Steps
		from AOC_2022_Day12_Input i,
			AOC_2022_Day12_Edges for path e,
			AOC_2022_Day12_Input for path i1
		where MATCH(shortest_path(i(-(e)->i1)+))
			and i.Elevation = 'S' collate SQL_Latin1_General_CP1_CS_AS
	)
select min(Steps) Answer1
from Rt
where LastElevation = 'E' collate SQL_Latin1_General_CP1_CS_AS
option (maxdop 1)

;with Rt as
	(select last_value(i1.Elevation) within group (graph path) LastElevation,
			len(string_agg(cast(i1.Elevation collate SQL_Latin1_General_CP1_CI_AS as varchar(max)), '') within group (graph path)) Steps
		from AOC_2022_Day12_Input i,
			AOC_2022_Day12_Edges for path e,
			AOC_2022_Day12_Input for path i1
		where MATCH(shortest_path(i(-(e)->i1)+))
			and i.Elevation = 'a' collate SQL_Latin1_General_CP1_CS_AS
	)
select min(Steps) Answer2
from Rt
where LastElevation = 'E' collate SQL_Latin1_General_CP1_CS_AS
option (maxdop 1)

drop table if exists AOC_2022_Day12_Input
drop table if exists AOC_2022_Day12_Edges