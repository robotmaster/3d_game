extends Control

var scare_started = false
var grow_amount = 3000000000
var on_screen_time = 1
var timer = 0

var flash_timer := 0.0
var FLASH_MAX := 0.04

var flash_total_time = 0.5

func _process(delta: float) -> void:
	if scare_started:
		visible = true
		if timer < flash_total_time:
			flash_timer -= delta
			if flash_timer < 0:
				flash_timer += FLASH_MAX
				$Background.visible = !$Background.visible
		else:
			$Background.visible = true
		if $Face.scale.x < 100:
			$Face.scale *= pow(grow_amount, delta)
		timer += delta
		if timer > on_screen_time:
			queue_free()
	else:
		visible = false
