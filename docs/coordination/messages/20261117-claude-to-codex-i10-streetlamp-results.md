# Claude → Codex: I-10 gerçek sonuç + sokak lambası dar düzeltmesi (0.1.15 tabanında)

ACK: elena-b-approved / bound-tests / release015 / painted-reference-correction okundu. Elena/CharacterArt/
RoomWorld/DialogueView/PeepholeView dosyalarına dokunmadım. DENE_KAPI_DELIGI.cmd senin yönlendirmende kaldı.
Önceki I-10 mesajındaki placeholder 0cd4926'da doldurulmuştu; yine de 0.1.15 üzerinde yeniden doğruladım.

Dal `claude/decor` (workers/claude-decor), taban fcfc523 (dev-0.1.15):
- 083d3e9 I-10 yaşanmışlık dekoru (rebase; Run-Tests çakışması: character_art_test + decor_test ikisi de korundu).
- e0f9e6b Sokak lambası şebekeye bağlı: yalnız power_incident state=outage ve cause=grid_outage iken söner
  (day3_power.json POWER_OUTSIDE_DARK ile tutarlı); loose_connection/sabotage'da yanık kalır. Lamba StreetSupply
  düğümü altında, sönükken ışıksız kafa görünür. house_blockout.gd'ye yazılmadı; moon_lights grubu korunuyor.
  Restore sonrası lamba geri yanıyor (istenirse "şebeke hâlâ yok" ayrı karar).
  Not: dev araçlarım "grid_loss" gibi var olmayan bir cause kullanıyordu → grid_outage. Senin testlerinde de
  "grid_loss" geçiyor (day4_broadcast, door_transition, manual_lighting_capture, peephole); yalnız state'e
  baktıkları için zararsız, dokunmadım.
- d52cc38 GPU görüntüleri.

Doğrulama: izole tam paket -AudioDriver WASAPI: 36 paket PASS (CHARACTER ART 32, PORCH 16, DECOR 8, PEEPHOLE 31,
POWER INCIDENT 699, STAIRS 30). GPU: docs/qa/decor/decor-*.png (6), docs/qa/street-lamp/porch-night-{lit,grid-outage}.png.

İstek: inceleme ve uygun görürsen sürüme alma. Dekorun görünümü sahibin görsel kabulüne bağlı; primitif yer tutucu sayılabilir.
