--Part 2 with thanks to tenthmascot for the amazing solution described in https://old.reddit.com/r/adventofcode/comments/1pk87hl/2025_day_10_part_2_bifurcate_your_way_to_victory/
create or alter function fn_AOC_2025_10_P1(@States varchar(max),
											@Buttons varchar(max)
										) returns table
as
return select cast(',' + string_agg(cast(stt as varchar(max)), ',') + ',' as varchar(max)) NewStates
		from (select distinct cast(s.[value] as bigint) ^ cast(b.[value] as bigint) stt
				from string_split(@States, ',') s
					cross join string_split(@Buttons, ',') b
				where s.[value] != ''
			) s
GO
create or alter function fn_AOC_2025_10_P2_DeductButtonFromJoltage(@Joltage varchar(max),
																	@Button varchar(max)
																) returns table
as
return with calc as
			(select j.ordinal, new_val, min(new_val) over() min_new_val
				from string_split(@Joltage, ',', 1) j
					left join string_split(@Button, ',') t on cast(t.[value] as int) = j.ordinal - 1
					cross apply (select j.[value] - iif(t.[value] is not null, 1, 0) new_val) n
			)
		select cast(string_agg(new_val, ',') within group(order by ordinal) as varchar(max)) joltage
		from calc
		where min_new_val >= 0
GO
create or alter function fn_AOC_2025_10_P2_Iterate(@States varchar(max)
													, @Buttons varchar(max)
													, @MinPush int
													, @Iteration int
													) returns table
as
return with b as
			(select cast(parsename([value], 2) as int) button_bin
					, parsename([value], 1) button
				from string_split(@Buttons, '|')
			)
			, rec as
			(select joltage, joltage_bin, base_pushes, 0 new_pushes, cast(-1 as int) last_pushed
				from string_split(@States, '|') s
					cross apply (select cast(parsename(s.[value], 2) as int) base_pushes
									, cast(parsename(s.[value], 1) as varchar(max)) joltage
								) p
					cross apply (select sum(iif(cast([value] as int)%2 = 0, 0, power(2, cast(ordinal - 1 as int)))) joltage_bin
									from string_split(joltage, ',', 1)
								) j
			union all
			select j.joltage, joltage_bin ^ button_bin, base_pushes, new_pushes + 1 double_pushes, button_bin last_pushed
			from rec r
				inner join b on button_bin > last_pushed
				cross apply fn_AOC_2025_10_P2_DeductButtonFromJoltage(r.joltage, b.button) j
			where j.joltage is not null
				and r.joltage_bin >= 0
			)
			, unq as
			(select joltage, min(total_pushes) total_pushes
				from rec
					cross apply (select base_pushes + new_pushes * power(2, @Iteration) total_pushes) t
				where joltage_bin = 0
				group by joltage
			)
			, eval1 as
			(select joltage2, total_pushes, is_done
					, min(iif(is_done = 1, total_pushes, null)) over() min_push
				from unq
					cross apply (select string_agg(cast(s.[value] as int)/2, ',') within group(order by s.ordinal) joltage2
									from string_split(joltage, ',', 1) s
									having min(s.[value]) >= 0
								) j
					cross apply (select iif(replace(replace(joltage, '0', ''), ',', '') = '', 1, 0) is_done) id
				where (@MinPush is null
						or total_pushes < @MinPush
						)
			)
		select cast(isnull(min(min_push), @MinPush) as int) min_push
			, string_agg(cast(iif(is_done = 0, concat(total_pushes, '.', joltage2), null) as varchar(max)), '|') states
		from eval1
		where total_pushes < min_push - 1
			or is_done = 1
			or min_push is null
GO
declare @Input varchar(max) =
'[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}'

drop table if exists #Input
drop table if exists #Input1
drop table if exists #rec
drop table if exists #rec1

select ordinal id, json_value(js, '$[0]') machine, replace(json_query(js, '$[1]'), ' ', '') buttons, replace(replace(json_query(js, '$[2]'), '[', ''), ']', '') joltage
into #Input
from string_split(replace(@Input, char(13), ''), char(10), 1) r
	cross apply (select '[' + replace(replace(replace(replace(replace(replace(replace([value], '[', '"'), ']', '",['), '(', '['), ')', '],'), '{', '] ['), '}', ']'), ', ]', '],') + ']' js) j
	


;with rec as
	(select id, cast(concat(',', 0, ',') as varchar(max)) states, 0 step, desired, b.buttons
		from #Input i
			cross apply (select cast(sum(power(2, s.[value] - 1)) as varchar(max)) desired
							from generate_series(cast(1 as int), cast(len(machine) as int)) s
							where substring(machine, s.[value], 1) = '#'
						) m
			cross apply (select string_agg(button, ',') buttons
							from (select sum(power(2, b1.[value])) button
									from openjson(buttons) b
										cross apply openjson(b.[value]) b1
									group by b.[key]
								) b
						) b
		union all
		select r.id, p.NewStates, r.step + 1, r.desired, r.buttons
		from rec r
			cross apply fn_AOC_2025_10_P1(r.states, r.buttons) p
		where r.states not like '%,' + r.desired + ',%'
	)
	, rnk as
	(select *, row_number() over(partition by id order by step desc) rn
		from rec
	)
select sum(step) Solution1
from rnk
where rn = 1
option (maxrecursion 32767)

;with rec as
	(select id, cast(concat('0.', joltage) as varchar(max)) states, b.buttons, cast(null as int) min_push, 0 iteration
		from #Input
			cross apply (select string_agg(button, '|') buttons
									from (select concat(sum(power(2, b1.[value])), '.', replace(replace(b.[value], '[', ''), ']', '')) button
											from openjson(buttons) b
												cross apply openjson(b.[value]) b1
											group by b.[key], b.[value]
										) b
								) b
		union all
		select id, i.states, r.buttons, i.min_push, iteration + 1 iteration
		from rec r
			cross apply fn_AOC_2025_10_P2_Iterate(states, buttons, min_push, iteration) i
		where r.states is not null
	)
select id, min(min_push) min_push
into #rec1
from rec
group by id
option (maxrecursion 32767)

select sum(min_push) Solution2
from #rec1