# Gece araştırmasından sonra nöbete katılma

## Amaç ve davranış

Gün 3'te uyku elektrik kesintisiyle kesildikten ve tesisat araştırıldıktan sonra nöbet seçimi kaybolmamalı. Başlatma penceresi 20:00–23:59 oldu; 23:00 öncesi seçim 23:00'te, sonraki seçim gerçek mevcut dakikada başlar. Geçmiş dakikalara enerji borcu yazılmaz. Bekleme sınırları yine 01/03/05/07'dir. Onay iki basış gerektirir; diğer eylem veya odadan çıkış iptal eder.

## Dosyalar ve bağımlılıklar

- scripts/time/night_session.gd: sahne-yerel başlatma uygunluğu ve gerçek başlangıç.
- scripts/time/night_timeline.gd: başlangıca göre süre doğrulaması; sabit dünya saati sınırları.
- localization/strings.csv: en/tr başlangıç ve maliyet açıklaması.
- tests/night_watch_test.gd, night_timeline_test.gd, presentation_test.gd: gerçek oda eylemi, saf zaman modeli, arayüz sınamaları.

Hiyerarşi değişmedi: HouseBlockout → CampaignDirector → NightSession. Yeni kaynak, autoload veya editör düğümü gerekmez. Godot 4.7.2 ile içe aktar; normal oyunda Gün 3 elektrik olayı sonrası Daniel'ın odasına dön. Eski v5 kayıtları korunur; yeni başlangıç alanı mevcut şemada doğrulanır.

## Doğrulama

İzole tam koşu son sahne PLAYER MOVEMENT TEST: PASS (6 checks) ile sonlandı, stderr boş; koşucu önceki sahnenin başarısı olmadan ilerlemez. Önceki aynı kod koşusu 16 paket/5632 denetim geçti; son değişiklik yalnızca onay metnini başlangıç saatiyle açıklığa kavuşturdu. Son kopya: tqh-tests-d06280bfff694b07a219364921d7fb0d. Gerçek Forward+ sunum koşusu PRESENTATION TEST: PASS (100 checks), en/tr 1080p/1440p; Türkçe 1080p görüntü açılıp incelendi.

Oda eylemi testi: 20:00 uyku → 23:00 kesinti → 20 dakika araştırma → 23:20 nöbet. Başlangıç enerjisi 100, 01:00'de 92, sabah 62; gıda 11, tek sabah çözümü. Olay kaydı değişmez, v5 kaydet/yükle geçer. Saf model ayrıca 23:59 ve sabaha yakın başlangıçlarda dakika ve JSON sınırlarını kontrol eder. Sahne-yerel kullanıcı seçimi hâlâ yalnızca 23:59'a kadar açılır; sonraki model başlangıçları doğrulama kapsamıdır.

## Sık hata ve bitti ölçütü

İki saatlik maliyeti geç başlangıca tam uygulamak veya geçmiş sınırları yeniden çözmek hatadır. Hesap başlangıçtan itibaren gerçek dakikaları kullanır. Sonradan katılma, kayıt ve UI kontrolleri tamam; fare/klavyeyle baştan sona oynama doğrulanmadı. Bu teslim genel gece olay yönetmeni veya Gün 4 uygulaması değildir. Sonraki bağımlılık: geri alınamaz kararlar öncesi güvenli kayıt yazımı.
