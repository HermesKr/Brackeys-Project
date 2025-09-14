extends Node

@onready var score_counter = %ScoreCounter

var score = 0

func add_point():
	score += 1
	score_counter.text = str(score)
