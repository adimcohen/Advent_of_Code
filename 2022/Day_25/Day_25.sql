declare @Str varchar(max) =
'1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122'

drop table if exists #Numbers

--Number Table
;with rec as
	(select -15000 Num
	union all
	select Num + 1
	from rec
	where Num <= 15000
	)
select Num
into #Numbers
from rec
option (maxrecursion 32767)
create unique clustered index IX_#Numbers on #Numbers(Num)

;with Input as
	(select row_number() over(order by (select 1)) ID, [value] Val
		from string_split(replace(@Str, char(13), ''), char(10))
	)
	, Digits as
	(select *
		from (values(-2, '=')
					, (-1, '-')
					, (0, '0')
					, (1, '1')
					, (2, '2')
			) v(Val, Digit)
	)
	, dv as
	(select sum(DecVal) DecVal
		from Input
			inner join #Numbers n on Num between 1 and len(Val)
			cross apply (select substring(Val, Num, 1) DigitS, len(Val) - Num Pwr) d
			cross apply (select cast(case DigitS
											when '-' then '-1'
											when '=' then '-2'
										else DigitS
									end as bigint) Digit
						) d1
			cross apply (select power(cast(5 as bigint), Pwr)*Digit DecVal) v
	)
	,rec as
	(select cast(Digit as varchar(max)) Snafu, cast((DecVal - ((DecVal+2)%5-2)) / 5 as bigint) Remainder
		from dv
			inner join Digits on Val = (DecVal + 2)%5 - 2
		union all
		select cast(Digit + Snafu as varchar(max)), cast((Remainder - ((Remainder+2)%5-2)) / 5 as bigint)
		from rec 
			inner join Digits on Val = (Remainder + 2)%5 - 2
		where Remainder > 0
		)
select Snafu Answer1
from rec
where Remainder = 0