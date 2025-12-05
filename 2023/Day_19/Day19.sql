drop table if exists AOC_2023_Day19_Workflows
create table AOC_2023_Day19_Workflows(Workflow varchar(10),
										Ordinal bigint,
										Trgt varchar(10),
										x int,
										m int,
										a int,
										s int,
										Operator char(1))
GO
create or alter function fn_AOC_2023_Day19_GetNext(@Workflow varchar(10),
											@x int,
											@m int,
											@a int,
											@s int) returns table
as
return select top 1 Trgt
		from AOC_2023_Day19_Workflows w
		where w.Workflow = @Workflow
			and (Operator is null
				or (Operator = '<'
					and (@x < w.x
						or @m < w.m
						or @a < w.a
						or @s < w.s
						)
					)
				or (Operator = '>'
					and (@x > w.x
						or @m > w.m
						or @a > w.a
						or @s > w.s
						)
					)
				)
		order by w.ordinal
GO
declare @Input varchar(max) =
'px{a<2006:qkq,m>2090:A,rfg}
pv{a>1716:R,A}
lnx{m>1548:A,A}
rfg{s<537:gd,x>2440:R,A}
qs{s>3448:A,lnx}
qkq{x<1416:A,crn}
crn{x>2662:A,R}
in{s<1351:px,qqz}
qqz{s>2770:qs,m<1801:hdj,R}
gd{a>3333:R,R}
hdj{m>838:A,pv}

{x=787,m=2655,a=1222,s=2876}
{x=1679,m=44,a=2067,s=496}
{x=2036,m=264,a=79,s=2244}
{x=2461,m=1339,a=466,s=291}
{x=2127,m=1623,a=2188,s=1013}'


drop table if exists #Components
drop table if exists #Ranges

insert into AOC_2023_Day19_Workflows
select Workflow, i3.ordinal, substring(i3.[value], ind2 + 1, len(i3.[value])) Trgt
	, iif(Rating = 'x', Val, null) x
	, iif(Rating = 'm', Val, null) m
	, iif(Rating = 'a', Val, null) a
	, iif(Rating = 's', Val, null) s
	, case when ind3 > 0 then '<'
			when ind4 > 0 then '>'
		end Operator
from string_split(replace(left(@Input, charindex(char(10)+char(13), @Input, 1) - 1), char(10), ''), char(13), 1) i
	cross apply (select charindex('{', i.[value], 1) ind1) i1
	cross apply (select left(i.[value], ind1 - 1) Workflow) i2
	cross apply string_split(substring(i.[value], ind1 + 1, len(i.[value]) - 2 - len(Workflow)), ',', 1) i3
	cross apply (select charindex(':', i3.[value], 1) ind2
						, nullif(charindex('<', i3.[value], 1), 0) ind3
						, nullif(charindex('>', i3.[value], 1), 0) ind4) i4
	cross apply (select iif(ind2 > 0, left(i3.[value], ind2 - 1), null) Condition) i5
	cross apply (select left(Condition, isnull(Ind3, Ind4) - 1) Rating
					, cast(substring(Condition, isnull(Ind3, Ind4) + 1, len(Condition)) as int) Val
				) i6
where i.[value] != ''
option (maxdop 1)

select ordinal, cast(trim('x=' from parsename(Comp, 4)) as int) x, cast(trim('m=' from parsename(Comp, 3)) as int) m, cast(trim('a=' from parsename(Comp, 2)) as int) a, cast(trim('s=' from parsename(Comp, 1)) as int) s
into #Components
from string_split(replace(substring(@Input, charindex(char(10)+char(13), @Input, 1) + 3, len(@Input)), char(10), ''), char(13), 1) i
	cross apply (select replace(replace(replace([value], '{', ''), '}', ''), ',', '.') Comp) i1
where [value] != ''
option (maxdop 1)

--1
;with rec as
	(select ordinal, x, m, a, s, cast('In' as varchar(10)) Trgt
		from #Components
		union all
		select ordinal, x, m, a, s, w.Trgt
		from rec r
			cross apply fn_AOC_2023_Day19_GetNext(r.Trgt, x, m, a, s) w
		where r.Trgt not in ('A', 'R')
	)
select sum(x+m+a+s) Answer1
from rec
where Trgt = 'A'
option (maxdop 1, maxrecursion 32767)

;with i as
	(select w.*, t.*
			, max(xn) over(partition by Workflow order by Ordinal) lx1
			, min(xx) over(partition by Workflow order by Ordinal) lx2
			, max(mn) over(partition by Workflow order by Ordinal) lm1
			, min(mx) over(partition by Workflow order by Ordinal) lm2
			, max(an) over(partition by Workflow order by Ordinal) la1
			, min(ax) over(partition by Workflow order by Ordinal) la2
			, max(sn) over(partition by Workflow order by Ordinal) ls1
			, min(sx) over(partition by Workflow order by Ordinal) ls2
		from AOC_2023_Day19_Workflows w
			outer apply (select case Operator
									when '>' then 1
									when '<' then x
								end LeftoverMin
							, case Operator
									when '>' then x
									when '<' then 4000
								end LeftoverMax
							where x is not null
						) tx
			outer apply (select case Operator
									when '>' then 1
									when '<' then m
								end LeftoverMin
							, case Operator
									when '>' then m
									when '<' then 4000
								end LeftoverMax
							where m is not null
						) tm
			outer apply (select case Operator
									when '>' then 1
									when '<' then a
								end LeftoverMin
							, case Operator
									when '>' then a
									when '<' then 4000
								end LeftoverMax
							where a is not null
						) ta
			outer apply (select case Operator
									when '>' then 1
									when '<' then s
								end LeftoverMin
							, case Operator
									when '>' then s
									when '<' then 4000
								end LeftoverMax
							where s is not null
						) ts
			cross apply (select isnull(tx.LeftoverMin, 1) xn, isnull(tx.LeftoverMax, 4000) xx
							, isnull(tm.LeftoverMin, 1) mn, isnull(tm.LeftoverMax, 4000) mx
							, isnull(ta.LeftoverMin, 1) an, isnull(ta.LeftoverMax, 4000) ax
							, isnull(ts.LeftoverMin, 1) sn, isnull(ts.LeftoverMax, 4000) sx
						) t
	)
	, i1 as
	(select *
			, isnull(lag(lx1) over(partition by Workflow order by Ordinal), 1) plx1
			, isnull(lag(lx2) over(partition by Workflow order by Ordinal), 4000) plx2
			, isnull(lag(lm1) over(partition by Workflow order by Ordinal), 1) plm1
			, isnull(lag(lm2) over(partition by Workflow order by Ordinal), 4000) plm2
			, isnull(lag(la1) over(partition by Workflow order by Ordinal), 1) pla1
			, isnull(lag(la2) over(partition by Workflow order by Ordinal), 4000) pla2
			, isnull(lag(ls1) over(partition by Workflow order by Ordinal), 1) pls1
			, isnull(lag(ls2) over(partition by Workflow order by Ordinal), 4000) pls2
		from i
	)
select Workflow
	, isnull(px.p1, lx1) x1, isnull(px.p2, lx2) x2
	, isnull(pm.p1, lm1) m1, isnull(pm.p2, lm2) m2
	, isnull(pa.p1, la1) a1, isnull(pa.p2, la2) a2
	, isnull(ps.p1, ls1) s1, isnull(ps.p2, ls2) s2
	, Trgt
into #Ranges
from i1
	outer apply (select case Operator
								when '>' then coalesce(x + 1, lx1, 1)
								when '<' then plx1
							end p1
						, case Operator
								when '>' then plx2
								when '<' then coalesce(x - 1, lx2, 4000)
							end p2
					where x is not null
				) px
	outer apply (select case Operator
								when '>' then coalesce(m + 1, lm1, 1)
								when '<' then plm1
							end p1
						, case Operator
								when '>' then plm2
								when '<' then coalesce(m - 1, lm2, 4000)
							end p2
					where m is not null
				) pm
	outer apply (select case Operator
								when '>' then coalesce(a + 1, la1, 1)
								when '<' then pla1
							end p1
						, case Operator
								when '>' then pla2
								when '<' then coalesce(a - 1, la2, 4000)
							end p2
					where a is not null
				) pa
	outer apply (select case Operator
								when '>' then coalesce(s + 1, ls1, 1)
								when '<' then pls1
							end p1
						, case Operator
								when '>' then pls2
								when '<' then coalesce(s - 1, ls2, 4000)
							end p2
					where s is not null
				) ps

--2
;with rec as
	(select 1 x1, 4000 x2, 1 m1, 4000 m2, 1 a1, 4000 a2, 1 s1, 4000 s2, cast('in' as varchar(10)) Trgt
		union all
		select greatest(r.x1, g.x1) x1, least(r.x2, g.x2) x2
			, greatest(r.m1, g.m1) m1, least(r.m2, g.m2) m2
			, greatest(r.a1, g.a1) a1, least(r.a2, g.a2) a2
			, greatest(r.s1, g.s1) s1, least(r.s2, g.s2) s2
			, g.Trgt
		from rec r
			inner join #Ranges g on g.Workflow = r.Trgt
								and (g.x1 between r.x1 and r.x2 or r.x1 between g.x1 and g.x2)
								and (g.m1 between r.m1 and r.m2 or r.m1 between g.m1 and g.m2)
								and (g.a1 between r.a1 and r.a2 or r.a1 between g.a1 and g.a2)
								and (g.s1 between r.s1 and r.s2 or r.s1 between g.s1 and g.s2)
	)
select sum(cast(x2 - x1 + 1 as bigint)*cast(m2 - m1 + 1 as bigint)*cast(a2 - a1 + 1 as bigint)*cast(s2 - s1 + 1 as bigint)) Answer2
from rec
where Trgt = 'A'
option (maxrecursion 32767)