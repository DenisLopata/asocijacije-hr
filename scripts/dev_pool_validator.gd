## scripts/dev_pool_validator.gd
##
## Offline static validator for the full category pool.
## Run headless: godot --headless --script scripts/dev_pool_validator.gd
##
## Detects:
##  1. Globally duplicated words across categories (would cause runtime conflict)
##  2. Internal category issues (word count != 4, duplicate within category, invalid rank)
##  3. Frazem subtype distribution (counts per tier/rank bucket)
##  4. Rank bucket sizes (warns if critically small)
##  5. Naming convention violations

@tool
extends SceneTree

func _init() -> void:
	DevPoolValidator.run_all_checks(PuzzleData)
	quit(0 if DevPoolValidator.last_error_count == 0 else 1)


class DevPoolValidator:
	static var last_error_count: int = 0

	static func run_all_checks(puzzle_data) -> Dictionary:
		var results := {"errors": [], "warnings": [], "info": {}}
		var pools := {
			"YELLOW": puzzle_data._yellow_pool(),
			"GREEN":  puzzle_data._green_pool(),
			"BLUE":   puzzle_data._blue_pool(),
			"PURPLE": puzzle_data._purple_pool(),
		}

		_check_word_uniqueness(pools, results)
		_check_category_structure(pools, results)
		_check_frazem_distribution(pools, results)
		_check_bucket_sizes(pools, results)
		_check_naming_conventions(pools, results)
		_print_results(results)

		last_error_count = results.errors.size()
		return results

	static func _check_word_uniqueness(pools: Dictionary, results: Dictionary) -> void:
		var word_locations := {}
		for tier in pools:
			for entry in pools[tier]:
				var cat_name: String = entry[0]
				var words: Array  = entry[1]
				var rank: int     = entry[2]
				for w in words:
					var wl := w.to_lower()
					if not word_locations.has(wl):
						word_locations[wl] = []
					word_locations[wl].append({"tier": tier, "rank": rank, "category": cat_name})

		var dup_count := 0
		for word in word_locations:
			var locs: Array = word_locations[word]
			if locs.size() > 1:
				dup_count += 1
				var details: Array[String] = []
				for loc in locs:
					details.append("%s r%d: %s" % [loc.tier, loc.rank, loc.category])
				results.errors.append("Word '%s' appears in: %s" % [word, ", ".join(details)])

		results.info["total_words"]      = word_locations.size()
		results.info["duplicate_words"]  = dup_count

	static func _check_category_structure(pools: Dictionary, results: Dictionary) -> void:
		var total := 0
		for tier in pools:
			for entry in pools[tier]:
				total += 1
				var cat_name: String = entry[0]
				var words: Array     = entry[1]
				var rank: int        = entry[2]

				if words.size() != 4:
					results.errors.append("'%s' (%s r%d) has %d words, expected 4" %
						[cat_name, tier, rank, words.size()])

				var seen := {}
				for w in words:
					var wl := w.to_lower()
					if seen.has(wl):
						results.errors.append("'%s' has duplicate word '%s'" % [cat_name, w])
					seen[wl] = true

				if rank < 1 or rank > 3:
					results.errors.append("'%s' has invalid rank %d" % [cat_name, rank])

		results.info["total_categories"] = total

	static func _check_frazem_distribution(pools: Dictionary, results: Dictionary) -> void:
		var subtypes := {}
		for tier in pools:
			for entry in pools[tier]:
				var cat_name: String = entry[0]
				var rank: int        = entry[2]
				var subtype = _get_frazem_subtype(cat_name)
				if subtype == null:
					continue
				var key := "%s r%d" % [tier, rank]
				if not subtypes.has(key):
					subtypes[key] = {}
				if not subtypes[key].has(subtype):
					subtypes[key][subtype] = []
				subtypes[key][subtype].append(cat_name)
		results.info["frazem_subtypes"] = subtypes

	static func _get_frazem_subtype(name: String):
		if "___" not in name:
			return null
		if " kao ___" in name:
			return "simile"
		if "Mogu prethoditi:" in name or "Mogu slijediti:" in name:
			return "hidden_connector"
		if " + ___" in name or name.begins_with("Bez +"):
			return "prepositional"
		if name.ends_with(" ___"):
			return "prefix_adj"
		if name.begins_with("___ "):
			return "suffix_noun"
		return "other_frazem"

	static func _check_bucket_sizes(pools: Dictionary, results: Dictionary) -> void:
		var sizes := {}
		for tier in pools:
			sizes[tier] = {1: 0, 2: 0, 3: 0}
			for entry in pools[tier]:
				sizes[tier][entry[2]] += 1

		for tier in sizes:
			for rank in [1, 2, 3]:
				var n: int = sizes[tier][rank]
				if n < 5:
					results.errors.append("BUCKET %s r%d has %d categories — critically small" % [tier, rank, n])
				elif n < 10:
					results.warnings.append("BUCKET %s r%d has %d categories — high repetition risk" % [tier, rank, n])
		results.info["bucket_sizes"] = sizes

	static func _check_naming_conventions(pools: Dictionary, results: Dictionary) -> void:
		for tier in pools:
			for entry in pools[tier]:
				var cat_name: String = entry[0]
				if cat_name.begins_with("Ide uz"):
					results.warnings.append("Naming: '%s' should be 'X ___'" % cat_name)
				if cat_name.begins_with("Sve ima"):
					results.warnings.append("Naming: '%s' should be 'Imaju X'" % cat_name)

	static func _print_results(results: Dictionary) -> void:
		print("=".repeat(70))
		print("POOL VALIDATOR — Asocijacije")
		print("=".repeat(70))
		print("\nSTATISTIKE:")
		print("  Total categories : ", results.info.get("total_categories", "?"))
		print("  Total unique words: ", results.info.get("total_words", "?"))
		print("  Duplicate words  : ", results.info.get("duplicate_words", 0))

		if results.info.has("bucket_sizes"):
			print("\nBUCKET SIZES:")
			for tier in ["YELLOW", "GREEN", "BLUE", "PURPLE"]:
				var s: Dictionary = results.info.bucket_sizes[tier]
				print("  %s: r1=%d  r2=%d  r3=%d  total=%d" %
					[tier, s[1], s[2], s[3], s[1] + s[2] + s[3]])

		if results.info.has("frazem_subtypes"):
			print("\nFRAZEM SUBTYPES (per bucket):")
			for key in results.info.frazem_subtypes:
				print("  %s:" % key)
				for subtype in results.info.frazem_subtypes[key]:
					var cats: Array = results.info.frazem_subtypes[key][subtype]
					print("    %s: %d" % [subtype, cats.size()])

		if results.errors.size() > 0:
			print("\nERRORS (%d):" % results.errors.size())
			for err in results.errors:
				print("  ERROR: ", err)

		if results.warnings.size() > 0:
			print("\nWARNINGS (%d):" % results.warnings.size())
			for w in results.warnings:
				print("  WARN : ", w)

		if results.errors.size() == 0 and results.warnings.size() == 0:
			print("\nAll checks passed.")
		print("=".repeat(70))
