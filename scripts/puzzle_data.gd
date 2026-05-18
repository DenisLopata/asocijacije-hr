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
	var complexity: String = "thematic"  # "obvious" | "thematic" | "wordplay"

	func _init(p_name: String, p_words: Array[String], p_diff: PuzzleData.Difficulty) -> void:
		name = p_name
		words = p_words
		difficulty = p_diff

class Puzzle:
	var title: String
	var categories: Array[PuzzleData.Category]

	func _init(p_title: String, p_categories: Array) -> void:
		title = p_title
		categories.assign(p_categories)

	func all_words() -> Array[String]:
		var result: Array[String] = []
		for cat in categories:
			result.append_array(cat.words)
		return result

# -------------------------------------------------------------------
# Large pool — one array per difficulty tier.
# Each entry: [name, [w1, w2, w3, w4], rank, complexity]
#   rank 1 = easiest within this tier
#   rank 2 = mid
#   rank 3 = hardest / lateral-thinking within this tier
#   complexity: "obvious" | "thematic" | "wordplay"
# -------------------------------------------------------------------
static func _yellow_pool() -> Array:
	return [
		# --- rank 1 ---
		["Boje",                   ["bijela", "crna", "ljubičasta", "ružičasta"],           1, "obvious",  ["bijel", "crn"]],
		["Godišnja doba",          ["proljeće", "ljeto", "jesen", "zima"],                  1, "obvious"],
		["Domaće životinje",       ["krava", "svinja", "magarac", "koza"],                  1, "obvious"],
		["Voće",                   ["jabuka", "breskva", "šljiva", "trešnja"],              1, "obvious"],
		["Povrće",                 ["mrkva", "krumpir", "češnjak", "špinat"],               1, "obvious"],
		["Dani u tjednu",          ["ponedjeljak", "utorak", "srijeda", "četvrtak"],        1, "obvious"],
		["Dijelovi tijela",        ["ruka", "noga", "glava", "leđa"],                       1, "obvious"],
		["Prijevozna sredstva",    ["auto", "vlak", "avion", "brod"],                       1, "obvious"],
		["Odjeća",                 ["majica", "hlače", "suknja", "jakna"],                  1, "obvious"],
		["Pića",                   ["voda", "mlijeko", "čaj", "kava"],                      1, "obvious"],
		["Oblici",                 ["krug", "kvadrat", "trokut", "pravokutnik"],            1, "obvious"],
		["Osjećaji",               ["veselje", "tuga", "strah", "ljutnja"],                 1, "obvious"],
		["Dijelovi lica",          ["čelo", "nos", "brada", "obrazi"],                      1, "obvious"],
		["Namještaj",              ["stol", "stolica", "krevet", "ormar"],                  1, "obvious"],
		["Bobičasto voće",         ["jagoda", "malina", "borovnica", "kupina"],             1, "obvious"],
		["Cvijeće",                ["orhideja", "tulipan", "karanfil", "suncokret"],        1, "obvious"],
		["Kućni ljubimci",         ["zamorac", "papiga", "hrčak", "zec"],                   1, "obvious"],
		["Rodbina",                ["majka", "otac", "sestra", "brat"],                     1, "obvious"],
		["Dijelovi dana",          ["jutro", "podne", "večer", "noć"],                      1, "obvious"],
		["Školski pribor",         ["olovka", "ravnalo", "guma", "šestar"],                 1, "obvious"],
		["Padavine",               ["kiša", "snijeg", "tuča", "susnježica"],                1, "obvious",  ["kiša"]],
		["Sportovi",               ["plivanje", "trčanje", "biciklizam", "gimnastika"],     1, "obvious"],
		["Kućanski aparati",       ["hladnjak", "perilica", "mikrovalna", "usisavač"],      1, "obvious"],
		["Dijelovi kuće",          ["kuhinja", "spavaonica", "blagovaonica", "kupaonica"],  1, "obvious"],
		["Instrumenti",            ["gitara", "violina", "truba", "flauta"],                1, "obvious"],
		["Alati",                  ["čekić", "pila", "odvijač", "kliješta"],                1, "obvious"],
		["Metali",                 ["zlato", "aluminij", "željezo", "bakar"],               1, "obvious",  ["zlat", "željez"]],
		["Školski predmeti",       ["matematika", "povijest", "geografija", "biologija"],   1, "obvious"],
		["Životinje u šumi",       ["medvjed", "vuk", "jelen", "lisica"],                   1, "obvious"],
		["Tople boje",             ["narančasta", "žuta", "crvena", "smeđa"],               1, "obvious",  ["crven", "žut"]],
		["Zimska odjeća",          ["šal", "kapa", "rukavice", "kaput"],                    1, "obvious"],
		["Završavaju na -ost",     ["radost", "mladost", "ljubaznost", "hrabrost"],         2, "wordplay"],
		["Odmilice za rodbinu",    ["mama", "tata", "baka", "deda"],                        1, "wordplay"],
		["Mlade životinje",        ["mače", "štene", "pile", "tele"],                       1, "wordplay"],
		["Osjetila",               ["vid", "sluh", "njuh", "okus"],                           1, "obvious"],
		# --- rank 2 ---
		["Doručak",                ["jaje", "tost", "jogurt", "žitarice"],                  2, "obvious"],
		["Planeti",                ["Mars", "Venera", "Saturn", "Jupiter"],                 2, "obvious"],
		["Drveće",                 ["lipa", "bukva", "bor", "javor"],                       2, "obvious"],
		["Zimski sportovi",        ["skijanje", "sanjkanje", "hokej", "klizanje"],          2, "obvious"],
		["Vrste mesa",             ["piletina", "govedina", "svinjetina", "janjetina"],     2, "obvious"],
		["Nakit",                  ["prsten", "ogrlica", "narukvica", "naušnica"],          2, "obvious",  ["prsten"]],
		["Vrtno povrće",           ["rajčica", "paprika", "tikvica", "patlidžan"],          2, "obvious"],
		["Načini kuhanja",         ["pečenje", "kuhanje", "prženje", "dinstanje"],          2, "obvious"],
		["Dijelovi bicikla",       ["kotač", "pedale", "upravljač", "sjedalo"],             2, "obvious"],
		["Vrste juhe",             ["goveđa", "kokošja", "riblja", "povrtna"],              2, "obvious"],
		["Oceani",                 ["Tihi", "Atlantski", "Indijski", "Arktički"],           2, "obvious",   ["tihi"]],
		["Morski sisavci",         ["dupin", "kit", "foka", "morž"],                        2, "obvious"],
		["Ljetni sportovi",        ["vaterpolo", "jedriličarstvo", "atletika", "veslanje"],  2, "obvious"],
		["Ptice na farmi",         ["pijetao", "guska", "purica", "patka"],                 2, "obvious"],
		["Vrste sladoleda",        ["karamel", "vanilija", "pistacija", "lješnjak"],        2, "obvious"],
		["Završavaju na -stvo",    ["prijateljstvo", "bratstvo", "bogatstvo", "kraljevstvo"], 2, "wordplay"],
		["Završavaju na -ica",     ["matica", "ulica", "granica", "klupica"],               2, "wordplay",  ["granica"]],
		["Završavaju na -aj",      ["tečaj", "sjaj", "običaj", "pokušaj"],                  2, "wordplay"],
		["Kuhinjske mjere",        ["žličica", "šalica", "gram", "dekagram"],               2, "wordplay"],
		["Imaju rep",              ["majmun", "kometa", "štakor", "paun"],                  2, "wordplay"],
		["Zvukovi životinja",      ["mukanje", "lavež", "kreketanje", "cvrkut"],               2, "obvious"],
		["Dijelovi cvijeća",       ["latica", "prašnik", "tučak", "stapka"],                   2, "obvious"],
		# --- rank 3 ---
		["Morski beskralježnjaci", ["hobotnica", "lignja", "meduza", "koralj"],             3, "obvious"],
		["Počinju s vodo-",        ["vodopad", "vodozemac", "vodomar", "vodoinstalater"],   3, "wordplay"],
		["Krije se broj",          ["stotina", "tisućnjak", "dvopek", "jednina"],           3, "wordplay",  ["kind:hidden_word"]],
		["Mogu biti kiseli",       ["krastavac", "kupus", "izraz", "vino"],                 3, "semantic"],
		["Mogu zujati",            ["komarac", "telefon", "muha", "struja"],                3, "semantic"],
		["Mogu prsnuti",           ["mjehur", "struna", "balon", "smijeh"],                 3, "semantic"],
		["Krije se oko",           ["naokolo", "brokoli", "kokoš", "pokoriti"],             3, "wordplay",  ["oko", "kind:hidden_word"]],
		["Krije se put",           ["naputak", "disputa", "šaputati", "reputacija"],        3, "wordplay",  ["put", "kind:hidden_word"]],
		["Krije se dan",           ["tjedan", "jedan", "slobodan", "vladanje"],             3, "wordplay",  ["dan", "kind:hidden_word"]],
		["Krije se led",           ["pogled", "izgled", "ugled", "poledica"],               3, "wordplay",  ["led", "kind:hidden_word"]],
		["Krije se val",           ["naval", "festival", "karneval", "zavaliti"],           3, "wordplay",  ["val", "kind:hidden_word"]],
		["Krije se mak",           ["zamak", "odmak", "umak", "pomak"],                     3, "wordplay",  ["mak", "pomak", "kind:hidden_word"]],
		["Mogu se oguliti",        ["banana", "naranča", "luk", "bundeva"],                 3, "semantic",  ["banana", "luk"]],
		["Idu u paru",             ["cipele", "skije", "obrve", "uši"],                     3, "thematic"],
		["Mogu procuriti",         ["cijev", "vijest", "krov", "šator"],                    3, "semantic"],
		["Krije se rat",           ["vrata", "karate", "pirat", "obrat"],                   3, "wordplay",  ["rat", "vrata", "kind:hidden_word"]],
		["Mogu kapati",            ["slavina", "svjeća", "med", "smola"],                   3, "semantic"],
		["Mogu poplaviti",         ["podrum", "stan", "polje", "njiva"],                    3, "semantic",  ["podrum"]],
		["Mogu šuštati",           ["lišće", "papir", "novčanica", "vrećica"],                 3, "semantic"],
		["Mogu se smrznuti",       ["jezero", "pipe", "plaća", "pregovori"],                   3, "semantic"],
	]

static func _green_pool() -> Array:
	return [
		# --- rank 1 ---
		["Note glazbene ljestvice", ["do", "re", "mi", "fa"],                              1, "thematic"],
		["Sportovi s loptom",      ["košarka", "odbojka", "rukomet", "tenis"],             1, "obvious"],
		["Mjerne jedinice",        ["metar", "kilogram", "sekunda", "litra"],              1, "obvious"],
		["Gradovi Hrvatske",       ["Zagreb", "Split", "Rijeka", "Osijek"],                1, "obvious"],
		["Egzotično voće",         ["mango", "papaja", "kivi", "ananas"],                  1, "obvious"],
		["Zanimanja",              ["liječnik", "učitelj", "vatrogasac", "pilot"],          1, "obvious"],
		["Europske države",        ["Njemačka", "Francuska", "Italija", "Španjolska"],     1, "obvious"],
		["Kuhinjski pribor",       ["lonac", "tava", "žlica", "nož"],                      1, "obvious"],
		["Životinje savane",       ["lav", "slon", "žirafa", "zebra"],                     1, "obvious"],
		["Kontinenti",             ["Europa", "Azija", "Afrika", "Amerika"],               1, "obvious"],
		["Grčki bogovi",           ["Zeus", "Hera", "Apolon", "Atena"],                    1, "obvious"],
		["Vrste filmova",          ["akcija", "komedija", "triler", "horor"],              1, "obvious"],
		["Nordijska mitologija",   ["Odin", "Thor", "Loki", "Freya"],                      1, "obvious"],
		["Hrvatski povijesni vladari", ["Tomislav", "Zvonimir", "Krešimir", "Petar"],      1, "thematic"],
		["Hrvatski otoci",         ["Brač", "Korčula", "Mljet", "Pag"],                    1, "obvious"],
		["Hrvatske planine",       ["Velebit", "Učka", "Dinara", "Biokovo"],               1, "obvious"],
		["Hrvatski nacionalni parkovi", ["Plitvice", "Kornati", "Brijuni", "Risnjak"],     1, "obvious"],
		["Slavni hrvatski sportaši", ["Modrić", "Ivanišević", "Kostelić", "Šuker"],        1, "obvious"],
		["Hrvatski književnici",   ["Krleža", "Marinković", "Šenoa", "Šimić"],             1, "obvious"],
		["Hrvatski izumi",         ["kravata", "padobran", "mehanička olovka", "torpedo"], 2, "thematic"],
		["Mora nazvana po boji",   ["Crno", "Crveno", "Bijelo", "Žuto"],                   1, "wordplay",  ["crn", "crven", "bijel", "žut"]],
		["Simboli ljubavi",        ["srce", "ruža", "golubica", "prsten"],                 1, "thematic", ["srce", "prsten", "ruža"]],
		["Rječnik putovanja",      ["viza", "putovnica", "kovčeg", "tranzit"],                 1, "obvious",   ["viza"]],
		# --- rank 2 ---
		["Brz kao ___",            ["munja", "vjetar", "soko", "metak"],                   2, "wordplay"],
		["Hrvatska jela",          ["sarma", "peka", "pašticada", "burek"],                2, "obvious"],
		["Kukci",                  ["pčela", "mrav", "leptir", "kornjaš"],                 2, "obvious"],
		["Začini",                 ["papar", "sol", "cimet", "kurkuma"],                   2, "obvious",  ["sol"]],
		["Ptice selice",           ["roda", "lastavica", "čaplja", "kukavica"],            2, "obvious"],
		["Rijeke Hrvatske",        ["Sava", "Drava", "Kupa", "Neretva"],                   2, "obvious"],
		["Materijali",             ["drvo", "staklo", "plastika", "kamen"],                1, "obvious"],
		["Dijelovi automobila",    ["motor", "mjenjač", "kočnica", "volan"],               2, "obvious"],
		["Dijelovi računala",      ["tipkovnica", "pisač", "zaslon", "procesor"],          2, "obvious"],
		["Kontaktni sportovi",     ["ragbi", "judo", "hrvanje", "boks"],                   2, "obvious"],
		["Glazbeni žanrovi",       ["jazz", "blues", "klasika", "folk"],                   2, "obvious"],
		["Vrste sira",             ["gouda", "cheddar", "brie", "feta"],                   2, "obvious"],
		["Vrste tjestenine",       ["špageti", "lazanje", "rigatoni", "penne"],            2, "obvious"],
		["Vrste kruha",            ["pšenični", "integralni", "raženi", "kukuruzni"],      2, "obvious"],
		["Vrste tkanine",          ["svila", "pamuk", "lan", "vuna"],                      2, "obvious"],
		["Plesovi",                ["valcer", "tango", "samba", "polka"],                  2, "obvious"],
		["Valute",                 ["euro", "dolar", "jen", "funta"],                      2, "obvious"],
		["Vitamini",               ["vitamin A", "vitamin B", "vitamin C", "vitamin D"],   2, "obvious"],
		["Planinski vrhovi",       ["Everest", "Kilimandžaro", "Mont Blanc", "Elbrus"],    2, "obvious"],
		["Slavni slikari",         ["Picasso", "Monet", "Da Vinci", "Rembrandt"],          2, "obvious"],
		["Slavni skladatelji",     ["Mozart", "Bach", "Beethoven", "Chopin"],              2, "obvious"],
		["Arheološki lokaliteti",  ["Stonehenge", "Pompeja", "Petra", "Machu Picchu"],     2, "thematic"],
		["Vrste ribe",             ["šaran", "pastrva", "brancin", "oslić"],               2, "obvious"],
		["Mitološka bića",         ["satir", "kentaur", "sfinga", "minotaur"],             2, "thematic"],
		["Književni žanrovi",      ["roman", "novela", "pripovijetka", "bajka"],           2, "thematic"],
		["Atletske discipline",    ["sprint", "bacanje", "maraton", "štafeta"],            2, "obvious"],
		["Vrste fotografije",      ["portret", "pejzaž", "makro", "reportaža"],            2, "thematic"],
		["Ekološki pojmovi",       ["ekosustav", "biom", "biodiverzitet", "prehrambeni lanac"], 2, "thematic"],
		["Ime i biljka",           ["Ruža", "Iris", "Ljubica", "Đurđica"],                 3, "wordplay",  ["ruža"]],
		["Žut kao ___",            ["limun", "kanarinac", "sumpor", "slama"],             2, "wordplay",  ["žut"]],
		["Tiho kao ___",           ["miš", "groblje", "pustinja", "sjena"],                2, "wordplay"],
		["Mali ___",               ["princ", "prst", "oglasi", "ekran"],                   2, "wordplay"],
		["Stari ___",              ["zavjet", "kontinent", "znanac", "most"],              2, "wordplay"],
		["Divlji ___",             ["zapad", "mačka", "životinje", "konj"],                2, "wordplay"],
		["Hladan kao ___",         ["led", "zmija", "stijena", "mramor"],                  2, "wordplay"],
		["Završavaju na -ač",      ["pjevač", "igrač", "gledač", "slušač"],                2, "wordplay"],
		["Mogu se otvoriti",       ["pivo", "račun", "restoran", "prozor"],                3, "wordplay"],
		["Završavaju na -lo",      ["šilo", "krilo", "sedlo", "vrelo"],                    2, "wordplay"],
		["Završavaju na -ar",      ["zubar", "mlinar", "ribar", "slastičar"],              2, "wordplay"],
		["Počinju s pra-",         ["praotac", "prabaka", "pradomovina", "pradavni"],      2, "wordplay"],
		["Mogu prethoditi: PUT",   ["dalek", "kratak", "asfaltni", "životni"],            3, "wordplay"],
		["Načini da kažeš NE",     ["nipošto", "nikako", "baš ne", "nema šanse"],         2, "wordplay"],
		["Načini da kažeš DA",     ["naravno", "svakako", "apsolutno", "definitivno"],    2, "wordplay"],
		["Načini smijeha",         ["hihotati", "kikotati", "cerekati", "grohotati"],      2, "wordplay"],
		["Načini gledanja",        ["zuriti", "škiljiti", "piljiti", "buljiti"],           3, "wordplay"],
		["Dalmatinska jela",       ["crni rižoto", "gregada", "buzara", "soparnik"],           2, "thematic",  ["crn"]],
		["Slavni europski gradovi", ["Barcelona", "Prag", "Amsterdam", "Lisabon"],             2, "obvious"],
		["Filmski redatelji",      ["Spielberg", "Kubrick", "Godard", "Tarantino"],            2, "thematic"],
		["Slavni dramatičari",     ["Shakespeare", "Molière", "Ibsen", "Brecht"],              2, "thematic"],
		["Balkanske prijestolnice", ["Beograd", "Sarajevo", "Skopje", "Podgorica"],            2, "obvious"],
		# --- rank 3 ---
		["Star kao ___",           ["Biblija", "svijet", "Metuzalem", "brda"],             3, "wordplay"],
		["Homonimi",               ["rod", "rok", "klin", "kvaka"],                        3, "wordplay",  ["rok", "kind:homonimi"]],
		["Crni/a ___",             ["humor", "petak", "kutija", "ovca"],                   3, "wordplay",  ["crn"]],
		["Bijeli/a ___",           ["zastava", "laža", "šum", "ovratnik"],                 3, "wordplay",  ["bijel"]],
		["Hrvatska prezimena",     ["Medvedović", "Orao", "Sokol", "Kunić"],               3, "wordplay"],
		["Imaju nos",              ["lokomotiva", "čarapa", "čizma", "Pinokio"],           3, "wordplay"],
		["Imaju krilo",            ["ptica", "vjetrenjača", "dvorac", "oltar"],            3, "wordplay"],
		["Skrivena Mira",          ["mirakul", "admiral", "smiraj", "emirat"],             3, "wordplay",  ["mira", "kind:hidden_word"]],
		["Glazbeni i drugi pojmovi", ["akord", "tempo", "kvarta", "pauza"],               3, "wordplay"],
		["Izgleda kao engleska riječ",    ["sin", "pet", "tin", "no"],                     3, "wordplay"],
		["Mogu biti težak",            ["posao", "metal", "razgovor", "karakter"],      3, "semantic"],
		["Mogu se pronaći",             ["lijek", "rješenje", "izlaz", "razlog"],        3, "semantic"],
		["Sinonimi za reći",            ["kazati", "izjaviti", "priopćiti", "oglasiti"], 3, "semantic"],
		["Mogu izaći",                  ["sunce", "novine", "film", "pjesma"],           3, "semantic"],
		["Mogu pasti",                  ["kiša", "cijene", "vlada", "mrak"],             3, "semantic",  ["kiša"]],
		["Sinonimi za velik",           ["ogroman", "silan", "golem", "masivan"],        3, "semantic"],
		["Sinonimi za brz",             ["hitar", "munjevit", "žustar", "rapidan"],      3, "semantic"],
		["Mogu rasti",                  ["stablo", "briga", "kamata", "cvijet"],         3, "semantic"],
		["Može biti pun",               ["stadion", "autobus", "trbuh", "ruksak"],       3, "wordplay"],
	]

static func _blue_pool() -> Array:
	return [
		# --- rank 1 ---
		["Matematičke operacije",  ["zbrajanje", "oduzimanje", "množenje", "dijeljenje"],  1, "obvious"],
		["Krvne grupe",            ["A", "B", "AB", "0"],                                  1, "thematic"],
		["Vrste vjetra",           ["bura", "jugo", "maestral", "tramontana"],             1, "obvious"],
		["Kemijski elementi",      ["kisik", "dušik", "vodik", "ugljik"],                  1, "obvious"],
		["Književni rodovi",       ["lirika", "epika", "drama", "esej"],                   1, "thematic"],
		["Vrste energije",         ["kinetička", "potencijalna", "toplinska", "kemijska"],  1, "thematic"],
		["Fizikalne veličine",     ["masa", "sila", "brzina", "ubrzanje"],                 1, "thematic"],
		["Matematičke grane",      ["algebra", "geometrija", "analiza", "statistika"],     1, "thematic"],
		["Vrste mikroorganizama",  ["bakterija", "virus", "gljivica", "parazit"],          1, "thematic"],
		["Anatomski organi",       ["jetra", "pluća", "bubreg", "slezena"],               1, "obvious"],
		["Vrste zubi",             ["sjekutić", "očnjak", "pretkutnjak", "kutnjak"],       1, "obvious"],
		["Krvne stanice",          ["eritrocit", "leukocit", "trombocit", "limfocit"],     2, "obvious"],
		["Vrste tkiva",            ["epitelno", "mišićno", "vezivno", "živčano"],          2, "obvious"],
		["Vrste leća",             ["konkavna", "konveksna", "sferna", "asferična"],       1, "thematic"],
		["Geometrijski pojmovi",   ["tangenta", "dijagonala", "perimetar", "površina"],   1, "obvious"],
		["Vrste rečenica",         ["izjavna", "upitna", "usklična", "niječna"],           1, "obvious"],
		["Hrvatski padeži",        ["nominativ", "genitiv", "dativ", "akuzativ"],          1, "obvious"],
		["Glagolska vremena",      ["prezent", "perfekt", "aorist", "futur"],              1, "obvious"],
		["Homonimi",               ["list", "grad", "kos", "pas"],                         3, "wordplay",  ["list", "grad", "kos", "pas", "kind:homonimi"]],
		["Počinju s kro-",         ["krokodil", "krošnja", "kronometar", "krojač"],        1, "wordplay"],
		# --- rank 2 ---
		["Geološka razdoblja",     ["jura", "kreda", "silur", "devon"],                    2, "thematic"],
		["Geografski pojmovi",     ["poluotok", "tjesnac", "fjord", "laguna"],             2, "thematic"],
		["Arhitektonski stilovi",  ["barok", "gotika", "renesansa", "modernizam"],         2, "thematic"],
		["Filozofi",               ["Sokrat", "Platon", "Aristotel", "Nietzsche"],         2, "thematic"],
		["Programski jezici",      ["Python", "Java", "Rust", "Swift"],                    2, "thematic"],
		["Vrste oblaka",           ["cirus", "kumulonimbus", "stratus", "nimbostratus"],   2, "thematic"],
		["Pisci nobelovci",        ["Hemingway", "Camus", "García Márquez", "Saramago"],   2, "thematic"],
		["Vrste čajeva",           ["matcha", "sencha", "darjeeling", "oolong"],           2, "thematic"],
		["Ekonomski sustavi",      ["kapitalizam", "socijalizam", "feudalizam", "merkantilizam"], 2, "thematic"],
		["Psihološki pojmovi",     ["ego", "alter ego", "id", "superego"],                 2, "thematic"],
		["Dijelovi DNA",           ["adenin", "timin", "gvanin", "citozin"],               2, "thematic"],
		["Poznate epohe",          ["antika", "srednji vijek", "prosvjetiteljstvo", "novi vijek"], 2, "thematic"],
		["Logički paradoksi",      ["lažac", "Zenonov", "Russellov", "sorit"],             2, "thematic"],
		["Lingvistički pojmovi",   ["morfem", "fonem", "sintaksa", "semantika"],           2, "thematic"],
		["Teorije svemira",        ["prasak", "inflacija", "multisvemir", "ciklički"],     2, "thematic"],
		["Psihološki poremećaji",  ["fobija", "anksioznost", "narcizam", "paranoja"],      2, "thematic"],
		["Filozofski pojmovi",     ["dijalektika", "ontologija", "epistemologija", "metafizika"], 2, "thematic"],
		["Vrste zakona",           ["kazneni", "građanski", "ustavni", "međunarodni"],     2, "thematic"],
		["Astronomski pojmovi",    ["crna rupa", "pulsar", "kvasar", "maglica"],           2, "thematic",  ["crn"]],
		["Teorije ličnosti",       ["psihoanaliza", "biheviorizam", "humanizam", "kognitivizam"], 2, "thematic"],
		["Vrste kemijskih veza",   ["ionska", "kovalentna", "metalna", "vodikova"],        2, "thematic"],
		["Književni stilovi",      ["realizam", "romantizam", "naturalizam", "ekspresionizam"], 2, "thematic"],
		["Vrste tla",              ["glina", "pijesak", "humus", "ilovača"],               2, "thematic"],
		["Psihološke obrane",      ["potiskivanje", "projekcija", "racionalizacija", "sublimacija"], 2, "thematic"],
		["Geološki procesi",       ["erozija", "sedimentacija", "vulkanizam", "tektonika"], 2, "thematic"],
		["Statističke mjere",      ["prosjek", "medijan", "mod", "varijanca"],             2, "thematic"],
		["Prirodne katastrofe",    ["potres", "cunami", "tornado", "erupcija"],            2, "thematic"],
		["Retoričke tehnike",      ["ethos", "pathos", "logos", "kairos"],                 3, "thematic"],
		["Vrste diskursa",         ["narativni", "argumentativni", "opisni", "dijaloški"], 2, "thematic"],
		["Može biti hladan/a",     ["tuš", "rat", "znoj", "slučaj"],                       3, "wordplay"],
		["Pasti kao ___",          ["kruška", "bomba", "grom", "snop"],                    2, "wordplay"],
		["Jak kao ___",            ["vol", "hrast", "div", "bik"],                         2, "wordplay"],
		["Počinju s nad-",         ["nadimak", "nadzor", "nadnica", "nadmudriti"],         2, "wordplay"],
		["Mogu se slomiti",        ["val", "rekord", "tišina", "srce"],                    3, "wordplay",  ["srce"]],
		["Mogu se izgubiti",       ["strpljenje", "put", "smisao", "trag"],                3, "wordplay"],
		["Slobodni/a ___",         ["pad", "udar", "stih", "tržište"],                     3, "wordplay"],
		["Lagan kao ___",          ["pero", "oblak", "pahulja", "zrak"],                   2, "wordplay"],
		["Tvrd kao ___",           ["granit", "dijamant", "čelik", "orah"],                2, "wordplay"],
		["Mrtvi/a/o ___",          ["kut", "slovo", "priroda", "trka"],                    3, "wordplay"],
		["Mogu biti visoki/e",     ["zgrada", "cijena", "temperatura", "ton"],             3, "wordplay"],
		["Mogu se nositi",         ["teret", "haljina", "odgovornost", "dijete"],          3, "wordplay"],
		["Duboki/a/o ___",         ["glas", "san", "žal", "dah"],                          2, "wordplay"],
		["Sportski pojmovi s drugim značenjem", ["gol", "skok", "lopta", "koš"],          3, "wordplay"],
		["Kartaške figure s drugim značenjem",  ["kralj", "dama", "pop", "as"],            3, "wordplay"],
		["Počinju s pre-",         ["prelaz", "pregled", "premijer", "predmet"],           2, "wordplay"],
		["Počinju s pod-",         ["podzemlje", "podsjetnik", "podloga", "podrum"],       2, "wordplay",  ["podrum"]],
		["Suprotno s prefiksom ne-",   ["red", "mir", "prilika", "sklad"],                 2, "wordplay"],
		["Crvena ___",             ["nit", "karta", "knjiga", "vrpca"],                    2, "wordplay",  ["crven"]],
		["Tvrda ___",              ["škola", "valuta", "disk", "riječ"],                   2, "wordplay"],
		["Topla ___",              ["preporuka", "dobrodošlica", "fronta", "postelja"],    2, "wordplay"],
		["Otvoreno ___",           ["nebo", "oči", "pismo", "prvenstvo"],                  2, "wordplay"],
		["Mogu prethoditi: GRAD",  ["stari", "novi", "gornji", "donji"],                   2, "wordplay"],
		["Mogu prethoditi: ŠKOLA", ["osnovna", "srednja", "glazbena", "plivačka"],         2, "wordplay"],
		["Mogu prethoditi: STIL",  ["plivački", "pisani", "borbeni", "umjetnički"],        2, "wordplay"],
		["Načini hodanja",         ["šuljati se", "gegati se", "koračati", "tabati"],      2, "wordplay"],
		["Načini govora",          ["mrmljati", "šaptati", "galamiti", "brbljati"],        2, "wordplay"],
		["Mogu rezati",            ["škare", "sjekira", "kosilica", "turpija"],            2, "wordplay"],
		["Glagoli za uništiti",    ["razoriti", "razbiti", "srušiti", "demolirati"],      2, "wordplay"],
		["Glagoli za stvoriti",    ["načiniti", "izraditi", "sagraditi", "kreirati"],     2, "wordplay"],
		["Imaju okrugli oblik",    ["kugla", "tanjur", "tipka", "novčić"],                2, "wordplay"],
		["Anglizmi u hrvatskom",   ["vikend", "brend", "mejkap", "frend"],                   2, "wordplay"],
		["Vrste demokracije",      ["direktna", "predstavnička", "parlamentarna", "predsjednička"], 2, "thematic"],
		["Medicinski pojmovi",     ["simptom", "dijagnoza", "operacija", "terapija"],        2, "thematic"],
		["Biološki procesi",       ["mitoza", "mejoza", "osmoza", "difuzija"],               2, "thematic"],
		# --- rank 3 ---
		["Krvni/a ___",            ["tlak", "slika", "sud", "grupa"],                      3, "wordplay"],
		["___ polje",              ["magnetsko", "minsko", "naftno", "vidno"],             3, "wordplay"],
		["Mogu prethoditi: SUSTAV", ["solarni", "operativni", "imuni", "nervni"],          3, "wordplay"],
		["Mogu slijediti: PUNI",   ["mjesec", "pansion", "gas", "pogodak"],                3, "wordplay"],
		["Logičke operacije",      ["I", "ILI", "NE", "XOR"],                             3, "wordplay"],
		["Hrvatska mjesta",        ["Zelina", "Zlatar", "Bijelo Brdo", "Crna Mlaka"],      3, "wordplay",  ["crn", "bijel", "zlat"]],
		["Europske prijestolnice bez slova a",   ["Beč", "Rim", "Bern", "Oslo"],          3, "wordplay"],
		["Skrivena životinja",     ["kompas", "klavir", "praksa", "evolucija"],            3, "wordplay",  ["kind:hidden_word"]],
		["Turcizmi",               ["šećer", "jastuk", "džep", "rakija"],                  3, "wordplay"],
		["Germanizmi",             ["šalter", "šank", "štikla", "knedla"],                 3, "wordplay"],
		["Talijanizmi",            ["pijaca", "špica", "pršut", "lanterna"],               3, "wordplay"],
		["Šahovski potezi s drugim značenjem", ["rokada", "gambit", "matiranje", "remi"], 3, "wordplay"],
		["Skriven Rim",            ["krimić", "grimasa", "primjerak", "rimovati"],         3, "wordplay",  ["rim", "kind:hidden_word"]],
		["Imaju rupu",             ["krafna", "tunel", "sito", "gumb"],                   3, "wordplay"],
		["Mogu prethoditi: VAGON",        ["putnički", "teretni", "poštanski", "spavaći"],  3, "wordplay"],
		["Mogu prethoditi: KARTA",        ["osobna", "autobusna", "zemljopisna", "sretna"], 3, "wordplay"],
		["Mogu prethoditi: RUKA",         ["desna", "lijeva", "pomoćna", "spretna"],        3, "wordplay"],
		["Mogu prethoditi: VRIJEME",      ["slobodno", "sadašnje", "ratno", "lijepo"],      3, "wordplay"],
		["Mogu prethoditi: KORAK",        ["polagani", "odlučan", "mali", "velik"],         3, "wordplay"],
		["Završavaju na -gram",           ["telegram", "hologram", "program", "anagram"],   3, "wordplay"],
		["Mogu se vratiti",             ["dug", "sjećanje", "roba", "osmijeh"],          3, "semantic"],
		["Imaju dršku",                 ["kišobran", "torba", "štap", "lopata"],         3, "semantic"],
		["Mogu se održati",             ["izbori", "sastanak", "utakmica", "koncert"],   3, "semantic"],
		["Mogu se donijeti",            ["odluka", "zakon", "presuda", "zaključak"],     3, "semantic"],
		["Sinonimi za ići",             ["kročiti", "gaziti", "putovati", "stupati"],    3, "semantic"],
		["Mogu se primiti",             ["nagrada", "gripa", "savjet", "poziv"],         3, "semantic"],
		["Sinonimi za loš",             ["katastrofalan", "užasan", "grozan", "strašan"],3, "semantic"],
		["Mogu skupiti",                ["volju", "snagu", "misli", "dojmove"],          3, "semantic"],
		["Može biti tamna",             ["soba", "strana", "materija", "tajna"],         3, "semantic"],
		["Mogu podnijeti",              ["kaznu", "žalbu", "ostavku", "gubitak"],        3, "semantic"],
		["Mogu popustiti",              ["mraz", "čvor", "napad", "napetost"],           3, "semantic"],
		["Sinonimi za nestati",         ["iščeznuti", "ispariti", "izgubiti se", "rasplinuti se"], 3, "semantic"],
		["Mogu isteći",                 ["ugovor", "viza", "jamstvo", "mandat"],         3, "semantic",  ["viza"]],
		["Može biti skrivena",          ["agenda", "kamera", "poruka", "zamka"],         3, "semantic"],
		["Mogu prethoditi: GLAS",       ["tihi", "prodoran", "izborni", "punomoćni"],    3, "wordplay",  ["tihi"]],
		["Mogu prethoditi: VAL",        ["udarni", "zvučni", "plimni", "toplinski"],     3, "wordplay"],
		["Mogu prethoditi: TOČKA",      ["mrtva", "prekretna", "polazna", "kulminacijska"], 3, "wordplay"],
		["Mogu procvjetati",            ["karijera", "ljubav", "kultura", "talent"],     3, "semantic"],
		["Mogu se poklopiti",           ["planovi", "interesi", "rokovi", "prilike"],    3, "semantic"],
		["Skrivena Ara",               ["narav", "parabola", "garaža", "karantena"],    3, "wordplay",  ["ara", "kind:hidden_word"]],
		["Mogu se zatvoriti",          ["tema", "poglavlje", "istraga", "granica"],     3, "semantic",  ["tema", "granica"]],
		["Mogu prethoditi: MOST",      ["viseći", "pokretni", "kameni", "željezni"],     3, "wordplay"],
	]

static func _purple_pool() -> Array:
	return [
		# --- rank 1 ---
		["Latinske izreke",        ["carpe diem", "veni vidi vici", "cogito ergo sum", "memento mori"], 1, "obvious"],
		["Retoričke figure",       ["metafora", "metonimija", "sinegdoha", "oksimoron"],  1, "obvious"],
		["Filozofski pravci",      ["empirizam", "racionalizam", "nihilizam", "egzistencijalizam"], 1, "thematic"],
		["Vrste argumentacije",    ["dedukcija", "indukcija", "abdukcija", "analogija"],  1, "thematic"],
		["Poetski žanrovi",        ["elegija", "oda", "sonet", "epigram"],                1, "obvious"],
		["Epistemološki pojmovi",  ["znanje", "uvjerenje", "opravdanje", "istina"],       1, "thematic"],
		["Latinski prefiks anti-",   ["antiteza", "antikrist", "antibiotik", "antipod"],  2, "thematic"],
		["Latinski prefiks super-",  ["superlativ", "supermen", "superiornost", "supervizor"], 2, "thematic"],
		["Latinski prefiks sub-",    ["subverzija", "subordinacija", "subjekt", "subkultura"], 2, "thematic"],
		["Latinski prefiks in-",     ["inverzija", "intuicija", "indikator", "integracija"], 2, "thematic"],
		["Grčki brojčani prefiks", ["monolog", "dijalog", "triatlon", "tetraedar"],       1, "obvious"],
		["Tipovi rime",            ["parna", "ukrštena", "obgrljena", "slobodna"],        1, "obvious"],
		["Vrste umjetničkih -izama", ["impresionizam", "kubizam", "futurizam", "dadaizam"], 1, "thematic"],
		["Filozofska pitanja",     ["tko", "što", "kako", "zašto"],                       1, "thematic"],
		["Kategorički imperativi", ["univerzalnost", "dostojanstvo", "autonomija", "samosvrha"], 3, "thematic"],
		["Latinski prefiks trans-",  ["transcendencija", "transformacija", "transparentnost", "transmutacija"], 2, "thematic"],
		["Grčki prefiks auto-",     ["automatizam", "autobiografija", "autohtoni", "autostop"], 2, "thematic"],
		["Crven kao ___",          ["rak", "cigla", "mak", "krv"],                        2, "wordplay",  ["crven"]],
		# --- rank 2 ---
		["Vrste pamćenja",         ["epizodično", "semantičko", "proceduralno", "radno"], 2, "thematic"],
		["Teorije uma",            ["funkcionalizam", "dualizam", "fizikalizam", "eliminativizam"], 3, "thematic"],
		["Evolucijski mehanizmi",  ["selekcija", "mutacija", "drift", "migracija"],       2, "thematic"],
		["Neurološki pojmovi",     ["sinapsa", "akson", "dendrit", "mijelin"],            3, "thematic"],
		["Tipovi naracije",        ["sveznajući", "prvoličan", "drugoličan", "nepouzdan"], 2, "thematic"],
		["Glazbene ljestvice",     ["dorska", "frigijska", "lidijska", "miksolidijska"],  3, "thematic"],
		["Stilske figure",         ["hiperbola", "litota", "eufonija", "anadiploza"],     3, "thematic"],
		["Kognitivne pristranosti",["potvrđivanje", "sidrenje", "retrospekcija", "dostupnost"], 3, "thematic"],
		["Semiotički pojmovi",     ["znak", "označitelj", "označeno", "referent"],        3, "thematic"],
		["Pravni pojmovi",         ["kazuistika", "precedent", "interpretacija", "supsidijarnost"], 3, "thematic"],
		["Teorije pravde",         ["utilitarizam", "deontologija", "aretaika", "kontraktualizam"], 3, "thematic"],
		["Matematičke teoreme",    ["Pitagorin", "Fermatov", "Bayesov", "Eulerov"],       2, "thematic"],
		["Matematička logika",     ["aksiom", "teorem", "dokaz", "lema"],                 2, "thematic"],
		["Filozofija uma",         ["svjesnost", "namjernost", "kvalije", "subjektivnost"], 2, "thematic"],
		["Vrste etike",            ["deontološka", "utilitaristička", "aretička", "situacijska"], 2, "thematic"],
		["Sintaktički nizovi",     ["parataksa", "hipotaksa", "sindeton", "asindeton"],    3, "thematic"],
		["Tipovi paradoksa",       ["ontološki", "temporalni", "pragmatički", "semantički"], 3, "thematic"],
		["Vrste motiva u književnosti", ["lajtmotiv", "dinamički", "statički", "naslovni"], 3, "thematic"],
		["Vrste teorija",          ["preskriptivna", "deskriptivna", "normativna", "eksplanatorna"], 3, "thematic"],
		["___ kamen",              ["bubrežni", "žučni", "temeljni", "dragi"],            2, "wordplay"],
		["Vruća ___",              ["tema", "linija", "čokolada", "točka"],               2, "wordplay",  ["tema"]],
		["Spavati kao ___",        ["klada", "beba", "top", "anđeo"],                     2, "wordplay"],
		["Zanati kao prezimena",   ["Kovač", "Kolar", "Tesar", "Lončar"],                 2, "wordplay"],
		["Zlatna ___",             ["groznica", "sredina", "ribica", "medalja"],           2, "wordplay",  ["zlat"]],
		["Ženska imena i pojmovi", ["Vjera", "Sloboda", "Nada", "Zora"],                  2, "wordplay"],
		["Crna ___",               ["burza", "magija", "kronika", "lista"],               2, "wordplay",  ["crn"]],
		["Bez + ___",              ["bol", "obzir", "um", "kraj"],                        2, "wordplay"],
		["Težak kao ___",          ["olovo", "grijeh", "mlinski kamen", "sudbina"],       2, "wordplay"],
		["Oštar kao ___",          ["britva", "igla", "mač", "jezik"],                    2, "wordplay"],
		["___ rat",                ["hladni", "domovinski", "zvjezdani", "vjerski"],      2, "wordplay"],
		["Mogu prethoditi: VATRA", ["vječna", "olimpijska", "sveta", "paklena"],           2, "wordplay"],
		["Mogu prethoditi: SAN",   ["mokri", "ružan", "lijepi", "dnevni"],                 2, "wordplay"],
		["Mogu slijediti: ZLATNI", ["okvir", "rez", "fond", "standard"],                   2, "wordplay",  ["zlat"]],
		["Mogu slijediti: TIHI",   ["ocean", "partner", "protest", "promatrač"],           2, "wordplay"],
		["Glagoli za promatrati",   ["opažati", "motriti", "uočiti", "nadzirati"],         2, "wordplay"],
		["Sinonimi za propast",    ["fijasko", "brodolom", "podbačaj", "promašaj"],        2, "semantic"],
		# --- rank 3 ---
		["Mogu biti živi/e",       ["biće", "srebro", "meso", "pitanje"],                 3, "wordplay",  ["srebr"]],
		["Metrika u poeziji",      ["jamb", "trohej", "daktil", "amfibrah"],              3, "thematic"],
		["Zvukovne figure",        ["aliteracija", "asonanca", "onomatopeja", "paronomazija"], 3, "thematic"],
		["Kvantna fizika",         ["kvark", "gluon", "bozon", "fermion"],                3, "thematic"],
		["Ekonomski paradoksi",    ["Giffenov", "Veblenov", "Simpsonov", "Condorcetov"],  3, "thematic"],
		["Tipovi silogizma",       ["Barbara", "Celarent", "Darii", "Ferio"],             3, "thematic"],
		["Teorije kaosa",          ["atraktor", "bifurkacija", "fraktal", "entropija"],   3, "thematic"],
		["Lingvistički univerzali",["arbitrarnost", "produktivnost", "pomak", "dvostruka artikulacija"], 3, "thematic",  ["pomak"]],
		["Fenomenološki pojmovi",  ["intencionalnost", "epoché", "intersubjektivnost", "horizont"], 3, "thematic"],
		["Sociolingvistički pojmovi", ["diglosija", "pidžin", "kreolski", "kodna izmjena"], 3, "thematic"],
		["Hermeneutički pojmovi",  ["hermeneutički krug", "predrazumijevanje", "razumijevanje", "tekst"], 3, "thematic"],
		["Teorije istine",         ["korespondencija", "koherencija", "pragmatizam", "deflacionizam"], 3, "thematic"],
		["Vrste modaliteta",       ["nužnost", "mogućnost", "kontingentnost", "nemogućnost"], 3, "thematic"],
		["Homonimi",               ["bit", "mast", "vez", "kosa"],                        3, "wordplay",  ["kosa", "kind:homonimi"]],
		["Otok = grad",            ["Hvar", "Krk", "Rab", "Vis"],                         3, "wordplay"],
		["Broj u prefiksu",        ["jednorog", "dvoboj", "trijumf", "četveronožac"],     3, "wordplay"],
		["Krije se nota",          ["dobar", "redar", "misija", "fakultet"],              3, "wordplay",  ["kind:hidden_word"]],
		["Suprotno s prefiksom ne-",        ["sreća", "pravda", "volja", "moć"],          3, "wordplay"],
		["Skrivena Ana",           ["banana", "kanal", "ranac", "fontana"],               3, "wordplay",  ["ana", "banana", "kind:hidden_word"]],
		["Skrivena Iva",           ["divan", "kriva", "privatan", "perspektiva"],         3, "wordplay",  ["iva", "kind:hidden_word"]],
		["Skrivena Pula",          ["kapula", "populacija", "kopula", "manipulacija"],    3, "wordplay",  ["pula", "kind:hidden_word"]],
		["Tri ili više značenja",  ["luk", "vrata", "oko", "ključ"],                      3, "wordplay",  ["luk", "vrata"]],
		["Hrvatski i engleski — različito značenje", ["kola", "sok", "ten", "sat"],      3, "wordplay"],
		["Padežni homonimi",       ["sela", "knjige", "žene", "priče"],                    3, "wordplay"],
		["Završavaju dijelom tijela", ["tvrdoglav", "dugonog", "miloruk", "golobrad"],     3, "wordplay"],
		["Palindromi",             ["kuk", "topot", "ratar", "potop"],                      3, "wordplay"],
		["Krije se dio tijela",           ["naručje", "nosač", "rukohvat", "zubarica"],    3, "wordplay",  ["kind:hidden_word"]],
		["Pridjevi strane svijeta",       ["sjeverni", "južni", "istočni", "zapadni"],     3, "semantic"],
		["I stvar i osjećaj",             ["breme", "pritisak", "opterećenje", "jaram"],   3, "wordplay"],
		["Krije se broj",                 ["osamnaest", "devetina", "sedamdeset", "desetak"], 3, "wordplay",  ["kind:hidden_word"]],
		["Mogu prethoditi: OKO",          ["ptičje", "magareće", "orlovsko", "sokolovo"],  3, "wordplay"],
		["Završavaju na -log",            ["katalog", "psiholog", "biolog", "analog"],     3, "wordplay",  ["katalog"]],
		["Sinonimi za lopov",           ["kradljivac", "razbojnik", "pljačkaš", "tat"],  3, "semantic"],
		["Skrivena Una",               ["luna", "tuna", "fortuna", "tribuna"],            3, "wordplay",  ["una", "kind:hidden_word"]],
		["Skrivena Eva",               ["nevaljao", "prevara", "revans", "sevap"],        3, "wordplay",  ["eva", "kind:hidden_word"]],
		["Skriven Ivan",               ["naivan", "kivan", "šivanje", "prošivan"],        3, "wordplay",  ["ivan", "kind:hidden_word"]],
		["Skrivena Ema",               ["premaz", "njemački", "emblema", "kinematograf"], 3, "wordplay",  ["ema", "kind:hidden_word"]],
		["Skrivena Ela",               ["ćelav", "pelar", "relaksacija", "korelacija"],   3, "wordplay",  ["ela", "kind:hidden_word"]],
		["Krije se osa",               ["kosač", "glosar", "dosadan", "vosak"],           3, "wordplay",  ["osa", "kind:hidden_word"]],
		["Krije se mir",               ["primirje", "mirovina", "miris", "smiriti"],      3, "wordplay",  ["mir", "kind:hidden_word"]],
		["Krije se sol",               ["resolutan", "rasol", "parasol", "resolucija"],   3, "wordplay",  ["sol", "kind:hidden_word"]],
		["Skrivena Toni",              ["antonim", "plutonij", "fotoni", "monotonija"],   3, "wordplay",  ["toni", "kind:hidden_word"]],
		["Krije se pet",               ["apetit", "kapetanica", "tapetirati", "upetljati"], 3, "wordplay",  ["pet", "kind:hidden_word"]],
	]

# today_seed  — YYYYMMDD int for today; drives weight variant and tier-order shuffle.
# excluded_seeds — array of YYYYMMDD ints (last N days) whose categories are excluded.
static func get_single_puzzle(today_seed: int = -1, excluded_seeds: Array = []) -> Puzzle:
	var raw_pools: Array = [_yellow_pool(), _green_pool(), _blue_pool(), _purple_pool()]
	var diffs: Array = [Difficulty.YELLOW, Difficulty.GREEN, Difficulty.BLUE, Difficulty.PURPLE]
	var extras: Dictionary = _category_extras()

	# Fix 2: rotate rank bias across days so difficulty varies slightly day-to-day.
	var weight_variants: Array = [
		[35, 45, 20],  # today_seed % 3 == 0 — slightly easier
		[25, 45, 30],  # today_seed % 3 == 1 — balanced
		[15, 45, 40],  # today_seed % 3 == 2 — slightly harder
	]
	var weights: Array = weight_variants[today_seed % 3] if today_seed >= 0 else [25, 45, 30]

	var pool_buckets: Array = []
	for pool in raw_pools:
		var buckets: Dictionary = {1: [], 2: [], 3: []}
		for entry in pool:
			var rank: int = entry[2] if entry.size() > 2 else 2
			buckets[rank].append(entry)
		for r in [1, 2, 3]:
			buckets[r].shuffle()
		pool_buckets.append(buckets)

	# Fix 4: union of excluded categories across all recent days.
	var excluded: Dictionary = {}
	for seed_val in excluded_seeds:
		if seed_val >= 0:
			for k in _names_for_seed(seed_val, weights):
				excluded[k] = true

	# Fix 3: shuffle tier pick order per-day so conflict resolution doesn't always
	# favour YELLOW over PURPLE. Use a separate RNG to avoid consuming global RNG state.
	var tier_order: Array = [0, 1, 2, 3]
	if today_seed >= 0:
		var rng_t := RandomNumberGenerator.new()
		rng_t.seed = today_seed ^ 0xDEAD  # XOR to avoid aliasing _names_for_seed seeds
		for i in range(3, 0, -1):
			var j := rng_t.randi() % (i + 1)
			var tmp = tier_order[i]; tier_order[i] = tier_order[j]; tier_order[j] = tmp

	var cats_by_tier: Dictionary = {}
	var used_subtypes: Dictionary = {}
	var used_conflict_tags: Dictionary = {}
	for p in tier_order:
		var entry: Array = _weighted_pick(pool_buckets[p], weights)
		if not _frazem_ok(entry[0], used_subtypes) or excluded.has(entry[0]) or not _conflict_ok(entry, used_conflict_tags):
			entry = _try_swap(pool_buckets[p], entry, used_subtypes, excluded, used_conflict_tags)
		var subtype := _get_frazem_subtype(entry[0])
		if subtype != "":
			used_subtypes[subtype] = true
		for tag in _get_conflict_tags(entry):
			used_conflict_tags[tag] = true
		var cat: Category = Category.new(entry[0], _to_typed(entry[1]), diffs[p])
		cat.rank       = entry[2] if entry.size() > 2 else 2
		cat.complexity = entry[3] if entry.size() > 3 else "thematic"
		cat.extra = extras.get(entry[0], "")
		cats_by_tier[p] = cat

	var cats: Array = []
	for p in 4:
		cats.append(cats_by_tier[p])

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
		var used_conflict_tags: Dictionary = {}
		for p in 4:
			var entry: Array = _weighted_pick(pool_buckets[p], weights)
			if not _frazem_ok(entry[0], used_subtypes) or not _conflict_ok(entry, used_conflict_tags):
				entry = _try_swap(pool_buckets[p], entry, used_subtypes, {}, used_conflict_tags)
			var subtype := _get_frazem_subtype(entry[0])
			if subtype != "":
				used_subtypes[subtype] = true
			for tag in _get_conflict_tags(entry):
				used_conflict_tags[tag] = true
			var cat: Category = Category.new(entry[0], _to_typed(entry[1]), diffs[p])
			cat.rank       = entry[2] if entry.size() > 2 else 2
			cat.complexity = entry[3] if entry.size() > 3 else "thematic"
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

# Entry format: [name, words, rank, complexity, conflict_tags?]
# conflict_tags is an optional Array[String] of root labels (e.g. "zlat").
# Two entries sharing any tag are excluded from appearing in the same puzzle.
static func _get_conflict_tags(entry: Array) -> Array:
	return entry[4] if entry.size() > 4 else []

static func _conflict_ok(entry: Array, used_tags: Dictionary) -> bool:
	for tag in _get_conflict_tags(entry):
		if used_tags.has(tag):
			return false
	return true

# Swaps a rejected entry for one that satisfies the frazem subtype cap,
# conflict tag constraints, and the adjacent-day exclusion set.
# Relaxes constraints progressively before accepting the original as last resort.
static func _try_swap(buckets: Dictionary, rejected: Array, used_subtypes: Dictionary, excluded: Dictionary, used_tags: Dictionary = {}) -> Array:
	var rank: int = rejected[2] if rejected.size() > 2 else 2
	buckets[rank].push_back(rejected)

	for r in [1, 2, 3]:
		for i in range(buckets[r].size() - 1, -1, -1):
			var cand: Array = buckets[r][i]
			if _frazem_ok(cand[0], used_subtypes) and not excluded.has(cand[0]) and _conflict_ok(cand, used_tags):
				buckets[r].remove_at(i)
				return cand

	# Relax exclusion — still enforce subtype cap and conflict tags
	for r in [1, 2, 3]:
		for i in range(buckets[r].size() - 1, -1, -1):
			var cand: Array = buckets[r][i]
			if _frazem_ok(cand[0], used_subtypes) and _conflict_ok(cand, used_tags):
				buckets[r].remove_at(i)
				return cand

	# Relax conflict tags — still enforce subtype cap
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
	var used_conflict_tags: Dictionary = {}
	for p in 4:
		var entry: Array = _weighted_pick_rng(pool_buckets[p], weights, rng)
		if not _frazem_ok(entry[0], used_subtypes) or not _conflict_ok(entry, used_conflict_tags):
			entry = _try_swap(pool_buckets[p], entry, used_subtypes, {}, used_conflict_tags)
		var subtype := _get_frazem_subtype(entry[0])
		if subtype != "":
			used_subtypes[subtype] = true
		for tag in _get_conflict_tags(entry):
			used_conflict_tags[tag] = true
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
		"Homonimi":                              "Jedna riječ, dva potpuno različita značenja",
		"Ime i biljka":                          "Ista riječ: žensko ime i biljka",
		"Hrvatska prezimena":                    "Izgledaju kao životinje, ali su prezimena",
		"Završavaju na -ač":                     "Sve riječi završavaju sufiksom -ač",
		"Imaju nos":                             "Sve imaju nos — doslovno ili u obliku",
		"Imaju krilo":                           "Sve imaju krilo — doslovno ili metaforički",
		"Počinju s pra-":                        "Sve riječi imaju prefiks pra-",
		"Hrvatska mjesta":                       "Izgledaju kao boje, ali su geografska mjesta",
		"Počinju s nad-":                        "Sve riječi imaju prefiks nad-",
		"Europske prijestolnice bez slova a":    "Prijestolnice koje ne sadrže slovo a",
		"Skrivena životinja":                    "U svakoj se riječi krije naziv životinje",
		"Turcizmi":                              "Riječi turskog podrijetla",
		"Germanizmi":                            "Riječi njemačkog podrijetla",
		"Talijanizmi":                           "Riječi talijanskog podrijetla",
		"Sportski pojmovi s drugim značenjem":   "Svaka je i sport i nešto drugo",
		"Kartaške figure s drugim značenjem":    "Karte ili nešto drugo?",
		"Šahovski potezi s drugim značenjem":   "Svaki je i šah i nešto drugo",
		"Skriven Rim":                           "U svakoj se riječi krije grad RIM",
		"Latinski prefiks anti-":               "Sve počinju s anti- (protiv)",
		"Latinski prefiks super-":              "Sve počinju s super- (iznad)",
		"Latinski prefiks sub-":                "Sve počinju s sub- (ispod)",
		"Latinski prefiks in-":                 "Sve počinju s in- (u, ne)",
		"Grčki brojčani prefiks":               "Skriven broj 1, 2, 3, 4 u prefiksu",
		"Latinski prefiks trans-":              "Sve počinju s trans- (preko)",
		"Grčki prefiks auto-":                  "Sve počinju s auto- (sam)",
		"Otok = grad":                           "Hrvatski otoci koji su i gradovi",
		"Zanati kao prezimena":                  "Stara hrvatska prezimena nazvana po zanatima",
		"Krije se nota":                         "U svakoj se krije druga nota — DO, RE, MI, FA",
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
		"Imaju rupu":                            "Sve imaju rupu — doslovno",
		"Mogu rezati":                           "Sve mogu rezati ili brusiti",
		"Glagoli za uništiti":                   "Sve znače uništiti",
		"Glagoli za stvoriti":                   "Sve znače stvoriti",
		"Imaju okrugli oblik":                   "Sve imaju okrugli oblik",
		"Mogu prethoditi: VATRA":                "Sve mogu prethoditi imenici VATRA",
		"Mogu prethoditi: SAN":                  "Sve mogu prethoditi imenici SAN",
		"Mogu slijediti: ZLATNI":                "Sve mogu slijediti pridjev ZLATNI",
		"Mogu slijediti: TIHI":                  "Sve mogu slijediti pridjev TIHI",
		"Završavaju dijelom tijela":             "Svaka riječ završava nazivom dijela tijela",
		"Glagoli za promatrati":                 "Sve znače pozorno gledati",
		"Krije se broj":                             "U svakoj se krije broj",
		"Broj u prefiksu":                           "Svaka riječ ima skriven broj kao prefiks: jed(no)-, dvo-, tri-, četvero-",
		"Mogu biti kiseli":                          "Sve može biti kiselo — doslovno ili u prenesenom smislu",
		"Mogu zujati":                               "Sve može zujati — insekti, uređaji, struja",
		"Mogu prsnuti":                              "Sve može prsnuti — fizički ili od smijeha",
		"Krije se oko":                              "U svakoj se riječi krije OKO",
		"Krije se put":                              "U svakoj se riječi krije PUT",
		"Krije se dan":                              "U svakoj se riječi krije DAN",
		"Krije se led":                              "U svakoj se riječi krije LED",
		"Krije se val":                              "U svakoj se riječi krije VAL",
		"Krije se mak":                              "U svakoj se riječi krije MAK",
		"Mogu se oguliti":                           "Sve se može oguliti ili oljuštiti",
		"Idu u paru":                                "Sve dolazi u paru — uvijek dvoje",
		"Mogu procuriti":                            "Sve može procuriti — doslovno ili u prenesenom smislu",
		"Krije se rat":                              "U svakoj se riječi krije RAT",
		"Mogu kapati":                               "Sve kapa — slavina, svjeća, med i smola",
		"Mogu poplaviti":                            "Sve može poplaviti — doslovno",
		"Krije se dio tijela":					 "U svakoj se krije dio tijela",
		"Prirodne katastrofe":					 "Sve su snažne prirodne pojave",
		"I stvar i osjećaj":					 "Fizička težina i emocionalni teret — oboje odjednom",
		"Izgleda kao engleska riječ":					 "Isto pismo, drugačije značenje na engleskom",
		"Pridjevi strane svijeta":					 "Sjeverni pol, južna Amerika, istočni blok, divlji zapad",
		"Završavaju na -gram":					 "Sve završavaju na -gram",
		"Završavaju na -log":					 "Sve završavaju na -log",
		"Palindromi":                            "Riječi koje se jednako čitaju s obje strane",
		"Skrivena Una":                          "U svakoj se riječi krije ime UNA",
		"Skrivena Eva":                          "U svakoj se riječi krije ime EVA",
		"Skriven Ivan":                          "U svakoj se riječi krije ime IVAN",
		"Skrivena Ema":                          "U svakoj se riječi krije ime EMA",
		"Skrivena Ela":                          "U svakoj se riječi krije ime ELA",
		"Može biti skrivena":                    "Sve mogu biti skrivene — u različitim kontekstima",
		"Mogu prethoditi: GLAS":                 "Sve mogu prethoditi imenici GLAS (glas = voice ili vote)",
		"Krije se osa":                          "U svakoj se riječi krije insekt OSA",
		"Mogu prethoditi: VAL":                  "Sve mogu prethoditi imenici VAL",
		"Mogu prethoditi: TOČKA":               "Sve mogu prethoditi imenici TOČKA",
		"Mogu procvjetati":                      "Sve može procvjetati — u prenesenom smislu",
		"Mogu se poklopiti":                     "Sve se može poklopiti — vremenski ili sadržajno",
		"Skrivena Ara":                          "U svakoj se riječi krije ime ARA",
		"Mogu se zatvoriti":                     "Sve se može zatvoriti — u različitim kontekstima",
		"Mogu skupiti":                          "Sve se može skupiti — u sebi ili oko sebe",
		"Može biti pun":                         "Sve može biti puno — doslovno ili u prenesenom smislu",
		"Anglizmi u hrvatskom":                  "Sve su posuđenice iz engleskog jezika",
		"Krije se mir":                          "U svakoj se riječi krije MIR",
		"Krije se sol":                          "U svakoj se riječi krije SOL",
		"Skrivena Toni":                         "U svakoj se riječi krije ime TONI",
		"Krije se pet":                          "U svakoj se riječi krije PET",
	}

static func _to_typed(arr: Array) -> Array[String]:
	var result: Array[String] = []
	result.assign(arr)
	return result
