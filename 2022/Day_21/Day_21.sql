drop table if exists AoC_2022_Day21_Monkeys
create table AoC_2022_Day21_Monkeys
	(Monkey varchar(20),
	Val bigint,
	Monkey1 varchar(20),
	Operation char(1),
	Monkey2 varchar(20)
	) as node

GO
create or alter function fn_AOC_2022_Day21_DoMath(@Val1 bigint, @Val2 bigint, @Operation char(1), @Reverse bit, @IsFirstValue bit) returns table
as
	return select case Operation
						when '+' then Val1 + Val2
						when '-' then Val1 - Val2
						when '/' then Val1 / Val2
						when '*' then Val1 * Val2
					end Result, ReverseVariables, UseReverseOperationIfFirstValue, Operation
			from (select iif(@Reverse = 0 or ReverseVariables = 0, @Val1, @Val2) Val1
						, iif(@Reverse = 0 or ReverseVariables = 0, @Val2, @Val1) Val2
						, iif(@Reverse = 0 or (@Reverse = 1
												and (@IsFirstValue = 0 or UseReverseOperationIfFirstValue = 0)
												), Operation, ReverseOperation) Operation
						, ReverseVariables, UseReverseOperationIfFirstValue
					from (values('+', '-', 1, 1)
							, ('-', '+', 0, 0)
							, ('*', '/', 1, 1)
							, ('/', '*', 0, 0)
							) o(Operation, ReverseOperation, ReverseVariables, UseReverseOperationIfFirstValue)
					where (@Reverse = 0 and Operation = @Operation)
						or (@Reverse = 1 and ReverseOperation = @Operation)
					) o
GO
create or alter function fn_AOC_2022_Day21_GetNewMonkeyState(@MonkeyState varchar(max)) returns table
as
	return with ms as
					(select json_value([value], '$.Monkey') Monkey,
							cast(json_value([value], '$.Val') as bigint) Val
						from openjson(@MonkeyState, '$')
					)
				select (select Monkey, max(Val) Val, max(RootValue) RootValue
						from (select m.Monkey, NewVal Val, max(iif(m.Monkey = 'Root', NewVal, null)) over() RootValue, 0 Ordinal
								from ms m1
									inner join AoC_2022_Day21_Monkeys m on m.Monkey1 = m1.Monkey
									inner join ms m2 on m.Monkey2 = m2.Monkey
									cross apply (select isnull(m.Val,
																(select Result
																	from fn_AOC_2022_Day21_DoMath(m1.Val, m2.Val, m.Operation, 0, 0)
																)
																) NewVal
												) nv
								union
								select Monkey, Val, null, 1 Ordinal
								from ms
							) t
						group by Monkey
						order by min(Ordinal)
						for json auto) NewMonkeyState
GO
declare @Str varchar(max) =
'root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32'

drop table if exists #MonkeyValues
drop table if exists AoC_2022_Day21_MonkeyConnections
drop table if exists #MonkeyRoute

insert into AoC_2022_Day21_Monkeys
select Monkey, iif(Monkey1 is null, cast(Act as bigint), null) Val, Monkey1, Operation, Monkey2
from string_split(replace(@Str, char(13), ''), char(10))
	cross apply (select '["' + replace([value], ': ', '", "') + '"]' js) i
	cross apply (select json_value(js, '$[0]') Monkey, json_value(js, '$[1]') Act) i1
	outer apply (select '["' + replace(Act, ' ', '", "') + '"]' js1
					where Act like '% %') i2
	cross apply (select json_value(js1, '$[0]') Monkey1, json_value(js1, '$[1]') Operation, json_value(js1, '$[2]') Monkey2) i3

create unique clustered index IX_AoC_2022_Day21_Monkeys on AoC_2022_Day21_Monkeys(Monkey1, Monkey2, Monkey)

create table AoC_2022_Day21_MonkeyConnections as edge

insert into AoC_2022_Day21_MonkeyConnections
select m.$node_id, m1.$node_id
from AoC_2022_Day21_Monkeys m
	inner join AoC_2022_Day21_Monkeys m1 on m1.Monkey in (m.Monkey1, m.Monkey2)

;with rec as
	(select 1 ID, (select Monkey, Val
					from AoC_2022_Day21_Monkeys
					where Val is not null
					for json auto) MonkeyState
		union all
		select ID + 1, NewMonkeyState
		from rec r
			cross apply fn_AOC_2022_Day21_GetNewMonkeyState(r.MonkeyState)
		where json_value(r.MonkeyState, '$[0].RootValue') is null
	)
	, Lst as
	(select top 1 MonkeyState
		from rec
		order by ID desc
	)
--Dumping monkey values into temp table for Q2
select json_value([value], '$.Monkey') Monkey, cast(json_value([value], '$.Val') as bigint) Val
into #MonkeyValues
from Lst
	cross apply openjson(MonkeyState, '$')
option (maxrecursion 32767)

select Val Answer1
from #MonkeyValues
where Monkey = 'root'

--Solution2
/*
Dumping route from root to humn into temp table
When I tried to put it in a CTE I got this error:
	Internal Query Processor Error: The query processor could not produce a query plan. For more information, contact Customer Support Services.
*/
;with Rt as
	(select last_value(m1.Monkey) within group (graph path) LastMonkey,
			'["' + string_agg(cast(m1.Monkey as varchar(max)), '","') within group (graph path) + '"]' MonkeyRoute
		from AoC_2022_Day21_Monkeys m,
			AoC_2022_Day21_MonkeyConnections for path c,
			AoC_2022_Day21_Monkeys for path m1
		where MATCH(shortest_path(m(-(c)->m1)+))
			and m.Monkey = 'root'
	)
select [key] ID, [value] Monkey
into #MonkeyRoute
from Rt
	cross apply openjson(MonkeyRoute, '$')
where LastMonkey = 'humn'
option (maxdop 1)

;with rec as
	(select r.ID, r.Monkey, v.Val, cast(null as bigint) FromValue, cast(null as char(1)) Operation, cast(null as bit) IsFirstMonkey, v.Val AnotherValue, cast(null as bigint) ShouldGet
		from #MonkeyRoute r
			inner join AoC_2022_Day21_Monkeys m on m.Monkey = 'root'
			inner join #MonkeyValues v on v.Monkey in (m.Monkey1, m.Monkey2)
										and v.Monkey <> r.Monkey
		where r.ID = 0
		union all
		select mr.ID, mr.Monkey, mt.Result, v.Val FromValue, m.Operation, cast(iif(v.Monkey = m.Monkey1, 1, 0) as bit) IsFirstMonkey, mt.Result, r.Val ShouldGet
		from rec r
			inner join AoC_2022_Day21_Monkeys m on m.Monkey = r.Monkey
			inner join #MonkeyRoute mr on mr.ID = r.ID + 1
			inner join #MonkeyValues v on v.Monkey in (m.Monkey1, m.Monkey2)
										and v.Monkey <> mr.Monkey
			cross apply fn_AOC_2022_Day21_DoMath(r.Val, v.Val, m.Operation, 1, iif(v.Monkey = m.Monkey1, 1, 0)) mt
	)
select Val Answer2
from rec
where Monkey = 'humn'