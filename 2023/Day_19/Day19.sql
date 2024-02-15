drop table if exists AOC_2023_Day19_Workflows
create table AOC_2023_Day19_Workflows(Workflow varchar(10),
										Ordinal bigint,
										Trgt varchar(10),
										x int,
										m int,
										a int,
										s int,
										Operator char(1))
GO
create or alter function fn_AOC_2023_Day19_GetNext(@Workflow varchar(10),
											@x int,
											@m int,
											@a int,
											@s int) returns table
as
return select top 1 Trgt
		from AOC_2023_Day19_Workflows w
		where w.Workflow = @Workflow
			and (Operator is null
				or (Operator = '<'
					and (@x < w.x
						or @m < w.m
						or @a < w.a
						or @s < w.s
						)
					)
				or (Operator = '>'
					and (@x > w.x
						or @m > w.m
						or @a > w.a
						or @s > w.s
						)
					)
				)
		order by w.ordinal
GO
declare @Input varchar(max) =
'tjt{s<421:R,m<858:R,R}
pn{m<2884:vzk,kv}
btq{x>3525:tmv,a>1758:rz,A}
blz{m<1251:A,A}
cq{s>2177:A,m<2653:xr,jhd}
ng{a>813:A,x>2371:A,s<2625:R,A}
vhb{x<870:A,x<956:R,x<992:R,A}
vgh{x>1126:A,m>3898:A,ktl}
lpl{x<241:mrx,npk}
sj{a<1405:R,x>749:nk,lrb}
lxb{x>2186:R,A}
hct{x>3522:R,a<3394:A,R}
hx{x>1130:A,R}
fb{s<3662:R,a>292:A,x<2915:A,R}
dd{s>2482:R,gpv}
bqp{x>2128:A,x<2009:R,s<1930:pvj,qx}
nn{m<463:R,x>1071:R,R}
fgk{s>1034:jzq,a>355:R,a<225:jzx,jsx}
vsx{s<1042:snp,m<3046:R,x<441:kl,A}
qcc{m<511:R,A}
xh{x<499:rn,jbt}
dc{a<3590:A,m<3779:A,R}
vr{a>3273:vb,x>2285:R,R}
bds{s<306:A,s>499:A,x<3062:A,A}
vjd{a>1008:dm,s>2534:xvk,a>402:ln,cs}
hts{m>2416:mt,m>2241:fn,fv}
zc{x>3475:A,m>2255:A,R}
qk{a>1936:R,m<3811:R,R}
txx{x>882:R,A}
ldj{a<1754:R,a>2649:R,x>2067:A,A}
jhd{x<2035:R,a>703:A,A}
vdp{x>324:A,x<146:R,A}
xz{m<1071:R,A}
ln{a<754:czt,a<875:R,m<651:js,R}
nlp{s>3695:xrj,x>3520:fr,s<3466:R,jmr}
bj{m>3673:R,x>767:R,R}
nb{m>3141:xtt,m<2506:xcc,cg}
fnq{m<1510:R,s<1712:A,s<1937:A,A}
gl{s<539:A,a<3836:A,R}
zlp{s>3294:A,x>874:R,A}
fsc{m>1216:A,R}
gjg{x>444:bdb,A}
xxt{a<2333:A,R}
qp{a<2914:A,R}
hrx{a>1154:R,R}
rjt{s<1369:jgx,m<3621:lc,jsv}
qhf{m>2169:R,m>2072:A,s>3461:A,A}
tx{a>1460:xm,x>2396:nh,x<2185:zhj,plc}
plc{s>1858:gp,tz}
zgl{x>1997:qcz,m<2077:bm,km}
svt{m>2677:mxg,a<1592:tm,qh}
vb{x<1656:A,x>2605:A,s>1065:R,R}
ddc{m>1102:A,A}
hv{x<582:pv,x<782:mh,x<935:R,A}
fx{a<398:A,a<628:R,A}
mt{a<1608:R,mrn}
dz{s>2542:sq,s<2394:ph,bxq}
qqb{x>3766:A,R}
px{m<994:A,A}
qlb{x<3607:A,m<2674:R,a<909:R,A}
mz{s>3811:R,x>3162:A,s<3637:A,R}
dj{m>837:A,m>493:R,R}
vd{m>3712:R,x>1536:R,a>2397:R,R}
hgq{s<2327:qs,x<3642:blz,cfz}
fqf{x>3166:A,R}
bqg{a<3089:pz,s>1067:R,m<3491:cz,R}
jj{x<876:A,A}
dbf{x>2283:R,R}
lc{a<1673:kvn,s>1698:gn,lrd}
sll{m<2418:A,a>2690:R,A}
jn{s>3300:A,s>2865:R,a<2377:R,R}
rmt{x>1029:R,a>1892:A,txx}
tb{a>2179:A,m<336:R,x>1273:R,R}
xmj{m>2340:fsl,x<3545:mfk,x>3768:mns,dtl}
bsq{m>754:R,m>413:A,A}
tl{x<2667:ppg,A}
qsp{m<2595:hvh,s<3649:R,s>3703:pkt,A}
qpr{m>1689:A,a<839:R,a>1009:A,R}
lhz{m<994:A,m>1143:A,R}
bnh{s>3147:vs,A}
fz{x<356:R,R}
lnz{x>3018:R,m<1045:A,R}
gh{m>482:A,x>1100:A,R}
nks{a>1858:A,m>243:R,x<2127:rpr,vkd}
jx{a>2810:fzb,R}
prp{x>1299:tjt,m<670:ddx,cr}
sgk{s>2056:cxr,m>3706:A,a<692:vcm,bj}
vjg{m>759:A,s>346:fqf,m>369:A,qq}
nbj{a>3394:A,nz}
lh{m>2524:pn,m>2280:mbg,ll}
sbf{s>1028:kxn,gd}
zrf{a>592:R,R}
jv{m<861:R,s>3550:R,R}
qg{x>1202:R,x<1117:ncr,a<1728:mfh,dgt}
hth{a>3474:R,A}
vrb{x<2884:R,m<1345:R,m>1634:R,R}
pc{s>1715:R,a<222:R,R}
zsj{m<2564:R,s>1964:rnk,zl}
lm{m>2198:R,m>2054:A,A}
jjt{m>1059:qd,xcb}
xgv{m<3861:A,s>3759:R,A}
qvj{s>2100:clf,bg}
ct{m<2821:A,R}
xm{m>2251:zsj,x>2394:mk,a<3040:bqp,df}
gdb{m<2361:pcn,ct}
psr{m<3379:A,a<1343:R,s>2860:R,R}
tc{m>1272:A,x<1039:md,lhz}
xxl{s>3601:qpr,s>3355:hnh,s<3240:A,R}
vnf{s<2572:A,m<2644:R,s>2645:A,A}
dxz{a>252:A,a<116:R,s<3838:R,R}
dbs{a>364:fns,s>2273:R,m<2302:gk,nx}
kgc{a>3320:hzt,x>2939:jx,s<3689:ms,fhz}
mxd{a>1547:gkl,x>3257:zh,a>611:mgp,nc}
gz{m<3730:A,R}
jg{s<3383:R,x>368:R,R}
qhl{m>3242:R,x<1109:A,a>2067:A,A}
mf{x<2058:R,A}
lv{x<2643:A,R}
gv{s>3910:zsf,R}
qgj{s>1303:gdb,a<1335:zkd,bsj}
vnk{s>3307:hmp,a>982:gb,s<3157:A,A}
pt{a>2908:A,s>2716:A,R}
bd{x>560:R,R}
cs{x<3526:R,R}
zq{s<2032:zfj,a<3301:bnh,vxz}
ppg{m>1031:A,a<2235:A,x>1671:A,R}
vg{m<1396:tpq,s<3801:tgx,a>3156:tq,rv}
db{x>3085:R,vq}
zqz{x>1179:R,s<3716:A,m<1413:R,R}
hmj{m>502:R,R}
xv{a>3405:R,m<2078:A,a>3335:R,R}
pr{x<1735:A,x<1798:A,m>2560:dt,A}
bsj{s>711:R,x>534:R,fqx}
mm{a<1003:tk,a<1264:R,R}
rfv{m<3548:gjg,s>2637:nxp,jp}
tdn{x>389:ht,m<3308:ft,dq}
jpm{s<238:A,R}
vq{x<2985:A,s>2381:A,m>3114:R,R}
fp{a<1734:dsq,a<2115:bkr,grk}
cls{s>2735:R,s>1889:R,R}
dm{x>3413:R,R}
lk{x>1667:qk,a<1962:kb,a>2237:vd,R}
zhj{m>2389:cq,a<817:rxr,zgl}
tpt{a<816:fx,s>3338:bdd,a<1152:R,A}
qzq{x>2078:hvj,fgk}
bmx{s<2549:R,x<1371:R,a>2370:R,A}
ps{m<3675:A,R}
hvh{x<1782:A,m<2172:R,A}
hbg{s>3071:A,R}
mfh{x<1154:A,x>1170:R,A}
snv{m<875:R,A}
rnk{x>2433:R,m<2710:R,R}
qx{a<2188:A,m<2110:A,R}
hp{m<3515:A,m>3557:A,R}
bjl{s>3846:R,A}
mqn{m>1440:R,xdf}
kj{s>465:A,A}
lrd{a<2245:A,x>1164:A,a>2433:A,R}
pkt{s<3726:R,x<1775:R,R}
fpp{s<3396:R,R}
zzr{a<3362:jrf,nm}
kcc{x<2914:bkc,m<3270:db,x<3026:fnt,phn}
cz{x<462:R,R}
hqt{x>83:R,s>585:R,A}
dk{x>1956:qrl,a>2615:A,R}
vj{s>286:R,s<144:A,nn}
zsf{s<3966:A,A}
kxn{s<1212:R,a>3263:A,R}
qbt{x>3615:A,s<295:R,a<436:A,R}
zkh{m<940:gj,x>3262:R,m>1437:ggs,vnn}
qhs{m<2086:A,zf}
bcr{x>3749:R,a<3037:A,A}
sx{m<3285:mgb,sfv}
ht{s>3015:R,s<2964:R,A}
fv{m<2086:A,a<1592:jj,s<3712:R,R}
qrl{a<2133:R,R}
fhz{a<2838:R,sf}
qsl{s>1107:tl,dxm}
dtl{m<2090:sg,A}
nk{x>1247:R,m>3578:A,A}
lnv{m>655:A,a>779:R,qm}
ktl{m>3829:R,x<733:R,s<2065:A,A}
qpk{a>689:A,m>3804:fz,x<406:dxz,R}
pvq{s<3169:cp,a<3568:psk,a<3839:dfn,hv}
xn{a>2674:lhp,s<2442:lqv,m<661:nck,qr}
bm{m>1977:A,A}
vvz{a>3595:gnm,A}
xnq{s>3370:lk,x<1662:vgs,x>1737:qmc,kz}
jdb{s<3625:R,a>2035:R,m<3572:fs,fh}
svv{s<3721:R,A}
tsp{a<3645:R,s<187:A,R}
vqb{s<3393:R,s>3497:A,R}
rhs{m<2149:A,a>3124:R,R}
crf{m<808:zgp,a>1617:rcp,m<1404:khj,tpt}
cbb{x<2260:R,s>2215:A,A}
kl{s>1705:A,m<3101:A,m>3117:R,R}
sg{m<1969:R,A}
mr{m<3104:gtb,x<740:jb,m>3548:znz,tt}
vgs{s<2697:R,a<1874:R,R}
ll{a>3520:qhs,x>591:vc,a<3205:kg,pg}
khj{x>1884:R,m>1045:fsc,vbb}
km{x<1946:R,R}
pbv{a>3212:A,R}
bc{m<678:kxt,x<3883:bcr,jv}
qkf{s>3282:jdb,m<3517:tdn,a<2262:gq,lnd}
gtb{s>3374:hts,x<947:hc,plx}
npl{x>632:A,R}
zgp{m>501:A,x>1884:A,A}
qq{s<173:R,s>264:A,R}
kgh{x<3627:A,m<797:R,a>617:qqb,A}
hmp{s<3601:A,s<3817:A,x<264:R,R}
jkd{x<3229:R,a<1551:R,s>539:R,R}
hmx{a<2979:A,R}
lx{s<3161:A,m>2319:R,m<2304:R,R}
fd{s>1204:vdp,A}
hvp{x>1719:qbg,a<3333:nnn,x>1628:dxr,bb}
sv{s<3604:A,a>3068:R,a<2721:R,A}
lhp{a<3538:xvl,gss}
zl{m>2704:R,R}
ctb{a>1176:A,A}
vhf{x<3088:A,s<3834:R,a>3560:R,R}
jp{a>865:xgn,m<3742:tp,rj}
ntr{x<2919:R,m>1236:R,R}
ds{s<519:R,s<878:A,s<1172:fcj,tlh}
vv{x<252:R,a<2541:R,m>3735:R,A}
gg{s>3328:R,A}
sxq{s<751:bzm,a<2688:qsl,csc}
szk{s<2549:R,s>2614:A,a>2001:R,A}
hf{x<3805:xd,x>3921:R,vrf}
ddx{m>287:R,R}
hg{a<3498:R,m<1783:A,x>3275:A,A}
dq{s>3044:A,a>2039:A,x>144:A,A}
rxr{s<2105:mf,s<2899:R,qhf}
nr{a>1144:lgd,x>719:sxb,vgp}
zlc{m>509:R,hct}
dx{m<1025:hmj,a<1400:bds,s<347:khk,kj}
phn{m<3669:R,mll}
trj{s>1845:R,a<2260:R,R}
dlq{x>1984:A,a<251:A,R}
zkd{x>349:R,x>191:dnq,m<2574:A,hqt}
bkc{s>1996:A,a<1391:A,s>1219:R,fpq}
bq{m>3698:R,A}
gxm{m<438:A,blq}
kxt{a>3248:R,s<3556:R,a<2744:R,R}
qlv{x<1354:A,A}
shq{a>926:lv,x<3143:dtk,lnv}
qgk{x<1658:R,x<1692:R,A}
rq{a<1045:A,a<1256:R,R}
lnx{m>607:A,x<2899:R,A}
ft{s>3044:A,x>232:R,s>2971:R,R}
bg{m>1166:fnq,ldc}
ljj{m<3829:R,R}
mkc{s>3828:A,R}
fpq{m<3563:A,a<2319:R,A}
sf{m>620:R,x<2753:A,R}
pnr{m>3713:tn,gqz}
tj{a<1737:R,s<3703:R,x>1093:A,R}
tm{x<1528:R,A}
hbs{s<3431:R,a>3711:A,R}
ql{m>2548:R,s<3880:A,A}
xdz{a<3296:R,m>3507:A,s>3467:A,R}
nq{a>1904:qxl,ch}
nh{a<756:dbs,s<1486:mm,qt}
ncr{x>1054:R,x<1031:R,m>2717:R,R}
xdf{a<966:A,s<2678:A,x>207:R,R}
vkd{s<3723:R,s<3777:A,A}
qr{s>3234:zqz,x<1219:A,m>1136:rfb,hl}
sq{s>2676:A,a<810:A,m>2571:A,A}
hl{a>2312:A,x>1386:R,R}
qt{x<2687:qzj,m>2371:A,x>2952:rq,R}
gqz{m<3658:R,x<1571:A,R}
zvr{a<1449:A,a<1537:R,a>1559:R,A}
gss{m<946:R,R}
rlf{s<3122:zj,x<2623:kf,a<2439:mxd,bp}
kd{s<860:jjt,qzq}
frg{m<721:R,s<495:jpm,s<594:R,hth}
jc{x>3005:kqz,fb}
ttx{m>1178:R,a>3549:A,s>3699:R,R}
ks{x>3192:qdl,m<2843:tx,jm}
rcc{m<135:bd,s>2351:plk,tbs}
gc{x>1252:R,x<1124:R,vnf}
tbs{s>1831:A,m<183:R,x>626:R,A}
bdd{a>1139:R,A}
rbb{a>2469:svv,R}
mc{x<161:bvc,m<386:A,m<743:znm,snv}
gn{s>2004:R,x>791:A,m>3451:trj,zp}
bkr{m<3830:A,m>3911:R,R}
mrn{a<1992:R,a>2373:A,a<2163:R,A}
kxj{a<2179:A,m<592:A,A}
xcb{a<346:R,x<2443:A,x>3253:qbt,A}
ns{m>3727:A,m>3650:A,x>267:hbg,A}
jbk{m>2388:R,x>502:lx,bts}
zf{a<3796:R,m<2198:A,a>3900:R,R}
rl{a>1132:A,a<412:pc,a>747:tr,R}
plx{s>2748:svt,a<1262:dz,a<2131:gc,ftq}
fth{s>3415:A,x>3229:A,m>837:A,A}
qh{x>1311:A,R}
cfz{x<3876:A,m<1394:R,A}
zj{x<3033:qvj,a<2496:vjd,sz}
tkp{m>1232:zvr,a<1388:vj,gxm}
jgt{m>536:A,R}
jgx{s>740:sj,lg}
rr{s<1225:A,x>943:R,a<1252:R,R}
nz{x>1618:A,s<3666:A,m>2719:R,R}
pcn{x<342:R,s>1843:A,A}
tk{a>857:R,s>708:A,s>398:R,A}
rpn{a<3305:fth,x<3457:fpp,R}
fns{x>2771:A,R}
bb{m>3739:A,zkv}
zkv{m<3489:R,a>3597:R,x>1601:A,A}
lnd{a>2476:vv,qnc}
nft{a<3516:R,x>1811:R,A}
mll{s<1685:A,A}
xb{s<1337:ds,s<2861:ghx,vbg}
sgp{a<1631:mv,lcf}
rbh{s>275:A,s<173:R,x>3194:R,R}
rk{x<359:mqn,m<1432:jq,zr}
ldc{x>2015:R,a<2608:R,R}
rx{m>3449:A,x>1235:A,R}
gb{m<3258:A,a<1246:R,R}
kb{m<3770:R,R}
tgx{x>3342:R,s<3664:R,A}
xg{s<2660:A,x>939:R,A}
vt{x<2340:prp,lf}
clf{s<2555:ttq,a<1704:A,s>2807:gtx,dbf}
bl{x<395:mc,m>560:bz,m>209:rm,rcc}
tv{a>3024:nqp,s<3413:A,a>2798:R,sll}
zfj{m<2880:R,m>3308:zk,m>3029:A,A}
cnd{m>1268:R,a<2716:R,m<1141:A,R}
bnb{a<3079:xh,pvq}
cr{a>972:R,A}
gj{x>3483:A,m<417:R,x>2977:A,A}
dxr{x>1672:R,R}
tn{m>3866:A,s<3107:A,A}
fqv{x>635:R,x>537:R,R}
tt{s>3362:sgp,sx}
gpv{x>1132:R,A}
gtx{x<2263:A,x<2606:A,R}
jzq{m>923:A,s<1232:A,s<1307:R,A}
csc{m<846:vr,sbf}
bnl{a>1592:sxq,a<587:kd,s>673:ccz,rb}
vc{s<3106:A,m<2054:A,m<2146:R,A}
hh{a<3653:vrb,s<403:vhc,gl}
xbt{a>3730:R,s<3499:R,x>757:R,R}
hnh{a>951:R,x<2772:A,s<3460:A,A}
lmz{m>1632:R,A}
snp{m<3008:R,a>3166:A,A}
lcf{m<3345:qhl,rx}
ch{x>770:jfx,m<1079:bl,rk}
xvl{x>1269:R,s<2919:R,s>3313:R,R}
mp{x<1027:R,a>1993:bq,A}
kqd{a<3553:A,x>1491:A,m<3290:R,R}
jsx{a>281:A,R}
rpd{a>242:A,A}
rjh{m<2862:A,a>3060:R,R}
rg{m<3849:A,s>1590:hq,R}
mfk{m<2148:A,x>3408:zc,R}
st{x<3546:R,a<3778:A,qlf}
ftq{m<2410:bmx,x<1478:cc,R}
lt{a>3327:R,x<632:vkc,s<1431:skh,qp}
qb{s>3719:R,m>2287:R,R}
qdl{m>3083:xb,xmj}
gpk{x>164:A,a>3716:A,R}
xgn{s<2433:R,s<2503:R,R}
bsd{x>3244:A,a>1518:A,s<240:R,R}
frr{m>1227:R,s>1077:A,A}
zk{s>1157:R,A}
jbt{x<788:A,a>2772:A,A}
rv{s<3917:bjl,xlq}
vnn{m<1170:A,A}
nc{x<2861:kk,m<797:jc,mht}
sfv{x>1230:psr,xg}
vsn{a>3227:A,a<2959:R,a<3095:R,A}
khk{m>1512:A,x>3003:R,s<191:R,R}
rn{a>2760:R,a>2685:A,R}
jzx{m<1200:A,R}
vcz{s>1081:A,m<2683:A,s<526:mx,td}
xlq{s>3969:R,a<2883:R,m<1695:A,A}
qcz{x<2078:A,A}
cb{x<470:gz,m>3778:qxh,a<983:fqv,R}
vgp{x<418:frr,m<1057:sc,A}
dxm{s>963:A,a>2021:mpj,R}
znm{a>1088:R,R}
cd{a<3298:A,m>2726:R,a>3599:R,A}
rm{a<946:A,m<378:R,A}
jb{s<2872:rfv,a<1688:dlk,qkf}
tpq{s>3763:A,a<3073:cnd,s<3644:A,ttx}
pq{a<1250:R,A}
gkl{a<1946:btq,a>2250:nqn,m>956:gmb,zs}
jsv{s<1865:rg,m>3758:vgh,a<1555:sgk,mp}
mv{s<3613:A,x>1133:cx,A}
mgp{a>1171:ntr,x>3038:xz,m>1255:xxl,zz}
fgs{s<3470:pr,x<1668:nbj,s>3751:vnh,qsp}
kz{a>1899:R,A}
qbg{s<1443:R,a>3515:A,pt}
jm{x<2632:gvb,kcc}
qxl{x<833:qrf,xn}
sc{a<774:A,x<538:R,A}
blq{x<1591:R,a<1517:A,A}
zr{a>997:A,m>1741:R,lmz}
zt{s<212:A,R}
czt{m<1048:R,R}
mht{m<1519:rpd,s<3483:A,lvp}
zbq{a>2959:R,x<2796:R,R}
fvg{x<1054:gg,ps}
pvj{s>762:A,x<2058:R,R}
skv{x>303:A,m<1222:dp,a<2430:R,A}
vbb{a<577:R,a<1073:R,m>904:R,R}
ph{a>597:R,s>2332:A,A}
mb{s>3687:snz,x<3662:jgt,s<3584:bc,rqx}
mxg{s<3157:A,s<3246:A,s<3324:R,R}
znz{a<1063:jxk,x<1435:hxf,xnq}
df{a>3410:pk,x>2036:R,zm}
zs{a>2098:kxj,m>416:rc,rrt}
td{x<1619:R,a<1141:A,x>1769:R,A}
dgt{m<2569:R,m<2884:A,s<815:R,R}
vcm{s<1944:A,a<317:R,R}
vbg{m<3690:qhc,xxt}
vs{x<1249:A,s>3443:A,s>3317:R,R}
ccz{x<1743:nr,shq}
fr{m>416:R,x<3686:A,m<249:R,A}
bdb{a<1316:A,R}
rfb{s>2777:R,m>1529:R,a>2216:A,A}
nck{x>1220:A,m>360:jn,R}
dsq{s>3244:A,a<1311:R,a<1534:R,A}
qrf{a<2715:skv,fdk}
hq{s<1695:A,A}
xnc{m>1175:A,s<3693:ldj,x>2143:cnv,A}
qnc{x>254:A,R}
mpj{m<923:A,A}
dtk{x>2279:R,R}
qhc{s>3289:A,a>2521:A,s>3046:R,A}
mrx{s>2922:R,a>1296:A,R}
xt{x>1034:sqq,s<2245:nb,m>3279:bnb,lh}
tlh{a>2441:A,x>3502:A,A}
vkc{m<2389:R,s<838:A,R}
jrf{m>2378:rjh,lm}
tz{s<1103:R,s<1546:zg,zqd}
lf{a>991:rbh,m<1007:R,A}
scg{x<288:A,a<2867:R,x>456:R,A}
zp{a<2075:R,a<2344:A,m<3366:A,R}
fvs{m<3396:A,a>743:R,R}
cnv{a>2244:R,s>3771:A,s<3731:R,A}
npk{s<2848:R,A}
vnh{x>1769:nft,m>2654:A,m<2371:rhs,ql}
mk{m<2094:zbq,R}
kg{m<2126:scg,hmx}
vz{s>396:jkd,m<848:A,bsd}
rrt{s>3534:A,a<2047:R,a>2076:R,A}
nnn{m<3633:A,a>2882:ljj,m>3833:R,qgk}
cfb{s>449:R,tsp}
bvc{m<424:A,a>1241:A,a>502:R,A}
qlf{x>3848:A,m<1570:R,a<3855:A,R}
snz{m>622:A,m>253:R,vsn}
lg{m>3549:ctb,s<397:zt,R}
hvj{s<1094:A,lnz}
vm{s>3321:rpn,zkh}
xd{s>382:R,x>3636:A,s>248:A,A}
qmc{a>2003:R,R}
rcp{x>1894:vqb,a<3205:R,hbs}
grk{m<3723:R,s<3188:R,A}
xtt{a<3359:bqg,vvz}
qrm{s>3415:A,R}
gd{m>1233:A,x<2420:R,a<3384:A,A}
rpr{m>134:A,m>85:R,R}
fcj{s<1040:A,A}
kf{s>3600:gmm,crf}
dh{x<1458:qg,vcz}
vhc{m<1441:R,R}
dlk{m<3550:vnk,s<3253:ns,s<3619:cb,qpk}
ms{x>2795:qcc,A}
xvk{m>825:A,s<2904:sfq,R}
ghx{m>3617:A,s<2307:A,m<3433:R,hp}
kqz{s<3515:A,s<3683:A,a<373:A,R}
js{s<1867:A,a<944:A,A}
hzt{x<2981:A,a<3743:mz,A}
rj{x<394:R,A}
bxq{m<2516:R,x>1257:A,A}
skh{m<2320:A,R}
kvn{x>1223:fvs,s<1861:A,a>944:A,R}
sp{s>3139:R,A}
fs{a>1908:A,s>3771:R,R}
mx{m<2933:A,A}
rqx{s<3624:sv,R}
gvb{a>2099:cbb,m>3240:rl,lxb}
pk{a>3721:A,m>2085:R,R}
in{m>1908:zd,xj}
gk{a<203:R,s<1291:A,A}
rc{s>3557:A,A}
zm{m>2088:A,s>2070:A,s<1076:A,R}
fn{m>2347:A,qb}
jcv{m>3599:A,x>1350:A,m>3575:A,R}
mh{a<3920:R,x>657:R,x>620:A,A}
zg{m<2228:A,A}
fdk{m<1255:A,cls}
nqn{s>3426:px,ddc}
vzk{m<2674:pbv,R}
gmb{s>3693:mkc,a>2114:th,a>2036:R,R}
qdx{s<3509:tfm,m>1437:A,s>3765:A,A}
tfm{x>3620:R,x>3474:R,R}
fzb{x>3167:A,A}
xcc{m>2208:lt,x>597:vhb,fd}
bp{s<3507:vm,m>1018:vg,x>3419:mb,kgc}
bts{s>3241:R,x<313:A,a<3709:A,R}
zqq{m<2799:A,a<1129:R,s<2654:R,A}
pg{s<3014:xv,x<264:R,A}
cx{m<3390:R,x<1569:R,x<1704:R,A}
kp{s>3356:A,R}
kk{x<2759:dj,m>1236:R,bsq}
gnm{m<3634:R,s<778:R,A}
rb{a<1231:vt,x>2612:rxp,tkp}
sfq{m<482:A,A}
mpq{s>3642:R,s>3564:R,m>3713:A,R}
ggs{a>3083:A,R}
rz{a<1824:R,A}
qzj{a>1057:A,a<865:A,R}
zqd{x>2291:R,R}
nx{a>209:R,R}
jfx{m<795:gh,tc}
xr{s<1204:R,A}
jq{s<2305:fmx,m>1240:R,m>1155:R,A}
cg{m>2865:vsx,mbm}
tmc{m<3261:vl,rjt}
fmx{s<1877:R,s<2044:R,R}
tq{s<3868:vhf,m<1604:A,s<3954:hg,A}
ttq{m>831:R,A}
gmm{s>3818:gv,m>724:xnc,m<412:nks,rbb}
mbm{s<755:cd,s<1467:A,A}
hqv{s<1551:R,R}
pz{x>614:R,x<313:A,A}
vl{x<1000:qgj,dh}
kv{s<2925:A,m<3109:jg,x>589:kp,A}
nzx{s<2975:A,a>1918:R,s>3047:A,R}
rtx{s>3393:xgv,hx}
kt{x<493:A,R}
fqx{m<2698:A,x>280:A,s>261:A,R}
sxb{a>851:R,a<763:A,a>814:A,qlv}
th{s<3462:R,m>1300:A,R}
cp{a<3491:A,m<3630:A,a<3753:dc,kt}
qd{s<462:A,s>596:dlq,s<514:A,A}
dnq{a<619:R,A}
vrf{m<832:R,x<3864:A,m<1232:R,R}
nqp{s<3390:R,x<638:R,R}
sz{m<916:zlc,a>3338:st,hgq}
qxh{s>3465:A,x<581:A,x>685:R,A}
cxr{s>2134:R,m<3676:R,R}
dfn{x>464:xbt,m<3652:A,gpk}
bz{s>2613:A,npl}
rxp{a>1468:vz,a<1313:vjg,x>3459:hf,dx}
tp{a>501:A,s<2404:A,A}
djj{m>2363:zqq,s<2638:A,R}
qs{a>2876:R,A}
dt{x<1825:R,s<2978:A,a<3128:A,A}
zd{x>1846:ks,a>2593:xt,s>2220:mr,tmc}
nxp{x>451:R,A}
zz{a>832:qrm,lnx}
hc{x<589:lpl,djj}
md{m>994:R,a<901:A,m<864:R,A}
hxf{s<2974:dd,s<3412:fp,m<3807:jt,rmt}
lvp{m<1760:R,A}
lrb{s>982:R,m<3511:A,m>3731:A,R}
xj{s<1372:bnl,x<1496:nq,rlf}
cc{s<2457:R,m>2782:A,R}
gp{s>3008:A,x>2320:ng,zrf}
gq{s>3138:R,a>2036:A,m>3755:nzx,R}
jt{m<3637:tj,x<1151:R,a>1926:mpq,R}
mns{m>2063:A,R}
jxk{x>1423:pnr,m>3731:rtx,m<3625:kxm,fvg}
qm{m<293:R,a<662:R,x<3520:A,A}
fnt{m>3590:hqv,A}
bzm{a<3161:dk,x<2018:frg,m<931:cfb,hh}
psk{m>3644:R,xdz}
dp{m>722:A,m<254:R,x>144:R,A}
tmv{a>1725:R,a>1636:R,A}
mgb{m>3218:hrx,a<1434:cj,s>2727:sp,szk}
kxm{x<996:zlp,x>1252:jcv,x>1126:A,R}
zh{m>1012:qdx,m>658:kgh,nlp}
lgd{a>1440:R,s>1098:rr,pq}
jmr{s>3574:R,s>3521:A,a>997:R,A}
lqv{m<984:tb,R}
xrj{x>3743:R,A}
sqq{x<1560:zq,m>3274:hvp,s>2447:fgs,zzr}
tr{s>2047:A,m>3516:A,x>2251:A,R}
vxz{x<1363:R,kqd}
mbg{a<3311:tv,jbk}
plk{a>971:R,R}
cj{m>3143:R,A}
fh{m>3798:R,s>3768:R,A}
fsl{a>1382:A,qlb}
nm{m<2569:A,R}
pv{a<3901:A,A}

{x=653,m=2123,a=2908,s=577}
{x=716,m=172,a=813,s=2294}
{x=417,m=2371,a=1280,s=962}
{x=1465,m=1705,a=1990,s=994}
{x=2864,m=2720,a=2250,s=94}
{x=667,m=1887,a=29,s=368}
{x=909,m=1113,a=1133,s=309}
{x=1709,m=1903,a=349,s=1399}
{x=217,m=858,a=140,s=762}
{x=49,m=57,a=22,s=74}
{x=104,m=2238,a=445,s=148}
{x=992,m=317,a=2051,s=1054}
{x=2280,m=513,a=60,s=649}
{x=703,m=2595,a=350,s=50}
{x=67,m=622,a=266,s=1573}
{x=1610,m=418,a=156,s=1751}
{x=597,m=1377,a=564,s=386}
{x=151,m=85,a=2961,s=1226}
{x=1086,m=2255,a=705,s=651}
{x=157,m=719,a=368,s=1381}
{x=283,m=1416,a=662,s=201}
{x=1749,m=89,a=211,s=1525}
{x=133,m=17,a=105,s=1602}
{x=1323,m=2909,a=302,s=21}
{x=188,m=308,a=1025,s=795}
{x=1945,m=69,a=32,s=568}
{x=3019,m=1357,a=2218,s=618}
{x=949,m=837,a=16,s=1019}
{x=454,m=55,a=1604,s=304}
{x=315,m=108,a=1116,s=17}
{x=1034,m=888,a=1699,s=632}
{x=3,m=616,a=2316,s=338}
{x=208,m=95,a=1263,s=1580}
{x=294,m=1270,a=2738,s=288}
{x=64,m=247,a=253,s=386}
{x=9,m=631,a=908,s=1226}
{x=1188,m=172,a=121,s=1148}
{x=610,m=65,a=913,s=2053}
{x=1567,m=461,a=2775,s=147}
{x=330,m=3786,a=108,s=948}
{x=778,m=1962,a=418,s=2863}
{x=31,m=888,a=1748,s=2452}
{x=2099,m=784,a=401,s=540}
{x=526,m=1971,a=2175,s=1614}
{x=83,m=1704,a=1814,s=11}
{x=3004,m=692,a=1596,s=934}
{x=210,m=3170,a=2656,s=791}
{x=1393,m=284,a=1697,s=144}
{x=66,m=302,a=1099,s=257}
{x=3224,m=867,a=747,s=2028}
{x=1664,m=136,a=750,s=433}
{x=257,m=934,a=1979,s=502}
{x=1477,m=2175,a=713,s=539}
{x=1579,m=2499,a=731,s=2714}
{x=1088,m=1224,a=29,s=1016}
{x=2851,m=593,a=423,s=92}
{x=735,m=968,a=1797,s=1930}
{x=2093,m=1750,a=640,s=113}
{x=913,m=1935,a=755,s=944}
{x=39,m=3312,a=1625,s=2902}
{x=1970,m=1790,a=1015,s=262}
{x=1530,m=177,a=513,s=1271}
{x=1723,m=2294,a=810,s=269}
{x=3074,m=1687,a=1536,s=1460}
{x=931,m=1410,a=181,s=504}
{x=31,m=48,a=756,s=597}
{x=2122,m=51,a=243,s=45}
{x=1819,m=2167,a=1980,s=2367}
{x=362,m=34,a=970,s=739}
{x=58,m=356,a=1237,s=792}
{x=151,m=791,a=1301,s=128}
{x=234,m=1612,a=732,s=724}
{x=880,m=1064,a=2516,s=517}
{x=2439,m=2327,a=1240,s=49}
{x=44,m=424,a=265,s=41}
{x=2197,m=1459,a=434,s=684}
{x=2438,m=1031,a=2381,s=137}
{x=715,m=2707,a=21,s=1413}
{x=138,m=422,a=107,s=851}
{x=571,m=612,a=3453,s=509}
{x=53,m=972,a=3387,s=87}
{x=100,m=1043,a=170,s=807}
{x=2073,m=241,a=1203,s=987}
{x=498,m=1015,a=566,s=1516}
{x=2088,m=91,a=1818,s=2569}
{x=1,m=2829,a=583,s=96}
{x=716,m=34,a=221,s=1568}
{x=467,m=373,a=957,s=12}
{x=3060,m=998,a=495,s=1261}
{x=1641,m=864,a=567,s=724}
{x=310,m=12,a=522,s=325}
{x=1719,m=1436,a=136,s=1801}
{x=715,m=1518,a=301,s=2449}
{x=3087,m=2379,a=2336,s=283}
{x=611,m=2457,a=237,s=833}
{x=1276,m=629,a=647,s=1357}
{x=45,m=96,a=280,s=3606}
{x=2449,m=685,a=147,s=2275}
{x=957,m=1008,a=395,s=1066}
{x=512,m=2032,a=876,s=2495}
{x=13,m=376,a=209,s=543}
{x=164,m=1368,a=1942,s=2209}
{x=1170,m=1887,a=96,s=556}
{x=37,m=1989,a=873,s=1150}
{x=205,m=1001,a=250,s=465}
{x=253,m=922,a=2099,s=1045}
{x=2653,m=1301,a=106,s=2071}
{x=1671,m=189,a=60,s=1399}
{x=1037,m=778,a=2274,s=627}
{x=370,m=226,a=2577,s=1976}
{x=1136,m=1548,a=665,s=273}
{x=9,m=297,a=1347,s=624}
{x=1950,m=973,a=3265,s=36}
{x=403,m=2917,a=678,s=1115}
{x=761,m=326,a=1344,s=2437}
{x=986,m=57,a=910,s=2503}
{x=655,m=1023,a=103,s=1116}
{x=1177,m=154,a=588,s=764}
{x=1614,m=3095,a=386,s=28}
{x=885,m=554,a=1505,s=752}
{x=4,m=94,a=1467,s=307}
{x=903,m=1937,a=372,s=1197}
{x=1354,m=366,a=853,s=3003}
{x=334,m=1998,a=653,s=2571}
{x=2104,m=2863,a=704,s=2427}
{x=10,m=426,a=92,s=6}
{x=758,m=1006,a=2284,s=2275}
{x=543,m=2193,a=171,s=2384}
{x=184,m=34,a=3133,s=42}
{x=2069,m=498,a=409,s=2148}
{x=266,m=1811,a=2888,s=1243}
{x=304,m=1626,a=1465,s=1352}
{x=146,m=2885,a=805,s=300}
{x=1136,m=672,a=1532,s=1319}
{x=65,m=5,a=334,s=2949}
{x=598,m=3629,a=843,s=258}
{x=882,m=155,a=1547,s=727}
{x=94,m=1054,a=940,s=1200}
{x=3184,m=393,a=2129,s=146}
{x=1022,m=2,a=1420,s=8}
{x=887,m=1093,a=1568,s=2510}
{x=580,m=2140,a=226,s=2581}
{x=1273,m=1454,a=799,s=621}
{x=231,m=952,a=569,s=453}
{x=1765,m=1013,a=1154,s=90}
{x=718,m=241,a=266,s=280}
{x=51,m=2166,a=760,s=40}
{x=962,m=967,a=574,s=40}
{x=1198,m=1260,a=1163,s=31}
{x=629,m=2546,a=262,s=123}
{x=662,m=94,a=1095,s=817}
{x=117,m=674,a=366,s=337}
{x=5,m=1324,a=915,s=315}
{x=2380,m=975,a=2390,s=1736}
{x=939,m=3955,a=656,s=1483}
{x=2678,m=315,a=968,s=105}
{x=549,m=1294,a=1915,s=1389}
{x=354,m=748,a=41,s=2723}
{x=699,m=648,a=347,s=82}
{x=645,m=26,a=174,s=734}
{x=3129,m=1205,a=85,s=1282}
{x=676,m=1450,a=243,s=551}
{x=185,m=745,a=237,s=1204}
{x=1426,m=654,a=2556,s=2850}
{x=517,m=1666,a=56,s=967}
{x=2336,m=444,a=8,s=1924}
{x=335,m=531,a=1601,s=111}
{x=867,m=3714,a=1654,s=339}
{x=2647,m=1651,a=3014,s=690}
{x=1466,m=381,a=691,s=2321}
{x=1994,m=200,a=2717,s=871}
{x=677,m=110,a=173,s=814}
{x=216,m=469,a=679,s=2511}
{x=343,m=236,a=674,s=798}
{x=2087,m=102,a=570,s=1988}
{x=465,m=1032,a=1562,s=3001}
{x=2396,m=979,a=507,s=543}
{x=40,m=185,a=269,s=169}
{x=39,m=103,a=586,s=1223}
{x=433,m=51,a=2600,s=413}
{x=553,m=975,a=141,s=82}
{x=23,m=55,a=2416,s=419}
{x=1925,m=3478,a=2,s=256}
{x=1083,m=434,a=3094,s=1865}
{x=2112,m=796,a=1106,s=1006}
{x=2300,m=602,a=1575,s=1639}
{x=724,m=7,a=1448,s=868}
{x=1531,m=155,a=345,s=1354}
{x=3454,m=494,a=1290,s=303}
{x=1466,m=1085,a=876,s=1313}
{x=1481,m=8,a=935,s=1313}
{x=703,m=1294,a=1,s=748}
{x=72,m=828,a=6,s=708}
{x=603,m=2090,a=1134,s=134}
{x=696,m=884,a=41,s=684}
{x=2768,m=436,a=294,s=203}
{x=2621,m=610,a=1095,s=1719}
{x=1155,m=3187,a=1420,s=694}
{x=5,m=2757,a=101,s=114}
{x=95,m=3009,a=1070,s=786}'


drop table if exists #Components
drop table if exists #Ranges

insert into AOC_2023_Day19_Workflows
select Workflow, i3.ordinal, substring(i3.[value], ind2 + 1, len(i3.[value])) Trgt
	, iif(Rating = 'x', Val, null) x
	, iif(Rating = 'm', Val, null) m
	, iif(Rating = 'a', Val, null) a
	, iif(Rating = 's', Val, null) s
	, case when ind3 > 0 then '<'
			when ind4 > 0 then '>'
		end Operator
from string_split(replace(left(@Input, charindex(char(10)+char(13), @Input, 1) - 1), char(10), ''), char(13), 1) i
	cross apply (select charindex('{', i.[value], 1) ind1) i1
	cross apply (select left(i.[value], ind1 - 1) Workflow) i2
	cross apply string_split(substring(i.[value], ind1 + 1, len(i.[value]) - 2 - len(Workflow)), ',', 1) i3
	cross apply (select charindex(':', i3.[value], 1) ind2
						, nullif(charindex('<', i3.[value], 1), 0) ind3
						, nullif(charindex('>', i3.[value], 1), 0) ind4) i4
	cross apply (select iif(ind2 > 0, left(i3.[value], ind2 - 1), null) Condition) i5
	cross apply (select left(Condition, isnull(Ind3, Ind4) - 1) Rating
					, cast(substring(Condition, isnull(Ind3, Ind4) + 1, len(Condition)) as int) Val
				) i6
where i.[value] != ''
option (maxdop 1)

select ordinal, cast(trim('x=' from parsename(Comp, 4)) as int) x, cast(trim('m=' from parsename(Comp, 3)) as int) m, cast(trim('a=' from parsename(Comp, 2)) as int) a, cast(trim('s=' from parsename(Comp, 1)) as int) s
into #Components
from string_split(replace(substring(@Input, charindex(char(10)+char(13), @Input, 1) + 3, len(@Input)), char(10), ''), char(13), 1) i
	cross apply (select replace(replace(replace([value], '{', ''), '}', ''), ',', '.') Comp) i1
where [value] != ''
option (maxdop 1)

--1
;with rec as
	(select ordinal, x, m, a, s, cast('In' as varchar(10)) Trgt
		from #Components
		union all
		select ordinal, x, m, a, s, w.Trgt
		from rec r
			cross apply fn_AOC_2023_Day19_GetNext(r.Trgt, x, m, a, s) w
		where r.Trgt not in ('A', 'R')
	)
select sum(x+m+a+s) Answer1
from rec
where Trgt = 'A'
option (maxdop 1, maxrecursion 32767)

;with i as
	(select w.*, t.*
			, max(xn) over(partition by Workflow order by Ordinal) lx1
			, min(xx) over(partition by Workflow order by Ordinal) lx2
			, max(mn) over(partition by Workflow order by Ordinal) lm1
			, min(mx) over(partition by Workflow order by Ordinal) lm2
			, max(an) over(partition by Workflow order by Ordinal) la1
			, min(ax) over(partition by Workflow order by Ordinal) la2
			, max(sn) over(partition by Workflow order by Ordinal) ls1
			, min(sx) over(partition by Workflow order by Ordinal) ls2
		from AOC_2023_Day19_Workflows w
			outer apply (select case Operator
									when '>' then 1
									when '<' then x
								end LeftoverMin
							, case Operator
									when '>' then x
									when '<' then 4000
								end LeftoverMax
							where x is not null
						) tx
			outer apply (select case Operator
									when '>' then 1
									when '<' then m
								end LeftoverMin
							, case Operator
									when '>' then m
									when '<' then 4000
								end LeftoverMax
							where m is not null
						) tm
			outer apply (select case Operator
									when '>' then 1
									when '<' then a
								end LeftoverMin
							, case Operator
									when '>' then a
									when '<' then 4000
								end LeftoverMax
							where a is not null
						) ta
			outer apply (select case Operator
									when '>' then 1
									when '<' then s
								end LeftoverMin
							, case Operator
									when '>' then s
									when '<' then 4000
								end LeftoverMax
							where s is not null
						) ts
			cross apply (select isnull(tx.LeftoverMin, 1) xn, isnull(tx.LeftoverMax, 4000) xx
							, isnull(tm.LeftoverMin, 1) mn, isnull(tm.LeftoverMax, 4000) mx
							, isnull(ta.LeftoverMin, 1) an, isnull(ta.LeftoverMax, 4000) ax
							, isnull(ts.LeftoverMin, 1) sn, isnull(ts.LeftoverMax, 4000) sx
						) t
	)
	, i1 as
	(select *
			, isnull(lag(lx1) over(partition by Workflow order by Ordinal), 1) plx1
			, isnull(lag(lx2) over(partition by Workflow order by Ordinal), 4000) plx2
			, isnull(lag(lm1) over(partition by Workflow order by Ordinal), 1) plm1
			, isnull(lag(lm2) over(partition by Workflow order by Ordinal), 4000) plm2
			, isnull(lag(la1) over(partition by Workflow order by Ordinal), 1) pla1
			, isnull(lag(la2) over(partition by Workflow order by Ordinal), 4000) pla2
			, isnull(lag(ls1) over(partition by Workflow order by Ordinal), 1) pls1
			, isnull(lag(ls2) over(partition by Workflow order by Ordinal), 4000) pls2
		from i
	)
select Workflow
	, isnull(px.p1, lx1) x1, isnull(px.p2, lx2) x2
	, isnull(pm.p1, lm1) m1, isnull(pm.p2, lm2) m2
	, isnull(pa.p1, la1) a1, isnull(pa.p2, la2) a2
	, isnull(ps.p1, ls1) s1, isnull(ps.p2, ls2) s2
	, Trgt
into #Ranges
from i1
	outer apply (select case Operator
								when '>' then coalesce(x + 1, lx1, 1)
								when '<' then plx1
							end p1
						, case Operator
								when '>' then plx2
								when '<' then coalesce(x - 1, lx2, 4000)
							end p2
					where x is not null
				) px
	outer apply (select case Operator
								when '>' then coalesce(m + 1, lm1, 1)
								when '<' then plm1
							end p1
						, case Operator
								when '>' then plm2
								when '<' then coalesce(m - 1, lm2, 4000)
							end p2
					where m is not null
				) pm
	outer apply (select case Operator
								when '>' then coalesce(a + 1, la1, 1)
								when '<' then pla1
							end p1
						, case Operator
								when '>' then pla2
								when '<' then coalesce(a - 1, la2, 4000)
							end p2
					where a is not null
				) pa
	outer apply (select case Operator
								when '>' then coalesce(s + 1, ls1, 1)
								when '<' then pls1
							end p1
						, case Operator
								when '>' then pls2
								when '<' then coalesce(s - 1, ls2, 4000)
							end p2
					where s is not null
				) ps

--2
;with rec as
	(select 1 x1, 4000 x2, 1 m1, 4000 m2, 1 a1, 4000 a2, 1 s1, 4000 s2, cast('in' as varchar(10)) Trgt
		union all
		select greatest(r.x1, g.x1) x1, least(r.x2, g.x2) x2
			, greatest(r.m1, g.m1) m1, least(r.m2, g.m2) m2
			, greatest(r.a1, g.a1) a1, least(r.a2, g.a2) a2
			, greatest(r.s1, g.s1) s1, least(r.s2, g.s2) s2
			, g.Trgt
		from rec r
			inner join #Ranges g on g.Workflow = r.Trgt
								and (g.x1 between r.x1 and r.x2 or r.x1 between g.x1 and g.x2)
								and (g.m1 between r.m1 and r.m2 or r.m1 between g.m1 and g.m2)
								and (g.a1 between r.a1 and r.a2 or r.a1 between g.a1 and g.a2)
								and (g.s1 between r.s1 and r.s2 or r.s1 between g.s1 and g.s2)
	)
select sum(cast(x2 - x1 + 1 as bigint)*cast(m2 - m1 + 1 as bigint)*cast(a2 - a1 + 1 as bigint)*cast(s2 - s1 + 1 as bigint)) Answer2
from rec
where Trgt = 'A'
option (maxrecursion 32767)