# NIGHT-001 ilk kod adımı

NightTimeline saf zaman/enerji hesabı olarak scripts/time/night_timeline.gd içinde oluşturuldu. Veri resources/events/night_watch.json içinde. Global kampanyayı değiştirmez; gelecek sahne-yerel NightSession denetleyicisinin hesabıdır. Ürün UI'sine henüz bağlanmadı ve kayıt sürümü henüz v5'e yükseltilmedi.

23:00–ertesi 07:00 mutlak dakika hesabı, 01/03/05/07 sınırlarının bir kez çözümü, kısmi uyku/uyanıklık enerjisi, atomik JSON geri yükleme ve bir kez sabah çözüm hakkı var. Başlangıç ve sınırların tekrar çağrılması tüketimi yeniden üretmez. Hatalı kaydı onarmak için veri uydurulmaz.

Test: 2 uyku modunun her 480 dakikasında JSON turu, sınır ve enerji karşılaştırması; karma gece ve bozuk kayıtlar. NightTimeline 2905 denetim, tüm 12 paket toplam 5321 denetim geçti. İlk testte parantez hatası düzeltildi; ardından JSON'dan gelen sınır sayılarının float/int karşılaştırması düzeltildi. Başarısız denemeler geçerli teslim sayılmadı.

Sonraki zorunlu bağımlılık: GameState v5, gece yarısı saati/fazı, sahne-yerel oturum, gerçek uyku/nöbet seçenekleri ve enerji/sabah tek çözümünün entegrasyonu. Bu teslim oynanabilir sekiz saatlik nöbet değildir. Görsel yön onayı geldiği için ilk oda entegrasyonu bu adımdan sonra önceliklendirildi.
