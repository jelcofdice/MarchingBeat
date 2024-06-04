class_name City extends GridSprite

# Called when the node enters the scene tree for the first time.

@export var team: int:
	set(value):
		var old := team
		team = value
		if old != team:
			redraw_decal()
			SignalBus.city_captured.emit(self, old)

func _ready():
	team = -1
	SignalBus.unit_moved.connect(_on_unit_moved)

func redraw_decal():
	$Decal.self_modulate = Constants.team_colors[team]

func _on_unit_moved(unit: Unit):
	if unit.pos == pos:
		team = unit.team
		unit.bearing = Vector2i.ZERO
