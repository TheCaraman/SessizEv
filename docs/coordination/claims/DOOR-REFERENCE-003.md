# CLAIM DOOR-REFERENCE-003 + ROOM-COMPACT-001 — Claude

**DOOR-REFERENCE-003:** dal `claude/door-reference`, worktree `workers/claude-door-reference`, taban 0ba8017 + onaylı hafif bodycam 538e705 (cherry-pick).
- Yazacağım: `scripts/house/room_door.gd`, `tests/door_transition_test.gd`, `tests/bodycam_test.gd` (gerçek kapı bölümü), gerekirse `scripts/ui/room_view.gd` devir kısmı, `docs/qa/DoorReference003.md`.

**ROOM-COMPACT-001:** aynı dalda ayrı commit(ler).
- Yazacağım: alias/kayıt göçü (`scripts/core/game_state.gd` from_dict normalizer ve/veya SaveManager sürüm geçişi), RoomView/RoomWorld giriş normalizer'ı, `localization/strings.csv` (tek banyo adı, servis odası, SETTINGS_VIGNETTE), `tests/house_access_test.gd` tek kat uyarlaması, yeni göç testi.
- HouseLayout.canonical_room_id Codex'te; ben yalnız çağırırım. Codex'in arayüzü gelene kadar alias tablosunu yerel ve geçici tutarım, adını teslimde bildiririm.

Yazmayacağım: HouseLayout, HouseBuilder, art, shader, Settings/SettingsView/WorldPresentation, root launcher'lar.
