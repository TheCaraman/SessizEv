# Elena V5 — yüzey ve hacim ayrıntısı

Sahip V4 karakterini hâlâ aşırı düşük poligonlu buldu. Kaynak mesh 8360 yerine38044üçgen,19084köşe. Catmull-Clark gerçek dış hatları değiştirir; baş2seviye,diğer yüzeyler1seviye. Yüzey iyileştirmesi iki kemik ağırlıkları atandıktan sonra uygulanır; ağırlıklar interpolasyonla korunur. Dirsek/diz kıyafet sıkışmasına hacim varyasyonu eklendi. Boyun ve gövde tek sürekli profil yapıldı; ayrı parçaların yaka açıklığı engellenir. Askı segmentlerine subdivision uygulanmaz; ayrı kapalı segmentlerin uçları küçülüp kopuk görünmesin. Görsel inceleme için otomatik mesh LOD kapalıdır; gerçek performans benchmarkı yapılmadı. KampanyaLOD politikası kararlaştırılmadı.

Dosyalar: tools/art/build_elena_v5.py,validate_elena_v5.py; source_art/elena_v5/elena_v5.blend; assets/models/elena_v5/elena_v5.glb ve gömülüresimlerin Godot çıkarımları; scripts/dev/elena_volume_review.gd V5yolu ve --close seçeneği. Ekstra sahne veya autoload gerekmez; mevcut izole model önizlemesi kullanılır. Blender4.5.15LTS/Godot4.7.2stable.

Blender doğrulaması:8poz,2880karışık kemikköşesi,normalizeağırlıklar; kenaroranları.70899..1.25532PASS. NativeForward+1280x960:ön/yan/yüzyakınplan,sekizyürüyüşpozu;13kemik/Idle_8fps/Walk_8fps,STEPPED_WALK_PASS ve capturesOK;3koşu exit0/stderrboş. runtime/elena-v5-{front,angle,close}.log/.err ve elena-v5-skin-final.log. Ekranlar docs/qa/elena-v5. İnsan tarafından oynama veya tümkampanya regresyonu iddiası yok.

E:/TheQuietHours/DENE_ELENA_3D.cmd V5başlatıcısına bağlanır; A/Ddönüş,Spaceyürü/bekle,Fyakınplan,Escçıkış. Gerçek kampanya/oyuncu kayıtları değiştirilmez. ÖncekiV4dalı korunur. Yeni yüz ve renk aynıdır;8poz/sn kesik hareket korunur,renderFPS'si düşürülmez.

Açık sınırlamalar: önprojeksiyonUV,saçın blok kütlesi,yan/arka doku,omuz veaskı bağlantısı hâlâ elrötuşu ister. Üçgen sayısının artması bu sanat sorunlarını tek başına çözmez. Kapsam yüzey/hacim revizyonu ve izole modeldir; nihai sahip kabulü ve kampanya entegrasyonu yok.
