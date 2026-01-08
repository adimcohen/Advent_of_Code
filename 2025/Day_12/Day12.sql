declare @Input varchar(max) =
'0:
###
##.
##.

1:
###
##.
.##

2:
.##
###
##.

3:
##.
###
##.

4:
###
#..
###

5:
###
.#.
###

4x4: 0 0 0 0 2 0
12x5: 1 0 1 0 2 2
12x5: 1 0 1 0 3 2'

drop table if exists #Shapes
drop table if exists #Spaces
;with i as
	(select *, cast(iif([value] like '%:', replace([value], ':', ''), null) as int) id
		from string_split(replace(@Input, char(13), ''), char(10), 1) r
		where r.[value] not like '%x%'
			and r.[value] != ''
	)
	, i1 as
	(select [value], ordinal, last_value(id) ignore nulls over(order by ordinal rows between unbounded preceding and 1 preceding) id
		from i
	)
select id shape_id, row_number() over(partition by id order by ordinal) rn, [value] line
into #Shapes
from i1
where [value] not like '%:'


;with i as
	(select *
		from string_split(replace(@Input, char(13), ''), char(10), 1) r
		where r.[value] like '%x%'
	)
select row_number() over(order by ordinal) SpaceID, cast(json_value(js, '$[0]') as int) r, cast(json_value(js, '$[1]') as int) c, json_query(js, '$[2]') arr
into #Spaces
from i
	cross apply (select '[' + replace(replace(replace([value], 'x', ','), ': ', ',['), ' ', ',') + ']]' js) j

select sum(iif(r*c > val*8, 1, 0))
from #Spaces
	cross apply (select sum(cast([value] as int)) val
					from openjson(arr)
				) t