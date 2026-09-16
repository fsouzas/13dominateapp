class_name SortStanding

static func sort_standing(main: Node, standing : Node, standings_extra : VBoxContainer, main_standings_result : VBoxContainer):
	var standing_last_size: int = 3
	if UniversalDict.armory_data.size() <= 13:
		UniversalDict.standing_size = UniversalDict.armory_data.size()
		add_standing(standing_last_size,UniversalDict.standing_size, standing, main_standings_result)
	else:
		UniversalDict.standing_size = 13
		add_standing(standing_last_size, UniversalDict.standing_size, standing, main_standings_result)
		while UniversalDict.standing_size < UniversalDict.armory_data.size() :
			standing_last_size = UniversalDict.standing_size
			if UniversalDict.armory_data.size() > (UniversalDict.standing_size + 19):
				UniversalDict.standing_size += 19 
			else:
				UniversalDict.standing_size = UniversalDict.armory_data.size()
			
			var standings_extra_temp: Node = standings_extra.duplicate()
			main.add_child(standings_extra_temp)
			add_standing(standing_last_size,UniversalDict.standing_size, standing, standings_extra_temp)
	

static func add_standing(standing_last_size_temp, standings_result_size, standing_temp, main_standings_result_temp):
	for i in range(standing_last_size_temp, standings_result_size):
		var player_data: Dictionary = UniversalDict.armory_data.values()[i]
		var hero_name: String = player_data["Hero"]
		
		var temp_standing_less: Node = standing_temp.duplicate()
		main_standings_result_temp.add_child(temp_standing_less)

		var hero_texture: TextureRect = temp_standing_less.get_child(1).get_child(1).get_child(1)

		hero_texture.texture = HeroesDb.get_heroi_standing(hero_name)

		if player_data["Rank"] == "Dropped":
			temp_standing_less.get_child(2).show()
			var shader_main_mat = hero_texture.material as ShaderMaterial
			var shader_mat = shader_main_mat.duplicate()
			hero_texture.material = shader_mat
			shader_mat.set_shader_parameter("percentage", 0)
		
		var grunge_texture1 := temp_standing_less.get_child(1).get_child(0).get_child(0)
		var grunge_texture2 := temp_standing_less.get_child(1).get_child(1).get_child(0)

		var player_position := temp_standing_less.get_child(1).get_child(0).get_child(1)
		var player_name := temp_standing_less.get_child(1).get_child(1).get_child(2)
		var player_wins := temp_standing_less.get_child(1).get_child(1).get_child(3).get_child(0)
		var player_color1 := temp_standing_less.get_child(1).get_child(0)
		var player_color2 := temp_standing_less.get_child(1).get_child(1)


		grunge_texture1.texture = load("res://assets/textures/grunge_"+str(randi_range(1,6))+".png")
		grunge_texture2.texture = load("res://assets/textures/grunge_"+str(randi_range(1,6))+".png")

		player_position.text = str(i + 1)
		player_name.text = player_data["Name"].to_upper()
		player_wins.text = player_data["Wins"].to_upper()
		player_color1.self_modulate = HeroesDb.get_heroi_color(hero_name)
		player_color2.self_modulate = HeroesDb.get_heroi_color(hero_name)
		temp_standing_less.show()
