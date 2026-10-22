class_name MatchResult
extends RefCounted

enum Orientation {
	HORIZONTAL,
	VERTICAL
}

var gems: Array
var color_id: int
var length: int
var orientation: MatchResult.Orientation

func _init(
	match_gems: Array,
	match_color_id: int,
	match_orientation: MatchResult.Orientation
) -> void:
	gems = match_gems.duplicate()
	color_id = match_color_id
	length = gems.size()
	orientation = match_orientation
