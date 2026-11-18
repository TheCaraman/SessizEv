# Claude → Codex / DEV-HELPER-GUARDS-001 teslim

Dal `claude/single-storey-audit`, yeni uç **3368b28** (audit 099dc77'nin üstünde, taban 7dc0629). Yalnız scripts/dev'deki altı yardımcı ve tests/dev_helpers_test.gd değişti; üretim art/geometri/night_route/launcher/room_lighting dosyalarına dokunulmadı.

**İnceleme (her araç okundu):**

| Araç | Ne yapıyor | Karar |
|---|---|---|
| peephole_review | house_blockout tam oturumunu açıyor (CampaignDirector time/power, arrivals, ShelterManager; --time/--outage ile otomatik kayıt yolları erişilebilir) | **Koruma**: ReviewSpots.isolated, sahneye girmeden |
| porch_review | aynısı | **Koruma** |
| atmosphere_review | yalnız RoomView, GameState yazmıyor | Serbest; başlıkta not |
| room_style_review | bellek içi new_campaign + RoomView; director/kayıt yok | Serbest; başlıkta not |
| room_art_preview | bellek içi new_campaign + admit + RoomView; director/kayıt yok | Serbest; başlıkta not |
| dialogue_art_preview | bellek içi new_campaign + DialogueRunner; runner kaydetmiyor, director dinleyicisi yok | Serbest; başlıkta not |

Settings autoload'u başlangıçta yalnız okuyor (load_preferences); serbest araçlar tercih yazmıyor.

**Test:** `dev_helpers_test` 36→49.
- scripts/dev/*.gd taranıyor: house_blockout.tscn, SaveManager, Settings.set_, Settings.restore_defaults, CampaignDirector veya commit_candidate geçen her yardımcı ReviewSpots.isolated ya da custom_user_dir_name koruması taşımalı (house_blockout.gd oyunun kendisi, hariç).
- Taramada 10 riskli yardımcı bulundu, hepsi korumalı.
- Negatif kontrol: izole kopyada porch_review'un koruması silinince test 2 hata ile düştü; dosya geri yüklendi.

**Doğrulama:**
- İzole kopyada peephole_review ve porch_review gerçek GPU çıktısı üretti (SAVED).
- Tam paket WASAPI: "All 41 test suites passed (including hardware audio lifecycle)".
- Silinen geçici klasörler yalnız kendi koşularımın yazdırdığı tam yollar.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
