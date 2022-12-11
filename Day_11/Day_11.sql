declare @Str varchar(max) =
'Monkey 0:
  Starting items: 66, 59, 64, 51
  Operation: new = old * 3
  Test: divisible by 2
    If true: throw to monkey 1
    If false: throw to monkey 4

Monkey 1:
  Starting items: 67, 61
  Operation: new = old * 19
  Test: divisible by 7
    If true: throw to monkey 3
    If false: throw to monkey 5

Monkey 2:
  Starting items: 86, 93, 80, 70, 71, 81, 56
  Operation: new = old + 2
  Test: divisible by 11
    If true: throw to monkey 4
    If false: throw to monkey 0

Monkey 3:
  Starting items: 94
  Operation: new = old * old
  Test: divisible by 19
    If true: throw to monkey 7
    If false: throw to monkey 6

Monkey 4:
  Starting items: 71, 92, 64
  Operation: new = old + 8
  Test: divisible by 3
    If true: throw to monkey 5
    If false: throw to monkey 1

Monkey 5:
  Starting items: 58, 81, 92, 75, 56
  Operation: new = old + 6
  Test: divisible by 5
    If true: throw to monkey 3
    If false: throw to monkey 6

Monkey 6:
  Starting items: 82, 98, 77, 94, 86, 81
  Operation: new = old + 7
  Test: divisible by 17
    If true: throw to monkey 7
    If false: throw to monkey 2

Monkey 7:
  Starting items: 54, 95, 70, 93, 88, 93, 63, 50
  Operation: new = old + 4
  Test: divisible by 13
    If true: throw to monkey 2
    If false: throw to monkey 0'

drop table if exists #Monkeys
drop table if exists #rec

;with i as
	(select i.ID, i.ID - rn MonkeyID, Val
	from (select row_number() over(order by (select 1)) ID, [value] Val
			from string_split(replace(@Str, char(10), ''), char(13))
			) i
		inner join (select ID, row_number() over(order by ID) rn
						from (select row_number() over(order by (select 1)) ID, [value]
								from string_split(replace(@Str, char(10), ''), char(13))) i1
						where [value] <> ''
					) i1 on i1.ID = i.ID
	)
	, i1 as
	(select ID, MonkeyID
		, Val ItemsStr
		, lead(Val, 1) over(partition by MonkeyID order by ID) OperationStr
		, lead(Val, 2) over(partition by MonkeyID order by ID) TestStr
		, lead(Val, 3) over(partition by MonkeyID order by ID) TrueStr
		, lead(Val, 4) over(partition by MonkeyID order by ID) FalseStr
	from i
	)
select MonkeyID
	, replace(substring(ItemsStr, len('  Starting items: ') + 2, len(ItemsStr)), ' ', '') Items
	, i3.Operation
	, OperationNumber
	, cast(substring(TestStr, len('  Test: divisible by ') + 2, len(TestStr)) as bigint) Test
	, cast(substring(TrueStr, len('    If true: throw to monkey ') + 2, len(TrueStr)) as int) True
	, cast(substring(FalseStr, len('    If true: throw to monkey ') + 2, len(FalseStr)) as int) False
	, max(MonkeyID) over() LastMonkeyID
into #Monkeys
from i1
	cross apply (select substring(OperationStr, len('  Operation: new = old ') + 2, 100) OperationStr1) os1
	cross apply (select charindex(' ', OperationStr1, 1) ind) i2
	cross apply (select left(OperationStr1, ind - 1) Operation,
						cast(nullif(substring(OperationStr1, ind + 1, len(OperationStr1)), 'old') as bigint) OperationNumber) i3
where ID % 7 = 2

;with rec as
	(select cast([value] as int) Item, MonkeyID OldOwnerMonkey, MonkeyID OwnerMonkey, cast(0 as int) RoundID, cast(-1 as int) TurnMonkey, 0 Cycle
		from #Monkeys
			cross apply string_split(Items, ',')
		union all
		select cast(NewItemValue as int) Item
			, r.OwnerMonkey
			, iif(r.OwnerMonkey = tm.TurnMonkey,
					iif(NewItemValue % Test = 0,
						True,
						False),
				r.OwnerMonkey) OwnerMonkey
			, NewRoundID RoundID
			, tm.TurnMonkey
			, r.Cycle + 1 Cycle
		from rec r
			inner join #Monkeys m on m.MonkeyID = r.OwnerMonkey
			cross apply (select iif(r.TurnMonkey = LastMonkeyID, 0, r.TurnMonkey + 1) TurnMonkey,
							r.RoundID + iif(r.TurnMonkey = m.LastMonkeyID or RoundID = 0, 1, 0) NewRoundID) tm
			cross apply (select isnull(m.OperationNumber, r.Item) OperationNumber1) on1
			cross apply (select iif(r.OwnerMonkey = tm.TurnMonkey,
									iif(m.Operation = '+',
											r.Item + OperationNumber1,
											r.Item * OperationNumber1)/3,
									r.Item) NewItemValue) nv
		where NewRoundID <= 20
	)
	, Totals as
	(select top 2 OldOwnerMonkey, count(*) cnt
		from rec
		where OldOwnerMonkey = TurnMonkey
		group by OldOwnerMonkey
		order by cnt desc
	)
select min(cnt) * max(cnt) Answer1
from Totals
option (maxrecursion 32767)

--Solution 2
----recursion #1
;with rm as
	(select MonkeyID, Test
	from #Monkeys
	where MonkeyID = 0
	union all
	select m.MonkeyID, r.Test * m.Test
	from rm r
		inner join #Monkeys m on m.MonkeyID = r.MonkeyID + 1
	)
	, a as
	(select max(Test) AllTests
		from rm
	)
	, rec as
	(select cast([value] as int) Item, MonkeyID OldOwnerMonkey, MonkeyID OwnerMonkey, cast(0 as int) RoundID, cast(-1 as int) TurnMonkey, 0 Cycle
		from #Monkeys
			cross apply string_split(Items, ',')
		union all
		select cast(NewItemValue as int) Item
			, r.OwnerMonkey
			, iif(r.OwnerMonkey = tm.TurnMonkey,
					iif(NewItemValue % Test = 0,
						True,
						False),
				r.OwnerMonkey) OwnerMonkey
			, NewRoundID RoundID
			, tm.TurnMonkey
			, r.Cycle + 1 Cycle
		from rec r
			inner join #Monkeys m on m.MonkeyID = r.OwnerMonkey
			cross apply (select iif(r.TurnMonkey = LastMonkeyID, 0, r.TurnMonkey + 1) TurnMonkey,
							r.RoundID + iif(r.TurnMonkey = m.LastMonkeyID or RoundID = 0, 1, 0) NewRoundID) tm
			cross apply (select isnull(m.OperationNumber, r.Item) OperationNumber1) on1
			cross apply (select iif(r.OwnerMonkey = tm.TurnMonkey,
									iif(m.Operation = '+',
											r.Item + OperationNumber1,
											r.Item * OperationNumber1) % (select AllTests from a),
									r.Item) NewItemValue) nv
		where NewRoundID <= 3500
	)
select *
into #rec
from rec
option (maxrecursion 32767)

----recursion #2
;with rm as
	(select MonkeyID, Test
	from #Monkeys
	where MonkeyID = 0
	union all
	select m.MonkeyID, r.Test * m.Test
	from rm r
		inner join #Monkeys m on m.MonkeyID = r.MonkeyID + 1
	)
	, a as
	(select max(Test) AllTests
		from rm
	)
	, rec as
	(select *, 1 IsCarryOver
		from #rec
		where Cycle = 3500*(select count(*) from #Monkeys)
		union all
		select cast(NewItemValue as int) Item
			, r.OwnerMonkey
			, iif(r.OwnerMonkey = tm.TurnMonkey,
					iif(NewItemValue % Test = 0,
						True,
						False),
				r.OwnerMonkey) OwnerMonkey
			, NewRoundID RoundID
			, tm.TurnMonkey
			, r.Cycle + 1 Cycle,
			0 IsCarryOver
		from rec r
			inner join #Monkeys m on m.MonkeyID = r.OwnerMonkey
			cross apply (select iif(r.TurnMonkey = LastMonkeyID, 0, r.TurnMonkey + 1) TurnMonkey,
							r.RoundID + iif(r.TurnMonkey = m.LastMonkeyID or RoundID = 0, 1, 0) NewRoundID) tm
			cross apply (select isnull(m.OperationNumber, r.Item) OperationNumber1) on1
			cross apply (select iif(r.OwnerMonkey = tm.TurnMonkey,
									iif(m.Operation = '+',
											r.Item + OperationNumber1,
											r.Item * OperationNumber1) % (select AllTests from a),
									r.Item) NewItemValue) nv
		where NewRoundID <= 7000
	)
insert into #rec
select Item, OldOwnerMonkey, OwnerMonkey, RoundID, TurnMonkey, Cycle
from rec
where IsCarryOver = 0
option (maxrecursion 32767)

;with rm as
	(select MonkeyID, Test
	from #Monkeys
	where MonkeyID = 0
	union all
	select m.MonkeyID, r.Test * m.Test
	from rm r
		inner join #Monkeys m on m.MonkeyID = r.MonkeyID + 1
	)
	, a as
	(select max(Test) AllTests
		from rm
	)
	, rec as
	(select *, 1 IsCarryOver
		from #rec
		where Cycle = 7000*(select count(*) from #Monkeys)
		union all
		select cast(NewItemValue as int) Item
			, r.OwnerMonkey
			, iif(r.OwnerMonkey = tm.TurnMonkey,
					iif(NewItemValue % Test = 0,
						True,
						False),
				r.OwnerMonkey) OwnerMonkey
			, NewRoundID RoundID
			, tm.TurnMonkey
			, r.Cycle + 1 Cycle,
			0 IsCarryOver
		from rec r
			inner join #Monkeys m on m.MonkeyID = r.OwnerMonkey
			cross apply (select iif(r.TurnMonkey = LastMonkeyID, 0, r.TurnMonkey + 1) TurnMonkey,
							r.RoundID + iif(r.TurnMonkey = m.LastMonkeyID or RoundID = 0, 1, 0) NewRoundID) tm
			cross apply (select isnull(m.OperationNumber, r.Item) OperationNumber1) on1
			cross apply (select iif(r.OwnerMonkey = tm.TurnMonkey,
									iif(m.Operation = '+',
											r.Item + OperationNumber1,
											r.Item * OperationNumber1) % (select AllTests from a),
									r.Item) NewItemValue) nv
		where NewRoundID <= 10000
	)
	, AllRec as
	(select OldOwnerMonkey
		from #rec
		where OldOwnerMonkey = TurnMonkey
		union all
		select OldOwnerMonkey
		from rec
		where OldOwnerMonkey = TurnMonkey
			and IsCarryOver = 0
	)
	, Totals as
	(select top 2 OldOwnerMonkey, count_big(*) cnt
		from AllRec
		group by OldOwnerMonkey
		order by cnt desc
	)
select min(cnt) * max(cnt) Answer2
from Totals
option (maxrecursion 32767)