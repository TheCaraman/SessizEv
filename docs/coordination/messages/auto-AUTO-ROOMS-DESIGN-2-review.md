# Otomatik koordinasyon — AUTO-ROOMS-DESIGN / review

2026-11-17T06:21:34.365936+00:00

claude: approved

Salt okunur inceleme. Yalnız Read/Glob/Grep kullandım; hiçbir komutu ve testi çalıştırmadım.

**Kapsam:** Çalışma ağacında izin dışında tek bir değişiklik bile yok. Tek değişiklik izinli `docs/design/RoomPreferences.md` dosyası. Kod, sahne, yerelleştirme ya da ARRIVALS dosyalarına dokunulmamış.

**Kanonla uyum (K-NPC-ARRIVALS-ROOMS-001, NPC_ArrivalAndRooms §2–5):**
- Son oda kararı oyuncuda. NPC yalnızca isteğini ya da itirazını bildiriyor; kendiliğinden başka odaya taşınma yok (Değişmez 1, Akış 3–4, kabul matrisi 1. satır).
- Kapasite, izolasyon rezervi ve tek konum kuralı korunuyor (Değişmez 2–4). Fiziksel hata, itirazı onaylayarak aşılamıyor.
- Belgede yeni bir kişisel tercih yok: Elena, Marcus ve Arthur için tercih atanmamış. Noah–Lily açıkça etkin olmayan, gelecekteki bir örnek olarak geçiyor. Sayısal güven ya da ceza alanı tanımlanmamış ve bunların kararlaştırılmadığı açıkça yazılmış. Bu, §3'teki "henüz tanımlanmadı" ifadesiyle tutarlı.
- Enfeksiyon ve seed tercih değerlendirmesine girdi olmuyor; ölü, gelmemiş, kovulmuş ya da izole kişi itiraz sürecine katılmıyor. Lily için şiddet ya da onu tek başına bırakma gibi bir davranış türetilmiyor.
- Belgenin başlığında ve son bölümünde "kodlanmadı" deniyor; özellik uygulanmış gibi sunulmuyor.

**Kod iddialarının doğrulanması (taban: fc36917):**
- `PLAN_MINUTES = 15`, `shelter_manager.gd:18`.
- Değişmeyen bir plan süre harcamıyor, `shelter_manager.gd:135-136`.
- Gün 3 elektrik kesintisinde (POWER_WAKE) plan kısmen uygulanmıyor, `shelter_manager.gd:139-141`.
- İzole sakin plan yoluyla taşınamıyor ya da işe verilemiyor (`ISO_PLAN_LOCKED`), `shelter_manager.gd:66-67`.
- `BEDS` altı yatak içeriyor: guest_a, guest_b ve multipurpose odalarında ikişer, `game_state.gd:33-35`.
- `get_location`, `get_room_sleepers`, `bed_room` ve `get_free_beds` fonksiyonları mevcut.
- `SaveManager.commit_candidate`, `save_manager.gd:27`.
- `ShelterView.confirm()` doğrudan `apply_plan()` çağırıyor, `shelter_view.gd:65-68`.
- Belgede adı geçen dört test dosyası ve koordinasyon mesajları mevcut.

**Kaynak taslakla karşılaştırma:** Belge taslağı kopyalamıyor; onu uygulanabilir sözleşmeye dönüştürüyor. `speaker_id`/`target_id` alanlarına indirgenmiş bir veri tablosu, oda tabanlı karşılama kuralı, eskimiş incelemeyi geçersiz kılma, aday kayıt akışı ve kabul matrisi var. Taslaktaki `room_tags` ve `priority` alanlarının çıkarılmasının gerekçesi yazılmış ve taslağın "share_with/avoid_with yeterli" sınırıyla uyumlu.

**Küçük notlar (engel değil):**
- UI metin tablosu "önerilen genel metin" olarak işaretlenmiş. Yerelleştirme kaynağına eklenmeden önce sahibin metni onaylaması uygun olur.
- Belgenin son bölümünde yazar, `tools/Run-Tests.ps1` komutunun ortam hatasıyla 1 çıkış koduyla bittiğini ve PASS sonucu olmadığını açıkça bildiriyor. Ben bunu doğrulayamadım; test kapısı dış yönetimde.

Belgede gerçek bir hata ya da sahip kararı gerektiren bir durum bulmadım.

Kaynak: runtime/continuous/state.json. Bu CLI çalışanı çıktısıdır; masaüstü sohbet ACK'i değildir.
