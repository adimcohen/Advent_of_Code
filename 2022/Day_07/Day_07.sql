declare @Str varchar(max) =
'$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k'

drop table if exists #Input

--Parse Lines
select row_number() over(order by (select 1)) ID, [value] Val
into #Input
from string_split(replace(@Str, char(10), ''), char(13))

--Solve Q1
;with i as
	(select d.ID, row_number() over(order by d.ID) DirID, dir
		from #Input d
			cross apply (select substring(d.Val, 6, len(d.Val)) dir) c
		where d.Val like '$ cd%'
	)
	, rec as
	(select ID, DirID, dir
		from i
		where DirID = 1
		union all
		select i.ID, i.DirID, case when i.dir = '..' and r.dir <> '/'
											then left(r.dir, isnull(nullif(len(r.dir) - charindex('/', reverse(r.dir), 1), 0), 1))
										when i.dir = '..' and r.dir = '/' 
											then r.dir
										else r.dir + iif(r.dir = '/', '', '/') + i.dir
									end
		from rec r
			inner join i on i.DirID = r.DirID + 1
	),
	Files as
	(select d.dir, fName, Size
		from #Input f
			cross apply (select top 1 dir
							from rec d
							where d.ID < f.ID
							order by d.ID desc
							) d
			cross apply (select charindex(' ', Val, 1) ind) i
			cross apply (select cast(left(Val, ind - 1) as int) Size,
								substring(Val, ind + 1, len(Val)) fName) i1
		where Val not like '$ cd%'
			and Val <> '$ ls'
			and Val not like 'dir %'
	),
	Dirs as
	(select '/' dir
		union all
		select concat(nullif(d.parent, '/'), '/', dir)
		from #Input f
			cross apply (select top 1 dir parent
							from rec d
							where d.ID < f.ID
							order by d.ID desc
							) d
			cross apply (select charindex(' ', Val, 1) ind) i
			cross apply (select substring(Val, ind + 1, len(Val)) dir) i1
		where Val not like '$ cd%'
			and Val <> '$ ls'
			and Val like 'dir %'
	)
	, AllDirAndFiles as
	(select d.dir, f.fName fName, isnull(f.Size, 0) Size
		from Dirs d
			left join Files f on f.dir = d.dir
	)
	, SizeByDir as
	(select dir, sum(Size) Size
		from AllDirAndFiles
		group by dir
	),
	SizeByDirWithSubDirs as
	(select s1.dir, sum(s2.Size) Size
		from SizeByDir s1
			inner join SizeByDir s2 on concat(nullif(s2.dir, '/'), '/') like concat(nullif(s1.dir, '/'), '%')
		group by s1.dir
	)
select sum(Size) Answer1
from SizeByDirWithSubDirs
where Size <= 100000
option (maxrecursion 32767)

--Solve Q2
;with i as
	(select d.ID, row_number() over(order by d.ID) DirID, dir
		from #Input d
			cross apply (select substring(d.Val, 6, len(d.Val)) dir) c
		where d.Val like '$ cd%'
	)
	, rec as
	(select ID, DirID, dir
		from i
		where DirID = 1
		union all
		select i.ID, i.DirID, case when i.dir = '..' and r.dir <> '/'
											then left(r.dir, isnull(nullif(len(r.dir) - charindex('/', reverse(r.dir), 1), 0), 1))
										when i.dir = '..' and r.dir = '/' 
											then r.dir
										else r.dir + iif(r.dir = '/', '', '/') + i.dir
									end
		from rec r
			inner join i on i.DirID = r.DirID + 1
	),
	Files as
	(select d.dir, fName, Size
		from #Input f
			cross apply (select top 1 dir
							from rec d
							where d.ID < f.ID
							order by d.ID desc
							) d
			cross apply (select charindex(' ', Val, 1) ind) i
			cross apply (select cast(left(Val, ind - 1) as int) Size,
								substring(Val, ind + 1, len(Val)) fName) i1
		where Val not like '$ cd%'
			and Val <> '$ ls'
			and Val not like 'dir %'
	),
	Dirs as
	(select '/' dir
		union all
		select concat(nullif(d.parent, '/'), '/', dir)
		from #Input f
			cross apply (select top 1 dir parent
							from rec d
							where d.ID < f.ID
							order by d.ID desc
							) d
			cross apply (select charindex(' ', Val, 1) ind) i
			cross apply (select substring(Val, ind + 1, len(Val)) dir) i1
		where Val not like '$ cd%'
			and Val <> '$ ls'
			and Val like 'dir %'
	)
	, AllDirAndFiles as
	(select d.dir, f.fName fName, isnull(f.Size, 0) Size
		from Dirs d
			left join Files f on f.dir = d.dir
	)
	, SizeByDir as
	(select dir, sum(Size) Size
		from AllDirAndFiles
		group by dir
	),
	SizeByDirWithSubDirs as
	(select s1.dir, sum(s2.Size) Size
		from SizeByDir s1
			inner join SizeByDir s2 on concat(nullif(s2.dir, '/'), '/') like concat(nullif(s1.dir, '/'), '%')
		group by s1.dir
	)
	, Req as
	(select 30000000 - (70000000 - Size) RequiredSpace
		from SizeByDirWithSubDirs
		where dir = '/'
	)
select top 1 Size Answer2
from SizeByDirWithSubDirs
where Size >= (select RequiredSpace
				from Req)
order by Size
option (maxrecursion 32767)