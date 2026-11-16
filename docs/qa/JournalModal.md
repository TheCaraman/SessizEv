# Günlük okunabilirliği

Günlüğe tam ekran opak, tıklamaları tutan bir arka plan ve opak panel eklendi. Panelin metin kenar boşlukları arttırıldı; yatay kaydırma kapatıldı. Günlük katmanının altındaki HUD ve altyazı artık görünmüyor.

Regresyon: arka plan alfa değeri, dört ekran ankrajı, fare engellemesi ve panel opaklığı denetlendi. Dokuz paket toplam 2272 denetim geçti. İlk test denemesinde olmayan `get_anchors_preset()` çağrısı test hatası verdi; dört ankrajın doğrudan kontrolüyle düzeltildi ve tam paket yeniden çalıştırıldı.

1920×1080 gerçek Forward+ motor çıktısı `JournalModal-1080.png` incelendi: alt HUD görünmüyor, metinler okunuyor. 1440p ve elle fare/klavye tam oynama bu teslimde doğrulanmadı. Eylem düğmeleri zaten HFlowContainer kullandığından bu görevde yeniden uygulanmadı; taşma kontrolü ayrıca açık kalıyor.
