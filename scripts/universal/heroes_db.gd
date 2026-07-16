extends Node

var young_heroes
var young_heroes_path = "res://database/young_heros_db.json"

func _ready() -> void:
	young_heroes = load_jason_file(young_heroes_path)
	#print(young_heroes)


func load_jason_file(filePath : String):
	if FileAccess.file_exists(filePath):
		var dataFile = FileAccess.open(filePath, FileAccess.READ)
		var parsedResult = JSON.parse_string(dataFile.get_as_text())
		
		if parsedResult is Dictionary:
			print(filePath + " is dictionary")
			return parsedResult
		else:
			print("Not dictionary")
	else:
		print("Cant find file")
