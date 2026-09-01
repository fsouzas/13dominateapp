class_name CSVStanding


static func load_csv_to_dict(file_path: String, type: String) -> Dictionary:
	var output_dict: Dictionary = {}

	var file = FileAccess.open(file_path, FileAccess.READ)

	if file == null:
		push_error("Failed to open file: " + file_path)
		return output_dict

	var headers: PackedStringArray = file.get_csv_line()

	var required: Array[String] = []

	if type == "standings":
		required = [
			"Rank",
			"Name",
			"Player ID",
			"Wins"
		]

	elif type == "heroes":
		required = [
			"Player Name",
			"Player ID",
			"Country/Region",
			"Hero"
		]

	else:
		push_error("Unknown CSV type: " + type)
		file.close()
		return output_dict


	var missing: Array[String] = []

	for element in required:
		if not headers.has(element):
			missing.append(element)


	if missing.size() > 0:

		if type == "standings":
			SignalBus.error_msg.emit(TranslationServer.translate("standings_csv_error_load"), "error")

		elif type == "heroes":
			SignalBus.error_msg.emit(TranslationServer.translate("heroes_csv_error_load"), "error")

		file.close()
		return output_dict


	SignalBus.error_msg.emit(TranslationServer.translate("csv_loaded_with_no_errors"), "correct")


	var key_index: int = headers.find("Player ID")

	if key_index == -1:
		push_error(
				"Error: 'Player ID' column not found in CSV headers."
		)

		file.close()
		return output_dict


	if type == "heroes":

		while not file.eof_reached():

			var row: PackedStringArray = file.get_csv_line()

			# Ignore empty lines
			if row.is_empty() or (
					row.size() == 1 and
					row[0].strip_edges() == ""
			):
				continue

			# Make sure Player ID exists
			if key_index >= row.size():
				continue

			var player_id: String = row[key_index].strip_edges()

			if player_id == "":
				continue

			var row_data: Dictionary = {}

			# Copy every column except Player ID
			for i in range(headers.size()):

				if i == key_index:
					continue

				if i < row.size():
					row_data[headers[i]] = row[i].strip_edges()
				else:
					row_data[headers[i]] = ""

			# Store using Player ID as key
			output_dict[player_id] = row_data


		file.close()
		return output_dict

	if type == "standings":

		var rank_index: int = headers.find("Rank")

		if rank_index == -1:
			push_error(
					"Error: 'Rank' column not found in standings.csv."
			)

			file.close()
			return output_dict


		var all_rows: Array[Dictionary] = []

		while not file.eof_reached():

			var row: PackedStringArray = file.get_csv_line()

			if row.is_empty() or (
					row.size() == 1 and
					row[0].strip_edges() == ""
			):
				continue

			if key_index >= row.size():
				continue

			var player_id: String = row[key_index].strip_edges()

			if player_id == "":
				continue

			var row_data: Dictionary = {}

			for i in range(headers.size()):

				if i < row.size():
					row_data[headers[i]] = row[i].strip_edges()
				else:
					row_data[headers[i]] = ""

			row_data["_player_id"] = player_id

			all_rows.append(row_data)


		var numeric_rank_by_player: Dictionary = {}

		for row_data in all_rows:

			var player_id: String = row_data["_player_id"]
			var rank: String = str(row_data["Rank"]).strip_edges()

			if rank.to_lower() == "dropped":
				continue

			if rank.is_valid_int():

				if not numeric_rank_by_player.has(player_id):
					numeric_rank_by_player[player_id] = rank


		for row_data in all_rows:

			var player_id: String = row_data["_player_id"]

			var rank: String = str(
					row_data["Rank"]
			).strip_edges()

			row_data.erase("_player_id")


			if numeric_rank_by_player.has(player_id):

				row_data["Rank"] = numeric_rank_by_player[player_id]

			else:

				row_data["Rank"] = rank


			output_dict[player_id] = row_data


	file.close()

	return output_dict


static func merge_dicts_keep_first_order(
		first_dict: Dictionary,
		second_dict: Dictionary
) -> Dictionary:

	var result: Dictionary = {}

	for player_id in first_dict:

		var merged_data: Dictionary = \
			first_dict[player_id].duplicate(true)

		if second_dict.has(player_id):

			for key in second_dict[player_id]:
				merged_data[key] = \
					second_dict[player_id][key]


		result[player_id] = merged_data


	return result
