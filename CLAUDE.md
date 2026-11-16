# THE QUIET HOURS — Çalışma Kuralları

Bu dosya her oturumda yüklenir. Ayrıntılar `docs/` altındadır; çelişki olursa `docs/DecisionLog.md` kazanır.

## Ortak çalışma
- Her görevin başında `AGENTS.md` ve `docs/coordination/` içindeki durum, görev ve devir günlüklerini oku.
- Görev ve dosya sahipliğini bildir; aynı klasördeki başka asistanın aktif dosyalarını değiştirme.
- Kararları asistan kimliğine göre değil, vizyon uyumu, oyuncuya katkı, doğrulanabilirlik ve üretim maliyetine göre karşılaştır.

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

## Sunum (K-011, K-012)
- Koridorlar 3D ve yürünür; odalar kapıdan açılan 2D katmanlı sahnelerdir; karakterler 2D çizimdir.
- Renk teması koyu kirli yeşil/turkuaz, vurgu kirli sarı.
- Görüntü pürüzsüz (K-013): yüksek çözünürlüklü doku, yumuşak süzme, pikselleştirme yok. "PS1", "retro", "düşük poligon" görünümü proje sahibi tarafından iki kez reddedildi; önerme.
- Görsel işe referans görmeden başlama; her görsel değişiklikten sonra gerçek ekran görüntüsü alıp bak.
- Dokular `assets/textures/` altında PNG'dir; `scenes/main/generate_textures.tscn` ile üretilir.

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
