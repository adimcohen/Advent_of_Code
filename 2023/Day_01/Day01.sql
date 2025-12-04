declare @Input varchar(max) =
'1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet'

drop table if exists #Input
drop table if exists #Numbers

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

select *
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1)

--1
;with nums as
	(select distinct ordinal,
			cast(cast(first_value(Chr) over(partition by ordinal order by Num rows between unbounded preceding and unbounded following) as char(1))
				+ cast(last_value(Chr) over(partition by ordinal order by Num rows between unbounded preceding and unbounded following) as char(1)) as int) val
		from #Input i
			inner join #Numbers n on n.Num <= len(i.[value])
			cross apply (select substring([value], Num, 1) Chr) c
		where isnumeric(Chr) = 1
	)
select sum(val) Answer1
from nums
GO
declare @Input varchar(max) =
'two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen'

drop table if exists #Input
select *
into #Input
from string_split(replace(@Input, char(10), ''), char(13), 1)
--2


;with nums as
	(select distinct ordinal, cast(cast(first_value(Chr) over(partition by ordinal order by Num rows between unbounded preceding and unbounded following) as char(1))
				+ cast(last_value(Chr) over(partition by ordinal order by Num rows between unbounded preceding and unbounded following) as char(1)) as int) val
		from #Input i
			inner join #Numbers n on n.Num <= len(i.[value])
			inner join (values('one', '1'),
							('two', '2'),
							('three', '3'),
							('four', '4'),
							('five', '5'),
							('six', '6'),
							('seven', '7'),
							('eight', '8'),
							('nine', '9')
						) v(digitN, digitV) on substring([value], Num, len(digitN)) = digitN
											or substring([value], Num, len(digitV)) = digitV
			cross apply (select cast(digitV as int) Chr) c
	)
select sum(val) Answer2
from nums