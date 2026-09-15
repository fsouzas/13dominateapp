extends Node

var save_path : String = "user://settings.cfg"
var config : ConfigFile = ConfigFile.new()
var locale : String = TranslationServer.get_locale()
var theme : String = "default"
var store: String = ""
var store_names: Array[String] = []

func load_settings():
    if not FileAccess.file_exists(save_path):
        return

    var error := config.load(save_path)

    if error != OK:
        return
    
    locale = config.get_value("general", "locale", locale)
    UniversalDict.setLocale(locale)

    theme = config.get_value("appearance", "theme", theme)
    ThemeManager.set_theme(theme)

    store = config.get_value("standings", "store", store)
    store_names = config.get_value("standings", "store_names", store_names)

func save_settings():
    config.set_value("general", "locale", locale)
    config.set_value("appearance", "theme", theme)
    config.set_value("standings", "store", store)
    config.set_value("standings", "store_names", store_names)


    var error := config.save(save_path)

    if error != OK:
        return
    
