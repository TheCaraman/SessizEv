# IMMERSION-I04 — kapı aralığı prototipi; yayımlanmadı

Taban0.1.11/11ef493, çalışma dalı codex/door-reveal. Hedef eski siyah recess ve ikinci siyah UI kapağını kaldırmak; gerçek fiziksel kapının arkasından güncel oda görüntüsüne yaklaşmak. Bu bir ara kaynak teslimidir; aktif masaüstü sürümü0.1.11 olarak kaldı.

## Gerçek dosyalar ve akış

- scripts/house/room_door.gd:0.55s fiziksel kanat,0.30s isteğe bağlı kamera yaklaşması, ücretsiz RoomView devri. Global kamera transformu saklanır; devir/iptal/temizlemede geri yüklenir. Escape animasyonu öldürür ve sonradan odayı açmasını engeller. Time_changed görünür önizlemeyi günceller.
- shaders/door_room_preview.gdshader: QuadMesh üzerinde SCREEN_UV ile nihai ekranla aynı koordinatlı oda resmi; perspektifte büyüyen küçük oda kartı yok. RoomVisuals gün/saat/güç varyantı ve Settings.world_tint kullanılır.
- scripts/ui/room_view.gd:_reveal_from_door ikinci siyah kapağı açmaz. hud.gd kapı geçişinde saat dışındaki kaplamaları gizler.
- scripts/core/settings.gd, scripts/ui/settings_view.gd, localization/strings.csv: bağımsız camera_motion0/1 tercihi ve EN/TR etiketler. Mevcut ayarlar dosyasına kaydolur; kampanya kayıt şeması değişmez. Ayar kapalıysa kanat animasyonu sürer, kamera yaklaşmaz.
- tests/door_transition_test.gd, interaction_test.gd, settings_test.gd: mevcut kontroller korunur; süre, texture, kamera dönüşü, Escape, hareket azaltma, gerçek Tab dolaşımı ve ayar yerleşimi sınanır.

Hierarchy: RoomDoor → Hinge → DoorLeaf; RoomDoor → RoomThreshold(QuadMesh + ShaderMaterial). Oyuncu CharacterBody koridorda kalır; yalnız Head/Camera3D geçici yaklaşır. Kapı önce EventBus.door_transition_changed(true), sonra room_view_requested(room_id), sonra transition_changed(false) üretir. Hareket/kamera kontrolü mevcut sahne dinleyicilerindedir. HouseBuilder/HouseLayout ve Claude I03 dosyalarına yazılmadı.

## Doğrulama ve sorunlar

Yeni yaklaşma süresi0.85s olduğu için eski interaction testi0.833s'de sonuç bekleyip başarısız oldu. Sonuç kontrolleri silinmeden kare zamanları geciktirildi. Sonra kamera tercihi eklenince Tab testi6girdiyle7kontrolü ziyaret etmeye çalıştı; döngü gerçek kontrol sayısına düzeltildi. Bunlar gizlenmiş PASS değildir.

Son güncel seçili kapı: settings100/door23/interaction14/WASAPI audio35 PASS; runtime/door-reveal-focused-tests.log. Kamera tercihi öncesi tam30paket geçti (door-reveal-final-tests.log); son tercihten sonra tam kapı henüz tekrar edilmedi. Sonraki kaynak değişiklikleriyle birlikte tam kapı zorunlu.

GPU: Forward+/GTX1080Ti,1920x1080. E:/TheQuietHours/runtime/door-gpu-review açık izolasyonlu proje/userdir; normal oyuncu verisine yazılmaz. Son native door_transition26kontrol PASS (23+3capture),stderrboş. Açılış/ara yaklaşma/oda devri PNG'leri bu teslimde saklandı. Kod değiştirilerek görüntü rötuşlanmadı. Bir C:Temp kopyası başka okuma öncesi kaybolduğundan kalıcı QA kopyasına geçildi; neden kesinleştirilmedi, Claude'a ortak kopyaları silmemesi bildirildi.

## Yayımdan önce açık işler

ÖNEMLİ: önizleme şimdilik yalnız arka planı gösteriyor. RoomView'daki ayrı RoomProps ve NPC figürleri ancak tam ekran devirde ekleniyor; bu görsel sıçramadır. Bunu tamamlanmış kesintisiz geçiş saymıyorum ve ana sürüme almıyorum. Sonraki adım: ortak oda dünya katmanı (arka plan + prop + gerçek uygun sakinler), hem RoomView hem önizleme tarafından kullanılsın. Gizli enfeksiyon bilgisi ve UI düğmeleri önizlemeye taşınmasın. Eşyalar/NPC'ler iki ayrı mantıkta çoğaltılmasın; tek konum/izolasyon/ölüm kuralları korunsun.

Ardından açı/iki kapı yönü, farklı FOV/parlaklık, gün/gece/kesinti, hareket azaltma, Escape ve hızlı yeniden etkileşim GPU/işlev testleri; güncel tam regresyon; ondan sonra aktif sürüm kararı. Şu aşamada yeni karakter sanatı, Gün5, kapı deliği veya merdiven teslimi yok. Kaynakları editörde açmak için ek kurulum gerekmez; mevcut Godot4.7.2 proje yeterli. Testler yalnız izolasyonlu Run-Tests.ps1; açık ana sahneye test kurulumuyla kullanıcı verisi yazılmaz.
