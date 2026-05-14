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
		["Boje",                   ["plava", "zelena", "žuta", "crvena"],              1],
		["Godišnja doba",          ["proljeće", "ljeto", "jesen", "zima"],              1],
		["Domaće životinje",       ["krava", "svinja", "konj", "koza"],                 1],
		["Voće",                   ["jabuka", "breskva", "šljiva", "trešnja"],           1],
		["Povrće",                 ["mrkva", "krumpir", "luk", "špinat"],               1],
		["Dani u tjednu",          ["ponedjeljak", "utorak", "srijeda", "četvrtak"],    1],
		["Dijelovi tijela",        ["ruka", "noga", "glava", "leđa"],                   1],
		["Prijevozna sredstva",    ["auto", "vlak", "avion", "brod"],                   1],
		["Odjeća",                 ["majica", "hlače", "suknja", "jakna"],              1],
		["Pića",                   ["voda", "sok", "čaj", "kava"],                      1],
		["Oblici",                 ["krug", "kvadrat", "trokut", "pravokutnik"],        1],
		["Osjećaji",               ["radost", "tuga", "strah", "ljutnja"],              1],
		["Dijelovi lica",          ["čelo", "nos", "brada", "obrazi"],                  1],
		["Namještaj",              ["stol", "stolica", "krevet", "ormar"],              1],
		["Bobičasto voće",         ["jagoda", "malina", "borovnica", "grožđe"],         1],
		["Cvijeće",                ["orhideja", "tulipan", "lavanda", "suncokret"],      1],
		# pas→zec, mačka→mačak to avoid conflicts with GREEN Brz kao ___ / Divlji ___
		["Kućni ljubimci",         ["morče", "papiga", "hrčak", "zec"],                  1],
		# baka→sestra to avoid conflict with GREEN Star kao ___
		["Rodbina",                ["mama", "tata", "sestra", "djed"],                  1],
		["Dijelovi dana",          ["jutro", "podne", "večer", "noć"],                  1],
		["Školski pribor",         ["olovka", "ravnalo", "guma", "šestar"],             1],
		# --- rank 2 ---
		["Sportovi",               ["plivanje", "trčanje", "biciklizam", "gimnastika"], 2],
		["Doručak",                ["jaje", "tost", "jogurt", "žitarice"],              2],
		["Kućanski aparati",       ["hladnjak", "perilica", "mikrovalna", "usisavač"],  2],
		["Dijelovi kuće",          ["kuhinja", "spavaća soba", "dnevna soba", "kupaonica"], 2],
		["Planeti",                ["Mars", "Venera", "Saturn", "Jupiter"],             2],
		["Instrumenti",            ["gitara", "violina", "truba", "flauta"],            2],
		["Drveće",                 ["lipa", "bukva", "bor", "javor"],                   2],
		["Alati",                  ["čekić", "pila", "odvijač", "kliješta"],            2],
		["Metali",                 ["zlato", "aluminij", "željezo", "bakar"],           2],
		["Školski predmeti",       ["matematika", "povijest", "geografija", "biologija"], 2],
		["Zimski sportovi",        ["skijanje", "sanjkanje", "hokej", "klizanje"],      2],
		["Životinje u šumi",       ["medvjed", "vuk", "jelen", "lisica"],               2],
		["Tople boje",             ["narančasta", "ljubičasta", "ružičasta", "smeđa"],  2],
		["Vrste mesa",             ["piletina", "govedina", "svinjetina", "janjetina"], 2],
		["Nakit",                  ["prsten", "ogrlica", "narukvica", "naušnica"],      2],
		["Vrtno povrće",           ["rajčica", "paprika", "tikvica", "patlidžan"],      2],
		["Načini kuhanja",         ["pečenje", "kuhanje", "prženje", "dinstanje"],      2],
		["Zimska odjeća",          ["šal", "kapa", "rukavice", "čizme"],                2],
		# upravljač→sjedalo conflict resolved in GREEN Dijelovi automobila (upravljač→volan)
		["Dijelovi bicikla",       ["kotač", "pedale", "upravljač", "sjedalo"],         2],
		["Vrste juhe",             ["goveđa", "kokošja", "riblja", "povrtna"],          2],
		# --- rank 3 ---
		["Oceani",                 ["Tihi", "Atlantski", "Indijski", "Arktički"],       3],
		["Morske životinje",       ["dupin", "hobotnica", "morski pas", "tuna"],        3],
		["Ljetni sportovi",        ["vaterpolo", "jedriličarstvo", "atletika", "veslanje"], 3],
		["Životinje na farmi",     ["pijetao", "guska", "purica", "patka"],             3],
		["Životinje u moru",       ["riba", "račić", "lignja", "školjka"],              3],
		# čokolada→karamel to avoid conflict with PURPLE Vruća ___
		["Vrste sladoleda",        ["karamel", "vanilija", "jagoda", "lješnjak"],       3],
	]

static func _green_pool() -> Array:
	return [
		# --- rank 1 ---
		["Note glazbene ljestvice", ["do", "re", "mi", "fa"],                          1],
		["Sportovi s loptom",      ["košarka", "odbojka", "rukomet", "tenis"],         1],
		["Mjerne jedinice",        ["metar", "kilogram", "sekunda", "litra"],          1],
		["Gradovi Hrvatske",       ["Zagreb", "Split", "Rijeka", "Osijek"],            1],
		["Egzotično voće",         ["mango", "papaja", "avokado", "ananas"],           1],
		["Zanimanja",              ["liječnik", "učitelj", "vatrogasac", "pilot"],      1],
		["Europske države",        ["Njemačka", "Francuska", "Italija", "Španjolska"], 1],
		["Kuhinjski pribor",       ["lonac", "tava", "žlica", "nož"],                  1],
		["Životinje savane",       ["lav", "slon", "žirafa", "zebra"],                 1],
		["Kontinenti",             ["Europa", "Azija", "Afrika", "Amerika"],            1],
		["Grčki bogovi",           ["Zeus", "Hera", "Apolon", "Atena"],                1],
		# drama→akcija to avoid conflict with BLUE Književni rodovi
		["Vrste filmova",          ["akcija", "komedija", "triler", "horor"],          1],
		["Nordijska mitologija",   ["Odin", "Thor", "Loki", "Freya"],                  1],
		# --- rank 2 ---
		# pasticada→pašticada (spelling fix)
		["Hrvatska jela",          ["sarma", "peka", "pašticada", "burek"],            2],
		["Kukci",                  ["pčela", "mrav", "leptir", "kornjaš"],             2],
		["Začini",                 ["papar", "sol", "cimet", "kurkuma"],               2],
		["Ptice selice",           ["roda", "lastavica", "čaplja", "kukavica"],        2],
		["Rijeke Hrvatske",        ["Sava", "Drava", "Kupa", "Neretva"],               2],
		["Materijali",             ["drvo", "staklo", "plastika", "kamen"],            2],
		# upravljač→volan to avoid conflict with YELLOW Dijelovi bicikla
		["Dijelovi automobila",    ["motor", "mjenjač", "kočnica", "volan"],           2],
		["Dijelovi računala",      ["tipkovnica", "miš", "zaslon", "procesor"],        2],
		["Kontaktni sportovi",     ["ragbi", "judo", "hrvanje", "boks"],               2],
		["Glazbeni žanrovi",       ["jazz", "blues", "klasika", "folk"],               2],
		["Vrste sira",             ["gouda", "cheddar", "brie", "feta"],               2],
		["Vrste tjestenine",       ["špageti", "lazanje", "rigatoni", "penne"],        2],
		# bijeli/crni→pšenični/integralni to avoid conflict with BLUE Vrste čajeva / PURPLE Boje u politici
		["Vrste kruha",            ["pšenični", "integralni", "raženi", "kukuruzni"],  2],
		["Vrste tkanine",          ["svila", "pamuk", "lan", "vuna"],                  2],
		["Plesovi",                ["valcer", "tango", "samba", "polka"],              2],
		["Valute",                 ["euro", "dolar", "jen", "funta"],                  2],
		["Vitamini",               ["vitamin A", "vitamin B", "vitamin C", "vitamin D"], 2],
		["Planinski vrhovi",       ["Everest", "Kilimandžaro", "Mont Blanc", "Elbrus"], 2],
		["Slavni slikari",         ["Picasso", "Monet", "Da Vinci", "Rembrandt"],      2],
		["Slavni skladatelji",     ["Mozart", "Bach", "Beethoven", "Chopin"],          2],
		["Arheološki lokaliteti",  ["Stonehenge", "Pompeja", "Petra", "Machu Picchu"], 2],
		["Vrste ribe",             ["šaran", "pastrva", "brancin", "lubin"],           2],
		["Mitološka bića",         ["satir", "kentaur", "sfinga", "minotaur"],         2],
		# esej→bajka to avoid conflict with BLUE Književni rodovi
		["Književni žanrovi",      ["roman", "novela", "pripovijetka", "bajka"],       2],
		["Atletske discipline",    ["sprint", "skok", "bacanje", "maraton"],           2],
		["Vrste fotografije",      ["portret", "pejzaž", "makro", "reportaža"],        2],
		["Ekološki pojmovi",       ["ekosustav", "biom", "biodiverzitet", "prehrambeni lanac"], 2],
		# --- rank 3: wordplay / lateral thinking ---
		["Mora nazvana po boji",   ["Crno", "Crveno", "Bijelo", "Žuto"],               3],
		["Ime i biljka",           ["Ruža", "Iris", "Ljubica", "Ljiljana"],            3],
		["Crni/a ___",             ["humor", "petak", "kutija", "ovca"],               3],
		["Bijeli/a ___",           ["zastava", "laža", "šum", "ovratnik"],             3],
		# zec→soko to avoid conflict with YELLOW Kućni ljubimci
		["Brz kao ___",            ["munja", "vjetar", "soko", "metak"],               3],
		# noć→pustinja to avoid conflict with YELLOW Dijelovi dana
		["Tiho kao ___",           ["miš", "grob", "pustinja", "groblje"],             3],
		["Hrvatska prezimena",     ["Medved", "Orao", "Sokol", "Kunić"],               3],
		["Mali ___",               ["brat", "prst", "oglasi", "vojnik"],               3],
		["Stari ___",              ["zavjet", "kontinent", "mačak", "most"],           3],
		["Divlji ___",             ["zapad", "mačka", "životinje", "vatra"],           3],
		# stijena (singular) is more natural than stijene
		["Hladan kao ___",         ["led", "zmija", "stijena", "mramor"],              3],
		["Star kao ___",           ["Biblija", "svijet", "baka", "brda"],              3],
		["Završavaju na '-ač'",    ["pjevač", "igrač", "gledač", "slušač"],            3],
		# avion+brod→lokomotiva+čarapa to avoid conflict with YELLOW Prijevozna sredstva
		["Sve ima 'nos'",          ["lokomotiva", "čarapa", "čizma", "Pinokio"],       3],
		# srce→prozor to avoid conflict with BLUE Može se 'slomiti'
		["Može se 'otvoriti'",     ["vrata", "račun", "restoran", "prozor"],           3],
		# avion→vjetrenjača to avoid conflict with YELLOW Prijevozna sredstva
		["Ima 'krilo'",            ["ptica", "vjetrenjača", "dvorac", "leptir"],       3],
	]

static func _blue_pool() -> Array:
	return [
		# --- rank 1 ---
		["Matematičke operacije",  ["zbrajanje", "oduzimanje", "množenje", "dijeljenje"], 1],
		["Krvne grupe",            ["A", "B", "AB", "0"],                              1],
		["Vrste vjetra",           ["bura", "jugo", "maestral", "tramontana"],         1],
		["Kemijski elementi",      ["kisik", "dušik", "vodik", "ugljik"],              1],
		["Književni rodovi",       ["lirika", "epika", "drama", "esej"],               1],
		["Vrste energije",         ["kinetička", "potencijalna", "toplinska", "kemijska"], 1],
		["Fizikalne veličine",     ["masa", "sila", "brzina", "temperatura"],          1],
		["Matematičke grane",      ["algebra", "geometrija", "analiza", "statistika"], 1],
		["Vrste mikroorganizama",  ["bakterija", "virus", "gljivica", "parazit"],      1],
		# --- rank 2 ---
		["Geološka razdoblja",     ["jura", "kreda", "silur", "devon"],                2],
		["Geografski pojmovi",     ["poluotok", "tjesnac", "fjord", "laguna"],         2],
		["Arhitektonski stilovi",  ["barok", "gotika", "renesansa", "modernizam"],     2],
		["Filozofi",               ["Sokrat", "Platon", "Aristotel", "Nietzsche"],     2],
		["Programski jezici",      ["Python", "Java", "Rust", "Swift"],                2],
		["Vrste oblaka",           ["cirrus", "kumulonimbus", "stratus", "nimbostratus"], 2],
		["Pisci nobelovci",        ["Hemingway", "Camus", "Kafka", "Orwell"],          2],
		# zeleni/crni/bijeli→matcha/sencha/darjeeling to avoid conflicts with GREEN Vrste kruha / PURPLE Boje u politici
		["Vrste čajeva",           ["matcha", "sencha", "darjeeling", "oolong"],       2],
		["Ekonomski sustavi",      ["kapitalizam", "socijalizam", "feudalizam", "merkantilizam"], 2],
		["Psihološki pojmovi",     ["ego", "alter ego", "id", "superego"],             2],
		["Dijelovi DNA",           ["adenin", "timin", "gvanin", "citozin"],           2],
		["Poznate epohe",          ["antika", "srednji vijek", "renesansa", "barok"],  2],
		["Logički paradoksi",      ["lažac", "Zenonov", "Russellov", "sorit"],         2],
		["Lingvistički pojmovi",   ["morfem", "fonem", "sintaksa", "semantika"],       2],
		["Teorije svemira",        ["Veliki prasak", "Inflacija", "Multisvemir", "Ciklički model"], 2],
		["Psihološki poremećaji",  ["fobija", "anksioznost", "narcizam", "paranoja"],  2],
		["Filozofski pojmovi",     ["dijalektika", "ontologija", "epistemologija", "metafizika"], 2],
		["Vrste zakona",           ["kazneni", "građanski", "ustavni", "međunarodni"], 2],
		["Astronomski pojmovi",    ["crna rupa", "pulsar", "kvasar", "magla"],         2],
		["Teorije ličnosti",       ["psihoanaliza", "biheviorizam", "humanizam", "kognitivizam"], 2],
		["Vrste kemijskih veza",   ["ionska", "kovalentna", "metalna", "vodikova"],    2],
		["Književni stilovi",      ["realizam", "romantizam", "naturalizam", "ekspresionizam"], 2],
		["Vrste tla",              ["glina", "pijesak", "humus", "ilovača"],           2],
		["Psihološke obrane",      ["potiskivanje", "projekcija", "racionalizacija", "sublimacija"], 2],
		["Geološki procesi",       ["erozija", "sedimentacija", "vulkanizam", "tektonika ploča"], 2],
		["Statističke mjere",      ["srednja vrijednost", "medijan", "mod", "varijanca"], 2],
		["Retoričke tehnike",      ["ethos", "pathos", "logos", "kairos"],             2],
		["Vrste diskursa",         ["narativni", "argumentativni", "opisni", "dijaloški"], 2],
		# --- rank 3: wordplay / lateral thinking ---
		["Logičke operacije",      ["I", "ILI", "NE", "XOR"],                         3],
		["Može biti 'hladan/a'",   ["tuš", "rat", "znoj", "slučaj"],                  3],
		["Ide uz 'zlatni/a/o'",    ["runo", "ribica", "doba", "medalja"],              3],
		["Dvije različite stvari", ["list", "grad", "more", "pas"],                    3],
		["Krvni/a ___",            ["tlak", "slika", "sud", "grupa"],                  3],
		["___ polje",              ["magnetsko", "minsko", "naftno", "vidno"],         3],
		["Pasti kao ___",          ["kruška", "bomba", "grom", "snop"],                3],
		["Jak kao ___",            ["vol", "hrast", "div", "bik"],                      3],
		["Hrvatska mjesta",        ["Zelina", "Zlatar", "Modra", "Crna Mlaka"],        3],
		["Počinju s 'nad-'",       ["nadimak", "nadzor", "nadnica", "nadmudriti"],     3],
		["Može se 'slomiti'",      ["val", "rekord", "tišina", "srce"],                3],
		["Sve se može 'izgubiti'", ["strpljenje", "put", "smisao", "trag"],            3],
		["Europske prijestolnice bez slova 'a'", ["Beč", "Rim", "Bern", "Berlin"],    3],
		["Slobodni/a ___",         ["pad", "udar", "stih", "tržište"],                 3],
		["Lagan kao ___",          ["pero", "oblak", "pahulja", "zrak"],               3],
		["Tvrd kao ___",           ["granit", "dijamant", "čelik", "orah"],            3],
		["Ide uz 'mrtvi/a/o'",     ["kut", "hodnik", "priroda", "trka"],               3],
		["Skrivena životinja",     ["kompas", "klavir", "praksa", "evolucija"],        3],
		["Može biti 'visok/a'",    ["zgrada", "cijena", "tlak", "ton"],                3],
		["Može se 'nositi'",       ["teret", "haljina", "odgovornost", "dijete"],      3],
		["Ide uz 'duboki'",        ["glas", "san", "more", "dah"],                     3],
	]

static func _purple_pool() -> Array:
	return [
		# --- rank 1 ---
		["Latinske izreke",        ["carpe diem", "veni vidi vici", "cogito ergo sum", "memento mori"], 1],
		["Retoričke figure",       ["metafora", "metonimija", "sinegdoha", "oksimoron"], 1],
		["Filozofski pravci",      ["empirizam", "racionalizam", "nihilizam", "egzistencijalizam"], 1],
		["Vrste argumentacije",    ["dedukcija", "indukcija", "abdukcija", "analogija"], 1],
		["Poetski žanrovi",        ["elegija", "oda", "sonet", "epigram"],             1],
		["Epistemološki pojmovi",  ["znanje", "vjera", "opravdanje", "istina"],        1],
		# --- rank 2 ---
		["Vrste pamćenja",         ["epizodično", "semantičko", "proceduralno", "radno"], 2],
		["Teorije uma",            ["funkcionalizam", "dualizam", "fizikalizam", "eliminativizam"], 2],
		["Evolucijski mehanizmi",  ["selekcija", "mutacija", "pomak", "migracija"],    2],
		["Neurološki pojmovi",     ["sinapsa", "akson", "dendrit", "mijelinska ovojnica"], 2],
		# Vrste narativnih glasova removed — shared 3/4 words with Tipovi naracije
		["Tipovi naracije",        ["sveznajući", "prvoličan", "drugoličan", "nepouzdan"], 2],
		["Glazbene ljestvice",     ["dorska", "frigijska", "lidijska", "miksolidijska"], 2],
		["Stilske figure",         ["hiperbola", "litota", "eufonija", "anadiploza"],  2],
		["Kognitivne pristranosti",["potvrđivanje", "sidrenje", "retrospekcija", "dostupnost"], 2],
		["Semiotički pojmovi",     ["znak", "označitelj", "označeno", "referent"],     2],
		["Pravni pojmovi",         ["kazuistika", "precedent", "interpretacija", "supsidijarnost"], 2],
		["Teorije pravde",         ["utilitarizam", "deontologija", "vrlinska etika", "kontraktualizam"], 2],
		["Matematičke teoreme",    ["Pitagorin", "Fermatov", "Bayesov", "Fourierov"], 2],
		["Vrste dokaza",           ["empirijski", "deduktivni", "induktivni", "abduktivni"], 2],
		["Matematička logika",     ["aksiom", "teorem", "dokaz", "lema"],              2],
		["Filozofija uma",         ["svjesnost", "namjernost", "qualia", "subjektivnost"], 2],
		# --- rank 3: wordplay / lateral thinking ---
		["Metrika u poeziji",      ["jamb", "trohej", "daktil", "amfibrah"],           3],
		["Zvukovne figure",        ["aliteracija", "asonanca", "onomatopeja", "paronomazija"], 3],
		["Kvantna fizika",         ["kvark", "gluon", "bozon", "fermion"],             3],
		["Ekonomski paradoksi",    ["Giffenov", "Veblenov", "Simpsonov", "Condorcetov"], 3],
		["Tipovi silogizma",       ["Barbara", "Celarent", "Darii", "Ferio"],          3],
		["Teorije kaosa",          ["atraktor", "bifurkacija", "fraktal", "Lyapunov eksponent"], 3],
		["Lingvistički univerzali",["arbitrarnost", "produktivnost", "pomak", "dvostruka artikulacija"], 3],
		["Fenomenološki pojmovi",  ["intencionalnost", "epoché", "intersubjektivnost", "horizont"], 3],
		["Sociolingvistički pojmovi", ["diglosija", "pidžin", "kreolski", "kodna izmjena"], 3],
		["Hermeneutički pojmovi",  ["hermeneutički krug", "predrazumijevanje", "interpretacija", "tekst"], 3],
		["Teorije istine",         ["korespondencija", "koherencija", "pragmatička", "deflacijska"], 3],
		["Vrste modaliteta",       ["nužnost", "mogućnost", "kontingentnost", "nemogućnost"], 3],
		["Dvije različite stvari", ["bit", "kosa", "mast", "vez"],                     3],
		["Otok = grad",            ["Hvar", "Krk", "Rab", "Vis"],                      3],
		["___ kamen",              ["bubrežni", "žučni", "temeljni", "dragi"],         3],
		["Vruća ___",              ["tema", "linija", "čokolada", "točka"],            3],
		["Crven kao ___",          ["rak", "cigla", "mak", "krv"],                      3],
		["Spavati kao ___",        ["klada", "beba", "top", "anđeo"],                  3],
		["Zanati kao prezimena",   ["Kovač", "Kolar", "Tesar", "Lončar"],              3],
		# trokut→trijumf (TRI-jumf) to avoid conflict with YELLOW Oblici; keeps 1-2-3-4 sequence
		["Krije se broj",          ["jednorog", "dvoboj", "trijumf", "četverokut"],    3],
		# rekord→redar (RE-dar) to avoid conflict with BLUE Može se 'slomiti'
		["Krije se nota",          ["dobar", "redar", "misija", "fakultet"],           3],
		# ribica→kosa to avoid conflict with BLUE Ide uz 'zlatni/a/o'
		["Zlatna ___",             ["groznica", "sredina", "kosa", "vez"],              3],
		["Dobivaju suprotno s 'ne-'", ["sreća", "pravda", "znanje", "moć"],           3],
		["Ženska imena i pojmovi", ["Vjera", "Sloboda", "Slava", "Zora"],              3],
		["Crna ___",               ["burza", "magija", "kronika", "lista"],            3],
		["Bez + ___",              ["bol", "obzir", "um", "nada"],                     3],
		["Težak kao ___",          ["olovo", "grijeh", "planina", "sudbina"],          3],
		["Oštar kao ___",          ["britva", "igla", "mač", "jezik"],                 3],
		["Boje u politici",        ["zeleni", "crveni", "crni", "plavi"],              3],
		# more→meso to avoid conflict with BLUE Dvije različite stvari
		["Može biti 'živo'",       ["biće", "srebro", "meso", "pitanje"],              3],
		["___ rat",                ["hladni", "domovinski", "zvjezdani", "građanski"], 3],
	]

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
		for p in 4:
			var entry: Array = _weighted_pick(pool_buckets[p], weights)
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
		"Mora nazvana po boji":              "Crno, Crveno, Bijelo, Žuto more",
		"Ime i biljka":                      "Ista riječ: žensko ime i biljka",
		"Crni/a ___":                        "Što ide uz 'crni/a'? Humor, petak…",
		"Bijeli/a ___":                      "Što ide uz 'bijeli/a'? Zastava, laža…",
		"Brz kao ___":                       "Frazeološke usporedbe brzine",
		"Tiho kao ___":                      "Frazeološke usporedbe tišine",
		"Hrvatska prezimena":                "Izgledaju kao životinje, ali su prezimena",
		"Hladan kao ___":                    "Frazeološke usporedbe hladnoće",
		"Star kao ___":                      "Frazeološke usporedbe starosti",
		"Završavaju na '-ač'":               "Sve riječi završavaju sufiksom -ač",
		"Mali ___":                          "Mali brat, mali prst, mali oglasi, mali vojnik",
		"Stari ___":                         "Stari zavjet, Stari kontinent, stari mačak, Stari most",
		"Divlji ___":                        "Divlji zapad, divlja mačka, divlje životinje, divlja vatra",
		"Može biti 'hladan/a'":              "Sve može opisati pridjev 'hladan/a'",
		"Ide uz 'zlatni/a/o'":               "Zlatno runo, zlatna ribica…",
		"Dvije različite stvari":            "Homonimi — jedna riječ, dva značenja",
		"Krvni/a ___":                       "Što ide uz 'krvni/a'? Tlak, slika…",
		"___ polje":                         "Magnetsko, minsko, naftno, vidno",
		"Pasti kao ___":                     "Frazeološke usporedbe pada",
		"Jak kao ___":                       "Frazeološke usporedbe snage",
		"Hrvatska mjesta":                   "Izgledaju kao boje, ali su geografska mjesta",
		"Počinju s 'nad-'":                  "Sve riječi imaju prefiks nad-",
		"Može se 'slomiti'":                 "Val, rekord, tišina, srce — sve se lomi",
		"Sve se može 'izgubiti'":            "Strpljenje, put, smisao, trag",
		"Europske prijestolnice bez slova 'a'": "Beč, Rim, Bern, Berlin",
		"Slobodni/a ___":                    "Slobodan pad, slobodan stih…",
		"Lagan kao ___":                     "Frazeološke usporedbe lakoće",
		"Tvrd kao ___":                      "Frazeološke usporedbe tvrdoće",
		"Ide uz 'mrtvi/a/o'":               "Mrtvi kut, mrtvi hodnik…",
		"Skrivena životinja":                "kom-PAS, k-LAV-ir, p-RAK-sa, e-VOL-ucija",
		"Krije se broj":                     "jedno-ROG(1), dvo-BOJ(2), TRI-jumf(3), četvero-KUT(4)",
		"Krije se nota":                     "DO-bar, RE-dar, MI-sija, FA-kultet",
		"Otok = grad":                       "Hvar, Krk, Rab, Vis — i otok i grad",
		"___ kamen":                         "Bubrežni, žučni, temeljni, dragi kamen",
		"Vruća ___":                         "Vruća tema, linija, čokolada, točka",
		"Crven kao ___":                     "Crven kao rak, cigla, mak, krv",
		"Spavati kao ___":                   "Frazeološke usporedbe dubokog sna",
		"Zanati kao prezimena":              "Kovač, Kolar, Tesar, Lončar",
		"Zlatna ___":                        "Zlatna groznica, sredina, kosa, vez",
		"Dobivaju suprotno s 'ne-'":         "Nesreća, nepravda, neznanje, nemoć",
		"Ženska imena i pojmovi":            "Vjera, Sloboda, Slava, Zora",
		"Crna ___":                          "Crna burza, magija, kronika, lista",
		"Bez + ___":                         "Bezbol, bezobzir, bezum, beznada",
		"Težak kao ___":                     "Frazeološke usporedbe težine",
		"Oštar kao ___":                     "Frazeološke usporedbe oštrine",
		"Boje u politici":                   "Zeleni, crveni, crni, plavi — stranke",
		"Sve ima 'nos'":                     "Lokomotiva, čarapa, čizma, Pinokio — sve ima nos",
		"Može se 'otvoriti'":                "Vrata, račun, restoran, prozor",
		"Ima 'krilo'":                       "Ptica, vjetrenjača, dvorac, leptir",
		"Može biti 'visok/a'":               "Zgrada, cijena, tlak, ton — sve može biti visoko",
		"Može se 'nositi'":                  "Teret, haljina, odgovornost, dijete",
		"Ide uz 'duboki'":                   "Duboki glas, san, more, dah",
		"Može biti 'živo'":                  "Živo biće, živo srebro, živo meso, živo pitanje",
		"___ rat":                           "Hladni, Domovinski, Zvjezdani, Građanski rat",
	}

static func _to_typed(arr: Array) -> Array[String]:
	var result: Array[String] = []
	result.assign(arr)
	return result
