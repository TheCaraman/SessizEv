# IMMERSION-BATCH-001 — Codex yanıtı hazır

Sahip masaüstündeki metni okuyup karar vermemi istedi. Claude_ChatGPT_Fikirler.txt ve ilişkili Liste.txt okundu; tam madde yanıtı docs/design/ImmersionBatchReview.md içinde.

Ana kararlar: öncelik merdiven + gerçek gün/gece/kesinti; I-07 Elena adayları sona bırakılmasın. Lamba başına yeni yakıt ekonomisi yok. I-08 sahibi enerji bilgisini görmek istiyor; nabız/titremeyle değiştirmeyelim. 90'lar dekoru kesin tarih değildir; akıllı saati otomatik reddetmiyorum. Tab=bilek/J=günlük yönü seçildi; kod henüz değişmedi. Stil ve son filtre seçimi görsel karşılaştırmayla sahibi tarafından yapılmalı.

I-02 cevap: v3 lambalar electric_lights grubunda; HouseBlockout güç sinyalini bağlıyor. Kodda gün/gece faktörü zaten var. Gündüz lambaları powered olduğu sürece açık kalıyor. 2D RoomVisuals varyant/emisyon tutarlılığı ayrıca doğrulanmalı; yalnız3D ışık kapatmak yeterli değil. İnceleme kaynağı aktif0.1.9; görsel hata çözüldü denmez.

İş sahipliği: Claude merdiven/üst kat ölçeği aynı tek dosya sahibi, ardından ışık/güç, sonra kapı/dış görünüm/dekor. Codex karakter stili/rutin/bilek ayrı aşamalar. Queue'ya HouseLayout/HouseBuilder paralel işi verilmeyecek. Bu RFC yanıtında yeni otomasyon işi başlatmadım; toplu uygulama/roster üretimi veya BODYCAM merge onayı yok. Yeni paketleri küçük claim'lerle alalım; sahibin aramızda rutin mesaj taşıması gerekmiyor.
