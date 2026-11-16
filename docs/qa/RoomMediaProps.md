# İlk odada TV/radyo katmanı

Amaç: onaylanan ilk odanın mevcut yayın eylemlerine görünür eşya karşılığı eklemek. Arka plan PNG değişmedi. Özgün, saydam 1417×1110 media_console.png üretildi; köşe alfa 0 doğrulandı. TV/radyo aynı dolap sprite'ında, ekran kapalıdır; hareketli yayın üretilmedi.

RoomView → Props:RoomProps düğümü resources/items/room_props.json içindeki normalize yerleşimi kullanır. Arka planın en-boy sığdırması ve kenar boşlukları hesaba katılır; oran bozulmadan slotun altına hizalanır. Oda açılınca veri yüklenir; çizimde tekrar dosya aranmaz. Figürler ayrı üst katmanda kalır. Oda değişince eski eşyalar temizlenir; UI ışık tonundan etkilenmez, eşyalar oda ışığına uyar.

Bağımlılıklar: scripts/art/room_props.gd; resources/items/room_props.json; assets/props/media_console.png ve motor import'u; scripts/ui/room_view.gd. Godot içe aktarması dışında ek kurulum yok. Normal kampanyada oturma odası kapısını aç; TV/radyo görülmeli, mutfağa geçince önceki eşya görünmemeli. Veri yolu eksikse Missing room prop hatası verir; yanlış resimle sessizce devam edilmez.

İzole gerçek 1080p kampanya görüntüsü RoomMediaProps-1080.png incelendi. İlk oda eylemleri ve eşya yerleşimi görünür. Presentation paketine eşyanın oturma odasında yüklenmesi/diğer odada temizlenmesi için iki denetim eklendi. 12 paket toplam 5323 denetim geçti. Fiziksel fareyle etkileşim, animasyon ve nihai ses bu teslimde sınanmadı.

Sonraki bağımlılık: ilk odanın ayrı gece/elektrik katmanları ve yeni üsluplu karakterler. TV ekranının görsel olarak yayın göstermesi henüz uygulanmadı. Kesintide gerçek TV eyleminin engellenmesi mevcut mekaniktir; sprite'ın kapalı ekranı tek başına güç simülasyonu sayılmaz.
