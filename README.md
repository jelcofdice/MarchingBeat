# Introduction
MarchingBeat is an experimental rythm-action Strategy game.
It's meant to be a hectic/chaotic competetive RTS, but where sense of rythm and planning
is more important than APM.
It's designed to be playable entirely with a dance mat, because more such games should exist.

# Game design overview
There are 2 rulesets Simple and Complete, where the Simple will be imGplemented first.
Feedback from the simple rules will influence design of the complete rules

## Simple rules
* There are "cities" on the game board which can be neutral or captured by a player,
* Players get points each turns based on how many cities they have captured.
* Each player controls 4 units.
* A player can issue a command to a unit to move in a direction by hitting 2 direction keys on subsequent beats:
    1. The direction corresponding to that unit
    2. The direction the unit should move it
    - This means it takes at least 2 beats to make a unit change direction, so planning your moves is key

The unit will then start moving in that direction one step per beat and will continue until it reaches a city (which it'll capture and then stop by) or collides with another unit.

Units cannot damage each other or be destroyed, at most you can block an opponent with your units.
