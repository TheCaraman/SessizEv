# Koridor — ilk plan ve malzeme yeniden yapımı

## Sahip talebi ve uygulanan değişim

Sahip koridoru dar, atmosferden ve örnek çizim dilinden uzak buldu; tamamen yeniden yapılmasına izin verdi. Bu ilk yapısal/görsel geçiştir, nihai sanat kabulü değildir. HouseLayout'ta ana hol ve üst koridorun dolaşım şeridi x=4..7, genişlik 3m oldu (önce 5..7, 2m). Batı odaları 4m genişliğe çekildi; mutfak/landing/vestibule/izolasyon/storage sınırları buna göre güncellendi. Dış 12×10m sınırı ve merdiven yerinde kalır. Oda kimlikleri, yatak/iş/kayıt bağlantıları değişmez; kayıtta koridor koordinatı tutulmadığından konum göçü gerekmedi.

Baklava desenli eski duvar yerine geniş lekeli mat sıva; alt 80cm koyu yeşil boya, mat yeşil kapı/kasa, nötr tavan. Çok küçük blok parke yerine uzun ve daha sade tahta döşeme. Bordo yolluk duvardan ayrı kalır. Lambalar küp yerine 40/48 dilimli yumuşak kesitli geometridir; yeni ışık/ambiyans dengesi, daha az bloom/sis ve daha yumuşak AO kullanılır. Hedef çizim diline yaklaşmaktır; PS1/pikselleştirme eklenmedi. Eski boş fotoğraf çerçeveleri/telefon gibi bazı prosedürel eşya yer tutucuları hâlâ görünür ve nihai değildir.

## Dosyalar, hiyerarşi ve kurulum

scripts/house/house_layout.gd; house_builder.gd; corridor_dressing.gd; scripts/art/house_materials.gd, texture_generator.gd; scripts/dev/generate_textures.gd, house_blockout.gd; assets/textures/wallpaper.png, parquet.png. HouseBuilder çalışma anında aynı ev hiyerarşisini üretir; kapıların önceki menteşe sistemi korunur. Yeni autoload yok. Hedefler/odalar 2D katman sisteminde kalır. Test HouseLayout kapsül/kapı/merdiven doğrulaması güncellendi; yeni dolaşım şeridinde gerçekten durulabildiği ayrıca kontrol edilir.

Godot 4.7.2 içe aktar. Normal oyunu yeniden başlat. Yalnız yüzeyleri tekrar üretmek için generate_textures.tscn -- --corridor-surfaces; genel üretici de yeni tahta döşemeyi kullanır. scenes/dev/corridor_review.tscn -- --capture-corridor [--upper] [--night] gerçek 1920×1080 inceleme kamerasıdır; kayıt yazmaz. Player kontrolü ve HUD yalnız bu sanat sahnesinde kapalıdır.

## Doğrulama ve sınırlar

İlk geometri sürümünde mevcut 22 paket geçti; son malzeme/armatür ve yeni şerit kontrollerinden sonra regresyon ayrıca çalıştırıldı. Gerçek Forward+ ground-day, upper-day ve upper-night görüntüleri alındı; gündüz iki kat görüntüsü açılıp incelendi. Yeni tavan/masa lambaları eski küp görünümünü azaltır. Gündüz de ev loştur; üst katta doğrudan dış pencere olmadığından gece farkı sınırlıdır. Bu, kapsamlı gün/gece ışık yönetmeni değildir.

Sık hata: yalnız görünen duvarı kaydırıp oda sınırı/kapı çarpışmasını bırakmak; yalnız dokuyu değiştirmek; ölçekleyerek kapıları esnetmek. Bu geçiş gerçek plan verisini ve kapı konumlarını birlikte değiştirir; kapı ölçüsü 0.9×2.1m korunur. Merdiven testi mevcut fiziksel yerinde çalışır.

Kalanlar: nihai çizimsel eşya/duvar detayları, daha güçlü kompozisyon ve gölge düzenlemesi, bütün 2D odalar/karakterlerle tam sanat tutarlılığı. Bu teslim tüm koridor sanatını veya kalan odaları tamamladı diye sunulmaz. Kullanıcının görsel değerlendirmesi otomatik fizik testlerinin yerine geçmez.

Son regresyon: 22 paket/6036 denetim geçti; House Layout 93. Görüntüler mevcut geometri/son armatürlerden alındı. Kullanıcı koridor ve odalar birlikte bitince haber verilmesini istedi; bu ara commit hazır-sürüm bildirimi değildir.
