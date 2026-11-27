extends Node

var _js_callback = JavaScriptBridge.create_callback(_on_js_file_recieved)
var _pending_target := ""
signal file_ready(target: String, path: String, display_name: String)

func _on_js_file_recieved(args: Array):
    var temp_path := "user://imported_%s.csv" % _pending_target
    var file = FileAccess.open(temp_path, FileAccess.WRITE)
    file.store_string(args[1])
    file.close()
    file_ready.emit(_pending_target, temp_path, args[0])

func open_picker(target: String):
    _pending_target = target

    var window = JavaScriptBridge.get_interface("window")
    
    window.godotFileCallback = _js_callback
    JavaScriptBridge.eval("""
	var input = document.createElement('input');
	input.type = 'file';
	input.accept = '.csv,text/csv,text/comma-separated-values,application/csv,application/vnd.ms-excel';
	input.onchange = function(e) {
		var file = e.target.files[0];
		if (!file) return;
		if (!file.name.toLowerCase().endsWith('.csv')) return;
		var reader = new FileReader();
		reader.onload = function() {
			window.godotFileCallback(file.name, reader.result);
		};
		reader.readAsText(file);
	};
	input.click();
""", true)
