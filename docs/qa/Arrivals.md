# Kurallı rastgele geliş takvimi — ARRIVALS-001 QA

2026-11-17 — Claude. Taban fc36917 (radyo checkpoint). Tasarım ve sahip kararı: docs/design/ArrivalSchedule.md (§9.0).

## Ne değişti
- `scripts/narrative/arrival_scheduler.gd` (yeni): kampanya başında bir kez takvim; ayrı RNG akışı; Elena sabit;
  Marcus/Arthur G2–3 09:00–16:00 başlangıç, 3 saat; günde ≤2, ≥90 dk; 23:00 sonrası yok; diyaloğu olmayan karakter
  girmez; K-005 yuva takası enfeksiyonu değiştirmez. `resources/events/arrival_pool.json` (yeni).
- `GameState`: `arrival_schedule`, `arrival_schedule_version`; `new_campaign` enfeksiyondan sonra üretir;
  SAVE_VERSION 5 → 6; eski kayıt `arrivals.json` sabit takvimini (version 0) alır, yeniden çekilmez.
- `SaveManager`: takvim yapısı, çözülmüş ziyaret ve kapıdaki ziyaret kimliği doğrulanır; `commit_candidate`
  takvimi değiştiren adayı reddeder.
- `CampaignDirector`: ziyaretleri JSON yerine canlı kampanyanın kayıtlı takviminden okur; kapı/"left" mantığı aynı.
- Testler: `arrival_scheduler_test` (19), `arrival_integration_test` (22) eklendi ve Run-Tests'e bağlandı.
  `day2_test` Gün2 tasarımının sabit ziyaretlerini sınadığı için kendi kampanyalarında sabit takvimi kullanır;
  `night_state_test` dinlenmenin kapıyla bölünmesi denetiminde sabit takvimi kullanır; `power_incident_test`
  eski kayıt benzetiminde takvim alanlarını da siler (eski kayıtlarda yoktu).

## Doğrulama
Run-Tests.ps1 (izole kullanıcı klasörü): 29 çekirdek paket PASS (WASAPI donanım paketi koşulmadı).
Entegrasyon testi gerçek CampaignDirector ile: Marcus'un G3'e düştüğü seed'de G2'de kapı çalmaz; G3'te dinlenme tam
planlanan dakikada kesilir; kapıdayken kaydet/yükle takvimi ve bekleyeni korur; takvimi değiştiren aday reddedilir;
yanıtlanmazsa pencere sonunda "left" ve tek kez çözülür; v5 kayıt sabit takvimle yüklenir, v6 olarak yeniden yazılır;
bilinmeyen çözülmüş ziyaret içeren kayıt reddedilir. Örnek seed 1234: d1_elena 18:00, d2_arthur 11:45, d3_marcus 15:00.
400 seed'de 298 farklı G2–3 takvimi.

## Sınırlar / açık
- G3 ziyaretiyle başlayan tam Gün3→Gün4→radyo→kapanış zinciri için ayrı test YAZILMADI. Gün4 kapanış/radyo/
  day12 zincir testleri artık rastgele takvimle koşuyor ve geçti; ama hepsinin G3 ziyaretli seed kullandığı doğrulanmadı.
- Marcus G3'te gelirse Gün2 sakin diyaloğu/işleri o oyunda görülmez (beklenen); Gün3 içerik dengesi elle oynanmadı.
- Oda tercihleri (ROOMS-001) ve yeni karakter içeriği bu işin parçası değil.
- Geliştirme sırasında testler bir kez izole çalıştırıcı DIŞINDA tek tek koşuldu ve gerçek kullanıcı klasörüne
  (AppData/Roaming/Godot/app_userdata/The Quiet Hours) yazdı: autosave, settings.cfg ve test kayıt dosyaları üzerine
  yazıldı. Önceki dosyaların yedeği bulunamadı. Bundan sonra yalnız Run-Tests.ps1 kullanılmalı.
