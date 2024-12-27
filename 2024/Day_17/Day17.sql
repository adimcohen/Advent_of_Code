create or alter function fn_AOC_2024_Day17_IterateProgramOnce(@Program varchar(100)
																, @A bigint
																, @B bigint
																, @C bigint
																) returns table
return with rec as
			(select @A A, @B B, @C C, cast(null as bigint) Ins, cast(null as bigint) Op, cast(null as bigint) ComboOp, cast('' as bigint) Owtput, cast(0 as bigint) NextID, 0 Steps
				union all
				select f.A, f.B, f.C, o.Ins, o.Op, cast(o1.ComboOp as bigint), f.Owtput, f.NextID, Steps + 1
				from rec r
					cross apply (select cast(substring(@Program, NextID + 1, 1) as bigint) Ins
										, cast(substring(@Program, NextID + 2, 1) as bigint) Op
								) o
					cross apply (select case when o.Op between 0 and 3 then o.Op
												when o.Op = 4 then A
												when o.Op = 5 then B
												when o.Op = 6 then C
											end ComboOp
								) o1
					cross apply (select case when o.Ins in (0, 6, 7) then A / power(2, o1.ComboOp)
											when o.Ins = 1 then B ^ o.Op
											when o.Ins in (2, 5) then o1.ComboOp % 8
											when o.Ins = 4 then B ^ C
										end Result
								) i1
					cross apply (select iif(o.Ins = 0, Result, A) A
										, iif(o.Ins in (1, 2, 4, 6), Result, B) B
										, iif(o.Ins = 7, Result, C) C
										, iif(o.Ins = 5, Result, Owtput) Owtput
										, case when o.Ins = 3 and A != 0 then o.Op
												when o.Ins = 3 and A = 0 then null
												else NextID + 2
											end NextID
								) f
				where r.NextID + 1 <= len(@Program)
					and (r.NextID > 0
						or r.Steps = 0
						)
			)
			, res as
			(select top 1 A, B, C, Owtput, NextID
				from rec
				order by Steps desc
			)
		select A, B, C, Owtput, NextID
		from res
GO
declare @Input varchar(max) =
'Register A: 47719761
Register B: 0
Register C: 0

Program: 2,4,1,5,7,5,0,3,4,1,1,6,5,5,3,0'

drop table if exists #Input
drop table if exists #Rec

select cast(max(iif([key] = '0', [value], null)) as bigint) A
	, cast(max(iif([key] = '1', [value], null)) as bigint) B
	, cast(max(iif([key] = '2', [value], null)) as bigint) C
	, max(replace(replace(replace(iif([key] = '3', [value], null), '[', ''), ']', ''), ',', '')) Prg
into #Input
from openjson('[' + replace(replace(replace(replace(replace(replace(@Input, 'Register A: ', ''), 'Register B: ', ','), 'Register C: ', ','), 'Program: ', ',['), char(13), ''), char(10), '') + ']]')



;with rec as
	(select Prg, A, B, C, cast(',' as varchar(max)) Owtput, cast(0 as bigint) NextID, 0 Steps
		from #Input
		union all
		select r.Prg, n.A, n.B, n.C, cast(concat(r.Owtput, n.Owtput, ',') as varchar(max)), n.NextID, r.Steps + 1
		from rec r
			cross apply fn_AOC_2024_Day17_IterateProgramOnce(Prg, A, B, C) n
		where r.NextID is not null
	)
select top 1 trim(',' from Owtput) Answer1
from rec
order by Steps desc
option (maxrecursion 32767)

;with Input as
	(select len(prg) - [value] + 1 ID, cast(substring(prg, [value], 1) as bigint) Result
		from #Input
			cross apply generate_series(cast(1 as int), cast(len(prg) as int))
	)
	, rec as
	(select cast(0 as int) ID, cast(0 as bigint) Result, cast(0 as bigint) A
		union all
		select cast(i.ID as int), i.Result, cast(n1.A as bigint)
		from rec r
			cross apply (select r.ID + 1 ID) n
			inner join Input i on i.ID = n.ID
			cross join generate_series(cast(0 as bigint), cast(7 as bigint), cast(1 as bigint))
			cross apply (select r.A * 8 + [value] A) n1
		where exists (select *
						from #Input
							cross apply fn_AOC_2024_Day17_IterateProgramOnce(prg, n1.A, 0, 0) t
						where t.Owtput = i.Result
					)
	)
select top 1 A Answer2
from rec
order by ID desc, A