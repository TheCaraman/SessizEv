# ROOMS-002 gerçek GPU incelemesi — ana sürüme alınmıyor

Zaman öğreticisi ana Codex kaynak incelemesinden sonra dış30paket WASAPI kapısını geçti (96ff9ca; campaign101). Ayrıca aynı izole test kopyasında Forward+/GTX1080Ti ile gerçek GPU görüntüleri alındı; kullanıcı verisine doğrudan sahne koşturulmadı. EN/TR zaman ipucu görüntülendi. Kaynaklar runtime/guidance010-{en,tr}.png ve runtime/room-review010-tr.png; capture stdout RELEASE CAPTURE: PASS, stderr boş.

ROOMS-002'de somut iki sorun var: (1) 1080p'de Shelter management başlığı y=üst kenarda HUD gün/saat yazısıyla üst üste geliyor; (2) oturumda EN'den TR'ye geçince satırların/metinlerin bir kısmı TR olurken statik başlıklar Resident/Bed/Job/Reports İngilizce kalıyor. Yeni dikey sütun başlıkları ve bütün ekran genişliğindeki seçimler de okunurluğu düşürüyor. Alt onaylar kaydırma gerektiriyor; bunun klavye odağı ve720p'de ayrıca doğrulanması gerekli.

Bu nedenle e065d7e oda ekranını henüz aktif sürüme almıyorum. Zaman ipucu96ff9ca'nın yalnız kendi diff'i 0.1.9 tabanına cherry-pick edilerek dev-0.1.10 hazırlanıyor; ayrı tam kapı sonucu bekleniyor. Trial94feb4d ikinci kez merge edilmeyecek. Zaman yönlendirmesi yayımlanınca strings.csv sahipliği bırakılacak.

ROOMS-002 sonraki küçük iş: başlığı HUD saatinin altına taşı/uyumlu üst boşluk ver; dil değişiminde bütün statik metinleri yenile; önizleme ve düzenle/uygula/iptal eylemlerini aynı bakışta daha anlaşılır yerleştir. Fiziksel plan/süre/save mantığını bu görsel düzeltmeye karıştırma. Merdiven I-03 Claude'un ayrı teknik ilk işi olarak kalır; bu belge onun başladığı iddiası değildir.
