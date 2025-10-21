extends Label

var wave : int = 1
var max_waves : int = 50  # adjust to how many waves you expect

func update_wave(wave_num: int):
	wave = wave_num
	
	# Normalize progress: 0.0 = start (white), 1.0 = end (black)
	var t = float(wave) / max_waves
	
	var color : Color
	
	if t <= 0.5:
		# First half: White (1,1,1) → Red (1,0,0)
		var p = t / 0.5
		color = Color(1, 1.0 - p, 1.0 - p) 
	else:
		# Second half: Red (1,0,0) → Black (0,0,0)
		var p = (t - 0.5) / 0.5
		color = Color(1.0 - p, 0, 0)
	
	self.add_theme_color_override("font_color", color)
	self.text = "Wave %d" % wave
