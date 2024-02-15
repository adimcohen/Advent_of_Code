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
'cpjw: 3
wnsc: 11
lqqs: 2
lwqb: whnr + ndsf
rtst: snlm * phwt
hhpl: pwff + pndl
bspq: mngz * qljm
mjnd: jsdd + gzlp
bdlb: 2
rldw: mqwn * bdhm
hnnb: fcvc + tmhn
hdps: 3
srhg: fmvc * qnml
vbdb: bmdj + rdcb
qpmh: 6
jjth: 16
jrhd: 4
bdtm: 5
jlhf: gzsb * llwh
nslr: 3
tsjv: phwg - wnwv
lsls: 1
btth: 2
wgnn: pdcp * nctj
ntss: nvjt + tsql
snbf: 4
wczz: qqzj * hmwc
fdnq: lvwp * rdpj
jcrh: 2
lqjq: ggbs * vvwf
twvf: lcrt * mnvj
nrzj: 2
ndtn: 2
zfrb: 4
tqnq: hfvf * mmsv
jgmd: dslz + pzvn
hvhw: 3
pffl: nbmg * vqds
nprt: wtzc + bjlc
vjfp: 9
ldqh: pqpt * dtjt
fwhm: rgcb * cwgs
nrvt: qhtr * pjlv
sgpn: svbw / mjjd
mnmg: 3
dqcz: hdfq * bnhb
dlbb: 14
tmhj: 4
wnwv: wcgp * qqdf
qccf: cdjl * pfhw
jnbs: 1
nlll: 4
tqfr: 9
wtgw: 4
bptt: 3
mrmc: tqzl - jgww
prqv: vfnq * vcmn
rfvg: 3
wjwj: fqwt * bfjw
gghr: hzgj * fbzw
cnpf: gdfz * jnsw
twcm: bhhw + bzcp
zpjw: 4
gnhv: gsqg * rrpv
qpgb: pmzr * vhps
gjfc: pqhg + bvjp
nmwb: 3
vvwh: 13
pgbz: zghw * lmnj
wqbh: 5
nnvv: rpqb * tczj
gswh: wjds * plbc
ddgb: 3
zjtj: 3
ttdh: 5
lcrt: 2
rwjv: 5
ldvj: qjcb * lplz
bmqs: vhwq + tdwd
tdmq: 13
wqst: flww * phnc
bhhw: pgmc * gpcf
qvsd: 2
fhnt: 4
shqh: dtdf / bdnn
sbnn: 2
njtl: 3
bqrc: 2
stst: gvjg * hmrp
gvsd: hvfg * fmjt
bdbg: 7
mnlg: 1
vrpv: 1
lcgq: 4
zfnc: 3
bttz: zzsb * qfcs
qnww: 7
llzj: bqqp + qprr
wrln: mtbt + rcmd
zvgp: dsqv * tcvz
jjrw: 2
tmvz: 3
dvqm: rwqp / zhbv
gjft: lfvc + jgsj
nvts: 5
grvm: 4
qtgr: dnmr + swqq
tftd: qpvc * jjwj
mcth: zwpb + zdct
rmrw: snlf * prmj
fqgr: 5
hvfz: 5
btqm: 2
fqph: cbsn * mfvf
wrhq: 8
ggrh: wjhh * fbjr
wgmc: sccq + tqfr
pshg: 3
vdvw: 3
rflc: svgp + rrvs
tphl: zsbg - mhnr
vqnc: phjj + gcjj
fbnb: jdws * tjbm
vsgw: sfzl + htrp
tpsj: 5
cbwh: mvht + jpfz
dwmm: 7
tjvl: 13
dmrb: 2
jlbn: 3
qfls: 8
vbwv: 1
phbp: gmmp + fltr
mvfw: lvhl * vgcf
wdnd: 3
tssv: 2
dqnn: mhnw * bjqn
rgdq: 1
qpmn: 3
pwgc: 9
cbnz: wzvc * jcrh
pvht: 2
fgwn: 7
gpcf: djfc + qhwt
rtfj: 2
nppg: crpc * cdgq
vgnm: hfph * bvhf
npqf: zfps / wmhm
zsbg: qhln * njjn
jplc: 1
bzqc: nzsh * zmdm
fnqt: wfwm + vcqw
wggf: hhcv * bhgl
jhhz: 5
brbz: 4
nfwb: mgzr * gwmt
lqcr: mltg * hgjn
nbgl: 12
nzhz: 7
tvqv: 3
rjvr: 3
wrqm: 13
vwzg: 10
bbps: jbtt + nzbd
jjpp: cwsr * wgmz
mmvb: 4
bmml: 20
qmgt: 5
jcvw: hhtp + jjpp
qjcb: ntvj * jrhd
twjv: 4
zngs: hthf * twjv
fdrw: 2
ltqr: 3
lzvf: 10
vhqj: vrpv + tflj
jdmt: zzcz * nqgp
crqf: 4
fgwt: jmht * sswf
gldh: jhdm * trdv
czvh: glhn + qrcf
rzmb: fgcz * brpw
sprq: mfwr * mvfn
nwqw: 2
rvrt: pczq + hwvh
gmmj: schd * glbd
wjhh: dnqg + htgz
lfvc: msjw * wdnd
nmdf: 2
clzc: bslw + tbvq
qqcv: rptr + ldpc
pzng: bmtt + tnnt
rjmn: lqhh * fbnb
zhgf: 10
tfmn: ghfv - bgnf
hjnp: 9
jtcw: cmhr + mfqp
hhql: 2
gwcv: vljq * dqpq
btwj: cbfh + vrcb
qcqv: 2
cmrd: 18
pdnm: sdld * pzcd
nwwc: 13
qrsr: 3
lnqr: 11
qhvs: 8
djfc: 3
zcph: 3
zwpc: 2
nctj: 5
chbg: rnqd + fmqc
mdbj: vzvs + ftqt
qldj: gjsv * hnnb
lvtr: 4
zhbv: 4
njrr: zgzd / fnhb
hqhg: zcph * frrd
vfdf: 2
dsqv: 2
ldpb: 3
gtff: 13
ztgm: rldz * gzcq
sjcb: pwgc * wvzp
ntvd: 3
jzcj: 18
svfs: bgtl * vrmt
ztvb: cpjw * zzsl
vgfp: 3
zzsl: cjtv / znqw
wqcd: 2
bpqv: 3
mwgc: bmnd * bwsw
cvgf: 2
rwht: 2
fztg: 15
dzts: 8
nnpz: 15
jlqz: 5
qhwv: rfpl * hwmd
qshc: 2
rlgn: 4
tljt: ctpd + wlrb
fzsj: gqhh * rmrw
lqbh: lqcb / cvgf
jswg: 3
ghwt: jlrp / fqgj
mndd: 3
tczg: 3
shhv: vlpl * fgdh
gdcz: rbbs * brng
lmtr: twvf + rnnn
bsbv: dnrp * wwdn
lwlc: 1
jlbj: jmzv / qtjf
rttr: rbdz + ltcq
mzjz: ggdw + zpvh
drmq: 2
lrvn: dlrb + phpz
ctgz: zjzr * vmlm
tbvq: tlrn * rchd
zzcz: mwdl + phvf
twgb: bcmd * bhwt
tqgm: cdpm * fwhc
ffnz: 2
fqct: 16
znnp: plwh + zgcr
qzwm: 4
ccgs: bqtb * pshg
hnpv: smbz + chsm
mjgg: gpbw + rgrc
hgrr: 3
gqcc: 17
rhnp: 3
vcgc: mrvw + fhfz
fmjt: 2
vmfj: qpgb + mlvw
svnd: cfqb + tffz
plll: 5
jmzv: ghrr * jbrz
thtj: 5
tnjb: qldj + chvt
mnvj: 8
wqch: mqrb - mzrf
zrvs: cqsp + lpzj
fzft: 9
lbbz: shlm * btpw
pngb: 2
jcsv: 2
rvff: vjpr + mrfh
bggw: 4
qzbv: bqqh + nsjc
vvmc: 3
ghnj: frwr + hbnz
wsnz: zvbd * lcgq
bpgr: 5
glwp: 2
rmnn: qvnq * tdcf
mrzg: nwwz + vglp
zqws: wqdn + pdsp
lrvz: vmfj + fmrv
lmfq: 2
wfvc: lfdt + zmcw
jpms: 6
htwq: fnqm + gpjv
mggc: 7
jmht: cjfw + cdsm
mprq: sprq + grtz
dqpm: 2
vzmb: 3
vnpq: rllg / bgnc
lwzq: lrvn / dgtn
zwmb: 2
wwlj: 11
cfnr: 4
rhch: mcfn + pfzh
jmrw: mdrj * llgc
htpt: vbbv + qsnz
gpdz: 2
lprw: mqdn + rnjt
vrgc: 2
bjqn: 7
gzqn: 8
prvm: 2
bwpw: 3
pnpr: jmrw * npwp
sdtv: szwj * bbjd
fgcz: jtbd * tpsj
qjcn: 2
bczf: 2
brvj: 2
ndsf: dvnl + ghtf
nffg: qpzh * gndz
qzzm: 19
wmrd: dncp + fqph
bhwt: 2
qvlz: 3
mjfn: 4
bfjn: bhlb * hbcf
brjh: 10
srnq: 3
zccj: 2
humn: 4672
trjc: 5
bcpv: 13
pdsp: tnjb + mbtq
stqm: 2
fnhb: 2
lwbr: zlnj - mfcl
hzqs: mgdb + zmqv
mprt: fgwn * hflv
dzhv: 3
hvrd: 16
tqgd: rrqc * dltq
ndtr: nbgl * bdnm
bbhp: 4
nwms: mtmg * vctj
jlrp: cpph * bjgw
lcwn: 5
zlfb: nfdw + fjmg
crtd: cqph * mdbl
llgc: bvpb + pgbz
pdsz: cjqt * btwj
whnr: jzcj + gdhf
fbjr: 2
zshr: 5
gdsj: cnst - szjn
zbfn: 10
rgsw: 11
ndbp: 12
nrtt: mgfr * wldb
cnbm: 3
tzrb: bjzn - vsml
dwqw: rgcd + wvhl
svdf: cqmt + scrf
mvzn: fwpz * sbnn
qmwj: 3
wfrs: 4
bnvm: 2
hjtj: rfvg * nzmq
jbrz: zvpd * jppf
crpf: lbps * fjjb
jgfg: 2
tzms: szqh + mspv
vfnq: mfcm * twfq
csdh: 10
mspv: 4
btjp: 4
pwvg: lqcr + wlpp
mqrb: 7
smhs: 6
pwmw: 3
mqwn: 3
bqqh: vjmc + cspn
hhgv: tshr + lnrv
vdsr: 3
llzc: 3
dnjt: dttd * prhd
cdjl: nfwh + vhqj
swtb: 7
lfgf: lwbr * gnhv
qctd: rflc * fzbr
rtdp: pwgq + dffr
qljm: 3
fcvc: 1
whsz: 3
njvr: 4
gqvh: 3
smlv: 3
crng: zhml * dwmb
qjcm: 3
vqwb: 2
mhnw: 2
dqcc: 3
jwzz: 11
tjdh: 3
szct: 11
cftw: gzjq + vpzz
tcmt: mhgc + wrrg
mfcm: 4
hgsj: 2
hbnz: 2
plfp: zftl / snvq
zdct: 2
qrqr: rqpg - vbmd
zqnt: 4
crbf: vbwv + lnqr
nczc: jrnl + ztvb
cpds: 3
plwc: 3
sjmg: 18
zfnr: mbgb * hrnm
vljq: vjzs + ndbp
bjgp: hzvw * sfnb
tpnf: 10
dhnd: njmz / jfrd
vcmn: zbjh + gtmr
fgfp: vvwh * sfnn
cmpq: vllr * lqqs
jbtm: pmzf / qldw
cmhr: vfdf * npsn
fhhh: 3
rchd: mdjw - pgcc
dttd: jcrt - phdb
dhnl: 6
npft: 17
rdpj: 6
qvmt: vbgp * gdsj
nsvl: 5
lsjl: 5
hvfr: bvrg * lsvh
mngz: 12
bcsp: 2
wjtl: 3
vjgw: 11
qjjl: 4
wgtm: nvtj + hwzj
htgz: mfwc * wcsf
swmh: 2
qqnd: 1
ztbw: qvmw * qfjf
gdzv: wmvp / qtrb
rgcd: 8
msqr: dvwg * zfff
pghc: 5
dbfv: gnjc / cbdt
sntz: 2
jclc: fhnt + bbps
sttt: 7
szcz: 4
cvcr: brqv / njtb
njqm: 2
gzsb: 2
mfvw: 2
stlr: 1
hhtl: 19
hfph: 13
ldfg: zshr * rltm
mlnd: 1
vrls: 4
bnvq: 5
wvhl: bhnc + tddg
zhml: 14
rtfm: hglg + ztcw
vbwr: zfnr + tqgd
zgcr: 15
mvsb: dnbc + bfbt
sfzl: dnjt + mwhs
tvql: qhcb + slpn
cmls: 3
jrnl: glsp + pnpr
wtzc: pvrm * nhgd
sdhv: wsmw + lwqp
gvjg: 5
dgtn: 2
tzvm: 4
rchh: zffd * qjvs
rfzj: npft + sjdn
pzzg: fvch * gswh
njmz: nwwc + ztfc
btgd: 2
pgtb: gwdh + qnww
bqbv: ppcm * spcb
jnth: 2
qmvn: 1
vsml: dzts * tphl
tgsv: 4
ssns: 2
ldpc: vwgs + gjvc
tlwg: tdbr * pcvm
ddfh: tfqz * vnft
hnbv: 9
mdjw: wptd / sztw
msjw: cqml * lddc
rlnh: 4
ztwc: nslw + cgrw
ttzh: dlvq * qvrt
blff: rvff / cvrb
gzjq: jgbj * tjvl
dmmm: 4
pdgj: 3
pbrg: 3
rwhb: sbhb + vghw
grrw: zjfr * zgmv
bvjv: 18
jppv: svdf + nffg
hfql: 5
pfzh: dwtm + jqsn
cmbd: whtb * qggc
shhr: jmbz + nlmn
lmvg: wlsb * vzzv
lcfh: dhbg + cvvh
pfhw: 2
hglg: qvsd * wdgz
tljz: 2
nhvm: 7
bdvz: 2
glzc: 2
jdpg: gfdp + hjlm
wjsn: 13
tqzl: wrsh * rzlf
cccm: 3
hhtp: cjbn * twcp
sfmc: 9
fpmh: 4
gvtg: 5
tcct: gsjj + gwgf
cntc: 3
mpfn: 5
fghm: zrvs * nhpc
ntvj: mcwm * bfjc
mzqf: mhvr / hhtq
twpz: 6
vrmt: 3
vstw: 4
wbrf: 6
wcdr: fhhh * zglz
htvl: 2
bdjj: svld - zftm
jlsp: bdjj * lfgs
hfmn: hfbp * mwmw
bgtl: dqcz + mwfq
nzph: 8
rpvs: 2
hjlm: 1
pbqr: 13
rlvf: 3
gqcv: 2
dlvq: 2
crwd: 5
rnjt: 11
vhps: 2
cpph: 2
gcjj: 5
zztn: 1
zgjr: dncq * cffd
tvgm: fswr * qttj
dcfm: 3
vjzs: 1
hcln: hsrj - wgjl
prvf: hhpl + jnbs
hnhz: 2
szwj: 3
tmhn: gqcv * tlwg
bcvp: pzzg + mhfp
mqdn: 6
dmlp: gfqj * cccm
cqph: 3
spcb: wbmf + tfcm
lqhh: 3
hwqm: 3
tmsn: lfvm / dmlp
twjr: 3
bwmf: glfl * tljt
zsvb: ggsz * pqzt
dmjp: 4
hhhd: 2
shsz: 2
dqvg: 3
hngp: rbgn + nvts
gqvm: qzzz * wrln
zhvh: 3
vtgz: 2
tpth: qnbt * wtgw
tpzr: vstw * htdg
tscf: 3
cmvs: tscf * tgsv
bggv: 3
cznd: tpzr + pfgv
vpnn: fpmh + hsdf
mbjh: 2
snch: 7
mwjz: bcsq / twlh
qpzg: rlgn * rtgl
qptq: fwmt + cjhb
rbgn: hrrj * twcq
ngdg: rvfq * htms
zssb: sfmc + mpfl
qprr: trjc * tqgm
bmfv: nrnw / qpmh
mmmv: pzng + zzps
nqwf: pdnm + gdcq
twlh: 2
gdfz: 5
frqv: 2
ppcm: 4
gjsv: 3
jfrd: 2
sgfr: 5
mlvw: jwzz * hnwf
gzcq: 2
btvt: dqcc * fnbz
bssc: fgwt * hcfs
dfww: 4
mtmg: fdnq / ccgb
glbd: bvws + dgln
bhfd: 3
rrrt: 2
lltw: 2
hchs: 2
mvvv: mgmt - zqws
vghw: 7
bwdh: jzzc * zccj
wpqv: dwbh * tzct
prmb: nczc * btqm
nsmw: 3
lvnv: czvh / ljtq
bvjp: szml + vvht
vhtd: 2
qndf: 1
mrrf: 11
bqjc: phgg * dtcp
qsgr: 1
vmcs: 17
cjqt: 3
szjn: 2
nrdr: 2
vhmn: zvgc * pbdc
rcbm: 2
jrvc: 2
wpch: 5
jpcq: 3
tsql: 9
vszp: 9
ltcq: 4
zvjr: 2
sntm: svvs - cbhb
zjlr: mwsb * nsnz
qrbr: 4
tdvn: 18
wvzp: 3
zgzd: pqrs * trmm
rfpl: 2
cbsn: 3
lzln: 11
glqc: 17
vpzz: rvhd + nvrz
pztg: djbs + ggnd
lnlp: glqc * mwgp
sgzz: humn + ggtn
bzds: llzc + fbtm
gwsd: 3
lwdq: dcms + vtdt
gdwp: 2
cjbn: 5
fztf: pssr + hgbt
cvgg: 17
wlrb: gbbs * bbsc
fgdh: 3
srcd: vhhd * fgvh
znpb: 3
mqss: 11
ggbg: lcwn * pghc
lhqb: 2
fcgh: 2
dnrp: 5
vpqf: jmgt * jnhd
dqlz: jdjb + nwhh
njjn: hhtl * vzmb
mnjq: zmff * gdcz
qhjv: mcth + nhzs
cbbv: 20
tcpv: 2
nmft: 5
fzdq: 3
plbc: nnpz + gtbg
ngsj: 1
mwph: 1
phwg: wrdt / glwp
czgw: 17
lbps: 4
rgcb: 3
vflm: sjcb * jwzb
hhcv: tzvm + fztg
cvws: whgp * vjzj
mfcp: 2
mbdb: 4
zzzl: vcvw + ltwc
mvcn: 5
zzsb: 9
jdhl: glzc * rhnp
hfhw: 15
ngqq: 4
bfjw: 5
sbhb: fwlz - wpqv
zwpb: lnlp / mgnc
hsdf: 5
dcbj: wcdr * qfcj
ctqh: stqw * sbfj
vbmd: 5
qsmw: twch * tljz
blhg: dngc + pznm
pfrm: vnng + gwsd
dhhv: 3
psww: 15
tqzq: 2
cpbd: 9
fjtd: 10
mwgp: 2
swps: plvl + znnp
nrnw: rnnf * wmvr
qhfj: npqf * crng
rqbg: njgv + jjth
bbnr: sttt * rtdp
jlhl: vpqf + zqnq
zpvl: qttq / jcsv
jbtt: mvfp + rpvs
cspn: gqhg / tldf
pcnz: 3
mhtd: vpds / ffnz
glqm: 3
qltq: 3
lpzj: 1
sfnn: 3
pbdc: 5
hwmd: dbqj * lrgw
nncd: 14
gdtp: nslr * zwmb
hfbp: 2
gbnr: dnrr + ldvj
wdmw: 4
fcdj: nlrb + brvm
mrfh: 7
tffz: 11
wnwm: 5
gpjv: csps * bmwt
qhln: nncd * qwvh
gsjj: hzfz + hfts
rrtd: 3
nhmj: 3
tvqg: 13
ghtf: gdzv + qsld
vcvw: 3
hjzd: sntm + jqwb
vctj: hpbb + rpqf
mznv: 19
dwbz: nvlp + qmwj
htqs: 2
dncq: 5
wptd: bpfz + nssm
lmnj: 2
dtjt: 6
smbz: jzwn * btjp
wjzc: 5
nvrz: lsjl * fqvv
root: zhms + qqqz
jsbw: rjsv + tvgm
bmls: pmft * qtqv
nwhh: bpqn * rgnl
vppt: 4
wsfb: 3
gbbs: fwhm + cvds
vrfp: 1
dcqb: mgpn * jgmd
shlm: tpbf * qsmw
qtfs: 3
btlt: 2
tcqq: htpt / mbjh
vcsq: 3
bwnn: 4
gqhg: ftvc * lwqb
sztw: 5
gzfv: 13
ftvc: 2
pcpp: 4
vdzc: 20
dcms: npld * gcmz
nqgp: 2
hpdm: lwlc + csdh
msfr: lvjq + rmnn
jrnm: ttwv + vgnm
dsrv: 2
cptf: tcmt * zdwl
vgcf: 7
rzrb: 5
gqhh: 6
ffrb: rgsw + jmgq
zqrm: 3
rbdz: nstl + bzds
flpf: 2
fzbr: 3
mmtc: 2
sjdn: 17
hwvh: 2
qtvm: 2
ngjt: jjtr * dtdn
mvfp: 4
jbwl: 7
bmrd: 17
qrvl: 4
pqzt: 5
svbw: tdnj * mmmv
cgsp: pgnc / flpf
wcrv: 7
ghcn: 15
mggm: hsff * clzc
rzqp: 5
vnft: 2
cdsm: hmpg + hzdv
pvwd: 2
hvgp: 3
bvhf: 2
mltg: 10
dhws: 6
hrnm: 2
gwdh: 1
btpw: mwjg - hjrt
gsfp: pqbm * cbwh
dtdn: 19
htdg: 2
grbc: znpb + rjtn
bbhs: 12
cwsz: mldd + zssb
dbzt: 3
tbmc: nflm + hhmh
gmmp: 1
jtrn: 7
rmbz: mfhn * gmmb
hsrj: bdsp - cjln
wfdz: cgsp + lcpt
qqqz: prqv * wczz
shrp: 3
gdcq: mvvv * qjwp
shlq: sppv + dwmm
dltq: wwlj + shbc
tfpc: dldl * mmpw
plcd: nmft * lfvt
swvn: 13
wztg: tdmq * ntvd
lzmm: 5
wgvd: 5
lbws: wgvl / fqwp
jzsg: cbnz + mlwq
crpc: 11
dqlm: swvn + jnjf
wqjj: 5
tlqt: bsws + hszt
tllm: 4
rqpg: wgtm * mblq
lvhl: 8
mfcl: vppv + phbp
dstm: 10
wvbf: drrm / jlhd
crfb: 6
dfnp: tcpv * gtvf
pqsh: 4
gvcm: jtcw * chfq
qtdd: 2
bznp: rhch * bczf
ztcw: scbf * jgrg
gjql: qrqf * cnjn
phgg: pqgn + scpt
frtp: wztg - btth
dftj: 11
chfq: 2
gjch: 5
fctc: hrcs + wbrl
tlvg: 3
nzfj: 3
pczq: lwlw + lqjq
svgp: vnsd * mmtc
sbfj: 2
rqfm: rvrp * pwzp
scnj: 2
cgtt: mvzn * jrvc
pwzj: hzqs + vdsr
sdtt: wpfc / jpms
hdfq: 2
djsz: 5
jzdn: qctd / dhhv
htrp: mzjz * fths
jtbd: 2
sssf: wjcb / wmrd
fnqm: 1
qlnl: qzwm + qpvl
bljd: zhgn + cnvl
zjfr: 4
qldw: 6
dvnl: nzph * zjtj
bmnd: sfgd + jghz
qttq: dwqw * zzvf
lnrv: tpdz * qmvz
frmh: 3
fpdn: 6
nhqm: rldr + jzdn
scpt: tdps + lrlv
ssfj: hchs * dwcz
dwmb: 5
pchg: 2
nhhm: 2
hcfs: 2
ttpl: 3
fmht: 3
cpgm: 6
jgtt: 4
jdgc: cwlh * rjvr
cjhb: zssj * phnm
pssr: glqm * vdnm
rpqb: mgtc - plsq
jqwb: jszt * ptlb
rtnq: pbqr + gldh
gzmv: 2
bdsp: lbbz + tncg
schs: 5
slpn: sjbs * qqsg
fwqw: 4
dtdf: qfff + rmbz
cqwh: 1
twvg: 5
hwzj: 7
scwr: 13
mgpn: 7
qzgs: nzhz * tssv
chch: gtff * zfrb
lwlw: 3
ftqt: rppv + hhhd
pwzp: zqsf + nhjl
mvff: 2
mlwt: 8
tdqp: 2
gndz: 6
qmtm: 2
jmjh: dnwr + jhnj
jmgq: zbfg + hjpl
zghw: 11
zvbd: 2
tvzs: tmfv + jvzq
wrdt: rpbn * zvjr
vltb: cqlj + rzhv
cqsp: lltw * whsz
mgmt: vbdb / gmvj
hzwh: zqrb * njhh
jtnf: 7
bpbh: lsls + mwjz
hgbt: njbs * fqgr
twch: 3
cqml: 3
brjn: 2
qwwh: fjtm * bzdr
zgfn: 13
jqln: ffdb * zbfn
lfvm: ppjh + nrfb
hpbb: srcd + lmmw
qqdh: 6
scgb: tvgs + hzpq
fjgb: 15
bnth: nmwl * ffzr
pqpt: 5
cwlt: gjfn + wshm
qpvl: 6
ghfv: sgzz / rdpm
lvjq: lwzq + nldz
qrvs: jbnj * rrtd
jgsj: 4
tldf: 2
ffzr: 4
jdws: 6
qjvs: tmsn + vvtb
dhfd: 5
tzhr: bwlp + pbjh
cwgs: 10
lqcg: 3
phnm: drmq * ddgb
lwjb: jsbw / bngf
bdnm: 2
dnjb: pnpp * cvhb
tmfv: 7
hdlh: 3
qzmm: grbc * qpmn
wqcg: 3
vwpg: 5
llwh: fjlp + lbws
mnhl: qrnj * nppg
lfgs: gjfc * lqcg
dvfb: 11
srrv: sptt / mfcp
znlh: 4
dnqg: hnlp * wjfg
hfhr: lprw * wmgq
lchh: qppj * bhfd
nqwm: rvnm + qhjv
nzbd: 1
tdwd: gqcc * bptt
svmv: rnfn / bnzm
vvtf: lvnv - bcmp
nzsh: 3
nbql: 4
hsff: 2
bmdr: jlhf + qrqr
jqsn: 10
hzdq: 13
bhlb: fqct - vcrb
wnrs: 5
qswm: 5
rfgt: htwq + hwvd
wmdh: 5
sppv: bnqf * pqsh
mqtn: pbtb + twcm
hnfc: 2
spcj: bqbv + lnwb
hmmn: ggmf - rtst
mvht: dfjz + pdsz
tgtl: 3
mgfr: 2
jrsw: cvdf * drgp
blvm: 3
sptt: 14
rnsd: 2
mvbt: jgmj * cnvb
lpvg: ggrh / wssv
zvgc: svdh * smbh
mpfp: 17
dffr: cpds + msqr
dzfl: 13
njhh: 4
rpnp: 3
ljsn: rfzj + hvrc
ldqj: 2
nvlp: hjft * gpdc
nbmg: zfjs + jlsp
rldr: 6
bhgl: 5
wtmf: 2
nzmq: 2
jldq: hfgm * fnqt
ghlr: lpqz * rfbr
qqvp: cswg * bpmb
ddfm: tzhp + jzhv
gnff: 2
fmcm: tvqv + dqvg
qrlf: pcdq + mlpj
nhpc: 2
bhwl: jlbn * bspm
pfgv: 5
vwjg: 2
lqwd: shqh - ncph
qwcq: prvf + rwjv
wrjp: 5
zjbq: 2
wpjs: 5
ztnt: shsz * spcj
frwr: 14
rtsp: vlls * sphz
vhwq: zgjr + nmrc
rhbp: nsmw * jwvr
lfvt: mrcp + bglb
rbtq: mwmh / fglm
mdcr: hvsp * bwpw
wdgz: 4
bjlc: rsmd * ssns
vqds: 2
qbbb: 11
mwdl: 14
vdnm: bhgm / rnsd
qrjj: 5
jwvr: ztbw + fzft
vmct: 3
gmvj: 3
glsp: pwvg + qnnz
jsbf: tjdh * fmht
dnwr: 2
bngf: 2
gnjc: fcgh * fgfp
pgdd: 3
hzgj: 12
jczm: vnbp + mgsr
hrlm: 2
lldv: 3
brqv: tlhw + nqwm
npsn: hzdq + grvm
fwhc: 17
tbcn: jgtt * sfvq
mrvw: jldq * wwqb
nhcs: 2
bfjc: 2
mgrj: hdzt + cpgm
rjsv: jgzv + lzvf
cfbz: 20
hqvd: 4
tzpj: zhgg * nplt
htms: wpch + hjtj
qnnz: lmvg + sdnc
rjtn: 5
hvfg: rmpl * scnj
rpbc: vcgs * bsgj
brpw: qshc + mmvb
bzmf: lzvn * gnff
tglm: lwrw * tzhr
szpv: bqcb * qvmt
snlm: 5
phvf: shrp * zhvh
bqzr: 2
vnsd: 9
lrlv: 2
schd: 2
qtqv: 7
jnhd: 2
hdzt: 8
vvtb: qldd / vgfp
wssv: 2
rmsp: 19
jgzv: 3
mzrf: 1
bgnf: sjmg * vcvj
gtfb: dmvm - mvbt
jmbz: hnpq / znqd
brvm: 2
ffdb: 2
dhrp: bhmp * fnfg
gfdp: fmcm + wrsg
gsps: gjjz + qsgr
bwlp: pjqs * mtsp
jcgl: 5
dgpj: 2
lhwh: mznv * dfww
mhgc: wcfg * jtnf
gcpc: gbnr * rjln
vhqs: 6
gpdc: 4
wrrg: grzz * lpvg
hhtq: 2
qpvc: mjgw * rzrb
vqbz: tdqd * tfst
szml: bmfv + bmls
fqvv: shhv * lldv
zvvp: 7
mldq: szcz + qdbw
qwsw: 2
gdzm: thtj + ldqj
lnqf: 2
rcfh: 2
fblv: jzgq / pwmw
rgrc: qjcn + wrjp
ndhv: ldqh * ggbg
wbrl: mvff * qrvl
mhnr: dwfj * jcgl
ljwl: 2
fwbf: ntss + vflm
nfdw: cvws + qwcq
pzmc: 2
qgrv: 8
phcg: ssqq * rtfm
mbdl: 12
sdnc: rfnn + dnjb
shnl: hjzd * ldpb
vcgs: 3
pllg: 15
hfgm: 8
lzzr: fnwf + cpvj
vjpr: blhg + vdzc
jlrj: bnvm + sgfr
bdbf: pppc + hwqm
snlf: pfrm + wsnz
mwvm: gqvh + tjvv
wwqb: mnmg * vnbb
mlpj: hjtb * wwfw
hbpr: jjfp + pzwp
mjdm: zqrm * qshf
cdvl: bsbv * plll
lmtl: ndhv + nrtt
lvwp: tzpb * nmdf
bnhb: 11
bmtt: 6
msvm: 2
tjsq: 17
nwwz: bspq - hgzc
nvjj: 8
zjrs: 1
dfwr: twpz * vchc
wrmw: 2
jmcl: 2
bcmp: vghb * rnzv
tdnj: 3
tshr: hmmn * gjql
vzzv: 2
ztdf: 2
tctc: bhmn + bzqc
bhnc: lzvg * wsfb
pdcp: rfsz - mbdl
lztj: 5
tltq: ctgz / brvj
vlpw: 5
vpjd: szct * pvwd
pltw: qwwh / rpnp
nztr: 2
rfnn: jdgc + bqhl
dvbh: 7
phnc: 3
gtzt: tlvg * nzlc
fqpc: 2
frwc: bwdh / bdlb
nhrd: wbrf + ctqn
wrsg: 1
npwq: wjtl * vmgv
pgmc: 6
zssj: 6
fgvh: 4
thnf: ztnt + spns
pgcc: qzqf * fpqh
pjsm: 7
lsvh: 2
ggbh: 4
wshm: 2
nhgd: bpsm + dlbb
cvgp: qqcv + mprt
ggbs: 2
swvw: 2
jzhv: cmrd + gbnj
bqtb: shmw + tmgj
bdnn: 2
nrfb: fvlz * mrmc
fsjg: mldq * fpzc
dstc: vrls + gtgj
vzgf: mscw / htvl
rvfq: 2
zbfg: wrmw + mjhp
plwh: 2
hnlp: 4
mfwr: 5
scbf: wblc * smlv
znqw: 2
rrpv: 4
rvtw: tfgt + jclc
bvqm: wqcg + vwhr
gqjd: 2
drgp: tqnq + hbrn
dgln: 3
wzvc: pmpv * wpjs
cwsr: 4
crvh: 8
grtz: 19
dngc: 16
hjrb: lzzr * qgmp
hcrl: flnm * mvbw
rvrp: 3
tdqd: 3
nldz: gvsd + bqjc
rgnl: 3
qzvg: 2
cvrb: 4
nvjd: 3
bfzn: ggbh * cmcc
pgbr: 5
ggqp: 7
dtfm: rtfj + dhcr
tpsw: cmbd + crbf
lvjg: ngdg - mlnd
cwml: 17
npwp: bwnn * cntc
wldp: 5
cfqb: cmtp / hfpq
rnls: 7
rjln: 2
scmg: frmh * hfdn
hdnz: dqnn + jlqz
cbfh: jfdg + nqtq
rcmd: 2
vmlm: tfzs + hfrd
jghc: gpqf + gfmf
bsws: bmqs * jdff
hjpl: qzvg * gmzp
rdpm: 5
dptv: 4
vrcc: ntqc * wgvd
rnqd: qjjl + zscr
rnnf: gpdz * frtp
dmvm: ghnj * tfmn
ttwv: 5
qsnz: crfn - cdvl
ndpt: nhmj * sttw
pvtg: 2
mfwc: trmr * pdgj
hfts: cjng + wggf
pfzz: nsfl * brbz
fqhp: 5
bvrg: 4
cnll: nbql * btlt
dncp: 1
vnbp: 3
fwlz: lchz + gtzt
wzgg: 14
cjpm: 3
hzvw: 4
tclf: 3
jsdd: cvgg * gbjd
zjsd: 1
smbh: 2
cpvp: qpzg * bpct
chwq: vltb + snzr
mfmf: 3
rsjv: hvhw * jrnm
fzsh: vwpg + gmmj
tzct: 3
vllr: tftd - ngsj
tzpb: mbdb + lwdq
wjfg: 4
zcqp: 8
vwgs: bcvp + lhwh
fpqh: 19
qhdj: hnbv * mlwt
gdgq: dqpm * bpbh
vmrq: 3
tvbj: 7
qqdf: mndd * chwq
zvpd: tjrb * tqzq
phjj: 2
jzjl: dpnb * wqbh
dmwq: vqnc * hngv
qrcf: gqvm * jghc
zgmv: 2
dldl: 4
bzdr: svfs - qzgs
hbrq: gdgf * vrgc
bcsq: vspz * jgfg
pqrs: rpph + mvcn
fvlz: 2
hzpq: tmlp * wldp
qtjf: 4
vbbv: rhrl + twgb
gzdj: vhzv + tbmc
bwfv: 4
jnnn: 4
rrvs: 5
snhp: 4
zqlf: plcd + hqhg
ptvb: 7
nbrf: bfhg + wlwl
rqwh: 2
zqrb: 3
hbrn: wqzm / msvm
twcq: 3
jlhd: fqpc + mpfn
vhzv: dwbz * jjrw
fqwt: dbcg - vwsm
wbmf: 4
bhmp: 2
pqhg: shwc + cftw
vqtq: 13
bdmd: btvt + stsm
zhgg: 3
mldd: 3
fjjb: 4
qlml: vqbz * cmls
rzlr: 5
mspf: vvtf * qshm
snzr: 13
fnbz: 3
nflf: 1
dslz: rsgm + zjdw
hngv: 2
qshm: 3
scgz: tcct * fzsh
lddc: 3
jbcl: nmsm - tbcn
pbjh: dftj * qfbm
zhpj: qtgr + llzj
wwzs: gwwg * jcjp
nzsr: bnss + pcnz
wfwm: dcfm * vzqv
cvds: tzms + tcmj
vmbd: 3
dcnp: 2
mwfq: twvg * crwd
sswf: 3
hspf: scgb + rtnq
zpds: 4
lcpt: 11
pmzf: vjgw * clbd
rvhd: vvmc * gzqn
hlps: 3
pvnp: 2
jnnc: 2
rzlf: 2
njjz: 5
jhnj: hpdm + cpmq
qhcb: cnpf + vrcc
cpzz: 2
jqpw: gjch * nprt
jnpd: hjlb + vhmn
sbfs: vhtd * hdps
gjfn: 12
vzzw: nhhm + nllc
rrfr: ghsf * rbvd
ttqg: 2
mmsv: 2
dcsn: hddw / thtz
zjdw: wjsn + zpvl
vzqv: 13
pwqw: 7
wlpp: nsvl * zqnt
cjbh: zpds * qzmm
pppc: 4
fnwf: llzr + bssc
bbmt: 5
bjnw: chch + dgml
tcmj: 15
svdh: rwhb + nlll
fvhd: 5
qfcj: 3
jzzc: plqw + pgtb
bdhm: lqnr * pvnp
mmzw: fghm + fsjg
sbhl: gvtg + bcsp
gtbg: znpf + crfb
rldz: 14
nsgn: ljwl * fzdq
mfgz: hnhz * dqlz
cbpq: 5
mqhs: hcrl * fcdj
npld: 3
bgnc: 2
rqch: mttp * jhhz
dnrr: tvql + thnf
flnm: bjgp + mnlg
swsg: zmvf * pngb
wlwl: jdhl * fpdn
ncwg: msfr / pvht
mjhp: wnwm * fqhp
jvzq: rjmn + cgtt
lzvn: 4
qwvh: sszf * dbzt
zmvf: ntmm * mlld
msvj: 8
tmgj: 10
nlrb: vwzg + stlr
wwdn: qmpt + vvng
mbgb: 13
jhqt: blvm * qtfs
jfdg: 8
plfl: zlml + mgrj
fqsv: vjfp - ttqg
pbtb: lvjg * nndz
grzz: 2
bvpb: 1
zdwl: gzdj - hvrd
gdhf: 2
qgwg: dfnp + swtb
tjrb: 5
htjr: nhcs * hvfz
sfgd: 13
cbhb: mdcr * nmwb
gfqj: 3
qzqf: rqbg / pchg
vbgp: bpgr + tslp
ssqq: 2
svld: hbln + mrzg
rsmd: hbpr + wmdh
psjf: bwfc * njqm
rpqf: 4
wmvp: sssf + jcvw
tgtw: nfzr * wjwj
gjjz: 6
bqcb: hvfr - zztn
rsgm: ttdh * tmrd
jmgt: 5
pqgn: thfl * frwc
hfrd: 4
cdtm: 2
qdbw: 3
zftm: 1
rttc: tllm + cpvp
ctqn: 1
cvvh: 3
tlrf: 7
qnml: 2
bznl: njtl * mfvw
rnfn: sgpn + wnrd
dclc: 10
znbw: 2
ncph: ccrc * bcmz
gwwg: czcg + mfgz
gpbs: lwjb + zscq
hjlr: 11
lmmw: vhqs + bmrd
tmrd: hcln * vqwb
lcnz: 2
cjng: qqvp + rttc
cvhb: 5
tjvv: 4
gpbw: cwsz + sldp
bfbt: tlrf + qhdj
qzzz: 5
ggsz: 5
ltzq: 6
jbnj: 4
hfpq: 2
hghs: 4
wgvl: mnjq - zzzl
qvmw: 2
cnvl: 2
cdgq: 3
pjqs: 3
zdtq: cqwh + cmvs
dnmr: hhdl + rlsq
cqmt: gdwp * bcps
zmcw: 17
zscr: 9
rpnt: 16
mwsb: qtdd + dctp
ghsf: 3
bzcp: jlrj + qlnl
hzdv: mjgg + mjdm
wqdj: scrq + mdbj
znff: 5
ppjh: mggm - tgtw
rnnn: hzls * wpth
hvrn: 4
rfsz: ndpt / qvlz
vspz: 10
sllf: nnvv * tsjv
wmbq: 2
nzbc: 3
qgrd: 12
ggtn: tgvr * jbcl
vlpl: 2
nbbl: 7
plsq: 3
zfjs: mqtn * vnpq
vrpr: fctc + gbvw
ljtq: 4
fhrl: 17
ctpd: lqwd / ttpl
tcvz: 4
mftf: 4
blmd: vmcs + psjf
jdjb: 1
nlmn: lmrw + sdtv
ggmf: vqhb / wnsc
zffd: 3
nqtq: tvqg * hvgp
wsmw: 10
dpnb: 10
cswg: 2
qttj: hqvd + vcsq
flrv: fcmf + ddfm
lplz: zvvp + rfgt
gbnj: qgrv * rlnh
zmff: 2
pzwp: cnbm * wrhq
hgjn: 5
qtrb: 3
fbtm: lpgn * bnvq
cmbh: 3
znhm: 4
nrnj: 6
dwml: snhp + qhvs
dqpq: 2
lmrw: 20
dswc: 17
mvfn: 2
pvrm: 5
wmvr: 3
tdjn: 3
cmlg: jpwb + cjbh
jdff: 5
bpfz: jnth * tlqt
hszt: 4
mcwm: 4
nfzr: cpzc / nwqw
lgqv: cpbd * bdln
gzlp: zjsd + sdtt
qsdr: szpv + ghlr
zmqv: 3
csfs: 2
tzhp: snwj * rmsp
wqvt: 3
qlqs: bbmt * vszp
rwqp: fwqw * dzfl
cgpt: lzln + bnbz
bcmd: lwhd + qlml
qfbm: 2
hmrp: 3
dlsq: 8
tvgs: wfvc * bfdm
nhzs: 4
pndl: 3
bqqp: lgqv + ldfg
dwhf: bljd * dcnp
rvnm: vqtq * dmmm
gcst: mtfh + swmh
mgsr: 8
nlpn: ggqp * bdtm
tdcf: pvtg + dswc
jppf: 2
mgwg: tbth + phdm
bnqf: 4
mcfn: pzmc * tmvz
tfcm: 3
nndz: 13
thtz: 2
dgml: 7
fwpz: rhbp / jpcq
tnnt: 3
hbln: pdwh * bdhj
ptbq: wzgg * vppt
mwmw: lchh - htjr
fbdq: 2
fpwb: nrvt - dcsn
hwvd: 11
shbc: crvh * mhlf
wwfw: 2
fqgj: 2
hflv: 17
rdcb: vzgq * ffrb
rppv: wjzc * lgbw
qnbt: ltzq + gpbs
tfgt: qrbr + prvm
wldb: vrfp + hzwh
wqzm: phqt - vbwr
pznm: pllg + hbrq
mhfp: hngp + wqst
sldp: 1
bhgm: tvzs * znbw
bbsc: 2
mhvr: vfvv + nwms
bqhl: pltw + rqfm
pjlv: sllf + rldw
jjtr: 3
ggsj: hspf / rtsp
ldrg: cwlt / nrzj
vppv: dstc + phsf
cjln: zhpj - phcg
clbd: mrrf + dbfv
dbcg: hvrn * rwht
jgrg: qndf + nrnj
rbbs: cbbv + hjlr
cnst: 9
gwmt: wqch + sllb
czcg: zsvb * qrjj
dlrb: bwwc * nhrd
nsfl: rrph * dtfm
zglz: 3
rpbn: hbnq + scgz
jszt: nvjj + bfjn
bwfc: pjsm * jqdh
sbjf: 7
gtvf: 3
pwff: 4
tddg: 13
lrnt: 2
cffd: 2
jghz: 16
wcgp: 4
bfdm: ngjt * nzbc
tqsj: sbhl * pzgm
mfvf: 2
mtsp: rpbc + znlh
fmqc: hhql * dclc
bslw: ncwg + qrlf
tflj: 8
lwhd: rzlr * tvbj
fths: mtjw * bdbg
nvjt: 2
qldd: qgrd * rngl
bmll: 2
vlls: 4
zzvf: jczm * nztr
wmgq: 7
dwfj: mvsb + tctc
szdp: 5
fhfz: wgmc * qsdr
bnfd: 4
gjvc: fhrl * hdlh
fnfg: dtnj + qjmj
qvnq: 19
zzpf: rqch * gvcm
mwmh: nvmv * nrdr
zscq: vmrq * bpqv
qnmb: 7
mtbt: 5
lpgn: 2
zjzr: 2
rvqz: crqf + bdbf
jccm: hjrb * rcfh
hddw: mspf + zqlf
vnbb: rzmb + plfp
znqd: 5
tgvw: 2
vcvj: zcqp + scwr
fvch: 2
lzvg: 3
bpmb: 6
shmw: hlps * nzsr
vghb: 4
qljj: qrvs + mwph
nmrc: zvgp * cpzz
cgrw: bdwf + dmwq
fjrf: 2
pmzr: 3
lplq: qvrb * znff
qvrt: nmwg + rnls
nvmv: jqpw / bhfp
wblc: 3
jgmj: qccf / sjgf
bsgj: 3
jjnw: 3
vvht: bgrl * dgpj
vhhd: dprf + qcqv
rswj: 7
mgdb: gdzm * rvrt
bdhj: nsgn + qqnd
cnjn: 3
qhwt: 4
rzhv: jlbj + dcbj
nrzc: lzng / dmrb
mrrt: 5
dhcr: 5
sjgf: 2
wlwd: prmb + gsfp
phpz: rbtq * zfzw
hthf: cmlg / wqjj
wbqt: hghs * qfls
hfvf: mdlm + snbf
tpdz: dlsq + tdws
rfbr: qnmb * mfmf
jpfz: tglm * mgtm
phdm: 5
nbpn: srhg + jnpd
cdpm: 3
gwgf: ccgs + qptq
nvtj: 4
nfwh: 4
fmrv: 9
rtgl: 2
mwjg: nlpn + gtlw
vjzj: 11
hwfc: 2
zfff: 4
gtmr: ggsj * qhfj
hczt: vwjg * tzhd
mtjw: 17
bhmn: cmpq + ghcn
hgzc: 9
fltr: zfnc * lrnt
vjsf: 17
ggdw: hfmn * hwfc
qfff: tpth * cvrt
mdrj: 3
qqsg: smhs + qljj
fzbm: rgdq + qgwg
ntmm: 7
hbcf: 3
bbjd: 11
mvbp: 2
dnbc: gcst * dvbh
qmzl: dwhf + swsg
vvwf: 4
hmpg: wlht + zlfb
wgsq: 2
rlsq: rhvf / fbdq
hvrc: gjft - bbhp
cvdf: 5
nmsm: qhwv + qlqs
bnss: 4
shwc: schs * ctqh
gmtp: rzqp * hvvb
dfwf: 9
whgp: 5
mfhn: tcqq - rrfr
vcrb: 3
pmpv: 5
mdbl: 5
qmpt: dstm + lwqz
vwhr: 4
vjmc: bnth + fvhd
qhvf: shnl / tczg
qdwd: 3
rflh: qqdh + snch
bjgm: 11
zmdm: njrr * ndtn
zbjh: tzrb * tmhj
wjcb: nhvm * nhqm
pwgq: 12
jpwb: 19
qmvz: clgh + bmml
dhbg: djqf * qswm
sjbs: blqt + cwml
znbc: 5
llzr: sntz * mhtd
sfvq: 2
bpsm: 1
zznh: 5
rdrg: 2
sfnb: 4
fglm: 2
hhdl: 14
pmwp: chbg * cshq
tfqz: wvbf - fztf
dvwg: 2
rhvf: gzfv * pcpp
trmr: 3
mgnc: 2
nmwg: 4
qvrb: djsz * pgbr
fpzc: 8
pzvn: zzpf / vlpw
hjrt: 15
nflm: jqln + zzbs
gcmz: 9
rngl: jbwl * tgnc
rhrl: mrrt * tqsj
sglf: 2
wgmz: 3
phqt: nqwf / bqrc
frrd: ndzm * cznd
pnpp: mwgc - znbc
cvrt: 2
lwrw: 3
nplt: wgsq + jsbf
hcjv: 2
wpfc: zjlr - hdnz
gtlw: lcfh * brjn
ghrr: 2
vtdt: jbtm / frqv
cspf: bwfv + jtrn
zqsf: wqcd * zgfn
wflj: 6
lqnr: vcgc + qhwh
snvq: 2
crfn: hnfc * hhgv
pqbm: sbjf + bvjv
gdgf: zjrs + rpnt
zfqb: dsrv * dvfb
phwt: qzbv - svmv
lwqz: pgdd * jjnw
hfhp: 19
hvsp: vzzw * vdvw
zmgc: tpsw + rvtw
cqlj: pmwp + lplq
rrqc: 3
cmcc: 3
bnbz: rrrt * wcrv
glfl: 2
dprf: 4
hrrj: qwsw * vggl
tmlp: bbnr - gdwt
mgmp: zpjw * ttzh
zftl: stqm + ptbq
jwzb: 9
wwvv: gghr + ddfh
flww: 3
sszf: 2
vggl: 3
nsjc: nrzc + vpjd
gtgj: mprq * lztj
gbjd: 2
prmj: 3
dmwg: twnj / bqzr
sdld: qmzl / ztdf
dtcp: 2
hbnq: fblv * qmtm
wcsf: 3
fcmf: ndtr + mgwg
tgnc: 3
qrnj: qjcm + lzmm
ccgb: hrlm + njvr
svvs: bmdr * mqss
trdv: 5
cpzc: vrpr + qbbb
bndt: 6
gpzc: 2
sdhc: nbrf + dptv
prhd: 2
rmpl: jdmt - fjgb
pcvm: 2
mzbj: 3
phdb: rdrg * hfhw
qpzh: 6
zhms: cvgp / mtrs
qpnc: 8
gfmf: 11
gmtg: fqsv + msvj
lnwb: 3
vcqw: cfnr * rcbm
bpqn: 2
sllb: 1
bdln: 2
mjgd: 2
ntqc: fwbf + sdhv
dwtm: 13
mrcp: cnll + hdcd
bglb: nlvc + hczt
fbzw: pwqw * srrv
mvbw: 3
bgrl: 11
lwqp: mgmp + mggc
mgtc: 10
vrcb: pbrg + tzpj
drrm: fzsj + jrsw
mbtq: jmjh + jlwt
twnj: gwcv + cvcr
cjtv: mzqf * zwpc
mjgw: 2
bdwf: 7
qjwp: 2
fjtm: 3
bpct: 2
thfl: 4
jjwj: 2
zpvh: vzgf - cspf
nstl: 2
hnpq: tfpc - cdtm
sccq: 20
bjgw: pwzj * lhqb
sjpz: hfhr / tltq
vnng: sglf * srnq
qggc: 3
szqh: 4
mwhs: jccm - cptf
hhmh: tgvw * sgfp
stqw: 5
nhjl: psww * cbpq
rrph: 3
jzwn: wbqt / jnnn
wcfg: 3
gpqf: htqs * rlvf
gmmb: 2
jnjf: zhgf + plwc
pgnc: 12
djqf: 2
nlvc: 9
dfjz: flrv * qtvm
bwwc: dvqm * rswj
wrsh: ztwc * wmjv
jgbj: 11
lqcb: 14
tlrn: swvw * wfdz
tdws: npwq - dhnl
mpfl: 10
rltm: 5
hmwc: qhvf * wqdj
tdbr: gqjd + rvqz
hjft: 2
vzvs: dprl * rflh
hzfz: gzmv * hnpv
mtrs: 2
jgww: lqbh * dhnd
cjfw: gdgq + qzzm
hrcs: 4
brng: 2
tczj: 5
sgfp: 4
wjds: 5
bhfp: 5
zlnj: wwvv / bfzn
pcdq: bttz - bvqm
njgv: nbbl * wflj
qfjf: 5
zfps: mwvm * wmbq
dwcz: lrvz - dhws
dprl: 3
dbqj: 2
lchz: 9
mttp: 19
zfzw: 5
fwmt: hfql * tgtl
vvng: 4
nllc: 9
cwlh: 3
tzhd: 11
dwbh: 2
mmpw: 8
gsqg: gpzc * qmgt
qjmj: sbfs * grrw
prhs: dhrp / jnnc
clgh: hfhp + znhm
shpg: ztgm / btgd
jzgq: dcqb - gcpc
tfzs: 3
cshq: 4
jcjp: 4
qrqf: 3
fjmg: vpnn * hplg
mgtm: 2
tjbm: 3
plvl: tclf * fjrf
mlld: 3
mhlf: dhfd + jnzb
jnsw: 7
cbdt: 6
nslw: blmd + tdqp
scrf: 20
qfcs: mjgd * qrsr
vchc: 3
tgvr: hcjv + szdp
tncg: lcnz * ssfj
fmvc: bwmf - mnhl
snwj: 4
ptvj: 2
qsld: 7
jnzb: 2
vmgv: 7
chvt: bcpv + wgnn
gmzp: 3
hjlb: crpf * zfqb
tdps: sjpz * ltqr
lzng: prhs * zjbq
ccrc: dqlm / csfs
tsbp: 5
blqt: dzhv * ldrg
wgjl: rttr * jmcl
glhn: rchh - lmtl
cmtp: zngs * mvbp
lrgw: pfjs + czgw
mfqp: dwml + jhqt
sphz: 2
trmm: 2
jldw: 3
dctp: njjz + bznl
zzps: wdmw * tcnd
mlwq: lmfq * sdhc
fswr: hgrr * bggv
hzls: 3
wlsb: mpfp + tjsq
vqhb: mqhs + lfgf
hnwf: 2
gdwt: tpnf * twjr
bnzm: 2
tbth: bbhs * qltq
cpmq: vmct * hpzn
hplg: 11
pdwh: 7
wlht: jzsg / bnfd
twfq: 2
njbs: bhwl + jzjl
mscw: lmtr * bdvz
wdlb: bzmf + crtd
bjzn: wlwd * jswg
zzbs: 3
vglp: 14
ltwc: bdmd + wprz
wprz: 6
mgzr: gsps * fdrw
tpbf: 5
dbmh: 3
qgmp: 3
fjlp: 20
twcp: 5
rnzv: cjpm * bjnw
cpvj: lvtr + cgpt
zqnq: 1
vzgq: 15
znpf: 2
tlhw: mzbj * scmg
nmwl: 2
spns: gmtg * jlhl
njtb: 3
qppj: 13
wpth: 9
hvvb: 3
bcps: fjtd + wrqm
vpds: lnqf * bmbp
czlh: 2
sjqz: ngqq + qpnc
mblq: 2
jjfp: dmjp * wtmf
qhwh: vmbd * pffl
jhdm: 5
lpqz: jdpg * zznh
hpzn: 16
lgbw: 9
ztfc: 9
djbs: wnrs + pfzz
hjtb: sjqz + shhr
jcrt: zmgc + ghwt
scrq: stst + bndt
chsm: cmbh * plfl
gbvw: tdvn + nflf
nssm: nbpn / tsbp
fqwp: 4
lfdt: ptvj * mftf
tcnd: 8
wnrd: dbmh * hjnp
bmbp: jppv + pztg
dtnj: cfbz + dmwg
qqzj: blff + shpg
pzcd: 15
phsf: fzbm * mvfw
plqw: 3
swqq: mjnd * nzfj
rptr: czlh * fpwb
bwsw: 2
cnvb: dfwr + jplc
nzlc: 3
qshf: 2
sttw: mmzw - vjsf
bmwt: 11
wqdn: rsjv + wfrs
stsm: 14
hdcd: 1
hfdn: 9
rpph: 2
ptlb: wqvt * tdjn
csps: 2
pzgm: ptvb + mjfn
pfjs: 6
rllg: nfwb * swps
bcmz: wdlb * vtgz
jlwt: ljsn - gmtp
qhtr: svnd * vsgw
rbvd: bggw + rztr
zlml: 5
wmjv: 2
wmhm: 2
nsnz: gdtp + qmvn
rztr: 4
bvws: bjgm + shlq
bfhg: 9
vfvv: wwzs * hgsj
zhgn: zdtq * qdwd
vwsm: 1
mjjd: 3
jqdh: 3
ggnd: brjh * rqwh
pmft: bznp / bmll
whtb: 7
mtfh: 5
mdlm: jldw * nvjd
bmdj: dfwf * gtfb
bspm: 17
tslp: 2
ndzm: 3
tfst: 2'

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