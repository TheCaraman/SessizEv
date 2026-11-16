# THE QUIET HOURS — Ses yönü

## Durum

Üretim belgesi başlangıcı; nihai ses bankası değildir. İlk uygulanmış ses kapı çalma geçicisidir. Müzik, konuşma kayıtları, ev ambiyansı ve diğer foley henüz üretilmedi. Oyun bu alanlarda tamamlanmış sayılmaz.

## Yön

Sessizlik, evin gündelik sesleri ve yönü anlaşılabilen sınırlı olay sesleri temel alınır. Sürekli korku müziği veya rastgele yüksek ses sıçratmaları kullanılmaz. Referans oyunların kayıtları/müziği kopyalanmaz. Sağlıklı ve enfekte kişinin kapı sesi aynı kalır; ses kimlik veya teşhis işareti değildir.

## İlk uygulanmış işaret: kapı

`scripts/audio/door_audio.gd`, `scenes/main/house_blockout.tscn` altındaki `DoorAudio` düğümünde çalışır. AudioStreamPlayer3D konumu HouseLayout içindeki ön kapıdan türetilir. Kaynak özgün kodla üretilen 22.05 kHz mono 16-bit kısa üç vuruştur; taşınabilir geçici foley olarak işaretlidir. Nihai kayıtta ahşap kapı rezonansı, oda akustiği ve doğal vuruş farkları hedeflenir.

Mevcut ziyaretçi değişiminde bir kez çalar. Aynı bildirimin tekrarı çalmaz; kapıdaki kişinin kayıttan yüklenmesi yeni geliş sayılmaz; ziyaretçi gidince ses durur. Kampanya rastgelelik durumuna dokunmaz. Yazılı kapı bildirimi korunur; ses kritik bilginin tek kanalı değildir. Yürünen koridorda yönlüdür; 2D oda akustiği ve duvarlardan gerçekçi sönümleme henüz uygulanmadı.

## Sonraki üretim bankası

| İşaret | Konum/koşul | Son üretim hedefi |
|---|---|---|
| Ahşap adım | Oyuncu adımı, kat/yüzey | Birkaç özgün varyant, tekrar yorgunluğu azaltılmış |
| Kapı mandalı | Gerçek etkileşim | Kısa, ölçülü; kullanılmayan kapıdan ses yok |
| Radyo | Radyo açık/inceleme | Özgün statik, kritik metin altyazılı |
| Elektrik kesilmesi | Gerçek güç olayı | Hafif röle/ampul kesilmesi; büyük patlama yok |
| Rüzgâr ve tesisat | Ev katmanları | Düşük seviyeli, korku olayı taklidi yapmayan |
| Sakin faaliyeti | Gerçek iş/konum | Program ile tutarlı; olmayan sakin sesi yok |

Nihai bankada master/music/effects/dialogue/ambience ayrı kontroller, duraklatma ve erişilebilir ses göstergeleri gerekir. Bu kontroller henüz yapılmadı. Lisans/kaynak ve dinleme onayı her teslimde kaydedilir.
