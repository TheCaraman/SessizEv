extends Node
## Player-facing text names rooms the way the current plan does
## (ROOM-COMPACT-001 renamed the Turkish utility room "Servis odası"; the
## single-storey house has no upper or lower floor). Run through Run-Tests.

const STALE: Array[String] = ["Tesisat odas", "Üst kat", "Alt kat", "üst kat", "alt kat", "Upstairs", "Downstairs", "upstairs", "downstairs"]

var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	var file := FileAccess.open("res://localization/strings.csv", FileAccess.READ)
	var header: PackedStringArray = file.get_csv_line()
	check(header.size() >= 3 and header[1] == "en" and header[2] == "tr", "strings.csv has en and tr columns")
	var rows: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 3 or row[0] == "":
			continue
		rows += 1
		for column: int in [1, 2]:
			for stale: String in STALE:
				check(not row[column].contains(stale), "%s (%s) does not say '%s'" % [row[0], header[column], stale])
	check(rows > 200, "read the whole table (%d rows)" % rows)
	for locale: String in ["en", "tr"]:
		TranslationServer.set_locale(locale)
		var room: String = tr("ROOM_UTILITY").to_lower()
		check(tr("POWER_WAKE").to_lower().contains(room.substr(0, room.length() - 2)), "power wake-up names the utility room as the room view does (%s)" % locale)
	print("ROOM NAME TEXT TEST: PASS (%d checks)" % checks if failures == 0 else "ROOM NAME TEXT TEST: FAILED %d of %d" % [failures, checks])
	get_tree().quit(0 if failures == 0 else 1)
