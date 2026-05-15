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
		["Boje",                   ["bijela", "crna", "ljubičasta", "ružičasta"],           1],
		["Godišnja doba",          ["proljeće", "ljeto", "jesen", "zima"],                  1],
		["Domaće životinje",       ["krava", "svinja", "magarac", "koza"],                  1],
		["Voće",                   ["jabuka", "breskva", "šljiva", "trešnja"],              1],
		["Povrće",                 ["mrkva", "krumpir", "češnjak", "špinat"],               1],
		["Dani u tjednu",          ["ponedjeljak", "utorak", "srijeda", "četvrtak"],        1],
		["Dijelovi tijela",        ["ruka", "noga", "glava", "leđa"],                       1],
		["Prijevozna sredstva",    ["auto", "vlak", "avion", "brod"],                       1],
		["Odjeća",                 ["majica", "hlače", "suknja", "jakna"],                  1],
		["Pića",                   ["voda", "mlijeko", "čaj", "kava"],                      1],
		["Oblici",                 ["krug", "kvadrat", "trokut", "pravokutnik"],            1],
		["Osjećaji",               ["veselje", "tuga", "strah", "ljutnja"],                 1],
		["Dijelovi lica",          ["čelo", "nos", "brada", "obrazi"],                      1],
		["Namještaj",              ["stol", "stolica", "krevet", "ormar"],                  1],
		["Bobičasto voće",         ["jagoda", "malina", "borovnica", "kupina"],             1],
		["Cvijeće",                ["orhideja", "tulipan", "karanfil", "suncokret"],        1],
		["Kućni ljubimci",         ["zamorac", "papiga", "hrčak", "zec"],                   1],
		["Rodbina",                ["majka", "otac", "sestra", "brat"],                     1],
		["Dijelovi dana",          ["jutro", "podne", "večer", "noć"],                      1],
		["Školski pribor",         ["olovka", "ravnalo", "guma", "šestar"],                 1],
		# --- rank 2 ---
		["Sportovi",               ["plivanje", "trčanje", "biciklizam", "gimnastika"],     2],
		["Doručak",                ["jaje", "tost", "jogurt", "žitarice"],                  2],
		["Kućanski aparati",       ["hladnjak", "perilica", "mikrovalna", "usisavač"],      2],
		["Dijelovi kuće",          ["kuhinja", "spavaonica", "blagovaonica", "kupaonica"],  2],
		["Planeti",                ["Mars", "Venera", "Saturn", "Jupiter"],                 2],
		["Instrumenti",            ["gitara", "violina", "truba", "flauta"],                2],
		["Drveće",                 ["lipa", "bukva", "bor", "javor"],                       2],
		["Alati",                  ["čekić", "pila", "odvijač", "kliješta"],                2],
		["Metali",                 ["zlato", "aluminij", "željezo", "bakar"],               2],
		["Školski predmeti",       ["matematika", "povijest", "geografija", "biologija"],   2],
		["Zimski sportovi",        ["skijanje", "sanjkanje", "hokej", "klizanje"],          2],
		["Životinje u šumi",       ["medvjed", "vuk", "jelen", "lisica"],                   2],
		["Tople boje",             ["narančasta", "žuta", "crvena", "smeđa"],               2],
		["Vrste mesa",             ["piletina", "govedina", "svinjetina", "janjetina"],     2],
		["Nakit",                  ["prsten", "ogrlica", "narukvica", "naušnica"],          2],
		["Vrtno povrće",           ["rajčica", "paprika", "tikvica", "patlidžan"],          2],
		["Načini kuhanja",         ["pečenje", "kuhanje", "prženje", "dinstanje"],          2],
		["Zimska odjeća",          ["šal", "kapa", "rukavice", "kaput"],                    2],
		["Dijelovi bicikla",       ["kotač", "pedale", "upravljač", "sjedalo"],             2],
		["Vrste juhe",             ["goveđa", "kokošja", "riblja", "povrtna"],              2],
		# --- rank 3 ---
		["Oceani",                 ["Tihi", "Atlantski", "Indijski", "Arktički"],           3],
		["Morski sisavci",         ["dupin", "kit", "foka", "morž"],                        3],
		["Ljetni sportovi",        ["vaterpolo", "jedriličarstvo", "atletika", "veslanje"],  3],
		["Ptice na farmi",         ["pijetao", "guska", "purica", "patka"],                 3],
		["Morski beskralježnjaci", ["hobotnica", "lignja", "meduza", "koralj"],             3],
		["Vrste sladoleda",        ["karamel", "vanilija", "pistacija", "lješnjak"],        3],
		["Završavaju na -ost",     ["radost", "mladost", "ljubaznost", "hrabrost"],         3],
		["Završavaju na -ica",     ["matica", "ulica", "granica", "klupica"],               3],
		["Odmilice za rodbinu",    ["mama", "tata", "baka", "deda"],                        3],
		["Završavaju na -aj",      ["tečaj", "sjaj", "običaj", "pokušaj"],                  3],
		["Počinju s 'vodo-'",      ["vodopad", "vodozemac", "vodomar", "vodoinstalater"],   3],
		["Mlade životinje",        ["mače", "štene", "pile", "tele"],                       3],
		["Kuhinjske mjere",        ["žličica", "šalica", "gram", "dekagram"],               3],
		["Imaju 'rep'",            ["majmun", "kometa", "štakor", "paun"],                  3],
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
		["Hrvatski povijesni vladari", ["Tomislav", "Zvonimir", "Krešimir", "Petar"],      1],
		["Hrvatski otoci",         ["Brač", "Korčula", "Mljet", "Pag"],                    1],
		["Hrvatske planine",       ["Velebit", "Učka", "Dinara", "Biokovo"],               1],
		["Hrvatski nacionalni parkovi", ["Plitvice", "Kornati", "Brijuni", "Risnjak"],     1],
		["Slavni hrvatski sportaši", ["Modrić", "Ivanišević", "Kostelić", "Šuker"],        1],
		["Hrvatski književnici",   ["Krleža", "Marinković", "Šenoa", "Šimić"],             1],
		["Hrvatski izumi",         ["kravata", "padobran", "mehanička olovka", "torpedo"], 1],
		# --- rank 2 ---
		["Hrvatska jela",          ["sarma", "peka", "pašticada", "burek"],                2],
		["Kukci",                  ["pčela", "mrav", "leptir", "kornjaš"],                 2],
		["Začini",                 ["papar", "sol", "cimet", "kurkuma"],                   2],
		["Ptice selice",           ["roda", "lastavica", "čaplja", "kukavica"],            2],
		["Rijeke Hrvatske",        ["Sava", "Drava", "Kupa", "Neretva"],                   2],
		["Materijali",             ["drvo", "staklo", "plastika", "kamen"],                2],
		["Dijelovi automobila",    ["motor", "mjenjač", "kočnica", "volan"],               2],
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
		["Vrste ribe",             ["šaran", "pastrva", "brancin", "oslić"],               2],
		["Mitološka bića",         ["satir", "kentaur", "sfinga", "minotaur"],             2],
		["Književni žanrovi",      ["roman", "novela", "pripovijetka", "bajka"],           2],
		["Atletske discipline",    ["sprint", "bacanje", "maraton", "štafeta"],            2],
		["Vrste fotografije",      ["portret", "pejzaž", "makro", "reportaža"],            2],
		["Ekološki pojmovi",       ["ekosustav", "biom", "biodiverzitet", "prehrambeni lanac"], 2],
		# --- rank 3 ---
		["Mora nazvana po boji",   ["Crno", "Crveno", "Bijelo", "Žuto"],                   3],
		["Ime i biljka",           ["Ruža", "Iris", "Ljubica", "Đurđica"],                 3],
		["Crni/a ___",             ["humor", "petak", "kutija", "ovca"],                   3],
		["Bijeli/a ___",           ["zastava", "laža", "šum", "ovratnik"],                 3],
		["Brz kao ___",            ["munja", "vjetar", "soko", "metak"],                   3],
		["Tiho kao ___",           ["miš", "groblje", "pustinja", "sjena"],                3],
		["Hrvatska prezimena",     ["Medvedović", "Orao", "Sokol", "Kunić"],               3],
		["Mali ___",               ["princ", "prst", "oglasi", "ekran"],                   3],
		["Stari ___",              ["zavjet", "kontinent", "znanac", "most"],              3],
		["Divlji ___",             ["zapad", "mačka", "životinje", "konj"],                3],
		["Hladan kao ___",         ["led", "zmija", "stijena", "mramor"],                  3],
		["Star kao ___",           ["Biblija", "svijet", "Metuzalem", "brda"],             3],
		["Završavaju na -ač",      ["pjevač", "igrač", "gledač", "slušač"],                3],
		["Imaju 'nos'",            ["lokomotiva", "čarapa", "čizma", "Pinokio"],           3],
		["Mogu se otvoriti",       ["pivo", "račun", "restoran", "prozor"],                3],
		["Imaju 'krilo'",          ["ptica", "vjetrenjača", "dvorac", "oltar"],            3],
		["Završavaju na -lo",      ["šilo", "krilo", "sedlo", "vrelo"],                    3],
		["Završavaju na -ar",      ["zubar", "mlinar", "ribar", "slastičar"],              3],
		["Počinju s 'pra-'",       ["praotac", "prabaka", "pradomovina", "pradavni"],      3],
		["Skrivena Mira",          ["mirakul", "admiral", "smiraj", "emirat"],             3],
		["Glazbeni i drugi pojmovi", ["akord", "tempo", "kvarta", "pauza"],               3],
		["Homonimi (osnovni)",     ["rod", "rok", "klin", "kvaka"],                        3],
		["Mogu prethoditi: PUT",   ["dalek", "kratak", "asfaltni", "životni"],            3],
		["Načini da kažeš NE",     ["nipošto", "nikako", "baš ne", "nema šanse"],         3],
		["Načini da kažeš DA",     ["naravno", "svakako", "apsolutno", "definitivno"],    3],
		["Načini smijeha",         ["hihotati", "kikotati", "cerekati", "grohotati"],      3],
		["Načini gledanja",        ["zuriti", "škiljiti", "piljiti", "buljiti"],           3],
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
		["Fizikalne veličine",     ["masa", "sila", "brzina", "ubrzanje"],                 1],
		["Matematičke grane",      ["algebra", "geometrija", "analiza", "statistika"],     1],
		["Vrste mikroorganizama",  ["bakterija", "virus", "gljivica", "parazit"],          1],
		["Anatomski organi",       ["jetra", "pluća", "bubreg", "slezena"],               1],
		["Vrste zubi",             ["sjekutić", "očnjak", "pretkutnjak", "kutnjak"],       1],
		["Krvne stanice",          ["eritrocit", "leukocit", "trombocit", "limfocit"],     1],
		["Vrste tkiva",            ["epitelno", "mišićno", "vezivno", "živčano"],          1],
		["Vrste leća",             ["konkavna", "konveksna", "sferna", "asferična"],       1],
		["Geometrijski pojmovi",   ["tangenta", "dijagonala", "perimetar", "površina"],   1],
		["Vrste rečenica",         ["izjavna", "upitna", "usklična", "niječna"],           1],
		["Hrvatski padeži",        ["nominativ", "genitiv", "dativ", "akuzativ"],          1],
		["Glagolska vremena",      ["prezent", "perfekt", "aorist", "futur"],              1],
		# --- rank 2 ---
		["Geološka razdoblja",     ["jura", "kreda", "silur", "devon"],                    2],
		["Geografski pojmovi",     ["poluotok", "tjesnac", "fjord", "laguna"],             2],
		["Arhitektonski stilovi",  ["barok", "gotika", "renesansa", "modernizam"],         2],
		["Filozofi",               ["Sokrat", "Platon", "Aristotel", "Nietzsche"],         2],
		["Programski jezici",      ["Python", "Java", "Rust", "Swift"],                    2],
		["Vrste oblaka",           ["cirus", "kumulonimbus", "stratus", "nimbostratus"],   2],
		["Pisci nobelovci",        ["Hemingway", "Camus", "García Márquez", "Saramago"],   2],
		["Vrste čajeva",           ["matcha", "sencha", "darjeeling", "oolong"],           2],
		["Ekonomski sustavi",      ["kapitalizam", "socijalizam", "feudalizam", "merkantilizam"], 2],
		["Psihološki pojmovi",     ["ego", "alter ego", "id", "superego"],                 2],
		["Dijelovi DNA",           ["adenin", "timin", "gvanin", "citozin"],               2],
		["Poznate epohe",          ["antika", "srednji vijek", "prosvjetiteljstvo", "novi vijek"], 2],
		["Logički paradoksi",      ["lažac", "Zenonov", "Russellov", "sorit"],             2],
		["Lingvistički pojmovi",   ["morfem", "fonem", "sintaksa", "semantika"],           2],
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
		["Geološki procesi",       ["erozija", "sedimentacija", "vulkanizam", "tektonika"], 2],
		["Statističke mjere",      ["prosjek", "medijan", "mod", "varijanca"],             2],
		["Retoričke tehnike",      ["ethos", "pathos", "logos", "kairos"],                 2],
		["Vrste diskursa",         ["narativni", "argumentativni", "opisni", "dijaloški"], 2],
		# --- rank 3 ---
		["Logičke operacije",      ["I", "ILI", "NE", "XOR"],                             3],
		["Može biti 'hladan/a'",   ["tuš", "rat", "znoj", "slučaj"],                       3],
		["Homonimi (lakši)",       ["list", "grad", "more", "pas"],                        3],
		["Krvni/a ___",            ["tlak", "slika", "sud", "grupa"],                      3],
		["___ polje",              ["magnetsko", "minsko", "naftno", "vidno"],             3],
		["Pasti kao ___",          ["kruška", "bomba", "grom", "snop"],                    3],
		["Jak kao ___",            ["vol", "hrast", "div", "bik"],                         3],
		["Hrvatska mjesta",        ["Zelina", "Zlatar", "Bijelo Brdo", "Crna Mlaka"],      3],
		["Počinju s 'nad-'",       ["nadimak", "nadzor", "nadnica", "nadmudriti"],         3],
		["Mogu se slomiti",        ["val", "rekord", "tišina", "srce"],                    3],
		["Mogu se izgubiti",       ["strpljenje", "put", "smisao", "trag"],                3],
		["Europske prijestolnice bez slova 'a'", ["Beč", "Rim", "Bern", "Oslo"],          3],
		["Slobodni/a ___",         ["pad", "udar", "stih", "tržište"],                     3],
		["Lagan kao ___",          ["pero", "oblak", "pahulja", "zrak"],                   3],
		["Tvrd kao ___",           ["granit", "dijamant", "čelik", "orah"],                3],
		["Mrtvi/a/o ___",          ["kut", "slovo", "priroda", "trka"],                    3],
		["Skrivena životinja",     ["kompas", "klavir", "praksa", "evolucija"],            3],
		["Mogu biti visoki/e",     ["zgrada", "cijena", "temperatura", "ton"],             3],
		["Mogu se nositi",         ["teret", "haljina", "odgovornost", "dijete"],          3],
		["Duboki/a/o ___",         ["glas", "san", "žal", "dah"],                          3],
		["Turcizmi",               ["šećer", "jastuk", "džep", "rakija"],                  3],
		["Germanizmi",             ["šalter", "šank", "štikla", "knedla"],                 3],
		["Talijanizmi",            ["pijaca", "špica", "pršut", "lanterna"],               3],
		["Sportski pojmovi s drugim značenjem", ["gol", "skok", "lopta", "koš"],          3],
		["Kartaške figure s drugim značenjem",  ["kralj", "dama", "pop", "as"],            3],
		["Počinju s 'pre-'",       ["prelaz", "pregled", "premijer", "predmet"],           3],
		["Počinju s 'pod-'",       ["podzemlje", "podsjetnik", "podloga", "podrum"],       3],
		["Suprotno s prefiksom 'ne-'", ["red", "mir", "prilika", "sklad"],                 3],
		["Crvena ___",             ["nit", "karta", "knjiga", "vrpca"],                    3],
		["Tvrda ___",              ["škola", "valuta", "disk", "riječ"],                   3],
		["Topla ___",              ["preporuka", "dobrodošlica", "fronta", "postelja"],    3],
		["Otvoreno ___",           ["nebo", "oči", "pismo", "prvenstvo"],                  3],
		["Šahovski potezi s drugim značenjem", ["rokada", "gambit", "matiranje", "remi"], 3],
		["Skriven Rim",            ["krimić", "grimasa", "primjerak", "rimovati"],         3],
		["Mogu prethoditi: SUSTAV", ["solarni", "operativni", "imuni", "nervni"],          3],
		["Mogu prethoditi: STIL",  ["plivački", "pisani", "borbeni", "umjetnički"],        3],
		["Mogu slijediti: PUNI",   ["mjesec", "pansion", "gas", "pogodak"],                3],
		["Načini hodanja",         ["šuljati se", "gegati se", "koračati", "tabati"],      3],
		["Načini govora",          ["mrmljati", "šaptati", "galamiti", "brbljati"],        3],
		["Imaju 'rupu'",           ["krafna", "tunel", "sito", "gumb"],                   3],
		["Mogu rezati",            ["škare", "sjekira", "kosilica", "turpija"],            3],
		["Glagoli za 'uništiti'",  ["razoriti", "razbiti", "srušiti", "demolirati"],      3],
		["Glagoli za 'stvoriti'",  ["načiniti", "izraditi", "sagraditi", "kreirati"],     3],
		["Imaju okrugli oblik",    ["kugla", "tanjur", "tipka", "novčić"],                3],
	]

static func _purple_pool() -> Array:
	return [
		# --- rank 1 ---
		["Latinske izreke",        ["carpe diem", "veni vidi vici", "cogito ergo sum", "memento mori"], 1],
		["Retoričke figure",       ["metafora", "metonimija", "sinegdoha", "oksimoron"],  1],
		["Filozofski pravci",      ["empirizam", "racionalizam", "nihilizam", "egzistencijalizam"], 1],
		["Vrste argumentacije",    ["dedukcija", "indukcija", "abdukcija", "analogija"],  1],
		["Poetski žanrovi",        ["elegija", "oda", "sonet", "epigram"],                1],
		["Epistemološki pojmovi",  ["znanje", "uvjerenje", "opravdanje", "istina"],       1],
		["Latinski prefiks 'anti-'", ["antiteza", "antikrist", "antibiotik", "antipod"],  1],
		["Latinski prefiks 'super-'", ["superlativ", "supermen", "superiornost", "supervizor"], 1],
		["Latinski prefiks 'sub-'",  ["subverzija", "subordinacija", "subjekt", "subkultura"], 1],
		["Latinski prefiks 'in-'",   ["inverzija", "intuicija", "indikator", "integracija"], 1],
		["Grčki brojčani prefiks", ["monolog", "dijalog", "triatlon", "tetraedar"],       1],
		["Tipovi rime",            ["parna", "ukrštena", "obgrljena", "slobodna"],        1],
		["Vrste umjetničkih -izama", ["impresionizam", "kubizam", "futurizam", "dadaizam"], 1],
		["Filozofska pitanja",     ["tko", "što", "kako", "zašto"],                       1],
		["Kategorički imperativi", ["univerzalnost", "dostojanstvo", "autonomija", "samosvrha"], 1],
		["Latinski prefiks 'trans-'", ["transcendencija", "transformacija", "transparentnost", "transmutacija"], 1],
		["Grčki prefiks 'auto-'",  ["automatizam", "autobiografija", "autohtoni", "autostop"], 1],
		# --- rank 2 ---
		["Vrste pamćenja",         ["epizodično", "semantičko", "proceduralno", "radno"], 2],
		["Teorije uma",            ["funkcionalizam", "dualizam", "fizikalizam", "eliminativizam"], 2],
		["Evolucijski mehanizmi",  ["selekcija", "mutacija", "drift", "migracija"],       2],
		["Neurološki pojmovi",     ["sinapsa", "akson", "dendrit", "mijelin"],            2],
		["Tipovi naracije",        ["sveznajući", "prvoličan", "drugoličan", "nepouzdan"], 2],
		["Glazbene ljestvice",     ["dorska", "frigijska", "lidijska", "miksolidijska"],  2],
		["Stilske figure",         ["hiperbola", "litota", "eufonija", "anadiploza"],     2],
		["Kognitivne pristranosti",["potvrđivanje", "sidrenje", "retrospekcija", "dostupnost"], 2],
		["Semiotički pojmovi",     ["znak", "označitelj", "označeno", "referent"],        2],
		["Pravni pojmovi",         ["kazuistika", "precedent", "interpretacija", "supsidijarnost"], 2],
		["Teorije pravde",         ["utilitarizam", "deontologija", "aretaika", "kontraktualizam"], 2],
		["Matematičke teoreme",    ["Pitagorin", "Fermatov", "Bayesov", "Eulerov"],       2],
		["Matematička logika",     ["aksiom", "teorem", "dokaz", "lema"],                 2],
		["Filozofija uma",         ["svjesnost", "namjernost", "kvalije", "subjektivnost"], 2],
		["Vrste etike",            ["deontološka", "utilitaristička", "aretička", "situacijska"], 2],
		["Logičke greške",         ["ad hominem", "slamnati", "lažna dilema", "kružno"],   2],
		["Sintaktički nizovi",     ["parataksa", "hipotaksa", "sindeton", "asindeton"],    2],
		["Tipovi paradoksa",       ["ontološki", "temporalni", "pragmatički", "semantički"], 2],
		["Vrste motiva u književnosti", ["lajtmotiv", "dinamički", "statički", "naslovni"], 2],
		["Vrste teorija",          ["preskriptivna", "deskriptivna", "normativna", "eksplanatorna"], 2],
		# --- rank 3 ---
		["Metrika u poeziji",      ["jamb", "trohej", "daktil", "amfibrah"],              3],
		["Zvukovne figure",        ["aliteracija", "asonanca", "onomatopeja", "paronomazija"], 3],
		["Kvantna fizika",         ["kvark", "gluon", "bozon", "fermion"],                3],
		["Ekonomski paradoksi",    ["Giffenov", "Veblenov", "Simpsonov", "Condorcetov"],  3],
		["Tipovi silogizma",       ["Barbara", "Celarent", "Darii", "Ferio"],             3],
		["Teorije kaosa",          ["atraktor", "bifurkacija", "fraktal", "entropija"],   3],
		["Lingvistički univerzali",["arbitrarnost", "produktivnost", "pomak", "dvostruka artikulacija"], 3],
		["Fenomenološki pojmovi",  ["intencionalnost", "epoché", "intersubjektivnost", "horizont"], 3],
		["Sociolingvistički pojmovi", ["diglosija", "pidžin", "kreolski", "kodna izmjena"], 3],
		["Hermeneutički pojmovi",  ["hermeneutički krug", "predrazumijevanje", "razumijevanje", "tekst"], 3],
		["Teorije istine",         ["korespondencija", "koherencija", "pragmatizam", "deflacionizam"], 3],
		["Vrste modaliteta",       ["nužnost", "mogućnost", "kontingentnost", "nemogućnost"], 3],
		["Homonimi (teži)",        ["bit", "mast", "vez", "kosa"],                        3],
		["Otok = grad",            ["Hvar", "Krk", "Rab", "Vis"],                         3],
		["___ kamen",              ["bubrežni", "žučni", "temeljni", "dragi"],            3],
		["Vruća ___",              ["tema", "linija", "čokolada", "točka"],               3],
		["Crven kao ___",          ["rak", "cigla", "mak", "krv"],                        3],
		["Spavati kao ___",        ["klada", "beba", "top", "anđeo"],                     3],
		["Zanati kao prezimena",   ["Kovač", "Kolar", "Tesar", "Lončar"],                 3],
		["Krije se broj",          ["jednorog", "dvoboj", "trijumf", "četveronožac"],     3],
		["Krije se nota",          ["dobar", "redar", "misija", "fakultet"],              3],
		["Zlatna ___",             ["groznica", "sredina", "ribica", "medalja"],           3],
		["Suprotno s prefiksom 'ne-' (jaki)", ["sreća", "pravda", "volja", "moć"],        3],
		["Ženska imena i pojmovi", ["Vjera", "Sloboda", "Nada", "Zora"],                  3],
		["Crna ___",               ["burza", "magija", "kronika", "lista"],               3],
		["Bez + ___",              ["bol", "obzir", "um", "kraj"],                        3],
		["Težak kao ___",          ["olovo", "grijeh", "mlinski kamen", "sudbina"],       3],
		["Oštar kao ___",          ["britva", "igla", "mač", "jezik"],                    3],
		["Mogu biti živi/e",       ["biće", "srebro", "meso", "pitanje"],                 3],
		["___ rat",                ["hladni", "domovinski", "zvjezdani", "vjerski"],      3],
		["Skrivena Ana",           ["banana", "kanal", "ranac", "fontana"],               3],
		["Skrivena Iva",           ["divan", "kriva", "privatan", "perspektiva"],         3],
		["Skrivena Pula",          ["kapula", "populacija", "kopula", "manipulacija"],    3],
		["Tri ili više značenja",  ["luk", "vrata", "oko", "ključ"],                      3],
		["Hrvatski i engleski — različito značenje", ["kola", "sok", "ten", "sat"],      3],
		["Padežni homonimi",       ["sela", "knjige", "žene", "priče"],                    3],
		["Mogu prethoditi: VATRA", ["vječna", "olimpijska", "sveta", "paklena"],           3],
		["Mogu prethoditi: SAN",   ["mokri", "ružan", "lijepi", "dnevni"],                 3],
		["Mogu slijediti: ZLATNI", ["okvir", "rez", "fond", "standard"],                   3],
		["Mogu slijediti: TIHI",   ["ocean", "partner", "protest", "promatrač"],           3],
		["Završavaju dijelom tijela", ["tvrdoglav", "dugonog", "miloruk", "crnook"],       3],
		["Glagoli za 'promatrati'", ["opažati", "motriti", "uočiti", "nadzirati"],         3],
		["Palindromi",             ["kuk", "topot", "ratar", "potop"],                      3],
	]

static func get_single_puzzle(yesterday_seed: int = -1) -> Puzzle:
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

	var excluded: Dictionary = {}
	if yesterday_seed >= 0:
		excluded = _names_for_seed(yesterday_seed, weights)

	var cats: Array = []
	var used_subtypes: Dictionary = {}
	for p in 4:
		var entry: Array = _weighted_pick(pool_buckets[p], weights)
		if not _frazem_ok(entry[0], used_subtypes) or excluded.has(entry[0]):
			entry = _try_swap(pool_buckets[p], entry, used_subtypes, excluded)
		var subtype := _get_frazem_subtype(entry[0])
		if subtype != "":
			used_subtypes[subtype] = true
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
		var used_subtypes: Dictionary = {}
		for p in 4:
			var entry: Array = _weighted_pick(pool_buckets[p], weights)
			if not _frazem_ok(entry[0], used_subtypes):
				entry = _try_swap(pool_buckets[p], entry, used_subtypes, {})
			var subtype := _get_frazem_subtype(entry[0])
			if subtype != "":
				used_subtypes[subtype] = true
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

# Returns the frazem subtype for a category name, or "" if not a frazem.
# Subtypes are capped at 1 per puzzle to avoid repetitive feel.
static func _get_frazem_subtype(name: String) -> String:
	if "___" not in name and "Mogu prethoditi:" not in name and "Mogu slijediti:" not in name:
		return ""
	if " kao ___" in name:       return "simile"
	if "Mogu prethoditi:" in name or "Mogu slijediti:" in name: return "hidden_connector"
	if " + ___" in name or name.begins_with("Bez +"):          return "prepositional"
	if name.ends_with(" ___"):   return "prefix_adj"
	if name.begins_with("___ "): return "suffix_noun"
	return "other_frazem"

static func _frazem_ok(name: String, used_subtypes: Dictionary) -> bool:
	var subtype := _get_frazem_subtype(name)
	return subtype == "" or not used_subtypes.has(subtype)

# Swaps a rejected entry for one that satisfies both the frazem subtype cap and
# the adjacent-day exclusion set. Relaxes exclusion first, then all constraints,
# before accepting the original as last resort.
static func _try_swap(buckets: Dictionary, rejected: Array, used_subtypes: Dictionary, excluded: Dictionary) -> Array:
	var rank: int = rejected[2] if rejected.size() > 2 else 2
	buckets[rank].push_back(rejected)

	for r in [1, 2, 3]:
		for i in range(buckets[r].size() - 1, -1, -1):
			var cand: Array = buckets[r][i]
			if _frazem_ok(cand[0], used_subtypes) and not excluded.has(cand[0]):
				buckets[r].remove_at(i)
				return cand

	# Relax exclusion — still enforce subtype cap
	for r in [1, 2, 3]:
		for i in range(buckets[r].size() - 1, -1, -1):
			var cand: Array = buckets[r][i]
			if _frazem_ok(cand[0], used_subtypes):
				buckets[r].remove_at(i)
				return cand

	# Relax everything — accept the rejected entry
	buckets[rank].pop_back()
	return rejected

# Simulates yesterday's draw using a local RNG (doesn't affect global RNG state).
# Returns a Dictionary of category names chosen, used as an exclusion set.
static func _names_for_seed(seed_val: int, weights: Array) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	var raw_pools: Array = [_yellow_pool(), _green_pool(), _blue_pool(), _purple_pool()]
	var pool_buckets: Array = []
	for pool in raw_pools:
		var buckets: Dictionary = {1: [], 2: [], 3: []}
		for entry in pool:
			buckets[entry[2] if entry.size() > 2 else 2].append(entry)
		for r in [1, 2, 3]:
			_shuffle_with_rng(buckets[r], rng)
		pool_buckets.append(buckets)
	var names: Dictionary = {}
	var used_subtypes: Dictionary = {}
	for p in 4:
		var entry: Array = _weighted_pick_rng(pool_buckets[p], weights, rng)
		if not _frazem_ok(entry[0], used_subtypes):
			entry = _try_swap(pool_buckets[p], entry, used_subtypes, {})
		var subtype := _get_frazem_subtype(entry[0])
		if subtype != "":
			used_subtypes[subtype] = true
		names[entry[0]] = true
	return names

static func _shuffle_with_rng(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi() % (i + 1)
		var tmp = arr[i]; arr[i] = arr[j]; arr[j] = tmp

static func _weighted_pick_rng(buckets: Dictionary, weights: Array, rng: RandomNumberGenerator) -> Array:
	var roll := rng.randi() % 100
	var chosen_rank := 1
	var cumulative := 0
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
		"Skrivena Mira":                         "U svakoj se riječi krije ime MIRA",
		"Glazbeni i drugi pojmovi":              "Svaka je i glazba i nešto drugo",
		"Homonimi (osnovni)":                    "Jedna riječ, dva potpuno različita značenja",
		"Ime i biljka":                          "Ista riječ: žensko ime i biljka",
		"Hrvatska prezimena":                    "Izgledaju kao životinje, ali su prezimena",
		"Završavaju na -ač":                     "Sve riječi završavaju sufiksom -ač",
		"Imaju 'nos'":                           "Sve imaju nos — doslovno ili u obliku",
		"Imaju 'krilo'":                         "Sve imaju krilo — doslovno ili metaforički",
		"Počinju s 'pra-'":                      "Sve riječi imaju prefiks pra-",
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
		"Šahovski potezi s drugim značenjem":   "Svaki je i šah i nešto drugo",
		"Skriven Rim":                           "U svakoj se riječi krije grad RIM",
		"Latinski prefiks 'anti-'":             "Sve počinju s 'anti-' (protiv)",
		"Latinski prefiks 'super-'":            "Sve počinju s 'super-' (iznad)",
		"Latinski prefiks 'sub-'":              "Sve počinju s 'sub-' (ispod)",
		"Latinski prefiks 'in-'":               "Sve počinju s 'in-' (u, ne)",
		"Grčki brojčani prefiks":               "Skriven broj 1, 2, 3, 4 u prefiksu",
		"Latinski prefiks 'trans-'":            "Sve počinju s 'trans-' (preko)",
		"Grčki prefiks 'auto-'":                "Sve počinju s 'auto-' (sam)",
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
		"Padežni homonimi":                      "Jedan oblik, različita značenja zbog padeža",
		"Mogu prethoditi: PUT":                  "Sve mogu prethoditi imenici PUT",
		"Načini da kažeš NE":                    "Različiti načini izražavanja odbijanja",
		"Načini da kažeš DA":                    "Različiti načini izražavanja slaganja",
		"Načini smijeha":                        "Sve su načini smijeha",
		"Načini gledanja":                       "Sve su načini gledanja",
		"Mogu prethoditi: SUSTAV":               "Sve mogu prethoditi imenici SUSTAV",
		"Mogu prethoditi: STIL":                 "Sve mogu prethoditi imenici STIL",
		"Mogu slijediti: PUNI":                  "Sve mogu slijediti pridjev PUNI",
		"Načini hodanja":                        "Sve su načini kretanja na nogama",
		"Načini govora":                         "Različite glasovne razine govora",
		"Imaju 'rupu'":                          "Sve imaju rupu — doslovno",
		"Mogu rezati":                           "Sve mogu rezati ili brusiti",
		"Glagoli za 'uništiti'":                 "Sve znače uništiti",
		"Glagoli za 'stvoriti'":                 "Sve znače stvoriti",
		"Imaju okrugli oblik":                   "Sve imaju okrugli oblik",
		"Mogu prethoditi: VATRA":                "Sve mogu prethoditi imenici VATRA",
		"Mogu prethoditi: SAN":                  "Sve mogu prethoditi imenici SAN",
		"Mogu slijediti: ZLATNI":                "Sve mogu slijediti pridjev ZLATNI",
		"Mogu slijediti: TIHI":                  "Sve mogu slijediti pridjev TIHI",
		"Završavaju dijelom tijela":             "Svaka riječ završava nazivom dijela tijela",
		"Glagoli za 'promatrati'":               "Sve znače pozorno gledati",
		"Palindromi":                            "Riječi koje se jednako čitaju s obje strane",
	}

static func _to_typed(arr: Array) -> Array[String]:
	var result: Array[String] = []
	result.assign(arr)
	return result
