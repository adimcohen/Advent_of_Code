create or alter function fn_AOC_2024_Day24_CalcWires(@Stat varchar(max)) returns table
as
return with Gates as
			(select p.*
				from openjson(@Stat)
					cross apply (select json_value([value], '$.w1') Wire1
									, json_value([value], '$.w2') Wire2
									, json_value([value], '$.w3') Wire3
									, json_value([value], '$.o') Op
									, cast(json_value([value], '$.v1') as int) v1
									, cast(json_value([value], '$.v2') as int) v2
									, cast(json_value([value], '$.v3') as int) v3
								) p
			)
			, NewVal as
			(select Wire1, Op, Wire2, a.Wire3
					, isnull(v1, iif(Wire1 = b.Wire3, b.v3, null)) v1
					, isnull(v2, iif(Wire2 = b.Wire3, b.v3, null)) v2
					, a.v3
				from Gates a
					outer apply (select top 1 b.Wire3, b.v3
									from Gates b
									where b.v3 is not null
										and ((b.Wire3 = a.Wire1 and a.v1 is null)
											or (b.Wire3 = a.Wire2 and a.v2 is null)
											)
								) b
			)
			, Calc as
			(select Wire1, Op, Wire2, Wire3, v1, v2
					, isnull(v3, iif(v1 + v2 is not null
									, case Op
										when 'AND' then v1 & v2
											when 'OR' then v1 | v2
											when 'XOR' then v1 ^ v2
										end
									, null
									)) v3
				from NewVal
			)
		select '[' + string_agg(cast(
					concat('{"w1":"', Wire1
					, '","o":"', Op
					, '","w2":"', Wire2
					, '","w3":"', Wire3
					, '"', isnull(',"v1":' + cast(v1 as char(1)), '')
					, isnull(',"v2":' + cast(v2 as char(1)), '')
					, isnull(',"v3":' + cast(v3 as char(1)), ''), '}')
					as varchar(max)), ',') + ']' Stat, min(iif(Wire3 like 'z%', isnull(v3, -1), 0)) MinZ
		from Calc
GO
declare @Input varchar(max) =
'x00: 1
x01: 0
x02: 0
x03: 1
x04: 1
x05: 1
x06: 0
x07: 0
x08: 0
x09: 1
x10: 0
x11: 0
x12: 0
x13: 0
x14: 1
x15: 0
x16: 0
x17: 0
x18: 0
x19: 0
x20: 0
x21: 0
x22: 0
x23: 1
x24: 0
x25: 1
x26: 0
x27: 0
x28: 0
x29: 0
x30: 1
x31: 0
x32: 1
x33: 0
x34: 0
x35: 0
x36: 1
x37: 0
x38: 1
x39: 1
x40: 0
x41: 1
x42: 1
x43: 1
x44: 1
y00: 1
y01: 1
y02: 1
y03: 1
y04: 0
y05: 1
y06: 0
y07: 1
y08: 0
y09: 1
y10: 1
y11: 1
y12: 1
y13: 1
y14: 0
y15: 0
y16: 0
y17: 0
y18: 0
y19: 0
y20: 0
y21: 0
y22: 1
y23: 0
y24: 0
y25: 1
y26: 0
y27: 1
y28: 1
y29: 1
y30: 0
y31: 0
y32: 0
y33: 1
y34: 0
y35: 0
y36: 0
y37: 1
y38: 0
y39: 1
y40: 1
y41: 1
y42: 0
y43: 0
y44: 1

trd XOR dtj -> z31
ggw OR gpv -> ths
crb OR qhw -> vbp
nbj OR rnw -> dft
rpt XOR hbh -> z14
x15 AND y15 -> jhq
swt AND cmf -> nvm
x31 XOR y31 -> trd
fhb AND pbj -> wfr
mdd XOR spr -> z42
bdr OR tct -> pbt
ttv XOR jkb -> z41
x09 AND y09 -> qsm
nvq AND gtd -> mck
kmb OR jtq -> ksf
y22 XOR x22 -> kqc
qjv AND pts -> mmm
x44 XOR y44 -> nnt
kqc XOR rtk -> z22
x09 XOR y09 -> hsq
gvs AND tmj -> psk
y27 XOR x27 -> swt
ssd OR hjf -> gvs
y36 XOR x36 -> vpm
y34 AND x34 -> vkh
rpb AND nwm -> kmb
tbc OR nvm -> ghk
htb AND qnf -> thg
x34 XOR y34 -> bhh
y01 AND x01 -> gwd
dft XOR vwf -> z04
x03 XOR y03 -> jfr
pts XOR qjv -> z17
psk OR frm -> wfg
x02 XOR y02 -> rsk
x14 AND y14 -> skj
y27 AND x27 -> tbc
vkh OR dcc -> brg
y42 XOR x42 -> spr
y35 XOR x35 -> jng
fnm XOR kqs -> z10
y02 AND x02 -> fph
jkb AND ttv -> bvs
x21 AND y21 -> mtd
x00 XOR y00 -> z00
x26 AND y26 -> z26
y36 AND x36 -> qnf
fhh OR hkv -> ttv
hgk OR gfv -> crt
rjb XOR jrg -> z06
psw OR nng -> z12
nhq OR bjf -> vtg
y28 XOR x28 -> pgc
vth OR jvv -> rjb
dtj AND trd -> bjf
x39 XOR y39 -> qnv
nvq XOR gtd -> z30
x24 XOR y24 -> qbp
tnr XOR kdw -> z11
bdg OR kmg -> hhd
x12 AND y12 -> psw
str AND gtt -> jvv
fht AND vbp -> wbb
vtg XOR bkh -> tbt
pmm AND msc -> ftq
bpc XOR hsq -> z09
hjd OR bjj -> qjv
twd XOR bdj -> z01
hsd OR nsf -> jnj
ghk XOR pgc -> z28
ctc OR skj -> sqb
ckk XOR sqb -> z15
y29 AND x29 -> drg
x20 AND y20 -> khd
swt XOR cmf -> z27
kqs AND fnm -> knt
x35 AND y35 -> cnp
hnm OR vqk -> whc
wfg XOR qbp -> z24
y40 AND x40 -> fhh
mtp XOR kth -> z13
dfp XOR mbg -> gsd
y08 AND x08 -> gth
nhb XOR cdq -> kth
mjb OR knt -> tnr
y08 XOR x08 -> ndh
crt XOR vhk -> z20
y43 AND x43 -> hsd
x18 XOR y18 -> pbj
msm XOR qdt -> z16
kqc AND rtk -> ssd
hsq AND bpc -> rjj
hwt OR mfj -> str
y04 XOR x04 -> vwf
x05 XOR y05 -> gtt
x28 AND y28 -> crb
tnr AND kdw -> fkw
x19 AND y19 -> hgk
x40 XOR y40 -> ttt
x25 AND y25 -> qmv
x17 XOR y17 -> pts
str XOR gtt -> z05
y13 AND x13 -> qrs
whc XOR ndh -> z08
x30 XOR y30 -> gtd
drg OR wbb -> nvq
gvs XOR tmj -> z23
cns OR qrs -> rpt
dpg XOR gnj -> z43
hpp AND wkk -> gpv
wnd XOR mwg -> z07
rjj OR qsm -> kqs
y16 AND x16 -> hjd
x23 XOR y23 -> tmj
ttt XOR pbt -> z40
x24 AND y24 -> qcb
mwg AND wnd -> hnm
x07 AND y07 -> vqk
x22 AND y22 -> hjf
x33 XOR y33 -> rpb
x32 XOR y32 -> bkh
y21 XOR x21 -> nkr
y17 AND x17 -> tkm
x13 XOR y13 -> mtp
fht XOR vbp -> z29
y06 XOR x06 -> jrg
x20 XOR y20 -> vhk
x19 XOR y19 -> jvg
hpp XOR wkk -> z37
rbb OR gth -> bpc
jfr XOR twj -> z03
ghk AND pgc -> qhw
y39 AND x39 -> bdr
y29 XOR x29 -> fht
x31 AND y31 -> nhq
y10 XOR x10 -> fnm
thg OR vpm -> wkk
jng AND brg -> bbb
y11 XOR x11 -> kdw
nhb AND cdq -> nng
x33 AND y33 -> jtq
y03 AND x03 -> rnw
x38 XOR y38 -> phr
ttt AND pbt -> hkv
cbq OR gwd -> rhr
ksf XOR bhh -> z34
twj AND jfr -> nbj
khd OR qgh -> gjg
jng XOR brg -> z35
x07 XOR y07 -> wnd
tbt OR skt -> nwm
x06 AND y06 -> dbc
pmm XOR msc -> z25
y32 AND x32 -> skt
y14 XOR x14 -> hbh
x37 AND y37 -> ggw
hbh AND rpt -> ctc
qmv OR ftq -> mbg
jrg AND rjb -> mjs
vwf AND dft -> mfj
htb XOR qnf -> z36
bbb OR cnp -> htb
vdn OR qtn -> z45
x15 XOR y15 -> ckk
ndh AND whc -> rbb
pbd OR wfr -> spq
rsk XOR rhr -> z02
x16 XOR y16 -> qdt
rhr AND rsk -> nkm
spq XOR jvg -> z19
y38 AND x38 -> kmg
nnt XOR jnj -> z44
y10 AND x10 -> mjb
nkr XOR gjg -> z21
phr AND ths -> bdg
jhq OR dgn -> msm
mtd OR dvg -> rtk
qbp AND wfg -> fws
x11 AND y11 -> mdq
rgv OR bvs -> mdd
x37 XOR y37 -> hpp
msm AND qdt -> bjj
y18 AND x18 -> pbd
vtg AND bkh -> z32
x30 AND y30 -> rkn
mtp AND kth -> cns
y12 XOR x12 -> nhb
vhk AND crt -> qgh
mjs OR dbc -> mwg
y41 XOR x41 -> jkb
nwm XOR rpb -> z33
mbg AND dfp -> kbg
nnt AND jnj -> qtn
ckk AND sqb -> dgn
twd AND bdj -> cbq
y44 AND x44 -> vdn
y23 AND x23 -> frm
y26 XOR x26 -> dfp
tkm OR mmm -> fhb
y04 AND x04 -> hwt
fkw OR mdq -> cdq
nkr AND gjg -> dvg
x25 XOR y25 -> msc
x05 AND y05 -> vth
spq AND jvg -> gfv
fph OR nkm -> twj
y41 AND x41 -> rgv
x43 XOR y43 -> gnj
fws OR qcb -> pmm
y01 XOR x01 -> twd
gnj AND dpg -> nsf
rkn OR mck -> dtj
qnv AND hhd -> tct
hhd XOR qnv -> z39
fhb XOR pbj -> z18
x42 AND y42 -> rcn
ksf AND bhh -> dcc
mdd AND spr -> pdt
phr XOR ths -> z38
pdt OR rcn -> dpg
gsd OR kbg -> cmf
x00 AND y00 -> bdj'

drop table if exists #Startup
drop table if exists #Gates
drop table if exists #rec

;with i as
	(select '[' + string_agg(cast('{"' + replace([value], ':', '":') + '}' as varchar(max)), ',') + ']' js
		from string_split(replace(left(@Input, charindex(concat(char(13), char(10), char(13), char(10)), @Input, 1) - 1), char(10), ''), char(13)) r
	)
select b.[key] collate database_default Wire, cast(b.[value] as int) Val
into #Startup
from i
	cross apply openjson(js) a
	cross apply openjson([value]) b

select parsename(rw, 4) Wire1, parsename(rw, 3) Op, parsename(rw, 2) Wire2, parsename(rw, 1) Wire3
into #Gates
from string_split(replace(replace(substring(@Input, charindex(concat(char(13), char(10), char(13), char(10)), @Input, 1) + 4, len(@Input)), char(10), ''), char(10), ''), char(13), 1)
	cross apply (select replace(replace([value], ' ->', ''), ' ', '.') rw) r

;with rec as
	(select cast(
			(select Wire1 w1, Op o, Wire2 w2, Wire3 w3, w1.Val v1, w2.Val v2, w3.Val v3
				from #Gates
					left join #Startup w1 on w1.Wire = Wire1
					left join #Startup w2 on w2.Wire = Wire2
					left join #Startup w3 on w3.Wire = Wire3
				for json path
			) as varchar(max)) Stat, -1 MinZ, 0 Steps
		union all
		select n.Stat, n.MinZ, Steps + 1
		from rec r
			cross apply fn_AOC_2024_Day24_CalcWires(r.Stat) n
		where r.MinZ = -1
	)
select top 1 *
into #rec
from rec
order by Steps desc
option (maxrecursion 32767)

;with i as
	(select string_agg(v3, '') within group (order by Wire3 desc) Bin
		from #rec
			cross apply openjson(Stat)
			cross apply (select json_value([value], '$.w1') Wire1
							, json_value([value], '$.w2') Wire2
							, json_value([value], '$.w3') Wire3
							, json_value([value], '$.o') Op
							, cast(json_value([value], '$.v1') as int) v1
							, cast(json_value([value], '$.v2') as int) v2
							, cast(json_value([value], '$.v3') as int) v3
						) p
		where Wire3 like 'z%'
	)
select sum(cast(substring(Bin, len(Bin) - [value], 1) as bigint) * power(cast(2 as bigint), [value])) Answer1
from i
	cross apply generate_series(cast(len(Bin) as int) - 1, cast(0 as int), cast(-1 as int))