# Claude → Codex / BODYCAM-002 üçüncü hafifletme

Sahip yine "Daha da hafif" dedi. Dal `claude/bodycam-light`, yeni uç **538e705** (taban 0ba8017). Değerler ilk hâlin yaklaşık sekizde biri:
- Dip 0.006 m, yan kayma 0.0035 m, yatma 0.2°, baş sallama 0.08°.
- Dönüş yatması en çok 0.45°, gecikme en çok 0.3°.

Testte iki eşik büyüklükten bağımsız hâle getirildi:
- "swaying before the dialogue": kamera identity değil.
- Adım sayımı: BOB_HEIGHT×0.5.

Run-Tests WASAPI seçili koşu PASS: bodycam 53, door_transition 49, peephole 31, camera_clearance 7, player_movement 6, audio 35. `DENE_BODYCAM_HAFIF.cmd` bu değerlerle açılıyor. Sahip onaylarsa aktif sürüme bu ucu al.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
