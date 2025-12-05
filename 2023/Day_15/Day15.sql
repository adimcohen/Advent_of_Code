declare @Input varchar(max) =
'rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7'

drop table if exists #Input
drop table if exists #Operations

select ordinal WordID, [value] Word, len([value]) LenWord
into #Input
from string_split(@Input, ',', 1)

--1
;with rec as
	(select WordID, Word, LenWord, 0 Ind, 0 Val
		from #Input
		union all
		select WordID, Word, LenWord, NewInd, (r.Val + ascii(substring(Word, NewInd, 1)))*17%256 Val
		from rec r
			cross apply (select Ind + 1 NewInd) i
		where r.Ind < r.LenWord
	)
select sum(Val) Answer1
from rec
where Ind = LenWord

--2
;with rec as
	(select WordID, Word, isnull(nullif(charindex('-', Word, 1), 0), charindex('=', Word, 1)) - 1 LenWord, 0 Ind, 0 Box
		from #Input
		union all
		select WordID, Word, LenWord, NewInd, (r.Box + ascii(Chr))*17%256 Box
		from rec r
			cross apply (select Ind + 1 NewInd) i
			cross apply (select substring(Word, NewInd, 1) Chr) i1
		where r.Ind < r.LenWord
	)
select WordID OpID, left(Word, LenWord) Lbl, Box, substring(Word, LenWord + 1, 1) Operation, cast(substring(Word, LenWord + 2, 1) as int) Lens
into #Operations
from rec
where Ind = LenWord

;with i as
	(select *, row_number() over(partition by Box, Lbl order by OpID desc) OBLID
			, iif(Operation = '-', OpID, 0) RemoveOpID
			, iif(Operation = '=', OpID, 0) AddOpID
		from #Operations
	)
	, i1 as
	(select *, iif(Operation = '=', max(RemoveOpID) over(partition by Box, Lbl order by OpID), null) LastRemoveOpID
		from i
	)
	, i2 as
	(select *, isnull(nullif(min(AddOpID) over(partition by Box, Lbl, LastRemoveOpID order by OpID), 0), OpID) Pos
		from i1
	)
	, i3 as
	(select (Box + 1) * Lens * row_number() over(partition by Box order by Pos) Val
		from i2
		where OBLID = 1
			and Operation = '='
	)
select sum(Val) Answer2
from i3