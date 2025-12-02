drop table if exists Numbers

;with rec as
	(select 1 Num
	union all
	select Num + 1
	from rec
	where Num < 32767
	)
select Num
into Numbers
from rec
option (maxrecursion 32767)
create unique clustered index IX_Numbers on Numbers(Num)
GO
create or alter function fn_AOC_2022_Day13_GetItemInfo(@Item varchar(max)) returns table
as
	return select ItemType, IsList, ItemCount
				from (select case when @Item like '%]%]' then null
								when @Item like '%]' then 3
								else 1
							end ItemType) it
					cross apply (select iif(ItemType = 3 or ItemType is null, 1, 0) IsList) il
					outer apply (select count(*) ItemCount
									from openjson(@Item, '$')
									where ItemType = 3
										or ItemType is null) ic
GO
create or alter function fn_AOC_2022_Day13_CompareValues(@Value1 int,
														@Value2 int
														) returns table
as
	return select case when @Value1 < @Value2 or @Value1 is null
							then 1
						when @Value2 < @Value1 or @Value2 is null
							then -1
						else 0
					end IsInOrder
GO
create or alter function fn_AOC_2022_Day13_MakeList(@Item varchar(max),
													@IsList bit
														) returns table
as
	return select iif(@IsList = 1,  @Item, '[' + @Item + ']') List,
				iif(@IsList = 0, 1, null) NewtemCount
GO
create or alter function fn_AOC_2022_Day13_DecideInOrder(@FirstItemIDInOrder int,
														@FirstItemIDOutOfOrder int) returns table
as
	return select case when @FirstItemIDInOrder < @FirstItemIDOutOfOrder or @FirstItemIDOutOfOrder is null and @FirstItemIDInOrder is not null
							then 1
						when @FirstItemIDOutOfOrder < @FirstItemIDInOrder or @FirstItemIDInOrder is null and @FirstItemIDOutOfOrder is not null
							then -1
						else 0
					end IsInOrder
GO
create or alter function fn_AOC_2022_Day13_CompareLists(@Item1 varchar(max),
														@IsList1 bit,
														@Item2 varchar(max),
														@IsList2 bit,
														@MaxItemCount int) returns table
as
return with i as
			(select min(iif(IsInOrder = 1, ItemID, null)) FirstItemIDInOrder,
					min(iif(IsInOrder = -1, ItemID, null)) FirstItemIDOutOfOrder
				from fn_AOC_2022_Day13_MakeList(@Item1, @IsList1) l1
					cross join fn_AOC_2022_Day13_MakeList(@Item2, @IsList2) l2
					cross apply (select coalesce(nullif(@MaxItemCount, 0), l1.NewtemCount, l2.NewtemCount) NewMaxItemCount) n
					left join Numbers on Num <= NewMaxItemCount
					cross apply (select isnull(Num, 0) - 1 ItemID) i
					outer apply (select *
									from openjson(l1.List, '$')
									where [key] = ItemID
								) p1
					outer apply (select *
									from openjson(l2.List, '$')
									where [key] = ItemID
								) p2
					cross apply (select iif(l1.List = '[]', -1, cast(p1.[value] as int)) Item1,
									iif(l2.List = '[]', -1, cast(p2.[value] as int)) Item2
									) it
					cross apply fn_AOC_2022_Day13_CompareValues(Item1, Item2)
			)
		select IsInOrder
		from i
			cross apply fn_AOC_2022_Day13_DecideInOrder(FirstItemIDInOrder, FirstItemIDOutOfOrder)
GO
create or alter function fn_AOC_2022_Day13_GetIsInOrder(@Item1 varchar(max),
														@IsList1 bit,
														@Item2 varchar(max),
														@IsList2 bit,
														@MaxItemCount int) returns table
as
	return select case when @IsList1 = 0 and @IsList2 = 0
							then (select IsInOrder from fn_AOC_2022_Day13_CompareValues(cast(@Item1 as int), cast(@Item2 as int)))
						when @IsList1 = 1 or @IsList2 = 1
							then (select IsInOrder from fn_AOC_2022_Day13_CompareLists(@Item1, @IsList1, @Item2, @IsList2, @MaxItemCount))
					end IsInOrder
GO
create or alter function fn_AOC_2022_Day13_CompareItems(@Item1 varchar(max), @Item2 varchar(max)) returns table
as
	return
		with rec as
			(select 1 Lvl, 0 ItemID, cast(0 as varchar(max)) Lineage, iif(it1.ItemType & it2.ItemType > 0, 1, 0) IsComparable,
					iif(it1.ItemCount > it2.ItemCount, it1.ItemCount, it2.ItemCount) MaxItemCount,
					Item1, Item2, it1.ItemType ItemType1, it2.ItemType ItemType2, it1.IsList IsList1, it2.IsList IsList2
				from (select @Item1 Item1, @Item2 Item2) i
					cross apply fn_AOC_2022_Day13_GetItemInfo(Item1) it1
					cross apply fn_AOC_2022_Day13_GetItemInfo(Item2) it2
			union all
			select r.Lvl + 1 Lvl
				, NewItemID ItemID
				, cast(concat(r.Lineage, '\', NewItemID) as varchar(max)) Lineage
				, iif(it1.ItemType & it2.ItemType > 0, 1, 0) IsComparable
				, iif(it1.ItemCount > it2.ItemCount, it1.ItemCount, it2.ItemCount) MaxItemCount
				, it.Item1
				, it.Item2
				, it1.ItemType ItemType1, it2.ItemType ItemType2, it1.IsList IsList1, it2.IsList IsList2
			from rec r
				inner join Numbers on Num <= MaxItemCount
				cross apply (select Num - 1 NewItemID) n
				outer apply (select [key], [value]
								from openjson(Item1, '$')
								where r.IsList1 = 1
									and [key] = NewItemID
							) p1
				outer apply (select [key], [value]
								from openjson(Item2, '$')
								where r.IsList2 = 1
									and [key] = NewItemID
							) p2
				outer apply (select case when r.IsList1 = 1
												then cast(p1.[value] as varchar(max))
											when r.IsList2 = 1 and p2.[key] > 0
												then null
											else r.Item1
										end Item1
								, case when r.IsList2 = 1
												then cast(p2.[value] as varchar(max))
											when r.IsList1 = 1 and p1.[key] > 0
												then null
											else r.Item2
										end Item2
							) it
				outer apply fn_AOC_2022_Day13_GetItemInfo(it.Item1) it1
				outer apply fn_AOC_2022_Day13_GetItemInfo(it.Item2) it2
			where r.IsComparable = 0
			)
			, i as
			(select row_number() over(order by Lineage) ItemID, IsInOrder
				from rec
					cross apply fn_AOC_2022_Day13_GetIsInOrder(Item1, IsList1, Item2, IsList2, MaxItemCount)
				where IsComparable = 1
			)
			, i1 as
			(select min(iif(IsInOrder = 1, ItemID, null)) FirstItemIDInOrder
					, min(iif(IsInOrder = -1, ItemID, null)) FirstItemIDOutOfOrder
				from i
			)
		select i2.IsInOrder
		from i1
			cross apply fn_AOC_2022_Day13_DecideInOrder(FirstItemIDInOrder, FirstItemIDOutOfOrder) i2
GO
declare @Str varchar(max) =
'[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]'

drop table if exists #Input


;with i
	as (select i.ID - rn + 1 PairID, row_number() over(partition by i.ID - rn order by i.ID) ListID, Val List
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
	(select PairID, List Item1, lead(List) over(partition by PairID order by ListID) Item2
		from i
	)
select PairID, Item1, Item2
into #Input
from i1
where Item2 is not null

select sum(PairID) Answer1
from #Input
	cross apply fn_AOC_2022_Day13_CompareItems(Item1, Item2)
where IsInOrder = 1

;with Packets as
	(select Item1 Item
		from #Input
		union all
		select Item2
		from #Input
		union all
		select Divider
		from (values('[[2]]'),
					('[[6]]')) v(Divider)
	)
select min(ItemID)*max(ItemID) Answer2
from (values('[[2]]'),
			('[[6]]')) v(Divider)
	cross apply (select count(*) + 1 ItemID
					from Packets p1
						cross apply fn_AOC_2022_Day13_CompareItems(Divider, p1.Item)
					where IsInOrder = -1
					) c

drop table if exists Numbers
drop function if exists fn_AOC_2022_Day13_GetItemInfo
drop function if exists fn_AOC_2022_Day13_GetIsInOrder
drop function if exists fn_AOC_2022_Day13_CompareLists
drop function if exists fn_AOC_2022_Day13_MakeList
drop function if exists fn_AOC_2022_Day13_CompareValues