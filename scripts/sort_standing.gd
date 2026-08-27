class_name SortStanding

static func sort_standing(main: Node, standing : Node, standings_extra : VBoxContainer, main_standings_result : VBoxContainer):
	var standing_last_size: int = 3
	if UniversalDict.armory_data.size() <= 13:
		UniversalDict.standing_size = UniversalDict.armory_data.size()
		add_standing(standing_last_size,UniversalDict.standing_size, standing, main_standings_result)
	else:
		UniversalDict.standing_size = 13
		add_standing(standing_last_size, UniversalDict.standing_size, standing, main_standings_result)
		while UniversalDict.standing_size <= UniversalDict.armory_data.size() :
			standing_last_size = UniversalDict.standing_size
			if UniversalDict.armory_data.size() > (UniversalDict.standing_size + 19):
				UniversalDict.standing_size += 19 
			else:
				UniversalDict.standing_size = UniversalDict.armory_data.size()
			
			var standings_extra_temp: Node = standings_extra.duplicate()
			main.add_child(standings_extra_temp)
			add_standing(standing_last_size,UniversalDict.standing_size, standing, standings_extra_temp)
			#Por algum motivo só saí do loop se eu fizer isso senão ele vai criar standings vazios até o fim dos tempos.
			if UniversalDict.standing_size >= UniversalDict.armory_data.size():
				break
	

static func add_standing(standing_last_size_temp, standings_result_size, standing_temp, main_standings_result_temp):
	for i in range(standing_last_size_temp, standings_result_size):
		var temp_standing_less: Node = standing_temp.duplicate()
		main_standings_result_temp.add_child(temp_standing_less)
		if HeroesDb.young_heroes[UniversalDict.armory_data.values()[i]["Hero"]]["standing"] == "":
			temp_standing_less.get_child(1).get_child(1).get_child(1).texture = HeroesDb.hero_textures["unknown"]["standing"]
			pass
		else:
			temp_standing_less.get_child(1).get_child(1).get_child(1).texture =HeroesDb.hero_textures[UniversalDict.armory_data.values()[i]["Hero"]]["standing"]
			pass
		if UniversalDict.armory_data.values()[i]["Rank"] == "Dropped":
			temp_standing_less.get_child(2).show()
			var shader_main_mat = temp_standing_less.get_child(1).get_child(1).get_child(1).material as ShaderMaterial
			var shader_mat = shader_main_mat.duplicate()
			temp_standing_less.get_child(1).get_child(1).get_child(1).material = shader_mat
			shader_mat.set_shader_parameter("percentage", 0)
			
		temp_standing_less.get_child(1).get_child(0).get_child(0).texture = load("res://assets/textures/grunge_"+str(randi_range(1,6))+".png")
		temp_standing_less.get_child(1).get_child(1).get_child(0).texture = load("res://assets/textures/grunge_"+str(randi_range(1,6))+".png")
		temp_standing_less.get_child(1).get_child(0).get_child(1).text = str(i + 1)
		temp_standing_less.get_child(1).get_child(1).get_child(2).text = UniversalDict.armory_data.values()[i]["Name"].to_upper()
		temp_standing_less.get_child(1).get_child(1).get_child(3).get_child(0).text = UniversalDict.armory_data.values()[i]["Wins"].to_upper()
		temp_standing_less.get_child(1).get_child(0).self_modulate = Color.from_string(HeroesDb.young_heroes[UniversalDict.armory_data.values()[i]["Hero"]]["color"], Color.MIDNIGHT_BLUE)
		temp_standing_less.get_child(1).get_child(1).self_modulate = Color.from_string(HeroesDb.young_heroes[UniversalDict.armory_data.values()[i]["Hero"]]["color"], Color.MIDNIGHT_BLUE)
		temp_standing_less.visible = true
		temp_standing_less.show()
