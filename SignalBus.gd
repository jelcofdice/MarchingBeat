extends Node

# Global timings
signal beat
signal half_beat

# Reference maintenance
signal unit_created # (unit: Unit)
signal unit_deleted # (unit: Unit)

# Map movements
signal new_contest # (pos: Vector2i)
signal city_captured # (city: City)
signal unit_moved # (unit: Unit)

# Input signals
signal word_sent # (team: int, unit.number: int, direction: Vector2i)