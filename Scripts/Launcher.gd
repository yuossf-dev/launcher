extends Control

const MANIFEST_URL: String = "https://yuossf-dev.github.io/launcher/manifest.json"
const GAME_FOLDER: String = "user://game"
const VERSION_FILE: String = "user://launcher_version.txt"
const GAME_EXE_NAME: String = "VillageDeathmatchXonlinefix.exe"

@onready var version_label: Label = $MarginContainer/VBoxContainer/VersionLabel
@onready var status_label: Label = $MarginContainer/VBoxContainer/StatusLabel
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var check_button: Button = $MarginContainer/VBoxContainer/Buttons/CheckButton
@onready var update_button: Button = $MarginContainer/VBoxContainer/Buttons/UpdateButton
@onready var play_button: Button = $MarginContainer/VBoxContainer/Buttons/PlayButton
@onready var manifest_request: HTTPRequest = $ManifestRequest
@onready var download_request: HTTPRequest = $DownloadRequest

var installed_version: String = "unknown"
var remote_manifest: Dictionary = {}


func _ready() -> void:
	check_button.pressed.connect(_on_check_pressed)
	update_button.pressed.connect(_on_update_pressed)
	play_button.pressed.connect(_on_play_pressed)
	manifest_request.request_completed.connect(_on_manifest_completed)
	download_request.request_completed.connect(_on_download_completed)
	installed_version = _read_installed_version()
	_update_version_label()


func _on_check_pressed() -> void:
	status_label.text = "Checking for updates..."
	update_button.disabled = true
	manifest_request.request(MANIFEST_URL)


func _on_update_pressed() -> void:
	if remote_manifest.is_empty():
		status_label.text = "No update manifest loaded"
		return
	var download_url: String = str(remote_manifest.get("download_url", ""))
	if download_url.is_empty():
		status_label.text = "Manifest missing download URL"
		return
	status_label.text = "Downloading update..."
	progress_bar.value = 0
	download_request.download_file = ProjectSettings.globalize_path(GAME_FOLDER.path_join("build.zip"))
	download_request.request(download_url)


func _on_play_pressed() -> void:
	var exe_path: String = ProjectSettings.globalize_path(GAME_FOLDER.path_join(GAME_EXE_NAME))
	if not FileAccess.file_exists(exe_path):
		status_label.text = "Game executable not found"
		return
	OS.create_process(exe_path, PackedStringArray())
	get_tree().quit()


func _on_manifest_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code != 200:
		status_label.text = "Manifest request failed (%d)" % response_code
		return
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		status_label.text = "Invalid manifest JSON"
		return
	remote_manifest = json.data
	var remote_version: String = str(remote_manifest.get("version", "unknown"))
	if remote_version == installed_version:
		status_label.text = "Game is up to date"
		update_button.disabled = true
	else:
		status_label.text = "Update available: %s" % remote_version
		update_button.disabled = false


func _on_download_completed(_result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if response_code != 200:
		status_label.text = "Download failed (%d)" % response_code
		return
	status_label.text = "Download complete. Replace/extract build manually next."
	var version: String = str(remote_manifest.get("version", installed_version))
	_write_installed_version(version)
	installed_version = version
	_update_version_label()
	update_button.disabled = true


func _read_installed_version() -> String:
	if not FileAccess.file_exists(VERSION_FILE):
		return "unknown"
	var file := FileAccess.open(VERSION_FILE, FileAccess.READ)
	if file == null:
		return "unknown"
	return file.get_as_text().strip_edges()


func _write_installed_version(version: String) -> void:
	var file := FileAccess.open(VERSION_FILE, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(version)


func _update_version_label() -> void:
	version_label.text = "Installed: %s" % installed_version
