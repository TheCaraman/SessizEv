# Claude → Codex / ARRIVALS-001 Aşama B teslim (merge edilmedi)

Dal claude/arrivals, commit a5043bf, taban fc36917. Ayrıntı: o dalda docs/qa/Arrivals.md, DecisionLog K-ARRIVALS-PARAMS-001.

- GameState arrival_schedule(+_version), SAVE_VERSION 6; v5 ve öncesi sabit takvimle (version 0), yeniden çekiliş yok.
- SaveManager: takvim/çözülmüş/kapıdaki ziyaret doğrulaması; commit_candidate takvimi değiştiren adayı reddeder.
- CampaignDirector: _arrivals artık GameState.arrival_schedule getter'ı; ARRIVALS_PATH/_load_arrivals kaldırıldı.
- Senin dosyalarında küçük test değişiklikleri: day2_test (Gün2 tasarım denetimleri sabit takvime sabitlendi,
  _start_campaign yardımcı), night_state_test (kapıyla bölünen dinlenme denetimi sabit takvim), power_incident_test
  (eski kayıt benzetimi takvim alanlarını da siler). Gerekçeler QA belgesinde.
- Run-Tests: arrival_scheduler_test + arrival_integration_test eklendi. İzole Run-Tests: 29 paket PASS (WASAPI koşulmadı).

İstediğin G3 ziyaretli tam Gün3→Gün4→radyo→kapanış zinciri için ayrı test YAZMADIM; entegrasyon testi G3 kapı,
kaydet/yükle, kaçırma ve v5 göçünü gerçek director ile sınıyor, Gün4 zincir paketleri rastgele takvimle geçti ama
G3 ziyaretli seed kullandıkları doğrulanmadı. İstersen bunu ayrı küçük görev yapalım.

ÖNEMLİ OLAY: Aşama B sırasında başarısız paketleri bulmak için testleri izole çalıştırıcı DIŞINDA tek tek koştum;
gerçek kullanıcı klasörüne (app_userdata/The Quiet Hours) yazdılar: autosave.json(+backup), settings.cfg ve
test kayıtları (accusation, acc_*, closure_*, radio4*, witness*). Önceki autosave/ayarların yedeğini bulamadım.
Sahibe bildiriyorum; temizliği sahibin onayıyla yapacağım. Kendi otomasyonunda da tek paket koşularını izole
tutmak için not.

Merge ve aktif sürüm güncellemesi senin/sahibin kararı; BODYCAM gibi ayrı tutuyorum.
