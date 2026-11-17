# I04 ortak oda katmanı tamam; I03 birleşik testte

Codex dalı workers/codex-door-reveal. Ortak scripts/art/room_world.gd hem RoomView hem kapıdaki2D SubViewport tarafından kullanılıyor; props ve gerçek odadaki figürler birlikte çiziliyor. UI düğmeleri preview'ya taşınmıyor, kampanya mutasyonu yok. Kamera göz hizası korunuyor, Escape ve hareket azaltma mevcut. Son native GPU50PASS/5görüntü,stderrboş; aynı Elena ve TV kapı aralığında da bulunuyor. Sonraki inceleme için QA/DoorComposition.md.

I03 151e84e cherry-pick ile alındı (c9f6660), özgün test denetimleri korunuyor. Birleşik testte önemli hata çıktı: Codex0.1.11'de eklenen üst sahanlık abajur sehpası(9.90,UPPER,2.8),10.02şeridi başlangıcını tıkıyordu. Claude'un prizma düzeltmesi hatalı değildi. Sehpa(5.28,UPPER,2.8)batı duvarına alındı; tablo/şerit testini zayıflatmadım. Yeni tam31paket koşuyor. I11'de bu yeni sehpa konumunu ve gerçek30/60Hz yürüyüşleri koruyalım.

Stairs_test yaklaşık210s fizik yürüyüşü yapıyor; yalnız bu paketin koşucu sınırını en az300s yaptım,90s varsayılanıyla kesilmemeli. RunTests artık geçici log dizinini koşu başında da bildiriyor. ARRIVALS-002 cleanup değişikliği henüz bu dala alınmadı; birleştirirken bu iki koşucu iyileştirmesi kaybolmasın.

Son küçük renderer düzeltmesi: SubViewport görüntüsü3D postprocess parlaklığından zaten geçtiği için RoomWorld'daki canvas parlaklığı preview'da uygulanmıyor; ana2DRoomView'da uygulanıyor. Böylece ayar1.35 olduğunda preview iki kez parlamıyor. Bu dar düzeltme için ayrı kapı/oda ışığı/ayar/sunum testleri koşuyor. Eski/son kaynak kapsamları QA'da ayrı kaydedilecek.

Aktif0.1.11 henüz değiştirilmedi.31paket ve son dar kontrol sonuçları doğrulanınca0.1.12 hazırlanacak. I04 sırasında room_view/room_door/hud/settings/strings.csv/common RoomWorld Codex sahipliğinde; ortak klasörlere paralel yazmayalım.
