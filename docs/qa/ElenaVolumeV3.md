# Elena Blender V3 — hacimli karakter denemesi

Sahip 2026-11-18 son görselini esas aldı; kontrollü düşük poligon ve düşük kare hızlı analog korku hareketi istedi. Bu karar ekran pikselleştirmesine izin sayılmaz.

Gerçek çıktılar: source_art/elena_v3/elena_v3.blend; assets/models/elena_v3/elena_v3.glb, owner-reference.png ve pigment PNG'leri. 2776 üçgen,13kemik; Idle_8fps ve Walk_8fps. Kaynak Blender4.5.15 LTS ile tools/art/build_elena_v3.py çalıştırılarak yeniden üretilir. Python modülleri Blender'ın kendi bpy/mathutils paketleri; harici Python gerekmez. Kaynak .blend import engellemesin diye source_art/.gdignore altında tutulur. glTF içine dokular gömülür.

Teknik: baş/gövde/kıyafet kapalı 3D ağlar, ön yüz referans projeksiyonu, arkalar gerçek taşınabilir pigment dokusu. Yalnız ön fotoğraf düzlemi veya billboard değildir. Önden görünüş referans rengini korur; yan UV gerilmesi, saç/omuz birleşimleri, elin ön dokuda sabit görünmesi, pantolon kıvrım eksikliği ve rijit eklemler açık kusurlardır. Tam üretim kalitesi veya sahip kabulü iddia edilmez. Koşulsuz uzun yürüyüş rotası ve kampanya entegrasyonu yok; animasyon yerinde döngüdür.

Godot4.7.2 nativeVulkan/Forward+1280x960 iki açı: docs/qa/elena-v3/godot-front.png ve godot-angle.png. İki koşuda Idle/Walk bulundu,13kemik doğrulandı; 0.015/0.045sn aynı bacak rotasyonu,0.19sn farklı rotasyon (STEPPED_WALK_PASS), görüntü kaydı OK,exit0,stderr boş. Gerçek kullanıcı verisi kullanılmadı. Bu insan tarafından tuşların denenmesi veya tam kampanya regresyonu değildir. İlk import .blend motor ayarı eksikliğiyle durdu; .blend source_art'a ayrıldı. İlk native görünümde Blender Noise düğümleri glTF'ye taşınmayıp beyaz kaldı; gerçek bitmap pigmentleriyle düzeltildi, son ekranlar bunları içerir.

Deneme: tools/Show-ElenaVolume.ps1. A/D yörüngede döndürür, Space yürüyüş/bekleme, F yüz yakın planı, Esc çıkar. Ayrı geçici kopya ve TheQuietHours-Tests kullanıcı alanı kullanılır. Aktif kampanya launcher'ı değiştirilmez. Sahne: ElenaVolumeReview/{importedElenaRig+Skin,WorldEnvironment,DirectionalLight3D,Camera3D,CanvasLayer/Label}; ek autoload yok.

Bitiş: hacimli kaynak/export/iskelet/iki kesik animasyon ve doğrulanmış motor önizlemesi mevcut. Sonraki sanat bağımlılığı bu modelin omuz/saç/eller/yan doku rötuşu ve sahip görsel değerlendirmesi. Odanın yaşanmışlığı ayrı iş olarak açık. Özgün referans kullanıcının sağladığı dosyadır; dışarıdan karakter modeli alınmadı.
