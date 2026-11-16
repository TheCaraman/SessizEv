# Koridor referans incelemesi ve ikinci düzeltme

2026-11-16 — CORRIDOR-REFERENCE-002. Kullanıcı önceki koridoru ve oda resminin kapıdan sonra büyümesi hissini reddetti; mevcut teslim nihai sanat kabulü değildir.

## Kaynak ve gözlem

[Resmî Steam sayfası](https://store.steampowered.com/app/3180070/No_Im_not_a_Human/) ve [resmî yayıncı](https://www.criticalreflex.com/no_im_not_a_human) incelendi. Steam'in resmî ekran görüntüleri arka plan tarayıcısında görüntülendi; oyun içine indirilmedi/kopyalanmadı.

Özellikle Steam koridor görseli `ss_de34f633e34a6b1b22ac27e785bd3550a2977949` pencere/jaluzi yönlü ışığı, eskimiş ev yüzeyleri, kitaplı küçük dolap, ahşap kapılar, halı ve okunabilir orta tonlar gösterir. Dış kapı görseli `ss_9fa566...` sokak/ağaç/yapı arka planıyla dış dünyaya bağlanır. Pembe oda görseli `ss_20a151...` açık sıva ve krem perdelerin her şeyi siyaha gömmeden kullanılabildiğini gösterir. Bunlar görsel yorumdur; oyunun motoru, shader tekniği veya odalarının gerçek üretim yöntemi hakkında doğrulanmış iddia değildir. Referansın kapı geçişinin tam hareketi bu araştırmada kare kare doğrulanmadı; bizim geçişimiz özgün teknik çözümdür.

## Uygulama

- Alt girişte 1,2 m dar açıklık 3 m oldu; ana dolaşım zaten 3 m.
- Her iki katta merdivene bakan tam duvar yerine 1,1 m fiziksel parapet ve ahşap üst başlık; görüş açılır, güvenli sınır kalır. Havada kalan fotoğraflar kaldırıldı, saat masaya indi.
- Girişte ikinci gerçek pencere; üst koridor sonunda gerçek ön cephe penceresi. Üst depo doğuya daraltıldı; penceresiz. Güncel ölçüler HousePlan ve HouseLayout'tadır.
- Camın arkasındaki opak ışık kartı kaldırıldı. Derinlik/paralaks veren erişilemez bahçe/çit/yol geometrisi ve çizimsel komşu ev/ağaç fonu oluşturuldu. Gece rengi mevcut saat çarpanından gelir; elektrik kesintisi dış ışığı kapatmaz.
- Daha açık sıva/tavan, boyalı ahşap kapı dokusu; turuncu lamba baskısı, gren ve kenar karartması azaltıldı. Pencere aralığı genişletildi, soğuk yeşil ışık açısı büyütüldü. Piksel çözünürlük düşürme yok.
- Kapıda tam oda resminin dar bir kartta gösterilmesi kaldırıldı. Fiziksel kanat 0,55 sn açılır; 0,12 sn kararma; oda sabit ölçekte 0,25 sn ortaya çıkar. Koridor ile tam ekran oda birbirine saydam biçimde bindirilmez. Geri çıkışta kanat sıfırlanır; ters kapanış animasyonu henüz yok.

## Sınırlar ve devam

Dış çevre: özgün image_gen çizimi assets/exterior/briar_glen_street_day.png, önde 3D yol/bahçe/çit. Nihai dış sanat kabulü değildir; farklı kat görüşleri aynı uzak fonu kullanır. Prompt ve kaynak docs/art/prompts/exterior_vista.json içinde saklanır. Koridor ev hacmi/okunabilirliği yönünden iyileştirildi; referanstaki bozuk çizim dili ve özgün eşya ayrıntısı tamamen karşılanmış sayılmaz. Küçük eşyalar ve resimler hâlâ prototip düzeyindedir. Fiziksel kullanıcı girdisiyle baştan sona elle test yapıldığı iddia edilmez. Bu kayıt önceki tasarımın sahibi tarafından kabul edildiği anlamına gelmez.

## Dosyalar, kurulum, beklenen davranış

scripts/house/{house_layout,house_builder,corridor_dressing,room_door,exterior_vista}.gd; scripts/art/{house_materials,texture_generator}.gd; scripts/dev/{house_blockout,corridor_review}.gd; scripts/ui/room_view.gd; shaders/retro_post.gdshader. Yeni autoload/eklenti yok. HouseBuilder → ExteriorVista; her kapıda CanvasLayer → ColorRect geçiş örtüsü; RoomView arayüz kökünde ayrı geçiş örtüsü. Godot 4.7.2'de projeyi import et; ana sahneyi veya scenes/dev/corridor_review.tscn aç. --capture-corridor, --foyer, --upper, --night görsel test seçenekleridir. E kapıyı açar; E/Esc odadan çıkar. Oyun zamanı bu geçişte tüketilmez.

Test: tools/Run-Tests.ps1; gerçek GPU koridor/foyer render'ları; tests/door_transition_test.tscn -- --capture-door. Yaygın sorun: eski çalışan oyun süreci yeni dosyaları almaz, oyunu yeniden başlat. Referans estetiğinin tam kabulü açık olduğu için görsel görev bitmiş sayılmaz. Sonraki bağımlılık özgün çizimsel dış çevre ve eşya/yüzey çalışması, ardından sahibin mekân incelemesidir.

Doğrulama: 22 paket/6063 denetim PASS. Gerçek GPU kapı 9 ve oda ışığı 64 denetim PASS; koridor alt/üst, giriş ve gece renderları incelendi. Son çizimsel fon sonrası odaklı power/presentation/layout koşuları ayrıca kaydedildi. Kesintide tesisat lambaları sönük görünen üç utility varyantı da aynı teslimde tamamlandı.

Odaklı son koşu: power669, presentation88, layout97 PASS. Presentation kapanışında AudioStreamWAV/AudioStreamPlaybackWAV için iki ObjectDB uyarısı gözlendi; verbose ile türleri doğrulandı. İşlevsel denetimler geçse de bu ses yaşam döngüsü uyarısı açık hata olarak sonraki işe bırakıldı; uyarısız test iddiası yok. Gece dış fonun alt parlaklık sınırı 0,18; pencere ışığı enerjisi eski 0,08 gece faktörünü kullanmayı sürdürür.
