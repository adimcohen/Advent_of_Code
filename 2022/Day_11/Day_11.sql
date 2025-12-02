declare @Str varchar(max) =
'Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1'

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
/*
Part 2 pushed me past the 32767 maxrecursion limit, so I had to break the recursion into a loop to process maxrecursion limit each iteration and dump the interim results into a temp table.
Tried to do the 3 recursion in the same statement, but it hung there forever.
Could be done in a single statement if it wasn't for the maxrecursion limit.
*/
declare @RoundCount int = 10000

create table #rec(Item int,
				OldOwnerMonkey bigint,
				OwnerMonkey bigint,
				RoundID int,
				TurnMonkey int,
				Cycle int)
create clustered index IX_#rec on #rec(Cycle)

declare @RecCount int,
		@i int = 1

select @RecCount = ceiling(count(*)*@RoundCount/32767.)
from #Monkeys

while @i <= @RecCount
begin
	;with rInput as
		(select isnull(max(RoundID), 0) CurrentRoundID
			from #rec
		)
		, rInput1 as
		(select CurrentRoundID, NextRoundID
			from rInput
				cross apply (select CurrentRoundID + @RoundCount / @RecCount NextRoundID1) i
				cross apply (select iif(@i < @RecCount, NextRoundID1, @RoundCount) NextRoundID) i1
		)
		, rm as
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
		, Anchor as
		(select *
			from #rec
			where Cycle = (select CurrentRoundID from rInput1)*(select count(*) from #Monkeys)
			union all
			select cast([value] as int) Item, MonkeyID OldOwnerMonkey, MonkeyID OwnerMonkey, cast(0 as int) RoundID, cast(-1 as int) TurnMonkey, 0 Cycle
			from #Monkeys
				cross apply string_split(Items, ',')
			where not exists (select * from #rec)
		)
		, rec as
		(select *, 1 IsCarryOver
			from Anchor
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
			where NewRoundID <= (select NextRoundID from rInput1)
		)
	insert into #rec
	select Item, OldOwnerMonkey, OwnerMonkey, RoundID, TurnMonkey, Cycle
	from rec
	where IsCarryOver = 0
	option (maxrecursion 32767)

	set @i += 1
end

;with Totals as
	(select top 2 OldOwnerMonkey, count_big(*) cnt
		from #rec
		where OldOwnerMonkey = TurnMonkey
		group by OldOwnerMonkey
		order by cnt desc
	)
select min(cnt) * max(cnt) Answer2
from Totals