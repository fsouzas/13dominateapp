class_name CSVStanding

enum MergeError {OK = 0, FIRST_EMPTY = 1, SECOND_EMPTY = 2, PLAYER_ID_MISMATCH = 3}
const HEADER_ALIAS := {
	#standings.csv
	"Rank": "rank",
	"Classement": "rank",
	"Rang": "rank",
	"Posizione": "rank",
	"ランキング": "rank",
	"Clasificación": "rank",

	"Name": "name",
	"Nom": "name",
	#"Name": "name",
	"Nome": "name",
	"名前": "name",
	"Nombre": "name",

	"Player ID": "player_id",
	"Identifiant du joueur": "player_id",
	"Spieler-ID": "player_id",
	"ID giocatore": "player_id",
	"プレイヤーID": "player_id",
	"ID del jugador": "player_id",

	"Wins": "wins",
	"Victoires": "wins",
	"Siege": "wins",
	"Vittorie": "wins",
	"勝利数": "wins",
	"Victorias": "wins",

	#heroes.csv
	"Player Name": "player_name",
	"Nom du joueur": "player_name",
	"Spielername": "player_name",
	"Nome del giocatore": "player_name",
	"プレイヤー名": "player_name",
	"Nombre del jugador": "player_name",

	"Country/Region": "country_region",
	"Pays/Région": "country_region",
	"Land/Region": "country_region",
	"Nazione/Regione": "country_region",
	"国/地域": "country_region",
	"País/Región": "country_region",

	"Hero": "hero",
	"Héros": "hero",
	"Held": "hero",
	"Eroe": "hero",
	"ヒーロー": "hero",
	"Héroe": "hero",
}

const DROPPED_ALIAS := {
	"Dropped": "dropped",
	"Abandonné": "dropped",
	"Gedroppt": "dropped",
	"Droppato": "dropped",
	"退出済み": "dropped",
	"Dropeado": "dropped",
}

static func load_csv_to_dict(file_path: String, type: String) -> Dictionary:
	var output_dict: Dictionary = {}

	var file = FileAccess.open(file_path, FileAccess.READ)

	if file == null:
		push_error("Failed to open file: " + file_path)
		print(output_dict)
		return output_dict

	var headers: PackedStringArray = file.get_csv_line()
	var normalized_headers: PackedStringArray = []

	for header in headers:
		if HEADER_ALIAS.has(header):
			normalized_headers.append(HEADER_ALIAS.get(header))
		else:
			normalized_headers.append("")

	var required: Array[String] = []

	if type == "standings":
		required = [
			"rank",
			"name",
			"player_id",
			"wins"
		]

	elif type == "heroes":
		required = [
			"player_name",
			"player_id",
			"country_region",
			"hero"
		]

	else:
		push_error("Unknown CSV type: " + type)
		file.close()
		print(output_dict)
		return output_dict


	var missing: Array[String] = []

	for element in required:
		if not normalized_headers.has(element):
			missing.append(element)


	if missing.size() > 0:

		if type == "standings":
			SignalBus.error_msg.emit(TranslationServer.translate("standings_csv_error_load"), "error")
			SignalBus.csv_state.emit(false)

		elif type == "heroes":
			SignalBus.error_msg.emit(TranslationServer.translate("heroes_csv_error_load"), "error")
			SignalBus.csv_state.emit(false)

		file.close()
		print(output_dict)
		return output_dict


	SignalBus.error_msg.emit(TranslationServer.translate("csv_loaded_with_no_errors"), "correct")
	SignalBus.csv_state.emit(true)


	var key_index: int = normalized_headers.find("player_id")

	if key_index == -1:

		file.close()
		print(output_dict)
		return output_dict


	if type == "heroes":

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

			for i in range(normalized_headers.size()):

				if i == key_index:
					continue

				if normalized_headers[i] == "":
					continue

				if i < row.size():
					row_data[normalized_headers[i]] = row[i].strip_edges()
				else:
					row_data[normalized_headers[i]] = ""

			output_dict[player_id] = row_data


		file.close()
		print(output_dict)
		return output_dict

	if type == "standings":

		var rank_index: int = normalized_headers.find("rank")

		if rank_index == -1:

			file.close()
			print(output_dict)
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

			for i in range(normalized_headers.size()):
				
				if normalized_headers[i] == "":
					continue

				if i < row.size():
					var value: String = row[i].strip_edges()

					if normalized_headers[i] == "rank" and DROPPED_ALIAS.has(value):
						value = DROPPED_ALIAS.get(value)

					row_data[normalized_headers[i]] = value
				else:
					row_data[normalized_headers[i]] = ""

			row_data["_player_id"] = player_id

			all_rows.append(row_data)


		var numeric_rank_by_player: Dictionary = {}

		for row_data in all_rows:

			var player_id: String = row_data["_player_id"]
			var rank: String = str(row_data["rank"]).strip_edges()

			if DROPPED_ALIAS.has(rank):
				rank = DROPPED_ALIAS.get(rank)

			if rank == "dropped":
				continue

			if rank.is_valid_int():

				if not numeric_rank_by_player.has(player_id):
					numeric_rank_by_player[player_id] = rank


		for row_data in all_rows:

			var player_id: String = row_data["_player_id"]

			var rank: String = str(
					row_data["rank"]
			).strip_edges()

			row_data.erase("_player_id")


			if numeric_rank_by_player.has(player_id):

				row_data["rank"] = numeric_rank_by_player[player_id]

			else:

				row_data["rank"] = rank


			output_dict[player_id] = row_data


	file.close()
	print(output_dict)
	return output_dict


static func merge_dicts_keep_first_order(first_dict: Dictionary, second_dict: Dictionary) -> Array:

	if first_dict.is_empty():
		return [{}, MergeError.FIRST_EMPTY]
	if second_dict.is_empty():
		return [{}, MergeError.SECOND_EMPTY]
	
	var missing_in_second: Array[String] = []

	for player_id in first_dict:
		if not second_dict.has(player_id):
			missing_in_second.append(str(player_id))
	
	var missing_in_first: Array[String] = []

	for player_id in second_dict:
		if not first_dict.has(player_id):
			missing_in_first.append(str(player_id))
	
	if not missing_in_second.is_empty() or not missing_in_first.is_empty():

		return [{}, MergeError.PLAYER_ID_MISMATCH]

	var result: Dictionary = {}

	for player_id in first_dict:

		var merged_data: Dictionary = first_dict[player_id].duplicate(true)

		if second_dict.has(player_id):

			for key in second_dict[player_id]:
				merged_data[key] = second_dict[player_id][key]


		result[player_id] = merged_data


	return [result, MergeError.OK]
