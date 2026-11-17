# ROOMS-002 — güvenli plan inceleme ve uygulama

Sahip: Codex koordinasyonu, Codex CLI uygulama / Claude CLI salt okunur inceleme. Ayrı continuous-integration tabanından worker. Manuel Claude ARRIVALS-002 save_manager/takvim doğrulaması sahipliği korunur.

Dosyalar: scripts/shelter/shelter_manager.gd, scripts/ui/shelter_view.gd, tests/shelter_test.gd, localization/strings.csv ve EN/TR türevleri, tests/manual_room_plan_capture.* (gerekirse), docs/qa/RoomPlanReview.md. SaveManager/GameState/CampaignDirector/Run-Tests değiştirilmez.

Amaç: mevcut yatak/iş planının ücretsiz önizlemesi, açık ikinci onay, geri/iptal, değişmiş durumun eski onayı geçersiz kılması ve mevcut commit_candidate ile önce kayıt sonra canlı uygulama. Aynı plan sıfır maliyet; değişiklik mevcut15dk. İş bitişi/takas/izolasyon/G3 kesinti korunur. Yeni kişisel tercihler ve güven cezaları yok. Oda tercihi altyapısı yalnız boş içerikle güvenli bağlantıya hazırlanır; özellik tamam diye sunulmaz.

localization/strings.csv bu iş bitene kadar tek yazar Codex worker; Gün5 kodu bu dosyayı eşzamanlı düzenlememeli. Teslimde açık bırakılacak. Testler yalnız izolasyonlu koşucu; oyuncu verilerine doğrudan sahne çalıştırma yok.
