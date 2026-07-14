class_name CSVStanding

static func load_csv_to_dict(file_path: String) -> Dictionary:
	var output_dict: Dictionary = {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("Failed to open file: " + file_path)
		return output_dict

	# 1. Parse the header row to find the "Player ID" index
	var headers: PackedStringArray = file.get_csv_line()
	var key_index: int = headers.find("Player ID")
	
	if key_index == -1:
		push_error("Error: 'Player ID' column not found in CSV headers.")
		file.close()
		return output_dict

	# 2. Parse the remaining rows
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		
		# Skip empty rows or trailing newlines
		if row.size() <= 1 and (row.size() == 0 or row[0] == ""):
			continue
			
		# Extract the unique key using the pre-located index
		var player_id: String = row[key_index]
		var row_data: Dictionary = {}
		
		# Map headers to values, skipping the "Player ID" column itself
		for i in range(headers.size()):
			if i == key_index:
				continue # Do not repeat the key inside the inner dictionary
				
			if i < row.size():
				row_data[headers[i]] = row[i]
			else:
				row_data[headers[i]] = "" # Default value for missing data
				
		output_dict[player_id] = row_data
		
	file.close()
	return output_dict
	
static func merge_dicts_keep_first_order(first_dict: Dictionary, second_dict: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	
	# Itera na ordem exata das chaves do primeiro dicionário
	for player_id in first_dict:
		# Copia os dados do primeiro dicionário
		var merged_data: Dictionary = first_dict[player_id].duplicate(true)
		
		# Se o jogador existir no segundo dicionário, mescla os dados adicionais
		if second_dict.has(player_id):
			for key in second_dict[player_id]:
				merged_data[key] = second_dict[player_id][key]
				
		# Insere no resultado (mantendo a sequência de inserção do primeiro)
		result[player_id] = merged_data
		
	return result
