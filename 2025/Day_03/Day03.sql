declare @Input varchar(max) =
'987654321111111
811111111111119
234234234234278
818181911112111'

drop table if exists #Input
select ordinal r, c.[value] c, cast(substring(r.[value], c.[value], 1) as int) v
into #Input
from string_split(replace(@Input, char(13), ''), char(10), 1) r
	cross apply generate_series(cast(1 as int), cast(len(r.[value]) as int)) c

;with i as
	(select *, max(v) over(partition by r order by c) MaxV, max(c) over( partition by r) MaxC
		from #Input
	)
select sum(MaxV*10 + Num2) Solution1
from i
	cross apply (select top 1 i1.c Loc1
					from #Input i1
					where i1.r = i.r
						and i1.v = MaxV
					order by i1.c
				) i1
	cross apply (select max(v) Num2
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc1
				) i2
where c = MaxC - 1

;with i0 as
	(select *, max(v) over(partition by r order by c) Num1, max(c) over(partition by r) MaxC
		from #Input
	)
	, i as
	(select r, Num1, MaxC
		from i0
		where c = MaxC - 11
	)
select sum(FinalNum) Solution2
from i
	cross apply (select top 1 i1.c Loc1
					from #Input i1
					where i1.r = i.r
						and i1.v = Num1
					order by i1.c
				) i1
	cross apply (select top 1 i2.v Num2, i2.c Loc2
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc1
						and i2.c <= MaxC - 10
					order by v desc, c
				) i2
	cross apply (select top 1 i2.v Num3, i2.c Loc3
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc2
						and i2.c <= MaxC - 9
					order by v desc, c
				) i3
	cross apply (select top 1 i2.v Num4, i2.c Loc4
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc3
						and i2.c <= MaxC - 8
					order by v desc, c
				) i4
	cross apply (select top 1 i2.v Num5, i2.c Loc5
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc4
						and i2.c <= MaxC - 7
					order by v desc, c
				) i5
	cross apply (select top 1 i2.v Num6, i2.c Loc6
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc5
						and i2.c <= MaxC - 6
					order by v desc, c
				) i6
	cross apply (select top 1 i2.v Num7, i2.c Loc7
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc6
						and i2.c <= MaxC - 5
					order by v desc, c
				) i7
	cross apply (select top 1 i2.v Num8, i2.c Loc8
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc7
						and i2.c <= MaxC - 4
					order by v desc, c
				) i8
	cross apply (select top 1 i2.v Num9, i2.c Loc9
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc8
						and i2.c <= MaxC - 3
					order by v desc, c
				) i9
	cross apply (select top 1 i2.v Num10, i2.c Loc10
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc9
						and i2.c <= MaxC - 2
					order by v desc, c
				) i10
	cross apply (select top 1 i2.v Num11, i2.c Loc11
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc10
						and i2.c <= MaxC - 1
					order by v desc, c
				) i11
	cross apply (select top 1 i2.v Num12
					from #Input i2
					where i2.r = i.r
						and i2.c > Loc11
					order by v desc, c
				) i12
	cross apply (select Num1*power(cast(10 as bigint), 11)
						+ Num2*power(cast(10 as bigint), 10)
						+ Num3*power(cast(10 as bigint), 9)
						+ Num4*power(cast(10 as bigint), 8)
						+ Num5*power(cast(10 as bigint), 7)
						+ Num6*power(cast(10 as bigint), 6)
						+ Num7*power(cast(10 as bigint), 5)
						+ Num8*power(cast(10 as bigint), 4)
						+ Num9*power(cast(10 as bigint), 3)
						+ Num10*power(cast(10 as bigint), 2)
						+ Num11*10
						+ Num12 FinalNum
					) f




