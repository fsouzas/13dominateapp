extends Node

var save_path = "user://settings.cfg"
var config : ConfigFile = ConfigFile.new()
var locale : String = TranslationServer.get_locale()
var theme : String = "default"
var store: String = ""
var store_names: Array[String] = []

func load_settings():
    if FileAccess.file_exists(save_path):
        config.load(save_path)

        locale = config.get_value("general", "locale", locale)
        TranslationServer.set_locale(locale)

        theme = config.get_value("appearance", "theme", theme)
        ThemeManager.set_theme(theme)

        store = config.get_value("standings", "store", store)
        store_names = config.get_value("standings", "store_names", store_names)
    else:
        pass

func save_settings():
    config.set_value("general", "locale", locale)
    config.set_value("appearance", "theme", theme)
    config.set_value("standings", "store", store)
    config.set_value("standings", "store_names", store_names)

    config.save(save_path)

