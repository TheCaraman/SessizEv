# Motor içinde atmosfer karşılaştırması

Güncelleme: sahip çizimsel yönü ve ilk oda entegrasyonunu onayladı. Araç artık arşivlenmiş eski oda ile gerçek üretim yolundaki yeni odayı karşılaştırır; aşağıdaki onay-bekleme ifadeleri önceki teslimin tarihsel notlarıdır.

`scenes/dev/atmosphere_review.tscn` ayrı inceleme sahnesidir. Normal başlangıç sahnesini veya üretim arka planlarını değiştirmez. Kampanya başlatmaz, kaydetmez, kişi kabul etmez. Mevcut RoomView arayüzünün arka planında iki görseli aynı kadrajda gösterir.

Godot editöründe bu sahneyi açıp F6 ile çalıştır. 1/mevcut, 2/öneri düğmeleri veya tuşlarıyla değiştir; Escape aracı kapatır. Başlangıçta öneri gösterilir. Türkçe açıklamalar geliştirme aracına aittir; ürün menüsü değildir.

İzole proje kopyasında `--resolution 1920x1080 res://scenes/dev/atmosphere_review.tscn -- --capture-atmosphere` iki gerçek motor görüntüsü üretti. Önerilen görüntü incelendi. Görseller docs/qa/atmosphere-review-{current,proposed}.png içinde. Dosya varlığı ve render doğrulandı; fiziksel fare/tuşla kullanım henüz denenmedi.

Mevcut gerçekçi oda ile ART-REV-003 çizimsel önerisi karşılaştırılır. Öneri nihai sanat onayı değildir. Bu araç yalnızca oda çerçevesi ölçeğini gösterir; aday karakter, gece varyantı, yeni oda etkileşimi veya nihai koridor malzemesi içermez. Sahibin değerlendirme kartı açık; cevap gelmeden diğer 12 oda yeniden üretilmez.
