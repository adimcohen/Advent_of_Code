declare @Str varchar(max) =
'30373
25512
65332
33549
35390'

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

select RowID, ColumnID, Num
into #Input
from (select row_number() over(order by (select 1)) RowID, [value]
		from string_split(replace(@Str, char(10), ''), char(13)) r
	) r
	cross apply (select n.Num ColumnID, cast(substring(r.[value], Num, 1) as int) Num
					from #Numbers n
					where n.Num <= len(r.[value])
				) n

;with i as
	(select RowID, ColumnID, Num
		from #Input i
		where not exists (select *
							from #Input i1
							where i1.Num >= i.Num
								and i1.RowID = i.RowID
								and i1.ColumnID > i.ColumnID
							)
				or not exists (select *
								from #Input i1
								where i1.Num >= i.Num
									and i1.RowID = i.RowID
									and i1.ColumnID < i.ColumnID
							)
				or not exists (select *
								from #Input i1
								where i1.Num >= i.Num
									and i1.ColumnID = i.ColumnID
									and i1.RowID > i.RowID
							)
				or not exists (select *
								from #Input i1
								where i1.Num >= i.Num
									and i1.ColumnID = i.ColumnID
									and i1.RowID < i.RowID
							)
	)
select count(*) Answer1
from i

;with InputWithMax as
	(select *, max(RowID) over() MaxRowID, max(ColumnID) over() MaxColumnID
	from #Input
	)
select max(e1*w1*n1*s1) Answer2
from InputWithMax t
	outer apply (select top 1 i.ColumnID - t.ColumnID e1
					from #Input i
					where i.RowID = t.RowID
						and i.ColumnID > t.ColumnID
						and (i.Num >= t.Num or i.ColumnID = t.MaxColumnID)
					order by i.ColumnID
				) e
	outer apply (select top 1 t.ColumnID - i.ColumnID w1
					from #Input i
					where i.RowID = t.RowID
						and i.ColumnID < t.ColumnID
						and (i.Num >= t.Num or i.ColumnID = 1)
					order by i.ColumnID desc
				) w
	outer apply (select top 1 t.RowID - i.RowID n1
					from #Input i
					where i.RowID < t.RowID
						and i.ColumnID = t.ColumnID
						and (i.Num >= t.Num or i.RowID = 1)
					order by i.RowID desc
				) n
	outer apply (select top 1 i.RowID - t.RowID s1
					from #Input i
					where i.RowID > t.RowID
						and i.ColumnID = t.ColumnID
						and (i.Num >= t.Num or i.RowID = t.MaxRowID)
					order by i.RowID
				) s