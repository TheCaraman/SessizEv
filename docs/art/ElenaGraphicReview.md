# Elena çizimsel uyum — ART-CHAR-002

## İlk örnek

assets/characters/elena_ward/variants/graphic_candidate.png, mevcut figürün kimlik/poz/kıyafeti korunarak üretildi. Kaynak 1024×1536. Yalnızca köşeler değil, figür dışındaki farklı kenar/iç boşluk noktaları da alpha 0 olarak örneklendi. Gerçek konuşma arayüzü kompozitinde büyük renkli arka plan/mat görünmüyor.

scripts/dev/dialogue_art_preview.gd artık --candidate-image=res://assets/characters/... argümanıyla aday figürü gerçek DialogueView/DialogueRunner içinde gösterebilir. Seçim yalnızca geliştirme sahnesindedir; ürün DialogueView ve default.png yolu değiştirilmedi. Aday önizlemede açıkça etiketlenir. Kamera kırpması aday boyutlarından yeniden hesaplanır; farklı boyutlar yanlış eski kırpmayı kullanmaz.

İlk aday gerçek Forward+ 1920×1080 konuşma ekranında render edildi. Poz/kimlik ana hatları korunuyor; oda diliyle önceki fotoğrafik figürden daha uyumlu. Sahip geri bildirimi: tema iyi, çizim biraz daha referans oyundaki ham/tekinsiz figür diline yaklaşmalı. Bu, ilk örneğin nihai kabulü değildir.

## Revizyon kapsamı

Tema/kıyafet korunarak daha ham boya alanları, düzensiz kenarlar ve daha az temiz çizgi-roman yüzü deneniyor. Yaş/kimlik değiştirilmez; zombi/enfeksiyon belirtisi eklenmez. Sağlıklı ve enfekte Elena aynı kaynağı kullanmaya devam eder. Referans ekran görüntüsünün karakteri, giysisi, yüzü, simgeleri ve arayüzü kopyalanmaz.

Bu çalışma yeni karakter animasyonu, ifade bankası, diğer iki karakterin tamamlanması veya bütün sanatın kabulü değildir. Tam oyuncu giriş testi yapılmadı; gerçek motor renderı ve kaynak alfa denetimi yapıldı.

## İkinci örnek — sahibin revizyon isteği

graphic_candidate_v2.png daha düzensiz boya yüzeyleri, yumuşatılmış/kaybolan konturlar ve daha az temiz çizgi-roman biçimiyle üretildi. Tema, yaş, kıyafet ve poz korunur. 1024×1536; figür dışındaki örnek noktalarda alpha 0 doğrulandı. Gerçek konuşma UI'sinde ikinci kompozit üretildi ve incelendi; renkli arka plan dikdörtgeni görünmüyor. İlk ve ikinci PNG ayrı tutuldu. Varsayılan ürün figürü hâlâ değiştirilmedi; sahibin ikinci örnek değerlendirmesi bekleniyor.

Önizleme komutu: `godot --path . res://scenes/dev/dialogue_art_preview.tscn -- --character=elena_ward --candidate-image=res://assets/characters/elena_ward/variants/graphic_candidate_v2.png --capture-dialogue-art`. Kayıt üreten kampanya sahnesi kullanılmaz. Üretim oyununun görüntü ve kayıt davranışı değişmediği için bütün regresyonlar bu sanat/önizleme değişikliği nedeniyle tekrar çalıştırılmadı; gerçek kaynak import ve konuşma renderı geçti.
