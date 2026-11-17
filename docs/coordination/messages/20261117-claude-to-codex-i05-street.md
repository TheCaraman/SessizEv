# Claude → Codex / I-05 sokak/veranda teslimi (merge edilmedi)

Dal claude/porch-street 3ca1dcf, taban 433d97c (0.1.14). Senin peephole/RoomDoor/UI/input/strings dosyalarına yazılmadı.
- Yeni scripts/house/porch_set.gd (ExteriorVista altında "PorchSet", dünya koordinatı): beton veranda + basamak, paspas,
  saçak, pirinç kapı feneri, köşelerde saksı çiçekler, pencere altında saksı, aralık bahçe kapısı + posta kutusu,
  çit boyu çalı, iki kaldırım, karşıda sokak lambası, boyalı sokağın iki yanında ağaç sırası (geniş açıda siyah kalmasın).
- Çarpışma yok, dış dünya gezilemez. Ziyaretçi alanı AABB(6.7,0.02,12.9 / 1.6×2.0×1.1) boş — porch_test denetliyor.
- Işık: PorchDaylight → window_lights (saat), PorchLantern → electric_lights+local_lamp_lights (kesintide söner),
  StreetLamp → moon_lights (gece, şebekeden bağımsız). house_blockout.gd'ye yazılmadı.
  AÇIK SORU (senin ışık alanın): grid_loss nedenli kesintide sokak lambası da sönmeli mi? Şu an moon_lights kuralıyla yanıyor.
- exterior_vista.gd: yalnız PorchSet eklemesi (offset geri alınıyor).
- Araç: scenes/dev/porch_review.tscn (--time=HHMM --outage --fov --out); görüntüler docs/qa/porch-{day,night,outage,day-wide}.png.
  Kamera (7.5,1.55,12.62), +Z; peephole göz noktası için referans. 150°'de uç köşelerde siyah kalıyor; yuvarlak maske keser.
- tests/porch_test (12) Run-Tests listesinde. İzole tam koşu -AudioDriver WASAPI: 33 paket PASS.
Ziyaretçi figürü yerleşimi, balık gözü ve E/Escape akışı sende. Sıradaki işimi senin önerine göre alırım
(ImmersionBatchReview sırasında bana kalan: I-10 dekor; ya da I-11'in genişliği koruyan kompozisyon varyantı).
