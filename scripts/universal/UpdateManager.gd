extends Node

signal update_available(latest_version : String, download_url : String)
signal update_check_finished(has_update: bool)
signal update_error(error : String)

const GITHUB_OWNER := "fsouzas"
const GITHUB_REPO := "13dominateapp"
const GITHUB_API := "https://api.github.com/repos/%s/%s/releases/latest"

var current_version : String
var latest_version : String
var latest_download_url : String

func _ready() -> void:
	current_version = ProjectSettings.get_setting("application/config/version", "0.0.0")
func check_for_update():
	var http := HTTPRequest.new()
	
	add_child(http)
	
	http.request_completed.connect(_on_github_request_completed.bind(http))
	
	var url := GITHUB_API % [GITHUB_OWNER, GITHUB_REPO]
	var headers := ["Accept: application/vnd.github+json", "User-Agent: 13-Dominate-App"]
	var error := http.request(url, headers)
	
	if error != OK:
		http.queue_free()
		update_error.emit(tr("could_not_connect_str"))
		print("could_not_connect_str")
		
func _on_github_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest):
	http.queue_free()

	var response_text := body.get_string_from_utf8()
	
	var data = JSON.parse_string(response_text)
	
	
	if data == null or not data is Dictionary:
		return
	
	latest_version = str(data.get("tag_name","")).trim_prefix("v")
	latest_download_url = str(data.get("html_url",""))
	
	if latest_version.is_empty():
		print("latest_version_empty")
		return
	if is_newer_version(latest_version, current_version):
		update_available.emit(latest_version,latest_download_url)
		update_check_finished.emit(true)
	else:
		update_check_finished.emit(false)
	
func is_newer_version(remote_version: String, local_version: String) -> bool:
	var remote_parts := remote_version.split(".")
	var local_parts := local_version.split(".")
	
	var max_parts: int = max(remote_parts.size(), local_parts.size())
	
	for i in range(max_parts):
		var remote_number := 0
		var local_number := 0
		
		if i < remote_parts.size():
			remote_number = int(remote_parts[i])
		if i < local_parts.size():
			local_number = int(local_parts[i])
		if remote_number > local_number:
			return true
		if remote_number < local_number:
			return false
	return false
