drop table if exists AOC_2024_Day19_Designs
create table AOC_2024_Day19_Designs(DesignID int, Design varchar(100), ReverseDesign varchar(100))
create unique clustered index IX_AOC_2024_Day19_Designs on AOC_2024_Day19_Designs(ReverseDesign)
create unique index IX_AOC_2024_Day19_Designs1 on AOC_2024_Day19_Designs(DesignID)
GO
create or alter function fn_AOC_2024_Day19_FindMatch(@Towel varchar(100)) returns table
as
return with rec as
			(select reverse(@Towel) Towel, 0 Ind, len(@Towel) TotalLen, 0 Steps, cast(',' as varchar(max)) Rt
				union all
				select substring(Towel, len(s.Design) + 1, 1000) Towel, Ind + len(s.Design), TotalLen, Steps + 1, cast(concat(Rt, s.ReverseDesign, ',') as varchar(max))
				from rec r
					cross apply (select Ind + 1 NewInd) n
					inner join AOC_2024_Day19_Designs s on Towel like reverse(s.Design) + '%'
			)
		select top 1 1 Good
		from rec
		where Ind = TotalLen
GO
create or alter function fn_AOC_2024_Day19_CountMatches(@Towel varchar(100),
														@Length int,
														@Stats varchar(max)) returns table
as
return select concat(@Stats, isnull((select sum(isnull(cast(s.[value] as bigint), 1))
						from generate_series(cast(1 as int), @Length, cast(1 as int)) n
							cross apply (select right(@Towel, @Length) Pattern) p
							cross apply (select left(Pattern, n.[value]) MiniPattern) mp
							inner join AOC_2024_Day19_Designs on Design = MiniPattern
							left join string_split(@Stats, ',', 1) s on @Length - s.ordinal = n.[value]
					), ''), ',') Stt
GO
declare @Input varchar(max) =
'wuwuwb, brwguu, bbb, ubb, rrgw, rwguuw, wuwuug, rwu, wgb, urrg, bburgrgw, brrwub, rgwr, uw, gbb, bgggrr, wuw, bgb, gbgwgb, uu, gwwu, bwub, ugg, rbr, gggwuw, rwgu, gbbuwugg, ubwwbg, gru, rbw, uuw, uwu, ubuw, wrg, grb, uru, gur, bbgg, bug, rgrb, wgur, br, bwwgruu, ubgbw, ruwg, buu, uuwrrgr, wrw, bbgr, ggbg, burbw, wgu, gwgg, u, grbw, rubrwb, bwu, wbwruwg, wwuurg, wbbrbgu, rgb, gwbww, uruu, brgwr, ruru, grrgub, bbg, guuur, bwbgr, bggb, bbguw, rww, uwrr, uwrgr, ur, wgrb, rbb, rbrub, rguggb, gug, rwb, wru, ubbbbub, urug, burgur, urrgbw, rgr, wbr, uuww, wrr, urw, uwurwb, buw, wwg, bgg, ggw, gbubgw, bw, wrub, gwg, rgwbr, rwbruu, bwug, uwbr, urbbbgw, ggb, burrubbu, wr, rur, gbbu, rrw, rbbrwgb, rwwww, ggurw, wugwggw, rwuggg, brguggb, brb, rgur, bgbw, bwgr, rgu, bugww, rbwr, gurrgur, grwbr, uug, bwru, bb, rguurbbg, wububgg, wwu, wbw, ugrw, ugbwuw, rwrrgw, gub, rbrrguu, wrgg, bguuw, gbugrw, wuur, bg, wwbgr, rwr, gwu, rrbgwgbw, bur, wrug, wrgbu, gbbw, rwg, uwgwb, bgbbbb, rrwwuu, rrgg, gwgur, ruww, grrgrb, gbuwwg, ggrb, uugwgu, ubbrgu, rbbru, wurw, b, uwurr, ubbr, rgugwbr, bgbwbgg, gr, rwww, gubgbgr, bgr, ug, grr, wuuruur, gw, rub, uwggu, bgw, uwg, gwr, bbrgr, bbru, urb, buuu, bbwguwb, ww, wrbww, gbwbwrw, grwr, gww, gbr, uggbgu, wruu, brwgu, gbwgu, r, wuwr, rurr, ugr, ubgbr, ubbwg, rggrb, wrggb, ggggbg, uruwg, uwbgb, bgwwwur, gbruu, grrbgb, rwgbuwrw, bu, rwwr, rgrwru, uwr, wrrur, rug, rwrwgr, gwbwbrru, uggbru, wrb, ruwbu, uugbr, wbgg, rbu, bgwwr, ggr, rwbwgr, rbbg, buurug, wgguu, wrwwg, gguw, rrg, guww, rgg, uguwbw, bgu, grw, rgugggw, uwrw, rburw, gbwgur, wugbubg, uww, wbb, ggu, ruwr, rrbb, wwr, gg, bwrbuw, ubu, rrr, ruubgg, wgbrr, wg, grgb, gubw, buubg, buur, bwuw, wugwwuug, rwgbw, guwg, bbbw, brrww, rgbgb, rubr, bbbu, wwbbggr, bggbuww, bwugwgu, rbubr, grbbu, grubgu, bwg, wgr, wwbww, wu, bgbrw, wug, wwrw, ugb, uwgr, rr, gbggr, gwrr, grrrw, urg, rbg, rgw, buuwuw, uwgbr, wrbu, wuggb, ruwu, wggwb, wwubbb, uwwgbwu, wgg, wrbuwgbb, ugub, wbu, wbuwwgu, wrwuwbuw, ugwgbbuu, bwgb, wgw, rgbwrrbb, uur, brug, wrbrg, ugw, rru, rugru, rggg, rbrgwr, guur, grwugrr, gugu, gubg, uubbu, gbwugb, rw, uuburg, gwwbu, grg, gbu, bbwbrbg, ubr, wur, rrubggu, bru, gwbb, bbr, bwbbrg, brrbggbr, wbbgw, brw, guu, rbww, bwb, wgurrbu, bgrwbr, bbruwu, rrugg, rb, bwr, grrbbbbw, bwbggwwg, wbg, bub, gwrrb, ubg, grrwgu, brrwru, bruwg, brr, rwbwrbg, urr, ggwbu, wgbrbgb, gwuw, wugwb, rrgbww, grgug, gwugg, gu, ubuuuu, wgrgbr, bbu, ggg, bguwb, ggrbrubr, guuu, wggrwwuw, ubrwgbr, bugwu, wwug, gb, wwwbg, ru, uwb, rrbuuu, buugw, rubwb, rrb, uub, rbubb, ggbrb, brgw, bww, wwbr, guw, bgur, ggwg, wurbr, wbubbr, ubub, gwb, bgwu, wwb, wurwuuu, gbw, ubrbur, uuuw, rbur, bgwg, grgbbbuu, ubw, rgbg, ugu, bwgwg, wwggbr, rguw, wub, wwru, bwrrwgu, uuu, uurrwwr, bguw, grru, buww, bbggrb, ubgb, brbrurw, ub, brgb, bwbwuwg, brub, wwbw, wwbwwrg, www, rwbubb, wbrugggw, grbug, ruu, urubu, gbbbrwu, bbugg, w, gwwrb, bgruuwrg, wugbg

uurgugruugbwuuwbbwubwuurubwbgubbruwurugbbg
wbuwrbbwbgbwruuwgugwgbrbwrgugwwgugbggbwbgubrrwr
rwgrrwuubwbwgrbrgwgggruwrbrbruwuwuggugbuugrgwwruuuuggubwwu
rugubrwugrgurrwggguubugbuubwrgbgrbuugbugwuwrwuuu
urwrgrubgbwbbruuubruubgwggurbgwurrbggrrbbgrwuug
wwbbrwwwwwrwgbuwrwubbbbrgguuwwrgbubrbwwgwrwrubwuwubur
ugbrwwruuurwgrwwruurbwgbwurubrwgubuwgburrru
wrgbuwuggbgggrbrrbbwbwwwrugbbuwugguwbwgrwwwbwrrrww
wwggwbwruubbwurrgrggbuuwwwgwbrwubggurbrwugguruggggbrwggbbrg
rrrgbububbuwrbrwrwgruuwgruuubrwrggrbgwwwrwgugwwbur
grbugrurruwbgurbbbguwwurrwugwgbubrggwgwrbbbggwbggrbrg
bwgbubrbruwrwgugrbguubuurgbugrwgbrrggguwwruruwugg
bruurwwbrugbrrrbbugbguubrbgbuggwuwburuwrugrgbwugbrb
rgrbbuwrubgbwbbrgguugruugbrwwuuugrgrwbuuwrgurwurrrwgbrg
gbrbrburrgrurbrbgwwurbrrgrrbbbuggbrbwwbrg
wwubuwrwruuuwbbgbubwgwggrggwbwbrugbwwrgrrrwru
bgwrrrgggbuwguwguuurbubgggguwbbrwwgwwrrugubgbwurrbrubrbg
rwrrguugubwrggugrrubrbuwwggwbruwwrrrwwrwuwgwgguggrwgrrggg
guwgrwurgguurgugbbgggwuggrgrruwwrgbruwwggrwugbrugbbugr
bggwwbrrbggguwggbruwgggbbbbbwgwurbbrgrwwwbwbruwwuu
bbrgbwgwbruwrrubrwbrwguwwuubbrgrbruuuuwuwuuggbr
brgwgwruuburwrrrruwruguwbuwggggwgwwugruuwubggrw
ggbbuuwwwgwggrwbbgurgwggwrggubgwgwrurbbgbbbrbgbwgww
ururruuugrrguuburwgwwubggwbrbruubgwbbgbbgrrbbggguwwurwbu
bburggbwubrugwuurbwgwrrurrwrwrgwwuwbugrwurgbbrg
grggguwrwbwbgrbwrrgwruuubbggbbbbwwbbgbbgrgugruurbwurwgwu
bugubggbubbrbuwgrurruggbubgrbrgwwbwgbggbwbwrgb
ggwwubbbguruwubuwwguugubbrbugwwwuwbubbgbggurbrwrwuur
wurubbbrbrbrbwubugugwbwrubgruuwrgbruubuubbrbubwbwbrg
wwbwguwgrgbbbuubwrbbggguubbwuuggwrwugbrgwbbrurubrbuurbrg
wwbbguggrrgbrwuwbrruwbrgguwbuburrrgrrbwbggrrbrguuwb
burrbburburwuugrwrgbruurrwbwgbruuwbwggbrbugbrgrurb
uwurubwgurrubbrwubbuwrwrbgggwgbuugrurrbbbuugwggwrrbw
bbbrwrgrubbrrubgwuubgbgrbggrwwubgbgrgurrgwuwb
wrgrrububwbggwwggwuwbwgrwrrbrbrbuubgwgbwrrgrwrbugwguub
wgrrwbuggbubrgwbugggrwgrubrgrrbbbbgwwwwwgbgbwrrrgburbrugr
bbgrugbubrwbrugggwubggwwbugbgwurwwwbwgbwrwgbbbggrugrrwb
gwbwguwgburrwwbbwbbbuwgbgrbubggrwrbburuwwurgrbrbuuurgrwwr
rbbwwbbbbbwuwrwubuwbwuwrwwwbuugrbugwbbwwbwuwgbwurugurbuwub
ugurgwbgruwugbbrwgwbrgrgrburgrrwubgwbbbubwrwuwbuwgrbbrg
rrwrbgubrwruwbugrggbbbgbwrgwuwgbggwwbgwgwugg
bwgrwggwgrgrgrbrwuwwwrbguuuuugwuguwgbgurgru
rubrwbuwgbwbbugwuggwbruubruuwuurbgrguwbwrugrwgwgu
uguwgwrwgwbbgrwrburggbrggbrubwrugbugburggwubggg
gbubbwuubbbubwgwururbwbwgruuubruuuruwbggrrgrbrwguruurwbrg
bburwuwrgwruurwggbbrubuwbburbbrbwbbbuuugguwruwuwruugwbrg
guuggrubgubgwwuuurrguubgbgrgwwugrugubgwruwguggrgg
bgrgwbbwgbgubburwrwwbgrbwrrbuuugubgwgwgwrggbrg
rgwruggwbubgggrwbgbggrbggbubbgruuwggrbburrrguub
brbburgwwbgbgugrruruwruugbuguwurwrbrggurrbrgubguubrwb
ggrgbwrrbbrgrrbuugubbwwbwuuwbuuguwwbburgbbuwubbrg
wrbgguwbwuggguruggbbrwurrrruurrurguwggurwugwgbgwgw
gggubbrwuubbgrgbbbrwruwbrbrrrwwbbrrgbwggurguurbbgwbrg
rwuguuuuwgwwbwrwwgbgrruburbugrgugwugwgbbuugrugbrub
grguruwubrwwbubwuguwbuwbwwggggwugwuwgwwbrwbrgwwguuwgguwbrg
ruugguwrgubrgubrgrbbrbuuguruwwrwgrrbuugwbbgwubu
wgwuburgwubrubugwwubgbrrubgrugurwuggbgbuwwwr
wbrurgguwbwuurbrbuuruwuurrggbgbbrwrbruwrgbgb
brgwbwrrgugubgguwggwrgwrbbgwgwgrrwrgugbrbbrbugbubrrbggbrg
buuwwgguurrbbbrbrggbgrrubbbrbubrbgwrgrugggwwbugguugur
wggbrgggbwuuwrrubrwbbbggrubrgrrbbbbwruwbwgrbguwgbrbbrg
wruuwuuubugrgbuwgruwuuwwguwbuuwrgwwbrguguubwwbrguwg
wrbrwgwbburbgrgwrbrwurrggurrurgbbwwugrgbrwr
urwwubrbrwgubgbbwbuggwuuuwrrruuwgubrgrggwubgwur
uwuwwwggbrwwrbbwrwgwbggbgrbwrrbrbuuuuwrruwuurrbruuwrrbr
wuwwwgrbrggwugbgrbbgubbguububgwrbgbgwwubwwrwu
uwruugrgwrbbbwgrwrwuwgrbrgurubwruwgwgrwgbgurgbrwwrrrrw
ubuuurgwwurbrgrggugwrubbuuggubuurwrgrgururwrrbbgbrgbggbgw
rbggwururwgbrgbrrbbrrbubggrbwwgggbgwbugbrwbbguurggg
bggwbugurrurrgwuugbrwrwuwgruugbwbrwwuwbuuugrbgubwurrrwrbrb
bburbwbwbuwbgwbwuugggbrrwwguwbwwwuwwwwgguugruguggwgrgurw
brwguwuuwwbbwguwubbguuuurbugwbwbgrwrwwrwwguwg
rwrrgrwbbbwguwgurwrrwbbgggrbbruwgwgguwbrwrwwwgrwrugbwggwgr
grguruuggwruwrgruwurrgbbrrgbgwuwrurbruwggbggrbrgugrrwbw
uburbbwwbwwrwguubrgwgrgbugwrgrbgwgwgwwrwrrwrgbgbbgbbuw
rrwuubruwrwubwwgrgguurwrurbburruwbguwuugwwwururrrbbggrburg
gwrruurruubrwrwrwwbbrgbgwwggrrggwgbrwrruwruuw
wbubbbguwrbbwrwgwgrrugwruwgguurbguggbbwurgrrgbugbrrggru
wuuwrgbrgugubbwwrgruwbwuubrggbbgrggwbwwwgbu
rwuwgurrwwggbuwgrgwrubrurrgruggubgwwrbuururbrruurbbbwrgb
rgbwuugbrrwggruruwbwrgwwguwuububgrubrwgrurubwrgubgubuur
rbgwugwwrgurrrrrbubwrgrwwrguwgbbuwbrwwgrrrrwgwubugbwrwugr
wgbwuruububggugrgubrrrurwwrgggbugwgwurbubgrbgurgubruurrwur
urbugwgwwwgwrrgbrrwwbwuuuggwbbuurgrburbwgbgrgr
uwbgrrrurwbwugbrbbbbubbugruwwrrbrbwwgbugbgbbrbuubruruuwbgbrg
rwwgrguburrubbuwwwrgwwwrguwgrbwuwgbrugubrbrg
brubbuburgwrgbrbgwwuuggguwwwggrwggbugwgwrrbbugrur
uwrubwubgwbgwbrwrbwwgugbubggwrurwbgwbwbrruugru
wrrbwwwwuugwrwugrgwwrrwgrwbwgubbbgugrgwrwbrgu
gubrrgwrburrrwgrwurbbwuruuuurugbrgbwwugrgwwrwgrrubuurrwbwbrg
wruubbuwwwbrwrbuurbrbburgrgwbrggbgwrwrwgwrugbwgwbrg
rbrubrbwgrwubggbwbwrrwbrgwrwbrwwbrwuwwwwggbgugbbuugurwbrg
gbugguubwuuguubrrrubwrgrrgwgwrubgbrrrubwgbbrub
grggurgbbubwbwurwubwrgbwbgbrubugrgugwgbbuuwgrbubbwgbgrbrg
ruugguwbwgbbwbruguwwrrggugwrguggwurwrbwrugubuwwbgbbuurr
uruuguwgwuwguwugggbbrbrwugugwbbggbgbgugruwwg
guburbggbwwbururruurgbuwburrbbrrguwubrrrrwbu
grbwwrrgbrbrbbrruugrgwggwgururbbguwwrbuguwuuwrwuuwguwbrug
uwuwwruuububbrurggbgwbwrrbrbrrburbruuguubbrrbgbrw
wwuggbuuwuuuuwgrrrbgrrubbgrgbrruwrurrggbbgburgrbw
rgrguuuruurrgrggrwubgruwrggrrgguwgbuuuwburw
ugrrugwgrgwrrwgbrggwguburgurbrwwbgbgbrruwrbrbwuruubrwgurb
rurbgbuuwuruwgbwwbrwbbuuuguggrugwrbggggbrrgwwubrbwbrg
rbugbgurrwwrgrburbbbgrbwwbwrwguwbgwuurgbwurgbgbuwugbwgurr
rwrbwggbubbbwbruwgrruuwwuwwwrbggguwwuwbrrbgrwru
bggbbuuwgwguugguburubuubwbguwbrrubwurgwrugrgbwggwwuwgrrwbb
rbwgbrrgguguwrgwbuuwrbgbuburrgruubwwbwruuubuwubrrrbbrg
uurburrbgubbuwrrruuugbwruwubrrrwugurrggurbbrbwbgbggur
bwugururrrguguurwwwwrgrugguuurgrwggbuuurwwrrruubr
brugugrbrrwuwbrwbgrrbubgruwuububrrwugubbbuuguurgwww
rwgrwrurrwgggbwubwrurbbbbrrwbburrbruwgugwgbruugbbgbwbbgg
guuwrgbuwrgwrbbgbrgbuwwburwwbrguwugbrbgwbbgrubrbbgbrwgugbw
uwrububugbbuguuuguwwgrwrgugwwuugugugwbwbwgbbgwburb
brbgubggbrwrbggburgbrurwrggwbbburuwbuubgbgug
rrrbuwrugbbwwuugrrrrbwuggbgugbwggwuuwbrrrggrb
wuuwggggwgugwwwuuubgrwgguwwrgwgwgrruwwugburuuuuuw
wubburggbuuuwrbwbgbuubguruuwgbrrgrbbgwbrbwrwbwggu
wuwrgguruuuwrwuwgrwguggrbrubrgwrbubgurbggrbbwbrwuwrg
wwuwrgurwugguugburwbugrugbrwuwggrugwwgruwwubguwrrrbbgbrr
gbuuuwwrwbbrbbrwbugwguuuugubrrwbrrubwgwwwgggrgwwbbgbgwwgb
gubwbbgggrrrrwguwrgrbwwwbbburwwgrbruurggwwrbuwubrbgwuuwu
gwruwugbgwgruurrurbuugbgbguuubuggurbuwwuwbgruwrgrggubw
wurgwwuuwwggwuuwbbrrgrgubuubbrggrwrgwwurwbrg
uuguwrrbbwugruguugugwguubwgrburggubgggggubgrrrwwgbrwuuub
grwgggbubgwggwrurbrurburbbrwwgrwwgbrgwururbwbgugwrguuu
grrbrwrggrgwgrwrgwugurwbuwuburwwurwwwuuguguwwwrwrg
bwbgrwwrbwuuwuwbwbrwuwgwwbbbbwbgugwgubrwgwgbuwr
brrggwbgrubburbwbwwrbruuuugrbwurwubwrbgubbgw
uugwbuurbrbbbgbruguwggwgwbrwbrgurgrggrrwuwrbuwgwbwbggbubuu
bruwuggubuwgbgwgbbwrbbggwrbuwbggurrgbggwruwburuurgw
uwurbuuwrrwurubuuuuuwwuwrgbgrbbguuwuwbbrruwgbb
wuurrbuugrubgwruggwbwruuruwgubburuurbwggbubggbrg
rruwbrurbgwwwwgrbuggrrbrwbguwggwwububurggu
ggrubrrrbgguuggubwrrugwrrrbwbbwwbbggguuwuuwgguggbbgggr
bbguwuruguruwgugbuuuwurgbuwbrbwuuuugbwggbgggrgggwrgwgrgbb
bbwrwbrrgubbrubrubgrgwrrubwwwuubwuuggbbrwrgbrgwrrg
gwrwbrwggrbwuruugrburbbggburwbbrgwrbwbwwuuguugu
guuwwrrbbubwuwggwbbbubrrrrwgrbubgbwwwggwggwburru
rwbbbrrwbuwuwwuuwwwwgwrbwwwrubwrbwwwgbbururwwbrrgbubwwbg
wwurgbggggwrwgwbururrbwwgwbrrbrgwwbbrbrg
rgwgbwbubwwbggbguuwbgrbrgbbubwrwubrgurruuuurrwrg
ruwwbuuwgbrgwgwwrbwugwgwgrgwgrgbgrbbuguwbguwurur
bubrwrbuguwruwurugggubwuruubugurwwwbwruwuubrrgwgubwrruw
rgrurgurbgrbbuguurbubwbbgrgrwwuggrbwrgbrg
wubwbbugwuwgrgbwururguurwrrgrbbuggrrruwuwrwubrbu
bgurruguubwuwburbgwbrbrwwrwbrgrbuuwrrwuwugwuwrbbrrr
rurugwwrguuugrubgwgwwrurbgbubgwrugwgubbbgwurwbw
ggwbbruuguwbwugwrbuurrbrrwgbuwrbruubrgwuwrwu
ruwrbrrggwbgrwgubgugbuurgrwrwuwuwrbbrrbbbuwbu
ugwwugwugwbwbgwrggugugurruwbuwgwrbbgruwrwwrggwbubwbgrrwbrb
rgwgguurwwrwuwrrbbgbbgugbbruuggburbgggwbwrb
rrubrwuguwgubbbrgrwgbgrwwgwrbuwbggwwwwrubggugwrwruggrurrr
wuburrrgrugrugggurwrgrwgwgurrurrubgwbwwubrwb
urbbwubwuwbgbwggbwrgbbwugbrbrgurbggrwwrwbrbgurgwb
bbwwbbrrrubgguwrbubgbbwuwgrrwrgrbbuggbuwuu
bwrurgurrwwruwgrbgwuwwwrbbrbbwgbggwbwbbrrggbbugbwggurrrr
bbwgbwbgruggugurgugwrrgrrrbwwbrububguggbrgwuurrrruub
grbgggbuwbugugggwwwgrrbbuugrwrrgugggwurugbbrwwuuuwbrguwbbw
uwubwwbgurrggbubrgggrurbruurgwbbrggugubbrwuggur
guwgrwgbgrbrrwrbburgrrrrwgguggggrbguubwbbuwbrbbrwrurgub
rrbbuwurgwrggbgwgwgrgbuwggrwbrburgubrwbuugggwgrub
rwbuurggbbubrugrbuurbubrbugggugrwggbrguubw
ubuwwwubbrgburwgrruwwwuwubrwbrbuuuwbrgwgrurwrbwgb
uwbrwbbwwbwwbwgurwwwurwugwbgugrgbgbwwgwuruguwrubgwruwgbwbb
ruwgbwbrgburuwgwwgbggggbbwwgwwrrguurubrugruwwrwb
gwgurgbgwugrwurgbuwubrbbbgrbwggwrrrrgurrbw
wrgugubggggbbbuwuwuubrbbuwrbuuruuwgwwgwwgbbuwu
ubgwwurgbugguwwwuwgrggburugwgrrubbbuuwrurw
burrrbburrrwwrwwurrwwurrrrbbwwuugwgrrgrubwbwwurbgugug
bwrwggrwgggrbbbgbrbuguwrruggbrugbwbbbwuuwurru
ugubrwuuwrrgugwubwbbgrubrgwgurbwbbuuruuugggrgwuuuwwubuubrg
urwuwgwrrgbwubwrrrwwgruwgubwwgrurwubbuwrgbwrrbbrbuubrbbwrr
grrgrugrrugubbggrrbuuuggbbuwbubwrrurwgbruurrgbubugu
wwuwbwggbgurwbuguwrbugwbwrubgbguwbbbuuurgrwggwguggrgubwb
wbwurggrbgwgbwbgbbrrguwurwgrwwrurrubwbuubwurbrg
grwbbbwbugwwwuwrugwbgrwgugrbuwwwrggrgbbwuwguwgwgb
grurbuugwgbwwugbuwgwgwburgurrrugrbgrbbubrurggrbg
wrwurbwbguububruwbrwrrrurwbrbwrubwbgbubwwrugrbuwwugwuw
ugubrgggurwruwgggrgbwwrguwgwwuugwrugrruwrwrgbwggbrg
urrugwwuubwguugugbruwuuugbgrwwbrgwgwwwwwbbbwrurugwgubw
uburuuwrgwurwggurgwgwwbrrgrwguwuwwgwgwrggrbggbbbbgbbg
grwrwwrubrbgrrubgbrwrrburwwubrbrwwgwgwgwwrubgurrgrw
bwrwrggubgwwbrrugurgrrwgrbwgwruuuwuugwrwuwbuwbgbgbgurgbgb
uubbwgbwgrrwbrbbubrgbgrrbbubbburwwgwubrguwwgrgbgu
rwgwguguwrbgrgrruubbbwuwbugbrrgguguuggbgrbbgburbur
gbuburbgwwbwubgbgbgwwurgbrwbgbgurbrrbruburwwrgrrurbbub
ruwwbgwbbgbugbgbwrgrbuwgubbrwwwubrbrwruwuruburgwrr
gwrrgbrgrggrrwwrgbgubwrrguugbuugbwwggwubwbbrwgwurgw
bgruwwuwgbwurwwwgubbbrwgrgwbggguwgbrrgggwwbbwubrubrrgbrg
wrbuuuuurrwbgrurwgwwwbrubrwgwggguggugbrbgur
gbgbugguburgbwrgrurwwruwugurwgwbwbrrubrbwwbgwgubwgubbrg
rguwwgrbrbwgurgbgrwrbrugrrbwgwubuuburgwwbrugrbgguwggwbrrb
wuuwwrgbbgwrwurgwuwrgwbbwbugwuurbbwbbwwwbwu
burrburruwwgubuugwgwburuugrbbbgbugbwwwrbbgbbw
bgbgrgrrbggwwrwuurbbgrwrrbwubrbuggrbwuwwruurbgbgwbug
urubgwbrugggwrbbrgurruwggbwrrwrbgggrwrrbrrwgwgwrrbwbgbbrg
gggbrgwbbwrgrbuuwuwrrbrrugwbburwuwwggbubgwrwuubuurrrwbrrwg
gubgubbuwuuubugwggwwwurgbbrwubbubgwubwugbbbgwgbrg
uwuwwwrubrrrgwbburugrrwwrrwburrubbugrrugwgbuugbrg
gbrruuwwrbburguwubbgwuwrguwwrbuwgbbgubwuburuubbbbburbwbrg
guugrbrruwggubbrwbgwggrrbrwuwrwwwubguuuwurwgbggwgrgwuw
wrbgurbbuuuwbrbggrbrubrubwbruubguuububwbwgugrrwgbugbrg
gbrrubrwwrurwbrrrrbbwbgwbugrgbgurwgugggbuwubgbbwr
ggubbbbgrbrgrwuwrggwgwrurwbwgubggrgwuuruuwugbwgbrurw
uruuwbwwbuwuururwuwwbgggurrruwrgbgwrurbrbugbrrbwrrwrbbuu
wuugwgwburbgbwbbuururwbwbbggruwwgbwrwuugbbg
brrgbwrubuguwrwuwwwugruubrbgurwgbbwbbbrrwrbbrubbu
grgburgrrrgwugbrrbrrwugruwuwrbuwgwwburbgurubwbbrwwub
wgggrgwguuugbrrburuuwrrugbgurgurgwwggggugguurrw
rbgurbrgwbugugwwwrgbrbbgwruwgurwwbuwrwrgrbwbubgrr
ggwrwwrbrgurrbwrbggrbubbuwbgrgrgbwrbrwurgrbrwbgugwrwwrrw
rrgguruugbrbwgwbwwuwbguuuwbggrgwrguruwurrwwrwrubb
rwwwbwubgbwuguuuwwwgwwgrgwwgrbgwwubguwuuwgrgbrrgbbggrr
uwrrrwrrurgbugguwgwrgrgggrgwgbbubugrurggwbwbbbgbrrwr
gwgrgubggurrubbwburgrugubuuurrubbgurwwwugbgwbrwgbggrwuuu
wgguurrgrurrrwwrrgubbrgwwggbrugwuubrwwwuwbugrbwurgbrg
bwrwwgrubbwbrbrurgubgbbwugbgggwwrurgurwbrrubgrwrgub
grbwgrugburbwrbwggburrbwuugwurbbwbburwbgbbrbgrrgurbgwwgw
buubwwgrwgrgbbwwrggubwbbbwbgwrubrbgrwggwrburuuw
bbgrwugbbgurbbrgwubuggurbguggbbbrrwgbrwbbgrrwwgwr
rugwgwbruuwbubgggbuugbgurwrwrurubgugurbgrrr
ruggggbgrwrwuugugbbrbbwbrrgbburuwbbwwbububwuubggwubbrguw
bgrurwbgbwrguuuwggrrrwbugrwuwrurguuubbwbbrgrbwubrgrgruw
bgwrbguwbwwrgwwbwuggwrburwbwrwwwwrrubgrrgwgrbbrrbbrg
ggbbguwgggbruuubwwugbrubrbubbruubwrwguubrguguwurbubggbubb
bbrwgbuwrwrrwrbwwwwgrwgbwrwubgurbbwbwwggbgbbgbgbbwggbrg
rgrrrbgbwgugwguwwguwwrwgbgrrgubgburbrgrbbgwburrrwuggwub
guuwubuugwruuuwgbrbbrurrwuuwwbruuwugrgggwr
grugrbbrrrruwwrgbgwbbrbwgrgbrwwgwbbbubuwwrwbrwrb
rgrgrbuwuruwrbwgbrwgrubwbbbuwbuurgggbwbgrwbrugwgwb
wwbgwurugrwugwwuugubrgbrrwuwguuuwgwrggrbubgwwbrg
grbbrwwbruuwbwgwrurgrrrrgrbrurbwrbuuuurwgubrggu
wuwgbwugwgbgububbuwrrwruwgrgbwggwubwwgbwwguwubbgwb
uugwbrwbbrbgruwururbgrgggurguggwuugwrubbrggwrbgwwbrbgww
rwwgbbwubburwbggwrrbbwwguggwgburbgrgwbrbwwb
brrgwwbwrggwrurrrbrbbwrruwurbgwrbbbwwwgggbwrgur
ubuwurguburwbwwwubrgubuwbruwrbwrgrugrwwbrrb
uugrwbbuurwguwrwgbrrubggugwwwgwgurwgbrbgwggbwrgrurur
rruugbrwrwbuwgbgbrrgrgurrurrbugbuwwwbgbwwrurbgubwuwubbugw
rbrubbugwruurgrrgugbruubggbwwuruurrwwwbwuggbgwbrg
buuwguwuwbbbbwbbubbwgrugbggrwwguurbwuuubuuubgrgbwgrwgbgrur
uwrwugwbbrurbruggruwubrgrwgugbbwrrwwwwwwbgrgrrrwrrbbwuu
bbuwwgbwuwbrbrgwrbwbgrrbbbbuuwgwuwbwbuubbggwggwggwrb
wgugubwugrrwrbwurwggbbrwwuwbwbbrwrgurwbbuwbwururwgr
gubgruurbwbrwgwbwrrrurggwgrgrwbwwbgrwwgruruu
ruwrruwbggwwwugwgbubgwbbwurbbubgurrwbgbrbbrgwuuwrgwwrgwg
rbruguggwwgubbgwrwuuwbwwbububrrwgwwwububrgbrrwrrbrg
brrbwwubgururgbwbgwwrgwbbgrwwrrubwrgwwwurggug
ruwgrrubbwwguuwubgwguwbrrbggbrbbgbbrugbuwwbuwbuurgrbuug
burbbbrgrrbbrrwgggwgrgrwrubwburbggbuwgugrbubrg
uuuggrggbrwwgwugwrgbbwwgwwgrwuwuurbuguwugbbgwgwuuwbbggwrwg
wwwugwrurrburbwbubugwwgwwbubgguubwrbugbguguwgwrrbwg
wguguwurwbbrrbububggwurgbrrgwwbwuwbuwwbuwbuwuurrrg
rrbgbgrbbrrwwwgwwwgrrgwrrurbguwrbgrugbrrwruugb
wubwbubwgwbuwurwgrwwugrbuwwwgubbugugwbwuwwbrgwubrur
gbruwgggwuwruwbwbwbgbwwwugwggrurbwuwbgrbwgggurgruuubuwgur
gwggbugguuubrgrrrgugbuwubggrwubuguuugwrbwwugubbwrrruwwrr
bbbwguuwbbbuwgrwuwwrwgwwrgubwruubbrwbggrwwuubbuwrrburwbrg
bugwburbruwurrwuuwrwggwwgbubuurugwrrrrurwuugrwbgrg
wbruwwwrgbwbgrbbgwwbwuwrbrruurburbbgggbrurbbuwbbbbwu
rurrrgbugrrwrwruwrugwurrrwuruwrugurubrwwbw
wwgrrbuuwrrwwrguggrwubwururwrrgrbrugguwgubgwgwubwrwbubrw
grggbggwuuwgrbwgbbguguwwbbwrgubrrugbubrwwbrbw
rbgbugubrwbuwgurbururrbwgrrgrbrgurrwggrgruwu
wurbbbggurgurgrrubrrgbguwwububbgrrwbwwgbwrurbg
gbuguguwuuwbbbbrwuubrguugwbwwguuubgbugbbwrwuru
buuubwwwurgrrwwwrbubggbrwbbgburwwgguwbbwuwg
bwrrrwbbrguwbbwwugbwuugbuwurwguurbguwwgbrwgwurwbr
uuggrrrbggwgwgbwwbugrrggbbgwugburguwbwrbwgbrgrgrrgwb
grbwugubrgbruuuggbbrbuggbgbbgrgwrurbwbgbgrgurgrrbbgwubu
gbbubrrbgbrwubrbrgugwgruruguwwbuwgbgwbgrgwbrbruwrubrgrrub
brbgguuggwbrwwwbrwgrbrrgbwgbuburbggrbwwbrg
grrwrwurrbuuwrwrbwgwrwuwrruwrguwrgrgrgwwrugwbrrbrubwwgg
wbguwbbubwbbrrbwgwruwwbrwwguugwbwbrrubbuurwrruruwww
rubrwrbgwggguuruwgbgurgggrrwwwuuggggwburbugrggbu
bwrwuuuwggwurguruurrgrgubugwbuwbgubburwbbbuugurubr
brwrbbbubwbwgrbwbwrgwbuurgubwgugwbbbwubgubgwuwurug
rwbubugbggurguubwggggurwbwbubrrbwbgwwbgwbwrwbwwrwuwugruu
wwruwwurwgrgwbubwrrggbuubgrwbwuubwbrguurwgwru
wbgwbwuguwgwrwguugwbwuwguuwgrwwggbbrbrgwbbuurrrw
gwrugruguubgggbgugbbwbrbrrrbrurbrgrrgbgbbwuwwbubbuggbru
bwrbrruruwuwrgubgrururwbguwbgubggbggubugrguggguurbwwwggg
rbbbwggbugwubbbgggrrwbbugrwbbwubgwugwburrbrbb
rbrwbbguuggwggbrbugwbrbruwugbggwubrwubrg
rruwugrurbrruguuwgrgbrurgruuggwwrrrwrgbbwguurg
rwguuuggwgubbwrwguuuwubrgbrwbrubguruggbuwguggurgwwwuugrbbrg
uuuuuruwbrrruubrbgburbrbruubuwbugwbbbrrbrurggg
rwwrwggrrwuurrubwbubuuububgugubbgwgwbruggr
uwwrgwgggwbrbbuwggrwbwurrbrbbbguwgbwbbbrgwugruwgg
rgrrugrbrrwubgrrbbuubwbbuwuwuwbugrbubrggbgwgbu
wbwuurwwururwgwrrbbgurgrbggbwbwbwuuuruubguruwrwbrg
uugbbbwgggbgugrbrrwurwgbugrggggbbbwgwuruuruguuw
bbruwggwuwuwbuguggubrbruwgbbggugwbrurrburwgwrbggwgrguburw
grbubuuwgrbwgwuwrbururbwbwwubwrbwwrgubgwrbwugbburubugurbb
wugwububgbugurbgbubbgwwburggwrgrwguwgrrgguwubbgbrg
rguubuwuwgurbgwubuwwrwbbwbbwrbwugbubuuwuubburbgwubgr
ubbgwuwrbrrgruugwwgubububuwgbruwgbbggbwuugwrbbbwrwubw
uwguwugrguubwgwuwrrbgwguurwgwwbrugggwrgrugrrbuuwwggu
ubwuuugrbuwugrrwrwruwgrwwbuggwgbrubgbbgwgrw
gwrwgwbuuggrrruwwgbuubrwwubggrwwrrgwgubgrwbuugurbbgwrbu
uuwrbuurrrrbbbwwbugbrwwbbggrgugbuwbrubrbbruggrburwg
grubrbwruguwrrrwbugrbrgurubbgrbuugwrwurubgwuuuwrrwgrbgw
uuwgbgruwrrgrrbugrwwuuubrubwurruggwugwwgbggbrwwwrrr
urwbubrugbruubbbwbwwbbgrwwwgrububugwbugbbuwuggbbrbrg
grrrbwrgruwruwbubruwrgwrbgwrgggbbguubbgbrrgg
uubuubrbwbbggbbwgurwbwrwrrubuwrbrbwwrbwuwgwrbwwwwgg
rwwgbubbwwrwgwrwwugubbuwbwwgrugbbwbrbguwbubrurgrguwburu
bruguguwuwgrgruruwruruwbbrrbuugurgubbrugrwbw
bwrbrrggrrbburwwrurwuwgbugbubbuggbbrubugggwuuw
wugwrruggrbwbgguubwuwubbwwrbrgrwbrwugbgrubr
wbwwrruggwruugugbwugwgwwwuwrwbrggrurguwbrbrg
uubuggubggbgrrguubrbbwwguuugwrgubrurgrugbrbgwrb
wwbruwrbrrwugbwguwgruwubbggbgrggbwugugrruwubwur
brgrwuurgrrbrurgbwwguwwurrrrruwwwgrbbgbuwbbgwrwubwwgr
rrguwggggwubrruwgwuugurwbbubruwwwuwuurwburrubbuuug
ruggrrgwrbwbwuwubwwgbrgruuubrrburuwgrgggbu
gwbuuwugurwubbgwugwgrrrwbwwugwbrwbubwbrg
bgguggrguuwrrggubwwgrrugwggubuuguggrbwgbwrwg
ugbrrwuwbbgggubbwggrbwgwbbguwugwbguruuuwggrwwuwug
rgbbwurbwbwgwgrggwrbbbbrugwwgrgwwwgggrggggurrggbg
wrubgrbgwuwgrrubrguwrurwwbbubwbrgbgrurrgwgurbbgwuw
wwwrbwgbbgurwbrbbwgwwbgruwwwubgwubbwrgwbbgbbguwbr
bbgggwugrrbwgrwwwrwbrwrwgururgrubwbggrbubggrgruwguu
rurgrgrwurubugbggubrgwuwugbgubrrubgurgwububg
gwgruwggugururwbwbbgrgwugwgwuburbbbgbgrwbrg
gwgwwbuuwwwggbggbwbwwugwbwbwrrrwbuububrbbwb
wrwgbuwbuwwbbwrbruugrwrbubwwbrbwuwburwrggwbgrg
bwrugbwggbbwbrrrrgwuwbugubrbgrgurgbwbgbrrggrr
urbggrwwgwugwbrgbguwrurgbbbbbruwgbbgbrwbbwuwbgrwugbrg
wgbwgbbggrbwbuwggwgrrguwbrurubbgwgruggrgrwbwbggu
wbwbgwgugbugrrwbubwggrbbrbgruuwrgwwrruubggrwb
grwubwurgrwrwuwuwuuwuwrbgguuugrburrwgrgwwguuwurwbwwg
bgbgwbbbuwubrgrrgugrwgwwbrwubrurrgwwgwwuuwubggburwgwu
uuggbububugwggggbgrugguruurrbbwwbrgbrwrrrwrbbgwggbb
brgugugwgbwguwuwubbgugwrguugwugwrggwgwwrbgbbbbuwr
rbgwbgrwgbrwrgrbrrubbbwwrgruguubwggbwwguwugrwwrwb
wrrugbwrbubbrgwgubrrbwruurubrrrwruwuwrugrb
ruuwbgbrwbwrgwrbwbugwrwwbwrbruwrubrrrgburggwrgwgrbrrbbgb
gbubgbrwrrbgwgbwrwbrgrgbugggrurbubbruurwwbwbrg
bgbwbuubguwgrbbbruruwguguwwwwbwbrbwbubwwuuugrgwrguuw
ugwggrwwuwgrubrwwggruwurrubuwuubugrggbrbububrg
ubuggbrwwgwruwwubrburrrwbgrwwgbrwugbggggrbrgb
grrubruurbrggwwbwrgwwgwrgugbguwurgbwuwruwrbg
uuwwwrgrbgrwrwgruuurbwbggwwgbbrwbbuwrrrwrgrgbbwbubrgrrg
ubrrwwuggrgugrruurwugrbuuwbgruwbbbrrubrgwbbbgubu
bgugrgwbwgwurgbrgugrwuggrburgugrbbbgbrrguuburrwwgwwbrbrugb
uwuwgbrbbwwrbwrrgbwwwrgggbrrrbgrgugrrurgwbwugwwuugugbgw
rugwrubwrrwguuurwrgbwuwbubwgrrbbbbwruwwrrb
bwwugbugbwwgwwwuwbgwrwuguwwruwrwgbrgwubwrbwwr
ubuwgurbrwwrurrgugrbgbruubggbbbwggbrgwbgwrbwwggbuubgruug
ugwwbwbrwwbrwrwggwruburubrguguwwrgrbrrwuubbgbgbbugubrg
wrwgwwbrbbwuwuwgbrurrggbbwggbrgrubbrbgrugwrbuuwggburg
bbgrububbubrwwwggwbbuurrurburuwwrrgruburwuubbggrbwgbgbu
bbuuwubggbgrgburbwbbubrrgwwbubrurubrbbrrrbbuww
ubrgwuggruwrgwgrbgwuwuburubuwbgbbwgbrruwrbruwbbwwg
wbrgwugubrubrgrurwwwrbwbbbbbwrrggwgwbwrgubwgwbgggrbgbrugbb
guggbwugwuwwwgrbrgrrugrbrgwugbgurgrbwwgbwruwuuuwbgwbwrgrww
bbugrbbuwubwbbruurubrrgruuuwgguuwgruggwrwbg
ggwrgbgugbbrwwwuggwwuuwwrgbrwrbrrgrbugwrrwuuuub
wbbgrgrurgurwbbwruwbbwgbwrbbrrwrrgbwrgrwugbgrubbwrrurr
urwrbbggwbuugwuggbgbuwbugugrubwwrgwbrruwgbgbggburgwgugurwbrg
brgrwrubgwrwburgurrbwggwguggwbgwrrgubruurggrubuur
ugwwbbwwruguwbbuurbggubwwbrurrrubbwwgbbrrrwbgugwbwuubrggrg
wgrgwuwrbuwurggwbrwbbuuurbwwugbbugubbuggbwwrr
rgrwwguguuwwrguwrgwbwbwbuuubrrwrbbwgubguwwwubu
bggrggbgbubruguuubbbgurrurwrrgrrrggwuwgrggruuub
rugbggwgurrrgbgrrbwbwwbbrrgwbbbgbrbgrguurguwbggrrrwguuuur
gwbrrwwuwruwguwwbwguubgbruuwgguwbwrbuwgbbgruurrrbw
gubwwuwbuwwbbuwubwwwrgwwrrrwgrwwgwgugrwuuubgurr
rbgggwwwbrbuggugruuwugwbgubgwwugrwguwggwburr
rurbubggwbwrubggwrwrrggruggrbuubgubugrbugbugubburr
rgugugggruwbuurwugrguwruggrrbgwgbwgrgurwwwur
uugubwgwgbgububwbwwgubbgbuugbwgrugbrguuwbrwrgbgu
bgbrrrrbgugwuugbwbrrbwuwwwrruwruwburbrugrwr
bgwrrwgwbwbbrwubgbwubuwgbbggrbrubbgbwuwbrg
rggburuurwrrurwguwuwgbuwwbbrbuwrwrgugwwbggwbgubrbbrbwwug
gwbbrwbggwwuwbuubwubwbbrggwbggrwwgbrbruwrrubwwrbwbgrbrg
gruuwrrrrrwgwgrwurwgguugrugwrrgrwrbgbbbbrwr
wbbwggggbbgurrbwuwwwuwwguwbwgrgubburgrgwwwbr
rrbbuwrrruwuurgrrrrruwggwbgbrbrbbgrrwgrurwruwwrgb
gwrrgwbgbggrrbubrwbrgrurrrruuwwbwgbugbgrwuwgrgguwugrbubuw
gwuggggrgbbbuurgwwbrwwurgrwuurwrrbwbwwrgurwugwrbuubgg
rgrbrbgwrbgbwuwrbbgbbgbbugrugwruuubwbgubururrgwuuggbg
wbburrwwwrgbrggwwugwwrgrbuggbubwbbbwbrguwgwwbwuubu
wbggwggrwrgbwwrbrrwbgurgugwwwbrwrrbruwwbwguubuubuw
ubggbuwrrwwwgbwburwuugwrgburububrrbbgubugurgugbwrbrwbw
ugrwrrguurguburwbbwgbwwuuburrrgurbbgrrgwbwgrugb
rwggwwubrbbrrwwggwwbuwugwbguubuwurguwrggurggwuuuurgubrr
brguurbbgwwbrrggrbubwrgwbwuwuwgruubguwbwrrgbbwgubw
ggrwwwgwbrugrbgrubbbwbrburguwguwggwwbbrbggwbubgbgbb
bwbugubgbbgbuurgbbwuburbrrrrrguwgbbuwggrgburbrwbrgbr
wwgguubwgbgwwruuwrgbrwbbrwbwrgrwgguwruwbwwrrgugwurugruug
wrgbuugrgrwbrbugrbwbbuwrbubbruugbbwrrugrrr
bbwbgurbbgwugrbrrbgwuggrrwugrruugburggugbrwwbggg
buwrguwguuwwwwwugbrugwbgwgbwwrwgbbbbwgbguw
rrbubruwwguruubgbwbrbrgggbbrbrrbbrugbgwubwrrubrgwrwggugur
gwrwgwrwggwgbugbuwrwuugugwugbruuuurwwgrgrbwwu
gwbburwurguwrugbgrgggbbubbgbrrruuwrrrbbwugwrruwbrubuwbrbgr
wurwwbbgbgbggbbrurgggwgbubwrubbbgrrbrbbuuu
uuwwurwwrwrgurwugbbgwbwrwruruuuuuuggbwgbrbuuub'

drop table if exists #Input
drop table if exists #Good
drop table if exists #rec

insert into AOC_2024_Day19_Designs
select ordinal, trim([value]), reverse(trim([value]))
from string_split(left(@Input, charindex(char(13)+char(10)+char(13)+char(10), @Input, 1) - 1), ',', 1)

select ordinal ID, [value] Towel
into #Input
from string_split(replace(substring(@Input, charindex(char(13)+char(10)+char(13)+char(10), @Input, 1) + 4, len(@Input)), char(10), ''), char(13), 1)

select ID, row_number() over(order by ID) rn
into #Good
from #Input
	cross apply fn_AOC_2024_Day19_FindMatch(Towel)
option (maxrecursion 32767)

select count(*) Answer1
from #Good

;with rec as
	(select ID, 0 ln, Towel, cast('' as varchar(max)) Stt
		from #Input
		where ID in (select g.ID
						from #Good g
					)
		union all
		select r.ID, NewLn, Towel, c.Stt
		from rec r
			cross apply (select r.ln + 1 NewLn) n
			cross apply fn_AOC_2024_Day19_CountMatches(Towel, NewLn, Stt) c
		where r.ln < len(Towel)
	)
select *
into #rec
from rec
where ln = len(Towel)


select sum(cast([value] as bigint)) Answer2 
from #rec
	cross apply string_split(Stt, ',', 1)
where ordinal = ln