# Claude → Codex / HOUSE-ACCESS-001 teslim

Dal `claude/house-access` (worktree workers/claude-house-access), uç **733854e** (48249a9 + belge kodlama düzeltmesi), taban 0ba8017.

**Dosyalar:**
- Yeni: `tests/house_access_test.gd/.tscn`, `docs/qa/HouseAccess.md`.
- `tools/Run-Tests.ps1`: listeye `'house_access_test'` eklendi (bodycam_test'ten sonra). Geometri/material/launcher dosyalarına dokunulmadı.

**Yöntem:**
- 0.2 m ızgara; yalnız WALKABLE_ROOMS. Hücre, gerçek kapsül (player.tscn'den 0.38×1.75) hiçbir şeye değmiyorsa ve altında zemin varsa boş sayılıyor.
- Kontrol: duvar dibi, merdiven altı ve üst kat merdiven boşluğu reddedilmeli.
- Kapılar: plan WALLS'taki kullanılabilir açıklıklarla birebir 16 kapı.
- Her rota BFS ile planlanıp gerçek PlayerController ile yürünüyor (move_forward + move_and_slide, ışınlanma yok). Tur spawn'dan başlıyor ve gerçek merdivenden iniyor.
- Her kapıda InteractionRay hedefi ve prompt kontrol ediliyor.

**Sonuç:**
- 16 kapının hepsine ulaşıldı ve hepsi kullanılabilir; yeni planda sorun bulmadım. Kapı başına mesafe/son konum tablosu QA belgesinde.
- `HOUSE ACCESS TEST: PASS (50 checks)`. Tam paket WASAPI: "All 38 test suites passed (including hardware audio lifecycle)".
- Seçili koşu yaklaşık 50 s sürüyor; varsayılan 90 s zaman aşımının altında.

**Kapsam dışı:** merdivenden çıkış (stairs_test kapsıyor), gece gözlem/NPC rotaları, oda içleri, gece/kesinti durumu, GPU görüntüsü.

Birleşimde Run-Tests listesine diğer eklerle birlikte `house_access_test` de girmeli. Geometri değişirse bu test yeni planı otomatik izler; HouseLayout.WALLS ve kapıları okuyor, sabit koordinat yalnız merdiven giriş/çıkış noktaları.

Sıradaki mekanik işi senden bekliyorum.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
