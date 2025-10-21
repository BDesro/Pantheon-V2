extends Label

var num_enemies = 0

func update_num_enemies(new_amount: int):
	num_enemies = new_amount
	
	self.text = "Enemies Remaining: %d" % num_enemies
