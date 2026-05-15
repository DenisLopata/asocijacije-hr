class_name PuzzleData

enum Difficulty { YELLOW, GREEN, BLUE, PURPLE }

const DIFFICULTY_COLORS: Dictionary = {
	Difficulty.YELLOW:  Color(0.949, 0.839, 0.310),
	Difficulty.GREEN:   Color(0.420, 0.690, 0.353),
	Difficulty.BLUE:    Color(0.380, 0.580, 0.780),
	Difficulty.PURPLE:  Color(0.678, 0.467, 0.788),
}

const DIFFICULTY_LABELS: Dictionary = {
	Difficulty.YELLOW:  "Lako",
	Difficulty.GREEN:   "Srednje",
	Difficulty.BLUE:    "Teško",
	Difficulty.PURPLE:  "Najteže",
}

const PUZZLE_COUNT: int = 5

# Weighted rank odds per puzzle slot [rank1%, rank2%, rank3%].
# Puzzle 1 strongly favours rank-1 entries; puzzle 5 strongly favours rank-3.
# All three values must sum to 100.
const RANK_WEIGHTS: Array = [
	[75, 20,  5],   # puzzle 1
	[55, 35, 10],   # puzzle 2
	[25, 50, 25],   # puzzle 3
	[10, 35, 55],   # puzzle 4
	[ 5, 20, 75],   # puzzle 5
]

class Category:
	var name: String
	var words: Array[String]
	var difficulty: PuzzleData.Difficulty
	var extra: String = ""
	var rank: int = 2  # 1=easy, 2=mid, 3=hard within this tier

	func _init(p_name: String, p_words: Array[String], p_diff: PuzzleData.Difficulty) -> void:
		name = p_name
		words = p_words
		difficulty = p_diff

class Puzzle:
	var title: String
	var categories: Array

	func _init(p_title: String, p_categories: Array) -> void:
		title = p_title
		categories = p_categories

	func all_words() -> Array[String]:
		var result: Array[String] = []
		for cat in categories:
			result.append_array(cat.words)
		return result

# -------------------------------------------------------------------
# Large pool — one array per difficulty tier.
# Each entry: [name, [w1, w2, w3, w4], rank]
#   rank 1 = easiest within this tier
#   rank 2 = mid (default if omitted)
#   rank 3 = hardest / lateral-thinking within this tier
# -------------------------------------------------------------------
static func _yellow_pool() -> Array:
	return [
		# --- rank 1 ---
		# v3: plava/zelena/žuta/crvena → bijela/crna/ljubičasta/ružičasta (frees žuta/crvena for Tople boje)
		["Boje",                   ["bijela", "crna", "ljubičasta", "ružičasta"],           1],
		["Godišnja doba",          ["proljeće", "ljeto", "jesen", "zima"],                  1],
		# v3: konj → magarac (konj conflict with GREEN r3 "Divlji ___")
		["Domaće životinje",       ["krava", "svinja", "magarac", "koza"],                  1],
		["Voće",                   ["jabuka", "breskva", "šljiva", "trešnja"],              1],
		# v3: luk → češnjak (luk conflict with PURPLE r3 "Tri ili više značenja")
		["Povrće",                 ["mrkva", "krumpir", "češnjak", "špinat"],               1],
		["Dani u tjednu",          ["ponedjeljak", "utorak", "srijeda", "četvrtak"],        1],
		["Dijelovi tijela",        ["ruka", "noga", "glava", "leđa"],                       1],
		["Prijevozna sredstva",    ["auto", "vlak", "avion", "brod"],                       1],
		["Odjeća",                 ["majica", "hlače", "suknja", "jakna"],                  1],
		# v3: sok → mlijeko (sok conflict with PURPLE r3 "Hrvatski i engleski")
		["Pića",                   ["voda", "mlijeko", "čaj", "kava"],                      1],
		["Oblici",                 ["krug", "kvadrat", "trokut", "pravokutnik"],            1],
		# v3: radost → veselje (conflict with YELLOW r3 "Završavaju na -ost")
		["Osjećaji",               ["veselje", "tuga", "strah", "ljutnja"],                 1],
		["Dijelovi lica",          ["čelo", "nos", "brada", "obrazi"],                      1],
		["Namještaj",              ["stol", "stolica", "krevet", "ormar"],                  1],
		# v3: grožđe → kupina (cleaner botanical classification)
		["Bobičasto voće",         ["jagoda", "malina", "borovnica", "kupina"],             1],
		# v3: lavanda → karanfil (cleaner flower category)
		["Cvijeće",                ["orhideja", "tulipan", "karanfil", "suncokret"],        1],
		# v3: morče → zamorac (literary standard)
		["Kućni ljubimci",         ["zamorac", "papiga", "hrčak", "zec"],                   1],
		["Rodbina",                ["majka", "otac", "sestra", "brat"],                     1],
		["Dijelovi dana",          ["jutro", "podne", "večer", "noć"],                      1],
		["Školski pribor",         ["olovka", "ravnalo", "guma", "šestar"],                 1],
		# --- rank 2 ---
		["Sportovi",               ["plivanje", "trčanje", "biciklizam", "gimnastika"],     2],
		["Doručak",                ["jaje", "tost", "jogurt", "žitarice"],                  2],
		["Kućanski aparati",       ["hladnjak", "perilica", "mikrovalna", "usisavač"],      2],
		# v3: spavaća soba/dnevna soba → spavaonica/blagovaonica (1-word consistency)
		["Dijelovi kuće",          ["kuhinja", "spavaonica", "blagovaonica", "kupaonica"],  2],
		["Planeti",                ["Mars", "Venera", "Saturn", "Jupiter"],                 2],
		["Instrumenti",            ["gitara", "violina", "truba", "flauta"],                2],
		["Drveće",                 ["lipa", "bukva", "bor", "javor"],                       2],
		["Alati",                  ["čekić", "pila", "odvijač", "kliješta"],                2],
		["Metali",                 ["zlato", "aluminij", "željezo", "bakar"],               2],
		["Školski predmeti",       ["matematika", "povijest", "geografija", "biologija"],   2],
		["Zimski sportovi",        ["skijanje", "sanjkanje", "hokej", "klizanje"],          2],
		["Životinje u šumi",       ["medvjed", "vuk", "jelen", "lisica"],                   2],
		# v3: ljubičasta → crvena (factual fix, ljubičasta is cool color); žuta added
		["Tople boje",             ["narančasta", "žuta", "crvena", "smeđa"],               2],
		["Vrste mesa",             ["piletina", "govedina", "svinjetina", "janjetina"],     2],
		["Nakit",                  ["prsten", "ogrlica", "narukvica", "naušnica"],          2],
		["Vrtno povrće",           ["rajčica", "paprika", "tikvica", "patlidžan"],          2],
		["Načini kuhanja",         ["pečenje", "kuhanje", "prženje", "dinstanje"],          2],
		# v3: čizme → kaput (cleaner winter association; čizme moved to a future category)
		["Zimska odjeća",          ["šal", "kapa", "rukavice", "kaput"],                    2],
		["Dijelovi bicikla",       ["kotač", "pedale", "upravljač", "sjedalo"],             2],
		["Vrste juhe",             ["goveđa", "kokošja", "riblja", "povrtna"],              2],
		# --- rank 3 ---
		["Oceani",                 ["Tihi", "Atlantski", "Indijski", "Arktički"],           3],
		# v3: "Morske životinje" restructured → "Morski sisavci" + "Morski beskralježnjaci"
		["Morski sisavci",         ["dupin", "kit", "foka", "morž"],                        3],
		["Ljetni sportovi",        ["vaterpolo", "jedriličarstvo", "atletika", "veslanje"],  3],
		# v3: "Životinje na farmi" → "Ptice na farmi" (differentiation from YELLOW r1)
		["Ptice na farmi",         ["pijetao", "guska", "purica", "patka"],                 3],
		# v3: "Životinje u moru" restructured → "Morski beskralježnjaci"
		["Morski beskralježnjaci", ["hobotnica", "lignja", "meduza", "koralj"],             3],
		# v3: jagoda → pistacija (conflict with YELLOW r1 "Bobičasto voće")
		["Vrste sladoleda",        ["karamel", "vanilija", "pistacija", "lješnjak"],        3],
		["Završavaju na -ost",     ["radost", "mladost", "ljubaznost", "hrabrost"],         3],
		["Završavaju na -ica",     ["matica", "ulica", "granica", "klupica"],               3],
		["Odmilice za rodbinu",    ["mama", "tata", "baka", "deda"],                        3],
	]

static func _green_pool() -> Array:
	return [
		# --- rank 1 ---
		["Note glazbene ljestvice", ["do", "re", "mi", "fa"],                              1],
		["Sportovi s loptom",      ["košarka", "odbojka", "rukomet", "tenis"],             1],
		["Mjerne jedinice",        ["metar", "kilogram", "sekunda", "litra"],              1],
		["Gradovi Hrvatske",       ["Zagreb", "Split", "Rijeka", "Osijek"],                1],
		["Egzotično voće",         ["mango", "papaja", "kivi", "ananas"],                  1],
		["Zanimanja",              ["liječnik", "učitelj", "vatrogasac", "pilot"],          1],
		["Europske države",        ["Njemačka", "Francuska", "Italija", "Španjolska"],     1],
		["Kuhinjski pribor",       ["lonac", "tava", "žlica", "nož"],                      1],
		["Životinje savane",       ["lav", "slon", "žirafa", "zebra"],                     1],
		["Kontinenti",             ["Europa", "Azija", "Afrika", "Amerika"],               1],
		["Grčki bogovi",           ["Zeus", "Hera", "Apolon", "Atena"],                    1],
		["Vrste filmova",          ["akcija", "komedija", "triler", "horor"],              1],
		["Nordijska mitologija",   ["Odin", "Thor", "Loki", "Freya"],                      1],
		# --- rank 2 ---
		["Hrvatska jela",          ["sarma", "peka", "pašticada", "burek"],                2],
		["Kukci",                  ["pčela", "mrav", "leptir", "kornjaš"],                 2],
		["Začini",                 ["papar", "sol", "cimet", "kurkuma"],                   2],
		["Ptice selice",           ["roda", "lastavica", "čaplja", "kukavica"],            2],
		["Rijeke Hrvatske",        ["Sava", "Drava", "Kupa", "Neretva"],                   2],
		["Materijali",             ["drvo", "staklo", "plastika", "kamen"],                2],
		["Dijelovi automobila",    ["motor", "mjenjač", "kočnica", "volan"],               2],
		# v3: miš → pisač (conflict with GREEN r3 "Tiho kao ___")
		["Dijelovi računala",      ["tipkovnica", "pisač", "zaslon", "procesor"],          2],
		["Kontaktni sportovi",     ["ragbi", "judo", "hrvanje", "boks"],                   2],
		["Glazbeni žanrovi",       ["jazz", "blues", "klasika", "folk"],                   2],
		["Vrste sira",             ["gouda", "cheddar", "brie", "feta"],                   2],
		["Vrste tjestenine",       ["špageti", "lazanje", "rigatoni", "penne"],            2],
		["Vrste kruha",            ["pšenični", "integralni", "raženi", "kukuruzni"],      2],
		["Vrste tkanine",          ["svila", "pamuk", "lan", "vuna"],                      2],
		["Plesovi",                ["valcer", "tango", "samba", "polka"],                  2],
		["Valute",                 ["euro", "dolar", "jen", "funta"],                      2],
		["Vitamini",               ["vitamin A", "vitamin B", "vitamin C", "vitamin D"],   2],
		["Planinski vrhovi",       ["Everest", "Kilimandžaro", "Mont Blanc", "Elbrus"],    2],
		["Slavni slikari",         ["Picasso", "Monet", "Da Vinci", "Rembrandt"],          2],
		["Slavni skladatelji",     ["Mozart", "Bach", "Beethoven", "Chopin"],              2],
		["Arheološki lokaliteti",  ["Stonehenge", "Pompeja", "Petra", "Machu Picchu"],     2],
		# v3: lubin → oslić (brancin and lubin are synonyms for the same fish)
		["Vrste ribe",             ["šaran", "pastrva", "brancin", "oslić"],               2],
		["Mitološka bića",         ["satir", "kentaur", "sfinga", "minotaur"],             2],
		["Književni žanrovi",      ["roman", "novela", "pripovijetka", "bajka"],           2],
		# v3: skok → štafeta (conflict with BLUE r3 "Sportski pojmovi s drugim značenjem")
		["Atletske discipline",    ["sprint", "bacanje", "maraton", "štafeta"],            2],
		["Vrste fotografije",      ["portret", "pejzaž", "makro", "reportaža"],            2],
		["Ekološki pojmovi",       ["ekosustav", "biom", "biodiverzitet", "prehrambeni lanac"], 2],
		# --- rank 3 ---
		["Mora nazvana po boji",   ["Crno", "Crveno", "Bijelo", "Žuto"],                   3],
		# v3: Ljiljana → Đurđica (Ljiljana isn't an exact homonym; đurđica is both name and plant)
		["Ime i biljka",           ["Ruža", "Iris", "Ljubica", "Đurđica"],                 3],
		["Crni/a ___",             ["humor", "petak", "kutija", "ovca"],                   3],
		["Bijeli/a ___",           ["zastava", "laža", "šum", "ovratnik"],                 3],
		["Brz kao ___",            ["munja", "vjetar", "soko", "metak"],                   3],
		# v3: grob → sjena (grob and groblje are near-synonyms)
		["Tiho kao ___",           ["miš", "groblje", "pustinja", "sjena"],                3],
		# v3: Medved → Medvedović (Medved is a Slovenian surname)
		["Hrvatska prezimena",     ["Medvedović", "Orao", "Sokol", "Kunić"],               3],
		# v3: brat → princ (conflict with YELLOW r1 "Rodbina"); vojnik → ekran (weak idiom)
		["Mali ___",               ["princ", "prst", "oglasi", "ekran"],                   3],
		# v3: mačak → grad, then grad → znanac (grad conflict with BLUE r3 "Homonimi (lakši)")
		["Stari ___",              ["zavjet", "kontinent", "znanac", "most"],              3],
		# v3: vatra → konj (divlja vatra not idiomatic; konj freed from YELLOW "Domaće životinje")
		["Divlji ___",             ["zapad", "mačka", "životinje", "konj"],                3],
		["Hladan kao ___",         ["led", "zmija", "stijena", "mramor"],                  3],
		# v3: baka → Metuzalem (authentic idiom)
		["Star kao ___",           ["Biblija", "svijet", "Metuzalem", "brda"],             3],
		["Završavaju na -ač",      ["pjevač", "igrač", "gledač", "slušač"],                3],
		["Imaju 'nos'",            ["lokomotiva", "čarapa", "čizma", "Pinokio"],           3],
		# v3: vrata → pivo (vrata conflict with PURPLE r3 "Tri ili više značenja")
		["Mogu se otvoriti",       ["pivo", "račun", "restoran", "prozor"],                3],
		# v3: leptir → oltar (leptir conflict with GREEN r2 "Kukci")
		["Imaju 'krilo'",          ["ptica", "vjetrenjača", "dvorac", "oltar"],            3],
		["Završavaju na -lo",      ["šilo", "krilo", "sedlo", "vrelo"],                    3],
		["Završavaju na -ar",      ["zubar", "mlinar", "ribar", "slastičar"],              3],
		# v3: pradjed → prabaka, pravijek → pradavni (more common words)
		["Počinju s 'pra-'",       ["praotac", "prabaka", "pradomovina", "pradavni"],      3],
	]

static func _blue_pool() -> Array:
	return [
		# --- rank 1 ---
		["Matematičke operacije",  ["zbrajanje", "oduzimanje", "množenje", "dijeljenje"],  1],
		["Krvne grupe",            ["A", "B", "AB", "0"],                                  1],
		["Vrste vjetra",           ["bura", "jugo", "maestral", "tramontana"],             1],
		["Kemijski elementi",      ["kisik", "dušik", "vodik", "ugljik"],                  1],
		["Književni rodovi",       ["lirika", "epika", "drama", "esej"],                   1],
		["Vrste energije",         ["kinetička", "potencijalna", "toplinska", "kemijska"],  1],
		# v3: temperatura → ubrzanje (conflict with BLUE r3 "Mogu biti visoki/e")
		["Fizikalne veličine",     ["masa", "sila", "brzina", "ubrzanje"],                 1],
		["Matematičke grane",      ["algebra", "geometrija", "analiza", "statistika"],     1],
		["Vrste mikroorganizama",  ["bakterija", "virus", "gljivica", "parazit"],          1],
		# --- rank 2 ---
		["Geološka razdoblja",     ["jura", "kreda", "silur", "devon"],                    2],
		["Geografski pojmovi",     ["poluotok", "tjesnac", "fjord", "laguna"],             2],
		["Arhitektonski stilovi",  ["barok", "gotika", "renesansa", "modernizam"],         2],
		["Filozofi",               ["Sokrat", "Platon", "Aristotel", "Nietzsche"],         2],
		["Programski jezici",      ["Python", "Java", "Rust", "Swift"],                    2],
		# v3: cirrus → cirus (Croatian spelling)
		["Vrste oblaka",           ["cirus", "kumulonimbus", "stratus", "nimbostratus"],   2],
		["Pisci nobelovci",        ["Hemingway", "Camus", "García Márquez", "Saramago"],   2],
		["Vrste čajeva",           ["matcha", "sencha", "darjeeling", "oolong"],           2],
		["Ekonomski sustavi",      ["kapitalizam", "socijalizam", "feudalizam", "merkantilizam"], 2],
		["Psihološki pojmovi",     ["ego", "alter ego", "id", "superego"],                 2],
		["Dijelovi DNA",           ["adenin", "timin", "gvanin", "citozin"],               2],
		["Poznate epohe",          ["antika", "srednji vijek", "prosvjetiteljstvo", "novi vijek"], 2],
		["Logički paradoksi",      ["lažac", "Zenonov", "Russellov", "sorit"],             2],
		["Lingvistički pojmovi",   ["morfem", "fonem", "sintaksa", "semantika"],           2],
		# v3: "Veliki prasak"/"Ciklički model" → prasak/ciklički (1-word consistency)
		["Teorije svemira",        ["prasak", "inflacija", "multisvemir", "ciklički"],     2],
		["Psihološki poremećaji",  ["fobija", "anksioznost", "narcizam", "paranoja"],      2],
		["Filozofski pojmovi",     ["dijalektika", "ontologija", "epistemologija", "metafizika"], 2],
		["Vrste zakona",           ["kazneni", "građanski", "ustavni", "međunarodni"],     2],
		["Astronomski pojmovi",    ["crna rupa", "pulsar", "kvasar", "maglica"],           2],
		["Teorije ličnosti",       ["psihoanaliza", "biheviorizam", "humanizam", "kognitivizam"], 2],
		["Vrste kemijskih veza",   ["ionska", "kovalentna", "metalna", "vodikova"],        2],
		["Književni stilovi",      ["realizam", "romantizam", "naturalizam", "ekspresionizam"], 2],
		["Vrste tla",              ["glina", "pijesak", "humus", "ilovača"],               2],
		["Psihološke obrane",      ["potiskivanje", "projekcija", "racionalizacija", "sublimacija"], 2],
		# v3: "tektonika ploča" → tektonika (1-word consistency)
		["Geološki procesi",       ["erozija", "sedimentacija", "vulkanizam", "tektonika"], 2],
		# v3: "srednja vrijednost" → prosjek (1-word consistency)
		["Statističke mjere",      ["prosjek", "medijan", "mod", "varijanca"],             2],
		["Retoričke tehnike",      ["ethos", "pathos", "logos", "kairos"],                 2],
		["Vrste diskursa",         ["narativni", "argumentativni", "opisni", "dijaloški"], 2],
		# --- rank 3 ---
		["Logičke operacije",      ["I", "ILI", "NE", "XOR"],                             3],
		["Može biti 'hladan/a'",   ["tuš", "rat", "znoj", "slučaj"],                       3],
		# v3: renamed from "Dvije različite stvari" → "Homonimi (lakši)"
		["Homonimi (lakši)",       ["list", "grad", "more", "pas"],                        3],
		["Krvni/a ___",            ["tlak", "slika", "sud", "grupa"],                      3],
		["___ polje",              ["magnetsko", "minsko", "naftno", "vidno"],             3],
		["Pasti kao ___",          ["kruška", "bomba", "grom", "snop"],                    3],
		["Jak kao ___",            ["vol", "hrast", "div", "bik"],                         3],
		# v3: Modra → Bijelo Brdo (Modra is in Slovakia, not Croatia)
		["Hrvatska mjesta",        ["Zelina", "Zlatar", "Bijelo Brdo", "Crna Mlaka"],      3],
		["Počinju s 'nad-'",       ["nadimak", "nadzor", "nadnica", "nadmudriti"],         3],
		["Mogu se slomiti",        ["val", "rekord", "tišina", "srce"],                    3],
		["Mogu se izgubiti",       ["strpljenje", "put", "smisao", "trag"],                3],
		# v3: Berlin → Oslo (length consistency)
		["Europske prijestolnice bez slova 'a'", ["Beč", "Rim", "Bern", "Oslo"],          3],
		["Slobodni/a ___",         ["pad", "udar", "stih", "tržište"],                     3],
		["Lagan kao ___",          ["pero", "oblak", "pahulja", "zrak"],                   3],
		["Tvrd kao ___",           ["granit", "dijamant", "čelik", "orah"],                3],
		# v3: hodnik → slovo ("mrtvi hodnik" not idiomatic; "mrtvo slovo na papiru" is)
		["Mrtvi/a/o ___",          ["kut", "slovo", "priroda", "trka"],                    3],
		["Skrivena životinja",     ["kompas", "klavir", "praksa", "evolucija"],            3],
		["Mogu biti visoki/e",     ["zgrada", "cijena", "temperatura", "ton"],             3],
		["Mogu se nositi",         ["teret", "haljina", "odgovornost", "dijete"],          3],
		# v3: more → žal (conflict with "Homonimi (lakši)")
		["Duboki/a/o ___",         ["glas", "san", "žal", "dah"],                          3],
		["Turcizmi",               ["šećer", "jastuk", "džep", "rakija"],                  3],
		["Germanizmi",             ["šalter", "šank", "štikla", "knedla"],                 3],
		["Talijanizmi",            ["pijaca", "špica", "pršut", "lanterna"],               3],
		["Sportski pojmovi s drugim značenjem", ["gol", "skok", "lopta", "koš"],          3],
		["Kartaške figure s drugim značenjem",  ["kralj", "dama", "pop", "as"],            3],
		# v3: premet → pregled (more common word)
		["Počinju s 'pre-'",       ["prelaz", "pregled", "premijer", "predmet"],           3],
		["Počinju s 'pod-'",       ["podzemlje", "podsjetnik", "podloga", "podrum"],       3],
		["Suprotno s prefiksom 'ne-'", ["red", "mir", "prilika", "sklad"],                 3],
		["Crvena ___",             ["nit", "karta", "knjiga", "vrpca"],                    3],
		["Tvrda ___",              ["škola", "valuta", "disk", "riječ"],                   3],
		# v3: mahuna → dobrodošlica ("topla mahuna" not idiomatic)
		["Topla ___",              ["preporuka", "dobrodošlica", "fronta", "postelja"],    3],
		# v3: srce → oči (srce conflict with "Mogu se slomiti", same rank)
		["Otvoreno ___",           ["nebo", "oči", "pismo", "prvenstvo"],                  3],
	]

static func _purple_pool() -> Array:
	return [
		# --- rank 1 ---
		["Latinske izreke",        ["carpe diem", "veni vidi vici", "cogito ergo sum", "memento mori"], 1],
		["Retoričke figure",       ["metafora", "metonimija", "sinegdoha", "oksimoron"],  1],
		["Filozofski pravci",      ["empirizam", "racionalizam", "nihilizam", "egzistencijalizam"], 1],
		["Vrste argumentacije",    ["dedukcija", "indukcija", "abdukcija", "analogija"],  1],
		["Poetski žanrovi",        ["elegija", "oda", "sonet", "epigram"],                1],
		# v3: vjera → uvjerenje (conflict with PURPLE r3 "Ženska imena i pojmovi")
		["Epistemološki pojmovi",  ["znanje", "uvjerenje", "opravdanje", "istina"],       1],
		["Latinski prefiks 'anti-'", ["antiteza", "antikrist", "antibiotik", "antipod"],  1],
		["Latinski prefiks 'super-'", ["superlativ", "supermen", "superiornost", "supervizor"], 1],
		["Latinski prefiks 'sub-'",  ["subverzija", "subordinacija", "subjekt", "subkultura"], 1],
		["Latinski prefiks 'in-'",   ["inverzija", "intuicija", "indikator", "integracija"], 1],
		# v3: trolist → triatlon (cleaner association)
		["Grčki brojčani prefiks", ["monolog", "dijalog", "triatlon", "tetraedar"],       1],
		["Tipovi rime",            ["parna", "ukrštena", "obgrljena", "slobodna"],        1],
		# --- rank 2 ---
		["Vrste pamćenja",         ["epizodično", "semantičko", "proceduralno", "radno"], 2],
		["Teorije uma",            ["funkcionalizam", "dualizam", "fizikalizam", "eliminativizam"], 2],
		["Evolucijski mehanizmi",  ["selekcija", "mutacija", "drift", "migracija"],       2],
		# v3: "mijelinska ovojnica" → mijelin (1-word consistency)
		["Neurološki pojmovi",     ["sinapsa", "akson", "dendrit", "mijelin"],            2],
		["Tipovi naracije",        ["sveznajući", "prvoličan", "drugoličan", "nepouzdan"], 2],
		["Glazbene ljestvice",     ["dorska", "frigijska", "lidijska", "miksolidijska"],  2],
		["Stilske figure",         ["hiperbola", "litota", "eufonija", "anadiploza"],     2],
		["Kognitivne pristranosti",["potvrđivanje", "sidrenje", "retrospekcija", "dostupnost"], 2],
		["Semiotički pojmovi",     ["znak", "označitelj", "označeno", "referent"],        2],
		["Pravni pojmovi",         ["kazuistika", "precedent", "interpretacija", "supsidijarnost"], 2],
		# v3: "vrlinska etika" → aretaika (1-word consistency)
		["Teorije pravde",         ["utilitarizam", "deontologija", "aretaika", "kontraktualizam"], 2],
		# v3: Fourierov → Eulerov (cleaner theorem)
		["Matematičke teoreme",    ["Pitagorin", "Fermatov", "Bayesov", "Eulerov"],       2],
		# v3: "Vrste dokaza" REMOVED (overlap with PURPLE r1 "Vrste argumentacije")
		["Matematička logika",     ["aksiom", "teorem", "dokaz", "lema"],                 2],
		# v3: qualia → kvalije (Croatian standard)
		["Filozofija uma",         ["svjesnost", "namjernost", "kvalije", "subjektivnost"], 2],
		# --- rank 3 ---
		["Metrika u poeziji",      ["jamb", "trohej", "daktil", "amfibrah"],              3],
		["Zvukovne figure",        ["aliteracija", "asonanca", "onomatopeja", "paronomazija"], 3],
		["Kvantna fizika",         ["kvark", "gluon", "bozon", "fermion"],                3],
		["Ekonomski paradoksi",    ["Giffenov", "Veblenov", "Simpsonov", "Condorcetov"],  3],
		["Tipovi silogizma",       ["Barbara", "Celarent", "Darii", "Ferio"],             3],
		# v3: "Lyapunov eksponent" → entropija (1-word consistency)
		["Teorije kaosa",          ["atraktor", "bifurkacija", "fraktal", "entropija"],   3],
		["Lingvistički univerzali",["arbitrarnost", "produktivnost", "pomak", "dvostruka artikulacija"], 3],
		["Fenomenološki pojmovi",  ["intencionalnost", "epoché", "intersubjektivnost", "horizont"], 3],
		["Sociolingvistički pojmovi", ["diglosija", "pidžin", "kreolski", "kodna izmjena"], 3],
		# v3: interpretacija → razumijevanje (conflict with PURPLE r2 "Pravni pojmovi")
		["Hermeneutički pojmovi",  ["hermeneutički krug", "predrazumijevanje", "razumijevanje", "tekst"], 3],
		# v3: pragmatička/deflacijska → pragmatizam/deflacionizam (consistent noun form)
		["Teorije istine",         ["korespondencija", "koherencija", "pragmatizam", "deflacionizam"], 3],
		["Vrste modaliteta",       ["nužnost", "mogućnost", "kontingentnost", "nemogućnost"], 3],
		# v3: renamed from "Dvije različite stvari" → "Homonimi (teži)"
		["Homonimi (teži)",        ["bit", "mast", "vez", "kosa"],                        3],
		["Otok = grad",            ["Hvar", "Krk", "Rab", "Vis"],                         3],
		["___ kamen",              ["bubrežni", "žučni", "temeljni", "dragi"],            3],
		["Vruća ___",              ["tema", "linija", "čokolada", "točka"],               3],
		["Crven kao ___",          ["rak", "cigla", "mak", "krv"],                        3],
		["Spavati kao ___",        ["klada", "beba", "top", "anđeo"],                     3],
		["Zanati kao prezimena",   ["Kovač", "Kolar", "Tesar", "Lončar"],                 3],
		# v3: četverokut → četveronožac (conflict with YELLOW r1 "Oblici")
		["Krije se broj",          ["jednorog", "dvoboj", "trijumf", "četveronožac"],     3],
		["Krije se nota",          ["dobar", "redar", "misija", "fakultet"],              3],
		["Zlatna ___",             ["groznica", "sredina", "ribica", "medalja"],           3],
		# v3: znanje → volja (conflict with PURPLE r1 "Epistemološki pojmovi")
		["Suprotno s prefiksom 'ne-' (jaki)", ["sreća", "pravda", "volja", "moć"],        3],
		# v3: Slava → Nada (Slava rare today); vjera freed since Epistemološki now uses uvjerenje
		["Ženska imena i pojmovi", ["Vjera", "Sloboda", "Nada", "Zora"],                  3],
		["Crna ___",               ["burza", "magija", "kronika", "lista"],               3],
		# v3: nada → kraj (conflict with "Ženska imena i pojmovi", same rank)
		["Bez + ___",              ["bol", "obzir", "um", "kraj"],                        3],
		# v3: planina → mlinski kamen (authentic idiom)
		["Težak kao ___",          ["olovo", "grijeh", "mlinski kamen", "sudbina"],       3],
		["Oštar kao ___",          ["britva", "igla", "mač", "jezik"],                    3],
		# v3: "Pridjevi političkih struja" REMOVED (weak category)
		["Mogu biti živi/e",       ["biće", "srebro", "meso", "pitanje"],                 3],
		# v3: građanski → vjerski (conflict with BLUE r2 "Vrste zakona")
		["___ rat",                ["hladni", "domovinski", "zvjezdani", "vjerski"],      3],
		# v3: ananas → ranac (conflict with GREEN r1 "Egzotično voće")
		["Skrivena Ana",           ["banana", "kanal", "ranac", "fontana"],               3],
		# v3: sliva → perspektiva (sliva is a verb form, not a noun)
		["Skrivena Iva",           ["divan", "kriva", "privatan", "perspektiva"],         3],
		["Skrivena Pula",          ["kapula", "populacija", "kopula", "manipulacija"],    3],
		["Tri ili više značenja",  ["luk", "vrata", "oko", "ključ"],                      3],
		["Hrvatski i engleski — različito značenje", ["kola", "sok", "ten", "sat"],      3],
	]

static func get_single_puzzle() -> Puzzle:
	var raw_pools: Array = [_yellow_pool(), _green_pool(), _blue_pool(), _purple_pool()]
	var diffs: Array = [Difficulty.YELLOW, Difficulty.GREEN, Difficulty.BLUE, Difficulty.PURPLE]
	var extras: Dictionary = _category_extras()
	var weights: Array = [25, 45, 30]

	var pool_buckets: Array = []
	for pool in raw_pools:
		var buckets: Dictionary = {1: [], 2: [], 3: []}
		for entry in pool:
			var rank: int = entry[2] if entry.size() > 2 else 2
			buckets[rank].append(entry)
		for r in [1, 2, 3]:
			buckets[r].shuffle()
		pool_buckets.append(buckets)

	var cats: Array = []
	var template_used := false
	for p in 4:
		var entry: Array = _weighted_pick(pool_buckets[p], weights)
		if _is_frazem_template(entry[0]) and template_used:
			entry = _pick_non_template_or_fallback(pool_buckets[p], entry)
		if _is_frazem_template(entry[0]):
			template_used = true
		var cat: Category = Category.new(entry[0], _to_typed(entry[1]), diffs[p])
		cat.rank  = entry[2] if entry.size() > 2 else 2
		cat.extra = extras.get(entry[0], "")
		cats.append(cat)

	var puzzle := Puzzle.new("Dnevni izazov", cats)
	if OS.is_debug_build():
		_assert_no_word_overlap([puzzle])
	return puzzle

static func get_puzzles() -> Array:
	var raw_pools: Array = [_yellow_pool(), _green_pool(), _blue_pool(), _purple_pool()]
	var diffs: Array = [Difficulty.YELLOW, Difficulty.GREEN, Difficulty.BLUE, Difficulty.PURPLE]
	var extras: Dictionary = _category_extras()

	# Build shuffled rank buckets for each pool.
	var pool_buckets: Array = []
	for pool in raw_pools:
		var buckets: Dictionary = {1: [], 2: [], 3: []}
		for entry in pool:
			var rank: int = entry[2] if entry.size() > 2 else 2
			buckets[rank].append(entry)
		for r in [1, 2, 3]:
			buckets[r].shuffle()
		pool_buckets.append(buckets)

	var puzzles: Array = []
	for i in PUZZLE_COUNT:
		var weights: Array = RANK_WEIGHTS[i]
		var cats: Array = []
		var template_used := false
		for p in 4:
			var entry: Array = _weighted_pick(pool_buckets[p], weights)
			if _is_frazem_template(entry[0]) and template_used:
				entry = _pick_non_template_or_fallback(pool_buckets[p], entry)
			if _is_frazem_template(entry[0]):
				template_used = true
			var cat: Category = Category.new(entry[0], _to_typed(entry[1]), diffs[p])
			cat.rank  = entry[2] if entry.size() > 2 else 2
			cat.extra = extras.get(entry[0], "")
			cats.append(cat)
		puzzles.append(Puzzle.new("Slagalica #%d" % (i + 1), cats))

	if OS.is_debug_build():
		_assert_no_word_overlap(puzzles)

	return puzzles

# Pick and remove one entry from buckets using weighted rank odds [w1, w2, w3].
# Falls back to any non-empty bucket if the chosen one is exhausted.
static func _weighted_pick(buckets: Dictionary, weights: Array) -> Array:
	var roll: int = randi() % 100
	var chosen_rank: int = 1
	var cumulative: int = 0
	for idx in 3:
		cumulative += weights[idx]
		if roll < cumulative:
			chosen_rank = idx + 1
			break

	if buckets[chosen_rank].is_empty():
		for fallback in [1, 2, 3]:
			if not buckets[fallback].is_empty():
				chosen_rank = fallback
				break

	var entry: Array = buckets[chosen_rank].back()
	buckets[chosen_rank].pop_back()
	return entry

# Returns true for "X ___" and "___ X" frazem-template category names.
# Used to enforce max-1-template-per-puzzle rule.
static func _is_frazem_template(cat_name: String) -> bool:
	return "___" in cat_name

# If a second frazem-template would land in the same puzzle, tries to swap it
# for a non-template from the same pool. Falls back to the original entry if
# no non-template is available.
static func _pick_non_template_or_fallback(buckets: Dictionary, rejected: Array) -> Array:
	var rank: int = rejected[2] if rejected.size() > 2 else 2
	buckets[rank].push_back(rejected)  # put rejected back

	for r in [1, 2, 3]:
		for i in range(buckets[r].size() - 1, -1, -1):
			if not _is_frazem_template(buckets[r][i][0]):
				var result: Array = buckets[r][i]
				buckets[r].remove_at(i)
				return result

	# All remaining entries are templates — pop the rejected entry and accept it
	buckets[rank].pop_back()
	return rejected

static func _assert_no_word_overlap(puzzles: Array) -> void:
	for puzzle in puzzles:
		var seen: Dictionary = {}
		for cat in puzzle.categories:
			for word in cat.words:
				assert(not seen.has(word),
					"Duplicate word '%s' in puzzle '%s' (categories: '%s' and '%s')" \
					% [word, puzzle.title, seen.get(word, "?"), cat.name])
				seen[word] = cat.name

static func _category_extras() -> Dictionary:
	return {
		# GREEN r3
		"Ime i biljka":                          "Ista riječ: žensko ime i biljka",
		"Hrvatska prezimena":                    "Izgledaju kao životinje, ali su prezimena",
		"Završavaju na -ač":                     "Sve riječi završavaju sufiksom -ač",
		"Imaju 'nos'":                           "Sve imaju nos — doslovno ili u obliku",
		"Imaju 'krilo'":                         "Sve imaju krilo — doslovno ili metaforički",
		"Počinju s 'pra-'":                      "Sve riječi imaju prefiks pra-",
		# BLUE r3
		"Homonimi (lakši)":                      "Jedna riječ, dva potpuno različita značenja",
		"Hrvatska mjesta":                       "Izgledaju kao boje, ali su geografska mjesta",
		"Počinju s 'nad-'":                      "Sve riječi imaju prefiks nad-",
		"Europske prijestolnice bez slova 'a'":  "Prijestolnice koje ne sadrže slovo 'a'",
		"Skrivena životinja":                    "U svakoj se riječi krije naziv životinje",
		"Turcizmi":                              "Riječi turskog podrijetla",
		"Germanizmi":                            "Riječi njemačkog podrijetla",
		"Talijanizmi":                           "Riječi talijanskog podrijetla",
		"Sportski pojmovi s drugim značenjem":   "Svaka je i sport i nešto drugo",
		"Kartaške figure s drugim značenjem":    "Karte ili nešto drugo?",
		# PURPLE r1
		"Latinski prefiks 'anti-'":             "Sve počinju s 'anti-' (protiv)",
		"Latinski prefiks 'super-'":            "Sve počinju s 'super-' (iznad)",
		"Latinski prefiks 'sub-'":              "Sve počinju s 'sub-' (ispod)",
		"Latinski prefiks 'in-'":               "Sve počinju s 'in-' (u, ne)",
		"Grčki brojčani prefiks":               "Skriven broj 1, 2, 3, 4 u prefiksu",
		# PURPLE r3
		"Homonimi (teži)":                       "Jedna riječ, dva potpuno različita značenja",
		"Otok = grad":                           "Hrvatski otoci koji su i gradovi",
		"Zanati kao prezimena":                  "Stara hrvatska prezimena nazvana po zanatima",
		"Krije se broj":                         "U svakoj se riječi krije broj",
		"Krije se nota":                         "U svakoj se riječi krije glazbena nota",
		"Ženska imena i pojmovi":               "Ista riječ: žensko ime i apstraktni pojam",
		"Bez + ___":                             "S prefiksom 'bez-' postaju nove riječi",
		"Skrivena Ana":                          "U svakoj se riječi krije ime ANA",
		"Skrivena Iva":                          "U svakoj se riječi krije ime IVA",
		"Skrivena Pula":                         "U svakoj se riječi krije grad PULA",
		"Tri ili više značenja":                 "Svaka riječ ima 3+ različita značenja",
		"Hrvatski i engleski — različito značenje": "Iste slova, različito značenje na hrv. i engl.",
	}

static func _to_typed(arr: Array) -> Array[String]:
	var result: Array[String] = []
	result.assign(arr)
	return result
