# THE QUIET HOURS — Çalışma Kuralları

Bu dosya her oturumda yüklenir. Ayrıntılar `docs/` altındadır; çelişki olursa `docs/DecisionLog.md` kazanır.

## İletişim
- Proje sahibiyle **Türkçe** konuş. Oyun içi metinler İngilizce yazılır ve çeviri anahtarı kullanır.
- Bu ticari bir iş. Yaratıcı bir değişiklik, ekleme veya "daha iyi olur" fikri varsa **önce sor**, birlikte karar verilir. Küçük teknik ayrıntılarda makul varsayılanı seç ve DecisionLog'a yaz.
- Zayıf tasarım kararlarını açıkça eleştir.

## Dürüstlük
- Var olmayan sahne, varlık, ses veya sistemi var gibi anlatma.
- Motor içinde çalıştırılmamış kodu "test edildi" diye sunma.
- Tamamlanmış diye sunulan kodda "gerisini buraya yaz" türü boşluk bırakma.

## Motor
- Godot **4.7.2 stable**, standart sürüm, GDScript (tipli), Forward+.
- 4.7 API ayrıntılarını ezbere değil, resmi belgelerden doğrula.

## Değişmez tasarım kuralları
- FPS dövüşü, nişan alma, açık dünya, crafting ağacı, çok oyunculu yok.
- Enfeksiyon kampanya başında atanır; sonradan sessizce değişmez. Olağan temasla bulaşmaz.
- Lily Reed öldürülemez, ekranda şiddet görmez, her zaman sağlıklıdır (K-001, K-002).
- Her kanıtın simülasyonda gerçek bir nedeni vardır. Enfekte yoksa enfekte fail uydurulmaz.
- Hiçbir olay ölü, kovulmuş veya yok bir NPC'ye ihtiyaç duymaz.
- Oyuncu izlenebilir bir neden olmadan enfekte olmaz.
- "No, I'm Not a Human" yalnızca ton esinidir; diyalog, karakter, sahne, arayüz veya varlık kopyalanmaz.

## Yapı
- Otomatik yüklenenler yalnızca gerçekten global olanlardır: `EventBus`, `InputSetup`, sonra `GameState`, `SaveManager`, `Settings`, `AudioManager`.
- Diğer sistemler `Campaign` kök düğümü altında sahne-yereldir.
- İçerik (NPC, olay, kanıt, diyalog) veri dosyalarındadır; koda gömülmez.

## Her görev teslimi
Hedef · dosyalar ve yollar · tam kod · düğüm hiyerarşisi · gereken kaynaklar · editör adımları · beklenen davranış · test · sık hatalar · bitti tanımı · sonraki bağımlılık.
