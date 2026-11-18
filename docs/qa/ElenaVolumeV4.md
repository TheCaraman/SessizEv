# Elena V4 / kol-bacak ve farklı yüz

Sahip V3 gövde/yüz yerleşimini beğendi; farklı yüz, daha fazla geometri, çanta tutan fotoğrafın yürüyüşü bozmamasını istedi. Yeni clean-front.png aynı boyama dilinde farklı yüz ve iki kolu aşağıda, çantasız/askısız gövde gösterir. Gerçek üretim istemi texture-production.json içinde; kaynak görsel orijinal V3 altında korunur.

Gerçek kaynak: source_art/elena_v4/elena_v4.blend, assets/models/elena_v4/elena_v4.glb. Üretim tools/art/build_elena_v4.py, Blender4.5.15. 8360 üçgen/4244köşe/13kemik. Önceki2776triye göre ayrıntı ağırlıklı olarak uzuvlara eklenir. Kol/bacak25halka×24çevre segmentli sürekli yüzey;672köşe eklem çevresinde iki kemiğin ağırlığını taşır. Parmaklar ayrı hacim, avuçla aynı forearm kemiğine bağlı; parmak animasyonu yok. Çanta ve çok parçalı askı gövde resminden ayrılmış gerçek geometridir; omuzda taşınır, yürüyüşte resimdeki sabit el görünmez. Kollar küçük karşı salınım ve dirsek bükümü yapar. Bekleme/yürüyüş saniyede8poz, oyun FPS'si düşürülmez.

Sahne scripts/dev/elena_volume_review.gd içindeki model yolu V4'e bağlandı. Mevcut Camera/Skeleton/AnimationPlayer/UI yapısı korunur. A/D dönüş,Space walk/idle,F yakın plan,Esc çıkış. tools/Show-ElenaVolume.ps1 izole kopya açar; E:/TheQuietHours/DENE_ELENA_3D.cmd bu dalı çağırır. Aktif kampanya ve oyuncu kaydı değişmez. V3 çalışması kendi dalında korunur.

Test: tools/art/validate_elena_v4.py gerçek .blend'i açıp8pozda tüm köşelerin sonlu olduğunu, ağırlıkların toplam1olduğunu ve kenar gerilmelerini denetler. skin-validation.json:672karışık köşe,kenar oranı0.7043..1.2588 PASS. Bu denetim hiçbir kumaş kesişmesi olmayacağını matematiksel garanti etmez.

Native Godot4.7.2 Vulkan/Forward+1280x960:2açı+8yürüyüşpozu; Idle/Walk ve13kemik bulundu, aynıörnek aralığında poz tutuldu/sonrakiörnekte değişti(STEPPED_WALK_PASS), captureOK,exit0,stderrboş. runtime/elena-v4-front/angle.log/.err ve elena-v4-skin.log. docs/qa/elena-v4/walk-contact.png sekiz gerçek görüntünün inceleme levhası. İlk görünümde askı fazla açılıyordu; omuz/çanta bağlantısı yaklaştırıldı ve native kontroller tekrarlandı. Önizleme testinde yürüme yerindedir; tam ev rotası veya ayak yerleşimi testi değildir.

Açık sanat sınırı: ön yüz hâlâ kontrollü projeksiyon UV kullanır, arka/yan pigment kaynakları ön kadar ayrıntılı değildir; saç/omuz birleşimi ve bazı askı açıları rötuş ister. Tam parmak rig'i, yüz mimik animasyonu, üretim kampanyası entegrasyonu yok. Yeni yüzün nihai kabulü sahibi tarafından yapılmadı. Oda geometrisi bu karakter revizyonunda değiştirilmedi.
