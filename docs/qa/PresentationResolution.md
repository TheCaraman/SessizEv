# Gün 3 oda arayüzü — çözünürlük ve dil

Gerçek HouseBlockout sahnesi SubViewport içinde 1920×1080 ve 2560×1440 boyutlarında oluşturuldu. İngilizce/Türkçe, yedi tesisat eylemi ve uzun sigorta kartı anlatımıyla sınandı. Düğme, anlatı ve çıkış ipucu sınırlarının ekran içinde kaldığı doğrulandı. Bu mevcut metinleri kapsar; gelecekteki her çevirinin sığacağı garantisi değildir.

Yeni presentation_test paketi 48 denetim içerir. Pencereli Forward+ çalışmada dört PNG ayrıca kaydedildi (52 kontrol). Görseller incelendi: güncel eylemler tek satıra sığıyor, uzun anlatım 1080p'de satıra bölünüyor, ipucu görünür. Burada yeni responsive düzen yazılmadı; mevcut HFlowContainer davranışı sınandı.

Kontrol sırasında HUD saatinin dil değişiminde eski dilde kaldığı görüldü. hud.gd çeviri değişimi bildiriminde saat, gün başlığı ve olağan ziyaretçi altyazısını yeniler. Aktif serbest metin bildiriminin dilini geriye dönük çevirdiği iddia edilmez. İlk yeni testte Hud düğümünün adı yanlış büyük harfle yazılmıştı; sahneye uygun adla düzeltildi.

Görseller mevcut geçici gerçekçi oda sanatını gösterir; sahibin yeni çizimsel atmosfer yönünün kabulü değildir. Fareyle tam oynama, bütün odalar, ekran oranları ve metin boyutu seçenekleri bu testin kapsamı dışında.

Çalıştırma: tools/Run-Tests.ps1; pencereli görüntü için izole test kopyasında Godot ile res://tests/presentation_test.tscn -- --capture-presentation.
