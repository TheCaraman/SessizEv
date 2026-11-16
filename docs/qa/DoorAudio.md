# Kapı sesi ilk uygulama

DoorAudio gerçek HouseBlockout sahnesine bağlandı. Yerel sentez sabit tohumla özgün mono üç vuruş üretir; kampanya tohumu/enfeksiyon durumunu değiştirmez. Ön kapı konumu HouseLayout'tan bulunur. Görsel bildirim korunur.

11 paket toplam 2404 denetim geçti. Ses paketindeki 10 kontrol: deterministik dalga, kampanya değişmezliği, mono/süre/oran, sıfır olmayan ve kırpılmayan sinyal, kapı konumu, bir kez geliş, yinelenen sinyal, kayıttan yükleme, ziyaretçinin gitmesi ve sonraki ziyaretçi. Ek dışa aktarım çağrısında 11 kontrol geçti ve door-knock-placeholder.wav üretildi.

Bu doğrulama dalga verisi ve olay entegrasyonunu kapsar. Gerçek hoparlör/kulaklıkla dinleme, nihai tını onayı, bütün koridorda yön tayini, duvar sönümlemesi ve farklı aygıtlar denenmedi. 2D oda akustiği ve ses ayarları açık. Örnek geçici olarak docs/qa altında tutuluyor; ürün aynı sentez kodunu kullanıyor.
