class_name MatchDetector
extends RefCounted


enum MatchShape {
	NONE,
	L,
	T,
	CROSS
}

#DETECTOR GLOBAL

func _get_horizontal_match_results(board: Array) -> Array[MatchResult]:
	var results: Array[MatchResult] = []

	var row_count: int = board.size()
	var column_count: int = board[0].size()

	for row in range(row_count):
		var current_sequence: Array = []

		for column in range(column_count):
			var gem = board[row][column]

			if current_sequence.is_empty():
				current_sequence.append(gem)
			elif gem.color_id == current_sequence[0].color_id:
				current_sequence.append(gem)
			else:
				if current_sequence.size() >= 3:
					results.append(
						MatchResult.new(
							current_sequence,
							current_sequence[0].color_id,
							MatchResult.Orientation.HORIZONTAL
						)
					)
				current_sequence = [gem]

		if current_sequence.size() >= 3:
			results.append(
				MatchResult.new(
					current_sequence,
					current_sequence[0].color_id,
					MatchResult.Orientation.HORIZONTAL
				)
			)

	return results
	
func _get_vertical_match_results(board: Array) -> Array[MatchResult]:
	var results: Array[MatchResult] = []

	var row_count: int = board.size()
	var column_count: int = board[0].size()

	for column in range(column_count):
		var current_sequence: Array = []

		for row in range(row_count):
			var gem = board[row][column]

			if current_sequence.is_empty():
				current_sequence.append(gem)
			elif gem.color_id == current_sequence[0].color_id:
				current_sequence.append(gem)
			else:
				if current_sequence.size() >= 3:
					results.append(
						MatchResult.new(
							current_sequence,
							current_sequence[0].color_id,
							MatchResult.Orientation.VERTICAL
						)
					)
				current_sequence = [gem]

		if current_sequence.size() >= 3:
			results.append(
				MatchResult.new(
					current_sequence,
					current_sequence[0].color_id,
					MatchResult.Orientation.VERTICAL
				)
			)

	return results

func get_match_results(board: Array) -> Array[MatchResult]:
	var match_results: Array[MatchResult] = []
	
	match_results.append_array(_get_horizontal_match_results(board))
	match_results.append_array(_get_vertical_match_results(board))
	
	return match_results
	
func get_unique_gems(match_results: Array[MatchResult]) -> Array:
	var unique_gems: Array = []

	for result in match_results:
		_append_unique_gems(unique_gems, result.gems)

	return unique_gems

#DETECTOR LOCAL

func get_matches_for_swap(board: Array, gem_a, gem_b) -> Array:
	var all_matched_gems = []

	_append_unique_gems(all_matched_gems, _get_matches_for_gem(board, gem_a))
	_append_unique_gems(all_matched_gems, _get_matches_for_gem(board, gem_b))

	return all_matched_gems

func _get_horizontal_match(board: Array, gem) -> Array:
	var matched_gems = [gem]
	var column = gem.column -1
	var column_count: int = board[gem.row].size()
	
	while column >= 0 and board[gem.row][column] != null and board[gem.row][column].color_id == gem.color_id:
		matched_gems.append(board[gem.row][column])
		column -= 1
	
	column = gem.column +1
	
	while column < column_count and board[gem.row][column] != null and board[gem.row][column].color_id == gem.color_id:
		matched_gems.append(board[gem.row][column])
		column += 1
	return matched_gems
	
func _get_vertical_match(board: Array, gem) -> Array:
	var matched_gems = [gem]
	var row = gem.row -1
	var row_count: int = board.size()
	
	while row >= 0 and board[row][gem.column] != null and board[row][gem.column].color_id == gem.color_id:
		matched_gems.append(board[row][gem.column])
		row -= 1
	
	row = gem.row +1
	
	while row < row_count and board[row][gem.column] != null and board[row][gem.column].color_id == gem.color_id:
		matched_gems.append(board[row][gem.column])
		row += 1
	return matched_gems
	
func _get_matches_for_gem(board: Array, gem) -> Array:
	var matched_gems: Array = []

	var horizontal_match = _get_horizontal_match(board, gem)
	if horizontal_match.size() >= 3:
		_append_unique_gems(matched_gems, horizontal_match)

	var vertical_match = _get_vertical_match(board, gem)
	if vertical_match.size() >= 3:
		_append_unique_gems(matched_gems, vertical_match)

	return matched_gems
	
func _append_unique_gems(target: Array, gems_to_add: Array) -> void:
	for gem in gems_to_add:
		if not target.has(gem):
			target.append(gem)


func get_shape_between(first: MatchResult, second: MatchResult) -> MatchShape:
	if first.color_id != second.color_id:
		return MatchShape.NONE
	if first.orientation == second.orientation:
		return MatchShape.NONE
		
	for gem in first.gems:
		if second.gems.has(gem):
			var first_index: int = first.gems.find(gem)
			var second_index: int = second.gems.find(gem)
			var first_is_end: bool = (first_index == 0 or first_index == first.gems.size() -1)
			var second_is_end: bool = (second_index == 0 or second_index == second.gems.size() -1)
		
			if first_is_end and second_is_end:
				return MatchShape.L
				
			if first_is_end or second_is_end:
				return MatchShape.T
				
			return MatchShape.CROSS
	
	return MatchShape.NONE


func get_all_shapes(match_results: Array[MatchResult]) -> Array[Dictionary]:
	var shapes: Array[Dictionary] = []

	for first_index in range(match_results.size()):
		for second_index in range(first_index + 1, match_results.size()):
			var shape: MatchShape = get_shape_between(
				match_results[first_index],
				match_results[second_index]
			)

			if shape != MatchShape.NONE:
				var detected_shape: Dictionary = {
					"shape": shape,
					"first_match": match_results[first_index],
					"second_match": match_results[second_index]
				}
				shapes.append(detected_shape)

	return shapes


func get_unique_gems_for_shape(detected_shape: Dictionary) -> Array[Gem]:
	var unique_gems: Array[Gem] = []

	var first_match: MatchResult = detected_shape["first_match"]
	var second_match: MatchResult = detected_shape["second_match"]
	
	_append_unique_gems(unique_gems, first_match.gems)
	_append_unique_gems(unique_gems, second_match.gems)
	
	return unique_gems
