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

class Category:
	var name: String
	var words: Array[String]
	var difficulty: PuzzleData.Difficulty
	var extra: String = ""

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
# Each entry: [name, [w1, w2, w3, w4]]
# -------------------------------------------------------------------
static func _yellow_pool() -> Array:
	return [
		["Domaće životinje",       ["krava", "svinja", "konj", "koza"]],
		["Boje",                   ["plava", "zelena", "žuta", "crvena"]],
		["Voće",                   ["jabuka", "kruška", "šljiva", "trešnja"]],
		["Povrće",                 ["mrkva", "krumpir", "luk", "špinat"]],
		["Godišnja doba",          ["proljeće", "ljeto", "jesen", "zima"]],
		["Dani u tjednu",          ["ponedjeljak", "utorak", "srijeda", "četvrtak"]],
		["Planeti",                ["Mars", "Venera", "Saturn", "Jupiter"]],
		["Oceani",                 ["Tihi", "Atlantski", "Indijski", "Arktički"]],
		["Dijelovi lica",          ["čelo", "nos", "brada", "obrazi"]],
		["Namještaj",              ["stol", "stolica", "krevet", "ormar"]],
		["Oblici",                 ["krug", "kvadrat", "trokut", "pravokutnik"]],
		["Metali",                 ["zlato", "srebro", "željezo", "bakar"]],
		["Osjećaji",               ["radost", "tuga", "strah", "ljutnja"]],
		["Odjeća",                 ["majica", "hlače", "suknja", "jakna"]],
		["Zimski sportovi",        ["skijanje", "sanjkanje", "hokej", "klizanje"]],
		["Instrumenti",            ["gitara", "violina", "truba", "flauta"]],
		["Prijevozna sredstva",    ["auto", "vlak", "avion", "brod"]],
		["Cvijeće",                ["ruža", "tulipan", "lavanda", "suncokret"]],
		["Drveće",                 ["hrast", "bukva", "bor", "javor"]],
		["Doručak",                ["jaje", "tost", "jogurt", "žitarice"]],
		["Životinje u moru",       ["riba", "račić", "lignja", "školjka"]],
		["Tople boje",             ["narančasta", "ljubičasta", "ružičasta", "smeđa"]],
		["Dijelovi tijela",        ["ruka", "noga", "glava", "leđa"]],
		["Kućanski aparati",       ["hladnjak", "perilica", "mikrovalna", "usisavač"]],
		["Sportovi",               ["plivanje", "trčanje", "biciklizam", "gimnastika"]],
		["Životinje u šumi",       ["medvjed", "vuk", "jelen", "lisica"]],
		["Pića",                   ["voda", "sok", "čaj", "kava"]],
		["Školski predmeti",       ["matematika", "povijest", "geografija", "biologija"]],
		["Dijelovi kuće",          ["kuhinja", "spavaća soba", "dnevna soba", "kupaonica"]],
		["Alati",                  ["čekić", "pila", "odvijač", "kliješta"]],
		["Bobičasto voće",         ["jagoda", "malina", "borovnica", "grožđe"]],
		["Morske životinje",       ["dupin", "hobotnica", "morski pas", "tuna"]],
		["Ljetni sportovi",        ["vaterpolo", "jedriličarstvo", "atletika", "veslanje"]],
		["Životinje na farmi",     ["pijetao", "guska", "purica", "patka"]],
	]

static func _green_pool() -> Array:
	return [
		["Note glazbene ljestvice", ["do", "re", "mi", "fa"]],
		["Sportovi s loptom",      ["košarka", "odbojka", "rukomet", "tenis"]],
		["Plesovi",                ["valcer", "tango", "samba", "polka"]],
		["Kukci",                  ["pčela", "mrav", "leptir", "kornjaš"]],
		["Začini",                 ["papar", "sol", "cimet", "kurkuma"]],
		["Planinski vrhovi",       ["Everest", "Kilimandžaro", "Mont Blanc", "Elbrus"]],
		["Slavni slikari",         ["Picasso", "Monet", "Da Vinci", "Rembrandt"]],
		["Vrste sira",             ["gouda", "cheddar", "brie", "feta"]],
		["Ptice selice",           ["roda", "lastavica", "čaplja", "kukavica"]],
		["Rijeke Hrvatske",        ["Sava", "Drava", "Kupa", "Neretva"]],
		["Vrste tkanine",          ["svila", "pamuk", "lan", "vuna"]],
		["Mjerne jedinice",        ["metar", "kilogram", "sekunda", "litra"]],
		["Vrste kruha",            ["bijeli", "crni", "raženi", "kukuruzni"]],
		["Materijali",             ["drvo", "staklo", "plastika", "kamen"]],
		["Dijelovi računala",      ["tipkovnica", "miš", "zaslon", "procesor"]],
		["Slavni skladatelji",     ["Mozart", "Bach", "Beethoven", "Chopin"]],
		["Vrste tjestenine",       ["špageti", "lazanje", "rigatoni", "penne"]],
		["Arheološki lokaliteti",  ["Stonehenge", "Pompeja", "Petra", "Machu Picchu"]],
		["Valute",                 ["euro", "dolar", "jen", "funta"]],
		["Vitamini",               ["vitamin A", "vitamin B", "vitamin C", "vitamin D"]],
		["Hrvatska jela",          ["sarma", "peka", "pasticada", "burek"]],
		["Gradovi Hrvatske",       ["Zagreb", "Split", "Rijeka", "Osijek"]],
		["Glazbeni žanrovi",       ["jazz", "blues", "klasika", "folk"]],
		["Vrste ribe",             ["šaran", "pastrva", "brancin", "lubin"]],
		["Europske države",        ["Njemačka", "Francuska", "Italija", "Španjolska"]],
		["Zanimanja",              ["liječnik", "učitelj", "vatrogasac", "pilot"]],
		["Dijelovi automobila",    ["motor", "mjenjač", "kočnica", "upravljač"]],
		["Egzotično voće",         ["mango", "papaja", "avokado", "ananas"]],
		["Životinje savane",       ["lav", "slon", "žirafa", "zebra"]],
		["Kontaktni sportovi",     ["ragbi", "judo", "hrvanje", "boks"]],
		["Kuhinjski pribor",       ["lonac", "tava", "žlica", "nož"]],
		# Tip 1 — skrivena veza
		["Mora nazvana po boji",   ["Crno", "Crveno", "Bijelo", "Žuto"]],
		# Tip 2 — homonimi: žensko ime i biljka
		["Ime i biljka",           ["Ruža", "Iris", "Ljubica", "Ljiljana"]],
		# Tip 3 — ___ + ista riječ
		["Crni/a ___",             ["humor", "petak", "kutija", "ovca"]],
		["Bijeli/a ___",           ["zastava", "laža", "šum", "ovratnik"]],
		# Tip 4 — frazeološki
		["Brz kao ___",            ["munja", "vjetar", "zec", "metak"]],
		["Tiho kao ___",           ["miš", "grob", "noć", "groblje"]],
		# Tip 5 — lažni prijatelji: izgledaju kao životinje, ali su hrvatska prezimena
		["Hrvatska prezimena",     ["Medved", "Orao", "Sokol", "Kunić"]],
		# Tip 3
		["Mali ___",               ["brat", "prst", "oglasi", "vojnik"]],
		["Stari ___",              ["zavjet", "kontinent", "mačak", "most"]],
		["Divlji ___",             ["zapad", "mačka", "životinje", "vatra"]],
		# Tip 4
		["Hladan kao ___",         ["led", "zmija", "stijene", "mramor"]],
		["Star kao ___",           ["Biblija", "svijet", "baka", "brda"]],
		# Tip 6
		["Završavaju na '-ač'",    ["pjevač", "igrač", "gledač", "slušač"]],
	]

static func _blue_pool() -> Array:
	return [
		["Filozofi",               ["Sokrat", "Platon", "Aristotel", "Nietzsche"]],
		["Programski jezici",      ["Python", "Java", "Rust", "Swift"]],
		["Vrste oblaka",           ["cirrus", "kumulonimbus", "stratus", "nimbostratus"]],
		["Kemijski elementi",      ["kisik", "dušik", "vodik", "ugljik"]],
		["Pisci nobelovci",        ["Hemingway", "Camus", "Kafka", "Orwell"]],
		["Vrste čajeva",           ["zeleni", "crni", "bijeli", "oolong"]],
		["Arhitektonski stilovi",  ["barok", "gotika", "renesansa", "modernizam"]],
		["Matematičke operacije",  ["zbrajanje", "oduzimanje", "množenje", "dijeljenje"]],
		["Geografski pojmovi",     ["poluotok", "tjesnac", "fjord", "laguna"]],
		["Logičke operacije",      ["I", "ILI", "NE", "XOR"]],
		["Vrste vjetra",           ["bura", "jugo", "maestral", "tramontana"]],
		["Krvne grupe",            ["A", "B", "AB", "0"]],
		["Ekonomski sustavi",      ["kapitalizam", "socijalizam", "feudalizam", "merkantilizam"]],
		["Psihološki pojmovi",     ["ego", "alter ego", "id", "superego"]],
		["Dijelovi DNA",           ["adenin", "timin", "gvanin", "citozin"]],
		["Poznate epohe",          ["antika", "srednji vijek", "renesansa", "barok"]],
		["Logički paradoksi",      ["lažac", "Zenonov", "Russellov", "sorit"]],
		["Vrste energije",         ["kinetička", "potencijalna", "toplinska", "kemijska"]],
		["Lingvistički pojmovi",   ["morfem", "fonem", "sintaksa", "semantika"]],
		["Teorije svemira",        ["Veliki prasak", "Inflacija", "Multisvemir", "Ciklički model"]],
		["Književni rodovi",       ["lirika", "epika", "drama", "esej"]],
		["Psihološki poremećaji",  ["fobija", "anksioznost", "narcizam", "paranoja"]],
		["Filozofski pojmovi",     ["dijalektika", "ontologija", "epistemologija", "metafizika"]],
		["Vrste zakona",           ["kazneni", "građanski", "ustavni", "međunarodni"]],
		["Geološka razdoblja",     ["jura", "kreda", "silur", "devon"]],
		["Vrste tla",              ["glina", "pijesak", "humus", "ilovača"]],
		["Astronomski pojmovi",    ["crna rupa", "pulsar", "kvasar", "magla"]],
		["Teorije ličnosti",       ["psihoanaliza", "biheviorizam", "humanizam", "kognitivizam"]],
		["Vrste kemijskih veza",   ["ionska", "kovalentna", "metalna", "vodikova"]],
		["Književni stilovi",      ["realizam", "romantizam", "naturalizam", "ekspresionizam"]],
		# Tip 1 — skrivena veza
		["Može biti 'hladan/a'",   ["tuš", "rat", "znoj", "slučaj"]],
		["Ide uz 'zlatni/a/o'",    ["runo", "ribica", "doba", "medalja"]],
		# Tip 2 — homonimi: jedna hrvatska riječ, dva značenja
		["Dvije različite stvari", ["list", "grad", "more", "pas"]],
		# Tip 3 — ___ + ista riječ
		["Krvni/a ___",            ["tlak", "slika", "sud", "grupa"]],
		["___ polje",              ["magnetsko", "minsko", "naftno", "vidno"]],
		# Tip 4 — frazeološki
		["Pasti kao ___",          ["kruška", "bomba", "grom", "snop"]],
		["Jak kao ___",            ["vol", "hrast", "stijena", "bik"]],
		# Tip 5 — lažni prijatelji: izgledaju kao boje, ali su hrvatska mjesta
		["Hrvatska mjesta",        ["Zelina", "Zlatar", "Modra", "Crna Mlaka"]],
		# Tip 6 — isti slogovi: počinju s 'nad-'
		["Počinju s 'nad-'",       ["nadimak", "nadzor", "nadnica", "nadmudriti"]],
		# Tip 1 — skrivena veza
		["Može se 'slomiti'",      ["val", "rekord", "tišina", "srce"]],
		["Sve se može 'izgubiti'", ["strpljenje", "put", "smisao", "trag"]],
		["Europske prijestolnice bez slova 'a'", ["Beč", "Rim", "Bern", "Berlin"]],
		# Tip 3
		["Slobodni/a ___",         ["pad", "udar", "stih", "tržište"]],
		# Tip 4
		["Lagan kao ___",          ["pero", "oblak", "pahulja", "zrak"]],
		["Tvrd kao ___",           ["granit", "dijamant", "čelik", "orah"]],
		["Ide uz 'mrtvi/a/o'",     ["kut", "hodnik", "priroda", "trka"]],
		# kompas = kom-PAS, klavir = k-LAV-ir, praksa = p-RAK-sa, evolucija = e-VOL-ucija
		["Skrivena životinja",     ["kompas", "klavir", "praksa", "evolucija"]],
	]

static func _purple_pool() -> Array:
	return [
		["Latinske izreke",        ["carpe diem", "veni vidi vici", "cogito ergo sum", "memento mori"]],
		["Retoričke figure",       ["metafora", "metonimija", "sinegdoha", "oksimoron"]],
		["Metrika u poeziji",      ["jamb", "trohej", "daktil", "amfibrah"]],
		["Filozofski pravci",      ["empirizam", "racionalizam", "nihilizam", "egzistencijalizam"]],
		["Zvukovne figure",        ["aliteracija", "asonanca", "onomatopeja", "paronomazija"]],
		["Kvantna fizika",         ["kvark", "gluon", "bozon", "fermion"]],
		["Ekonomski paradoksi",    ["Giffenov", "Veblenov", "Simpsonov", "Condorcetov"]],
		["Pravni pojmovi",         ["kazuistika", "precedent", "interpretacija", "supsidijarnost"]],
		["Tipovi silogizma",       ["Barbara", "Celarent", "Darii", "Ferio"]],
		["Teorije pravde",         ["utilitarizam", "deontologija", "vrlinska etika", "kontraktualizam"]],
		["Neurološki pojmovi",     ["sinapsa", "akson", "dendrit", "mijelinska ovojnica"]],
		["Evolucijski mehanizmi",  ["selekcija", "mutacija", "pomak", "migracija"]],
		["Glazbene ljestvice",     ["dorska", "frigijska", "lidijska", "miksolidijska"]],
		["Stilske figure",         ["hiperbola", "litota", "eufonija", "anadiploza"]],
		["Teorije kaosa",          ["atraktor", "bifurkacija", "fraktal", "Lyapunov eksponent"]],
		["Lingvistički univerzali",["arbitrarnost", "produktivnost", "pomak", "dvostruka artikulacija"]],
		["Matematičke teoreme",    ["Pitagorin", "Fermatov", "Bayesov", "Fourierov"]],
		["Kognitivne pristranosti",["potvrđivanje", "sidrenje", "retrospekcija", "dostupnost"]],
		["Poetski žanrovi",        ["elegija", "oda", "sonet", "epigram"]],
		["Semiotički pojmovi",     ["znak", "označitelj", "označeno", "referent"]],
		["Vrste argumentacije",    ["dedukcija", "indukcija", "abdukcija", "analogija"]],
		["Fenomenološki pojmovi",  ["intencionalnost", "epoché", "intersubjektivnost", "horizont"]],
		["Vrste pamćenja",         ["epizodično", "semantičko", "proceduralno", "radno"]],
		["Teorije uma",            ["funkcionalizam", "dualizam", "fizikalizam", "eliminativizam"]],
		["Sociolingvistički pojmovi", ["diglosija", "pidžin", "kreolski", "kodna izmjena"]],
		["Vrste dokaza",           ["empirijski", "deduktivni", "induktivni", "abduktivni"]],
		["Tipovi naracije",        ["sveznajući", "prvoličan", "drugoličan", "nepouzdan"]],
		["Hermeneutički pojmovi",  ["hermeneutički krug", "predrazumijevanje", "interpretacija", "tekst"]],
		["Teorije istine",         ["korespondencija", "koherencija", "pragmatička", "deflacijska"]],
		["Vrste modaliteta",       ["nužnost", "mogućnost", "kontingentnost", "nemogućnost"]],
		# Tip 1 — skrivena veza: ista forma, dva značenja (imenica+imenica ili imenica+glagolski oblik)
		["Dvije različite stvari", ["bit", "kosa", "mast", "vez"]],
		# Tip 2 — homonimi: otok i grad istog naziva
		["Otok = grad",            ["Hvar", "Krk", "Rab", "Vis"]],
		# Tip 3 — ___ + ista riječ
		["___ kamen",              ["bubrežni", "žučni", "temeljni", "dragi"]],
		["Vruća ___",              ["tema", "linija", "čokolada", "točka"]],
		# Tip 4 — frazeološki
		["Crven kao ___",          ["rak", "rajčica", "paprika", "krv"]],
		["Spavati kao ___",        ["klada", "beba", "top", "anđeo"]],
		# Tip 5 — lažni prijatelji: izgledaju kao jedno, a hrvatska su prezimena zanatlija
		["Zanati kao prezimena",   ["Kovač", "Kolar", "Tesar", "Lončar"]],
		# Tip 6 — skriveni broj u složenici
		["Krije se broj",          ["jednorog", "dvoboj", "trokut", "četverokut"]],
		# Tip 6 — skrivena nota u riječi (do/re/mi/fa)
		["Krije se nota",          ["dobar", "rekord", "misija", "fakultet"]],
		# Tip 1 — skrivena veza
		["Zlatna ___",             ["groznica", "sredina", "ribica", "vrata"]],
		["Dobivaju suprotno s 'ne-'", ["sreća", "pravda", "znanje", "moć"]],
		# Tip 2 — homonimi
		["Ženska imena i pojmovi", ["Vjera", "Sloboda", "Slava", "Zora"]],
		# Tip 3
		["Crna ___",               ["burza", "magija", "kronika", "lista"]],
		["Bez + ___",              ["bol", "obzir", "um", "nada"]],
		# Tip 4
		["Težak kao ___",          ["olovo", "grijeh", "planina", "sudbina"]],
		["Oštar kao ___",          ["britva", "igla", "mač", "jezik"]],
		# Tip 5 — lažni prijatelji
		["Boje u politici",        ["zeleni", "crveni", "crni", "plavi"]],
	]

static func get_puzzles() -> Array:
	var adv: Dictionary = _advanced_names()
	var raw_pools: Array = [_yellow_pool(), _green_pool(), _blue_pool(), _purple_pool()]
	var diffs: Array = [Difficulty.YELLOW, Difficulty.GREEN, Difficulty.BLUE, Difficulty.PURPLE]
	var extras: Dictionary = _category_extras()

	# Split each pool: standard entries first, advanced last — both groups shuffled internally.
	var sorted_pools: Array = []
	for pool in raw_pools:
		var std: Array = []
		var advanced: Array = []
		for entry in pool:
			if entry[0] in adv:
				advanced.append(entry)
			else:
				std.append(entry)
		std.shuffle()
		advanced.shuffle()
		sorted_pools.append(std + advanced)

	var puzzles: Array = []
	for i in PUZZLE_COUNT:
		var cats: Array = []
		for p in 4:
			var entry: Array = sorted_pools[p][i]
			var cat: Category = Category.new(entry[0], _to_typed(entry[1]), diffs[p])
			cat.extra = extras.get(entry[0], "")
			cats.append(cat)
		puzzles.append(Puzzle.new("Slagalica #%d" % (i + 1), cats))

	if OS.is_debug_build():
		_assert_no_word_overlap(puzzles)

	return puzzles

static func _assert_no_word_overlap(puzzles: Array) -> void:
	for puzzle in puzzles:
		var seen: Dictionary = {}
		for cat in puzzle.categories:
			for word in cat.words:
				assert(not seen.has(word),
					"Duplicate word '%s' in puzzle '%s' (categories: '%s' and '%s')" \
					% [word, puzzle.title, seen.get(word, "?"), cat.name])
				seen[word] = cat.name

# Names of categories that use lateral-thinking / wordplay — kept at end of shuffled pool
# so earlier puzzles stay approachable.
static func _advanced_names() -> Dictionary:
	var names: Array[String] = [
		"Mora nazvana po boji", "Ime i biljka", "Crni/a ___", "Bijeli/a ___",
		"Brz kao ___", "Tiho kao ___", "Hrvatska prezimena", "Mali ___", "Stari ___",
		"Divlji ___", "Hladan kao ___", "Star kao ___", "Završavaju na '-ač'",
		"Može biti 'hladan/a'", "Ide uz 'zlatni/a/o'", "Dvije različite stvari",
		"Krvni/a ___", "___ polje", "Pasti kao ___", "Jak kao ___", "Hrvatska mjesta",
		"Počinju s 'nad-'", "Može se 'slomiti'", "Sve se može 'izgubiti'",
		"Europske prijestolnice bez slova 'a'", "Slobodni/a ___", "Lagan kao ___",
		"Tvrd kao ___", "Ide uz 'mrtvi/a/o'", "Skrivena životinja",
		"Krije se broj", "Krije se nota", "Otok = grad", "___ kamen", "Vruća ___",
		"Crven kao ___", "Spavati kao ___", "Zanati kao prezimena",
		"Zlatna ___", "Dobivaju suprotno s 'ne-'", "Ženska imena i pojmovi",
		"Crna ___", "Bez + ___", "Težak kao ___", "Oštar kao ___", "Boje u politici",
	]
	var d: Dictionary = {}
	for n in names:
		d[n] = true
	return d

# Short explanatory lines shown in the solved-category row for tricky categories.
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
		"Krije se broj":                     "jedno-ROG, dvo-BOJ, tro-KUT, četvero-KUT",
		"Krije se nota":                     "DO-bar, RE-kord, MI-sija, FA-kultet",
		"Otok = grad":                       "Hvar, Krk, Rab, Vis — i otok i grad",
		"___ kamen":                         "Bubrežni, žučni, temeljni, dragi kamen",
		"Vruća ___":                         "Vruća tema, linija, čokolada, točka",
		"Crven kao ___":                     "Frazeološke usporedbe crvenila",
		"Spavati kao ___":                   "Frazeološke usporedbe dubokog sna",
		"Zanati kao prezimena":              "Kovač, Kolar, Tesar, Lončar",
		"Zlatna ___":                        "Zlatna groznica, sredina, ribica, vrata",
		"Dobivaju suprotno s 'ne-'":         "Nesreća, nepravda, neznanje, nemoć",
		"Ženska imena i pojmovi":            "Vjera, Sloboda, Slava, Zora",
		"Crna ___":                          "Crna burza, magija, kronika, lista",
		"Bez + ___":                         "Bezbol, bezobzir, bezum, beznada",
		"Težak kao ___":                     "Frazeološke usporedbe težine",
		"Oštar kao ___":                     "Frazeološke usporedbe oštrine",
		"Boje u politici":                   "Zeleni, crveni, crni, plavi — stranke",
	}

static func _to_typed(arr: Array) -> Array[String]:
	var result: Array[String] = []
	result.assign(arr)
	return result
