drop table if exists AOC_2022_Day14_Input1
create table AOC_2022_Day14_Input1(X int, Y int)
GO
create or alter function fn_AOC_2022_Day14_GetMinValue(@j varchar(max)) returns table
as
return select min(cast([value] as int)) MinValue
		from openjson(@j, '$')
GO
create or alter function fn_AOC_2022_Day14_LandSandInt(@CurrentSand varchar(max),
														@SandX int,
														@SandY int,
														@Floor int) returns table
as
return with Layout as
			(select X, Y
				from AOC_2022_Day14_Input1
				union all
				select cast(json_value([value], '$[0]') as int), cast(json_value([value], '$[1]') as int)
				from openjson(@CurrentSand, '$')
			)
			, rec as
			(select @SandX X, @SandY Y, cast(-1 as int) DownY, cast(0 as int) Step
			union all
			select cast(NewX as int) X
					, cast(NewY as int) Y
					, cast(Down.DownY as int) DownY
					, r.Step + 1 Step
				from rec r
					cross apply (select isnull(MinValue, @Floor) - 1 DownY
									from fn_AOC_2022_Day14_GetMinValue('[' + stuff(
																		(select concat(',', l.Y)
																			from Layout l
																			where l.X = r.X
																				and l.Y > r.Y
																			for xml path('')
																		), 1, 1, '') + ']'
																	)
									) Down
					outer apply (select p.X, p.Y
									from (values(r.X - 1, r.Y + 1)) p(X, Y)
									where not exists (select *
														from Layout l
														where l.X = p.X
															and l.Y = p.Y
													)
								) Lt
					outer apply (select p.X, p.Y
									from (values(r.X + 1, r.Y + 1)) p(X, Y)
									where not exists (select *
														from Layout l
														where l.X = p.X
															and l.Y = p.Y
													)
								) Rt
					cross apply (select iif(Lt.X is null, Rt.X, Lt.X) X, iif(Lt.X is null, Rt.Y, Lt.Y) Y, iif(Lt.X is null, 3, 2) Choice) p
					cross apply (select iif(Down.DownY > r.Y
													, r.X
													, p.X) NewX
										, iif(Down.DownY > r.Y
													, Down.DownY
													, p.Y) NewY
								) n
				where NewX is not null
					and r.DownY is not null
					and (NewY < @Floor
						or @Floor is null)
			)
			, LastStep as
			(select top 1 X, Y, DownY
				from rec
				where Step > 0
				order by Step desc
			)
		select X, Y
		from LastStep
		where DownY is not null
GO
declare @Str varchar(max) =
'502,19 -> 507,19
523,100 -> 523,104 -> 519,104 -> 519,111 -> 528,111 -> 528,104 -> 526,104 -> 526,100
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
507,117 -> 521,117 -> 521,116
517,34 -> 522,34
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
510,75 -> 510,78 -> 505,78 -> 505,84 -> 518,84 -> 518,78 -> 515,78 -> 515,75
503,34 -> 508,34
501,15 -> 506,15
523,136 -> 523,138 -> 518,138 -> 518,145 -> 535,145 -> 535,138 -> 528,138 -> 528,136
513,113 -> 513,114 -> 527,114
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
523,136 -> 523,138 -> 518,138 -> 518,145 -> 535,145 -> 535,138 -> 528,138 -> 528,136
530,150 -> 535,150
526,133 -> 526,131 -> 526,133 -> 528,133 -> 528,129 -> 528,133 -> 530,133 -> 530,129 -> 530,133
523,100 -> 523,104 -> 519,104 -> 519,111 -> 528,111 -> 528,104 -> 526,104 -> 526,100
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
510,34 -> 515,34
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
510,75 -> 510,78 -> 505,78 -> 505,84 -> 518,84 -> 518,78 -> 515,78 -> 515,75
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
524,34 -> 529,34
498,46 -> 502,46
510,46 -> 514,46
509,19 -> 514,19
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
526,133 -> 526,131 -> 526,133 -> 528,133 -> 528,129 -> 528,133 -> 530,133 -> 530,129 -> 530,133
497,13 -> 502,13
504,46 -> 508,46
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
545,155 -> 545,157 -> 541,157 -> 541,160 -> 556,160 -> 556,157 -> 550,157 -> 550,155
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
510,75 -> 510,78 -> 505,78 -> 505,84 -> 518,84 -> 518,78 -> 515,78 -> 515,75
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
507,43 -> 511,43
523,100 -> 523,104 -> 519,104 -> 519,111 -> 528,111 -> 528,104 -> 526,104 -> 526,100
506,31 -> 511,31
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
510,75 -> 510,78 -> 505,78 -> 505,84 -> 518,84 -> 518,78 -> 515,78 -> 515,75
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
507,117 -> 521,117 -> 521,116
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
534,152 -> 539,152
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
495,19 -> 500,19
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
523,136 -> 523,138 -> 518,138 -> 518,145 -> 535,145 -> 535,138 -> 528,138 -> 528,136
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
527,152 -> 532,152
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
533,148 -> 538,148
510,75 -> 510,78 -> 505,78 -> 505,84 -> 518,84 -> 518,78 -> 515,78 -> 515,75
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
516,46 -> 520,46
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
545,155 -> 545,157 -> 541,157 -> 541,160 -> 556,160 -> 556,157 -> 550,157 -> 550,155
501,119 -> 501,120 -> 512,120 -> 512,119
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
512,25 -> 517,25
526,133 -> 526,131 -> 526,133 -> 528,133 -> 528,129 -> 528,133 -> 530,133 -> 530,129 -> 530,133
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
513,31 -> 518,31
526,133 -> 526,131 -> 526,133 -> 528,133 -> 528,129 -> 528,133 -> 530,133 -> 530,129 -> 530,133
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
520,31 -> 525,31
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
482,21 -> 482,22 -> 490,22
510,75 -> 510,78 -> 505,78 -> 505,84 -> 518,84 -> 518,78 -> 515,78 -> 515,75
498,17 -> 503,17
523,136 -> 523,138 -> 518,138 -> 518,145 -> 535,145 -> 535,138 -> 528,138 -> 528,136
545,155 -> 545,157 -> 541,157 -> 541,160 -> 556,160 -> 556,157 -> 550,157 -> 550,155
513,43 -> 517,43
523,100 -> 523,104 -> 519,104 -> 519,111 -> 528,111 -> 528,104 -> 526,104 -> 526,100
505,17 -> 510,17
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
509,28 -> 514,28
545,155 -> 545,157 -> 541,157 -> 541,160 -> 556,160 -> 556,157 -> 550,157 -> 550,155
537,150 -> 542,150
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
501,43 -> 505,43
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
501,119 -> 501,120 -> 512,120 -> 512,119
507,37 -> 511,37
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
523,100 -> 523,104 -> 519,104 -> 519,111 -> 528,111 -> 528,104 -> 526,104 -> 526,100
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
501,119 -> 501,120 -> 512,120 -> 512,119
510,40 -> 514,40
488,19 -> 493,19
482,21 -> 482,22 -> 490,22
494,15 -> 499,15
523,136 -> 523,138 -> 518,138 -> 518,145 -> 535,145 -> 535,138 -> 528,138 -> 528,136
526,133 -> 526,131 -> 526,133 -> 528,133 -> 528,129 -> 528,133 -> 530,133 -> 530,129 -> 530,133
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
526,133 -> 526,131 -> 526,133 -> 528,133 -> 528,129 -> 528,133 -> 530,133 -> 530,129 -> 530,133
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
545,155 -> 545,157 -> 541,157 -> 541,160 -> 556,160 -> 556,157 -> 550,157 -> 550,155
513,97 -> 513,89 -> 513,97 -> 515,97 -> 515,94 -> 515,97 -> 517,97 -> 517,94 -> 517,97 -> 519,97 -> 519,93 -> 519,97 -> 521,97 -> 521,88 -> 521,97 -> 523,97 -> 523,94 -> 523,97
523,136 -> 523,138 -> 518,138 -> 518,145 -> 535,145 -> 535,138 -> 528,138 -> 528,136
504,40 -> 508,40
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
526,133 -> 526,131 -> 526,133 -> 528,133 -> 528,129 -> 528,133 -> 530,133 -> 530,129 -> 530,133
523,100 -> 523,104 -> 519,104 -> 519,111 -> 528,111 -> 528,104 -> 526,104 -> 526,100
545,155 -> 545,157 -> 541,157 -> 541,160 -> 556,160 -> 556,157 -> 550,157 -> 550,155
516,28 -> 521,28
545,155 -> 545,157 -> 541,157 -> 541,160 -> 556,160 -> 556,157 -> 550,157 -> 550,155
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
491,17 -> 496,17
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
526,133 -> 526,131 -> 526,133 -> 528,133 -> 528,129 -> 528,133 -> 530,133 -> 530,129 -> 530,133
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
497,72 -> 497,63 -> 497,72 -> 499,72 -> 499,65 -> 499,72 -> 501,72 -> 501,71 -> 501,72 -> 503,72 -> 503,67 -> 503,72 -> 505,72 -> 505,63 -> 505,72 -> 507,72 -> 507,71 -> 507,72 -> 509,72 -> 509,70 -> 509,72 -> 511,72 -> 511,69 -> 511,72
523,100 -> 523,104 -> 519,104 -> 519,111 -> 528,111 -> 528,104 -> 526,104 -> 526,100
513,113 -> 513,114 -> 527,114
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
510,75 -> 510,78 -> 505,78 -> 505,84 -> 518,84 -> 518,78 -> 515,78 -> 515,75
488,59 -> 488,51 -> 488,59 -> 490,59 -> 490,52 -> 490,59 -> 492,59 -> 492,55 -> 492,59 -> 494,59 -> 494,52 -> 494,59 -> 496,59 -> 496,50 -> 496,59 -> 498,59 -> 498,58 -> 498,59 -> 500,59 -> 500,56 -> 500,59 -> 502,59 -> 502,56 -> 502,59 -> 504,59 -> 504,57 -> 504,59
541,152 -> 546,152
523,136 -> 523,138 -> 518,138 -> 518,145 -> 535,145 -> 535,138 -> 528,138 -> 528,136'


drop table if exists #Numbers
--Create a numbers table - never leave home without one
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

;with Input as
	(select PathID, StepID, Co, lead(Co) over(partition by PathID order by StepID) NextCo
		from (select row_number() over(order by (select 1)) PathID, [value] Line
				from string_split(replace(@Str, char(13), ''), char(10))
				) p
			cross apply (select row_number() over(order by (select 1)) StepID, '[' + [value] + ']' Co
							from string_split(replace(Line, ' ->', ''), ' ')
							) s
	),
	XY as
	(select cast(json_value(Co, '$[0]') as int) X1, cast(json_value(Co, '$[1]') as int) Y1
			, cast(json_value(NextCo, '$[0]') as int) X2, cast(json_value(NextCo, '$[1]') as int) Y2
		from Input
		where NextCo is not null
	)
insert into AOC_2022_Day14_Input1
select distinct x.Num X, y.Num Y
from XY
	cross apply (select iif(X2 >= X1, X1, X2) X1,
						iif(Y2 >= Y1, Y1, Y2) Y1,
						abs(X2 - X1) XRange,
						abs(Y2 - Y1) YRange
				) r
	inner join #Numbers x on x.Num between r.X1 and r.X1 + XRange
	inner join #Numbers y on y.Num between r.Y1 and r.Y1 + YRange

create unique clustered index IX_AOC_2022_Day14_Input1 on AOC_2022_Day14_Input1(X, Y)
create unique index IX_AOC_2022_Day14_Input1a on AOC_2022_Day14_Input1(Y, X)


;with rec as
	(select cast('[]' as varchar(max)) CurrentSand, 0 SandUnits
	union all
	select cast(json_modify(r.CurrentSand, 'append $', json_query(concat('[', X, ', ', Y, ']'))) as varchar(max)) CurrentSand, SandUnits + 1
	from rec r
		cross apply fn_AOC_2022_Day14_LandSandInt(r.CurrentSand, 500, 0, null) n
	where n.X > -1
	)
select  max(SandUnits) Answer1
from rec
option (maxrecursion 32767)

/*
Commented out as it takes hours to run :)
;with f as
	(select max(Y) + 2 Flr
		from AOC_2022_Day14_Input1)
	, rec as
	(select cast('[[500,12],[499,12],[501,12],[500,11],[498,12],[499,11],[503,14],[502,14],[504,14],[503,13],[502,12],[501,11],[500,10],[496,14],[495,14],[497,14],[496,13],[497,12],[498,11],[499,10],[505,14],[504,13],[503,12],[502,11],[501,10],[500,9],[493,16],[492,16],[494,16],[493,15],[494,14],[495,13],[496,12],[497,11],[498,10],[499,9],[507,16],[506,16],[508,16],[507,15],[506,14],[505,13],[504,12],[503,11],[502,10],[501,9],[500,8],[490,18],[489,18],[491,18],[490,17],[491,16],[492,15],[493,14],[494,13],[495,12],[496,11],[497,10],[498,9],[499,8],[509,16],[508,15],[507,14],[506,13],[505,12],[504,11],[503,10],[502,9],[501,8],[500,7],[487,21],[486,21],[488,21],[487,20],[485,21],[486,20],[489,21],[488,20],[487,19],[488,18],[489,17],[490,16],[491,15],[492,14],[493,13],[494,12],[495,11],[496,10],[497,9],[498,8],[499,7],[511,18],[510,18],[512,18],[511,17],[510,16],[509,15],[508,14],[507,13],[506,12],[505,11],[504,10],[503,9],[502,8],[501,7],[500,6],[484,21],[485,20],[486,19],[487,18],[488,17],[489,16],[490,15],[491,14],[492,13],[493,12],[494,11],[495,10],[496,9],[497,8],[498,7],[499,6],[513,18],[512,17],[511,16],[510,15],[509,14],[508,13],[507,12],[506,11],[505,10],[504,9],[503,8],[502,7],[501,6],[500,5],[483,21],[484,20],[485,19],[486,18],[487,17],[488,16],[489,15],[490,14],[491,13],[492,12],[493,11],[494,10],[495,9],[496,8],[497,7],[498,6],[499,5],[515,24],[514,24],[516,24],[515,23],[513,24],[514,23],[518,27],[517,27],[519,27],[518,26],[515,30],[514,30],[516,30],[515,29],[512,33],[511,33],[513,33],[512,32],[509,36],[508,36],[510,36],[509,35],[506,39],[505,39],[507,39],[506,38],[503,42],[502,42],[504,42],[503,41],[500,45],[499,45],[501,45],[500,44],[497,58],[497,57],[499,58],[498,57],[497,56],[499,57],[498,56],[497,55],[499,56],[498,55],[497,54],[499,55],[498,54],[497,53],[501,58],[501,57],[501,56],[500,55],[499,54],[498,53],[497,52],[501,55],[500,54],[499,53],[498,52],[497,51],[503,58],[503,57],[503,56],[502,55],[501,54],[500,53],[499,52],[498,51],[497,50],[504,71],[504,70],[504,69],[504,68],[504,67],[504,66],[502,71],[502,70],[500,71],[501,70],[502,69],[500,70],[501,69],[502,68],[500,69],[501,68],[502,67],[503,66],[504,65],[500,68],[501,67],[502,66],[503,65],[504,64],[500,67],[501,66],[502,65],[503,64],[504,63],[506,71],[506,70],[508,71],[507,70],[506,69],[508,70],[507,69],[506,68],[508,69],[507,68],[506,67],[510,71],[510,70],[509,69],[508,68],[507,67],[506,66],[510,69],[509,68],[508,67],[507,66],[506,65],[510,68],[509,67],[508,66],[507,65],[506,64],[512,83],[511,83],[513,83],[512,82],[510,83],[511,82],[514,83],[513,82],[512,81],[509,83],[510,82],[511,81],[515,83],[514,82],[513,81],[512,80],[508,83],[509,82],[510,81],[511,80],[516,83],[515,82],[514,81],[513,80],[512,79],[507,83],[508,82],[509,81],[510,80],[511,79],[517,83],[516,82],[515,81],[514,80],[513,79],[512,78],[506,83],[507,82],[508,81],[509,80],[510,79],[511,78],[517,82],[516,81],[515,80],[514,79],[513,78],[512,77],[511,77],[517,81],[516,80],[515,79],[514,78],[513,77],[512,76],[511,76],[514,77],[513,76],[512,75],[511,75],[514,76],[513,75],[512,74],[511,74],[514,75],[513,74],[512,73],[509,77],[508,77],[509,76],[507,77],[508,76],[509,75],[510,74],[511,73],[514,74],[513,73],[512,72],[516,77],[517,77],[516,76],[518,96],[518,95],[518,94],[518,93],[520,96],[520,95],[520,94],[520,93],[519,92],[516,96],[516,95],[516,94],[517,93],[518,92],[520,92],[519,91],[516,93],[517,92],[518,91],[520,91],[519,90],[514,96],[514,95],[514,94],[515,93],[516,92],[517,91],[518,90],[520,90],[519,89],[514,93],[515,92],[516,91],[517,90],[518,89],[520,89],[519,88],[514,92],[515,91],[516,90],[517,89],[518,88],[520,88],[519,87],[514,91],[515,90],[516,89],[517,88],[518,87],[520,87],[519,86],[514,90],[515,89],[516,88],[517,87],[518,86],[522,96],[522,95],[522,94],[522,93],[524,110],[523,110],[525,110],[524,109],[522,110],[523,109],[526,110],[525,109],[524,108],[521,110],[522,109],[523,108],[527,110],[526,109],[525,108],[524,107],[520,110],[521,109],[522,108],[523,107],[527,109],[526,108],[525,107],[524,106],[520,109],[521,108],[522,107],[523,106],[527,108],[526,107],[525,106],[524,105],[520,108],[521,107],[522,106],[523,105],[527,107],[526,106],[525,105],[524,104],[527,106],[526,105],[525,104],[524,103],[525,103],[524,102],[525,102],[524,101],[525,101],[524,100],[525,100],[524,99],[522,103],[521,103],[522,102],[520,103],[521,102],[522,101],[518,113],[517,113],[519,113],[518,112],[516,113],[517,112],[520,113],[519,112],[518,111],[515,113],[516,112],[517,111],[518,110],[514,113],[515,112],[516,111],[517,110],[518,109],[514,112],[515,111],[516,110],[517,109],[518,108],[512,116],[511,116],[513,116],[512,115],[510,116],[511,115],[514,116],[513,115],[512,114],[509,116],[510,115],[511,114],[512,113],[513,112],[514,111],[515,110],[516,109],[517,108],[518,107],[508,116],[509,115],[510,114],[511,113],[512,112],[513,111],[514,110],[515,109],[516,108],[517,107],[518,106],[506,119],[505,119],[507,119],[506,118],[504,119],[505,118],[508,119],[507,118],[506,117],[507,116],[508,115],[509,114],[510,113],[511,112],[512,111],[513,110],[514,109],[515,108],[516,107],[517,106],[518,105],[503,119],[504,118],[505,117],[506,116],[507,115],[508,114],[509,113],[510,112],[511,111],[512,110],[513,109],[514,108],[515,107],[516,106],[517,105],[518,104],[519,103],[520,102],[521,101],[522,100],[523,99],[525,99],[524,98],[502,119],[503,118],[504,117],[505,116],[506,115],[507,114],[508,113],[509,112],[510,111],[511,110],[512,109],[513,108],[514,107],[515,106],[516,105],[517,104],[518,103],[519,102],[520,101],[521,100],[522,99],[523,98],[527,103],[529,132],[529,131],[529,130],[529,129],[529,128],[527,132],[527,131],[527,130],[525,144],[524,144],[526,144],[525,143],[523,144],[524,143],[527,144],[526,143],[525,142],[522,144],[523,143],[524,142],[528,144],[527,143],[526,142],[525,141],[521,144],[522,143],[523,142],[524,141],[529,144],[528,143],[527,142],[526,141],[525,140],[520,144],[521,143],[522,142],[523,141],[524,140],[530,144],[529,143],[528,142],[527,141],[526,140],[525,139],[519,144],[520,143],[521,142],[522,141],[523,140],[524,139],[531,144],[530,143],[529,142],[528,141],[527,140],[526,139],[525,138],[519,143],[520,142],[521,141],[522,140],[523,139],[524,138],[532,144],[531,143],[530,142],[529,141],[528,140],[527,139],[526,138],[525,137],[524,137],[533,144],[532,143],[531,142],[530,141],[529,140],[528,139],[527,138],[526,137],[525,136],[524,136],[527,137],[526,136],[525,135],[524,135],[527,136],[526,135],[525,134],[522,137],[521,137],[522,136],[523,135],[524,134],[527,135],[526,134],[525,133],[520,137],[521,136],[522,135],[523,134],[524,133],[525,132],[519,137],[520,136],[521,135],[522,134],[523,133],[524,132],[525,131],[526,130],[527,129],[528,128],[531,137],[530,137],[532,137],[531,136],[529,137],[530,136],[533,137],[532,136],[531,135],[529,136],[530,135],[534,137],[533,136],[532,135],[531,134],[529,135],[530,134],[536,147],[535,147],[537,147],[536,146],[534,147],[535,146],[539,149],[538,149],[540,149],[539,148],[538,147],[537,146],[536,145],[541,149],[540,148],[539,147],[538,146],[537,145],[536,144],[543,151],[542,151],[544,151],[543,150],[542,149],[541,148],[540,147],[539,146],[538,145],[537,144],[536,143],[545,151],[544,150],[543,149],[542,148],[541,147],[540,146],[539,145],[538,144],[537,143],[536,142],[547,159],[546,159],[548,159],[547,158],[545,159],[546,158],[549,159],[548,158],[547,157],[544,159],[545,158],[546,157],[550,159],[549,158],[548,157],[547,156],[546,156],[551,159],[550,158],[549,157],[548,156],[547,155],[546,155],[549,156],[548,155],[547,154],[546,154],[549,155],[548,154],[547,153],[544,156],[543,156],[544,155],[545,154],[546,153],[549,154],[548,153],[547,152],[546,151],[545,150],[544,149],[543,148],[542,147],[541,146],[540,145],[539,144],[538,143],[537,142],[536,141],[551,156],[552,156],[551,155],[550,154],[549,153],[548,152],[547,151],[546,150],[545,149],[544,148],[543,147],[542,146],[541,145],[540,144],[539,143],[538,142],[537,141],[536,140],[553,156],[552,155],[551,154],[550,153],[549,152],[548,151],[547,150],[546,149],[545,148],[544,147],[543,146],[542,145],[541,144],[540,143],[539,142],[538,141],[537,140],[536,139],[554,156],[553,155],[552,154],[551,153],[550,152],[549,151],[548,150],[547,149],[546,148],[545,147],[544,146],[543,145],[542,144],[541,143],[540,142],[539,141],[538,140],[537,139],[536,138],[535,137],[534,136],[533,135],[532,134],[531,133],[555,156],[554,155],[553,154],[552,153],[551,152],[550,151],[549,150],[548,149],[547,148],[546,147],[545,146],[544,145],[543,144],[542,143],[541,142],[540,141],[539,140],[538,139],[537,138],[536,137],[535,136],[534,135],[533,134],[532,133],[531,132]]' as varchar(max)) CurrentSand, 901 SandUnits
		, cast(null as int) X, cast(null as int) Y
	union all
	select cast(json_modify(r.CurrentSand, 'append $', json_query(concat('[', n.X, ', ', n.Y, ']'))) as varchar(max)) CurrentSand, SandUnits + 1, n.X, n.Y
	from rec r
		cross join f
		cross apply fn_AOC_2022_Day14_LandSandInt(r.CurrentSand, 500, 0, Flr) n
	)
select max(SandUnits) + 1 Answer2
from rec
option (maxrecursion 32767)
*/