declare @Input varchar(max) =
'123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +  '

drop table if exists #Input
select r.ordinal r, c.ordinal c, iif(tv in ('*', '+'), tv, null) symbol, cast(iif(tv not in ('*', '+'), tv, null) as bigint) val
into #Input
from string_split(replace(@Input, char(13), ''), char(10), 1) r
	cross apply string_split(replace(replace(replace(trim(r.[value]), ' ', ' ^'), '^ ', ''), '^', ''), ' ', 1) c
	cross apply (select trim(c.[value]) tv) t

select sum(total) Solution1
from #Input i
	cross apply (select iif(i.symbol = '+'
							, sum(cast(i1.val as bigint))
							, exp(sum(log(cast(i1.val as float))))
							) total
					from #Input i1
					where i1.c = i.c
						and i1.r < i.r
				) t1
where i.symbol in ('+', '*')

-----p2
drop table if exists #Input2
select r.ordinal r, c.[value] c
	, iif(chr in ('*', '+'), chr, null) symbol
	, iif(chr not in ('*', '+'), chr, null) dig
into #Input2
from string_split(replace(@Input, char(13), ''), char(10), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int)) c
	cross apply (select substring(r.[value], c.[value], 1) chr) h

;with s as
	(select row_number() over(order by c) rn, symbol
		from #Input2 s
		where symbol is not null
	)
	, n as
	(select c, trim(string_agg(iif(dig != ' ', dig, ''), '') within group(order by r)) val
		from #Input2
		where symbol is null
		group by c
	)
	, n1 as
	(select *
			, iif(val = '', sum(iif(val = '', 1, null)) over(order by c), null) rn
		from n
	)
	, n2 as
	(select val
			, isnull(last_value(rn) ignore nulls over(order by c desc), (select max(rn) from s)) rn
		from n1
	)
select sum(total) Solution2
from s
	cross apply (select iif(symbol = '+'
							, sum(cast(val as bigint))
							, round(exp(sum(log(cast(val as bigint)))), 0)
							) total
					from n2
					where n2.rn = s.rn
						and n2.val != ''
				) n