class_name GameState
extends RefCounted

signal selection_changed(selected: Array[String])
signal guess_correct(category: PuzzleData.Category)
signal guess_wrong(words: Array[String], one_away: bool)
signal hint_peek(category_name: String, hints_left: int)
signal hint_word(category_name: String, word: String, hints_left: int)
signal hint_solve(category: PuzzleData.Category, hints_left: int)
signal score_changed(total: int, gained: int)
signal game_won()
signal game_lost()

const MAX_MISTAKES: int = 4
const MAX_SELECTION: int = 4
const MAX_HINTS: int = 3

const BASE_POINTS: Dictionary = {
	PuzzleData.Difficulty.YELLOW:  100,
	PuzzleData.Difficulty.GREEN:   200,
	PuzzleData.Difficulty.BLUE:    300,
	PuzzleData.Difficulty.PURPLE:  400,
}
const MISTAKE_MULTIPLIERS: Array = [1.0, 0.75, 0.50, 0.25, 0.0]
const HINT_MULTIPLIERS: Array  = [1.0, 0.75, 0.50, 0.25]

var puzzle: PuzzleData.Puzzle
var selected_words: Array[String] = []
var solved_categories: Array = []
var mistakes_remaining: int = MAX_MISTAKES
var hints_remaining: int = MAX_HINTS
var hints_used: int = 0
var hint_multiplier: float = 1.0
var score: int = 0
var category_scores: Dictionary = {}
var _peeked_category: PuzzleData.Category = null
var guess_history: Array = []
var puzzle_time_sec: float = 0.0

func _init(p_puzzle: PuzzleData.Puzzle) -> void:
	puzzle = p_puzzle

func toggle_word(word: String) -> void:
	if word in selected_words:
		selected_words.erase(word)
	elif selected_words.size() < MAX_SELECTION:
		selected_words.append(word)
	selection_changed.emit(selected_words.duplicate())

func deselect_all() -> void:
	selected_words.clear()
	var empty: Array[String] = []
	selection_changed.emit(empty)

func can_submit() -> bool:
	return selected_words.size() == MAX_SELECTION

func submit_guess() -> void:
	if not can_submit():
		return

	var guess: Array[String] = selected_words.duplicate()
	guess_history.append(guess.duplicate())

	for cat in puzzle.categories:
		if cat in solved_categories:
			continue
		if _matches_category(guess, cat):
			solved_categories.append(cat)
			selected_words.clear()
			var empty: Array[String] = []
			selection_changed.emit(empty)
			var mistakes_used: int = MAX_MISTAKES - mistakes_remaining
			var multiplier: float = MISTAKE_MULTIPLIERS[mistakes_used] * hint_multiplier
			var gained: int = int(BASE_POINTS[cat.difficulty] * multiplier)
			score += gained
			category_scores[cat.name] = gained
			score_changed.emit(score, gained)
			guess_correct.emit(cat)
			if solved_categories.size() == puzzle.categories.size():
				game_won.emit()
			return

	mistakes_remaining -= 1
	var one_away: bool = _is_one_away(guess)
	guess_wrong.emit(guess, one_away)
	if mistakes_remaining <= 0:
		game_lost.emit()

func is_word_solved(word: String) -> bool:
	for cat in solved_categories:
		if word in cat.words:
			return true
	return false

func get_unsolved_words() -> Array[String]:
	var result: Array[String] = []
	for word in puzzle.all_words():
		if not is_word_solved(word):
			result.append(word)
	return result

func find_category_for_word(word: String) -> PuzzleData.Category:
	for cat in puzzle.categories:
		if word in cat.words:
			return cat
	return null

func get_one_away_outlier(guess: Array[String]) -> String:
	for cat in puzzle.categories:
		if cat in solved_categories:
			continue
		var non_matching: Array[String] = []
		var match_count: int = 0
		for word in guess:
			if word in cat.words:
				match_count += 1
			else:
				non_matching.append(word)
		if match_count == MAX_SELECTION - 1 and non_matching.size() == 1:
			return non_matching[0]
	return ""

func _matches_category(guess: Array[String], cat: PuzzleData.Category) -> bool:
	if guess.size() != cat.words.size():
		return false
	for word in guess:
		if word not in cat.words:
			return false
	return true

func can_use_hint() -> bool:
	return hints_remaining > 0 and solved_categories.size() < puzzle.categories.size()

func use_hint() -> void:
	if not can_use_hint():
		return
	hints_remaining -= 1
	hints_used += 1
	hint_multiplier = HINT_MULTIPLIERS[hints_used]
	selected_words.clear()
	var empty: Array[String] = []
	selection_changed.emit(empty)

	if hints_used == 1:
		# Hint 1: reveal category name
		_peeked_category = _hardest_unsolved()
		hint_peek.emit(_peeked_category.name, hints_remaining)
	elif hints_used == 2:
		# Hint 2: reveal one word from peeked category (or new one if already solved)
		var target: PuzzleData.Category
		if _peeked_category != null and _peeked_category not in solved_categories:
			target = _peeked_category
		else:
			target = _hardest_unsolved()
			_peeked_category = target
		var unsolved_words: Array[String] = []
		for w in target.words:
			if not is_word_solved(w):
				unsolved_words.append(w)
		var revealed: String = unsolved_words[randi() % unsolved_words.size()]
		hint_word.emit(target.name, revealed, hints_remaining)
	else:
		# Hint 3: auto-solve hardest unsolved
		var target: PuzzleData.Category
		if _peeked_category != null and _peeked_category not in solved_categories:
			target = _peeked_category
		else:
			target = _hardest_unsolved()
		_peeked_category = null
		solved_categories.append(target)
		category_scores[target.name] = 0
		score_changed.emit(score, 0)
		hint_solve.emit(target, hints_remaining)
		if solved_categories.size() == puzzle.categories.size():
			game_won.emit()

func _hardest_unsolved() -> PuzzleData.Category:
	var best: PuzzleData.Category = null
	for cat in puzzle.categories:
		if cat in solved_categories:
			continue
		if best == null or cat.difficulty > best.difficulty:
			best = cat
	return best

func get_puzzle_summary() -> Dictionary:
	return {
		"score":            score,
		"solved_count":     solved_categories.size(),
		"total_count":      puzzle.categories.size(),
		"mistakes_used":    MAX_MISTAKES - mistakes_remaining,
		"hints_used":       hints_used,
		"solved_categories": solved_categories.duplicate(),
		"category_scores":  category_scores.duplicate(),
	}

func _is_one_away(guess: Array[String]) -> bool:
	for cat in puzzle.categories:
		if cat in solved_categories:
			continue
		var matches: int = 0
		for word in guess:
			if word in cat.words:
				matches += 1
		if matches == MAX_SELECTION - 1:
			return true
	return false
