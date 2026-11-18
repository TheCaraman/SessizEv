# Elena V6 — oran, saç, yürüyüş

Sahip V5 bacak/gövde uyumunu,saç oturmasını ve animasyonu reddetti. V6:üstbacak/baldır dolgunluğu,hem altında pelvisgeçişi; pantolonun gerçek baskıdokusundan tekrar eden küçük birpigmentörneği. Eski ayrık büyük arka saç kütlesi kaldırıldı; kafatasını izleyen yarımkabuk ve daha küçük ensebağı var. Ön yüzkimliği korunur.

Animasyon eski üçgensel sinüsbacak salınımı yerine2kemik analitikIK ile üretilir. Her ayak için yüzde62.5basış/yüzde37.5salınım; 28cmadım aralığı,6.4cmtepe kaldırma,küçük yanal/dikey kalça kayması,karşı kol ve dirsek hareketi. Ayağın basış yönü sabit,8poz/sn kesik stil korunur. Yerinde yürüyüş; ileri root-motion ve oyun içi yol takibi yok. Bütün ara değerler tools/art/build_elena_v6.py içinde gerçekkemik konumlarına işlenir; export için canlıIK bağımlılığı gerekmez.40.220tri13kemik.

Dosyalar: source_art/elena_v6/elena_v6.blend; assets/models/elena_v6/elena_v6.glb,dokular; tools/art/build_elena_v6.py vevalidate_elena_v6.py; scripts/dev/elena_volume_review.gd V6model yolu,yangörünüş --side,zeminvegölge. Eroot DENE_ELENA_3D.cmd bu dalın izole Show-ElenaVolume.ps1'ini açar. ÖncekiV5ve kampanya korunur.

Blendergerçekskin doğrulaması8poz/2880karışıkköşe:sonluverteks/normalizeağırlık/kenargerilme.40066..1.47227PASS. AyakIKhedefinin gerçek kemikbaşına maksimumhatası1.16e-7m. Destekteki gerçek ayakkabıköşelerinin en altZ değeri yerden ençok.000953m uzak:PASS. Bu yalnız örneklenmiş pozları kapsar; motor içinde engel/zeminadaptasyonu veya bütünkumaşkesişmelerinin yokluğu garantisi değildir. contact-targets.json,skin-validation.json gerçeksonuçlar.

Godot4.7.2Forward+1280x960:ön,yan,açılı3nativekoşu exit0/stderrboş;Idle/Walk8fps,13kemik,STEPPED_WALK_PASS. Ön ve yan8'erpoz kaydı; walk-side-contact.png ve walk-side.mp4 gerçekyakalamalardan türetildi. İlk görüntüde basışayakkabısı2cmfazlayüksekti; ayakvekalçahedefleri indirildi, gerçek taban testi eklenip nativeyenidençalıştırıldı. runtime/elena-v6-*.log/.err,elena-v6-skin-final.log.

Kontrol:A/Ddönüş,Spaceyürü/bekle,Fyüz,Escçıkış. Gerçekkişiselkayıt kullanılmaz. Görsel kabul hâlâsahibineait. Yan/arkaUV,omuz-kıyafet birleşimi,parmakrig'i,saçtelleri veçantaaskı rötuşu açık. Bu mekanik doğrulamalar animasyonun sanat kalitesini tekbaşına onaylamaz; tamkampanya regresyonu yapılmadı.
