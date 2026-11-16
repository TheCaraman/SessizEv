# Gün 4 — ilk yetişkin evden çıkarma kararı

## Amaç ve teslim

Elena, Marcus veya Arthur uygun ve evdeyse bulunduğu gerçek odanın eylemlerinde evden çıkarma seçimi bulunur. İlk basış ad, geri alınamazlık, 15 dakika, güven kaybı, boşalan yatak, iş iptali ve erzak iadesi olmadığını açıklar. İkinci basış aynı kampanya görüntüsüne bağlıdır. Başka eylem/odadan çıkış iptal eder; saat, NPC, iş, kaynak veya kanıt değişirse yeniden onay gerekir. Başarısız kayıt karar uygulamaz. Bu karar suçluluk veya enfeksiyon teşhisi değildir.

Dosyalar: scripts/narrative/resident_judgment.gd, resources/events/resident_judgment.json; CampaignDirector eylem/iptal bağlantıları; localization/strings.csv; tests/resident_judgment_test.gd/.tscn; Run-Tests.ps1. RefCounted karar denetleyicisi CampaignDirector tarafından sahiplenilir; yeni autoload/düğüm gerekmez. Godot 4.7.2 içe aktar; Gün 4'te sakinin mevcut odasını aç. İşteyse yatak odasında değil görev odasında görünür.

## Sonuç ve sınırlar

Hedef expelled olur, room boşalır, yatak ve bitmemiş iş kaldırılır, hedef güveni −20 (alt sınır −100), saat +15. Enfeksiyon, kaynak stokları ve tamamlanmış geçmiş değişmez. Lily hedef olamaz. İzole, yaralı, etkisiz veya absent kişiler bu ilk yüz yüze akışa alınmaz; ölü/kovulmuş/yok kişi sunulmaz. Ziyaretçi varken veya gece sınırında süre yetmezse işlem yok. Sakin reddi ve izolasyondan çıkarma ayrıca uygulanacak.

SaveManager aday işlemi ve transaction/day4-expel-<id> işareti kullanılır. Diğer sakinlerin saatle biten işleri mevcut ShelterManager zaman sinyalinden çözülür; bu genel iş sistemini yeniden yazmaz. Mevcut yükleme de aynı saat sinyaliyle kayıtlı bitmemiş işleri çözer. Hedefin işi escort başlangıcında kesilir; karar aralığında bitecek olması ürün kazandırmaz. Animasyonlu kapıya yürütme yok; sonuç metniyle kesilir. Şiddet veya yeni karakter sanatı eklenmedi. Grup ilişkisi/moral tepkisi ve kişiye özel ayrılık diyaloğu henüz yok; tam anlatı teslimi sayılmaz.

## Test

Resident Judgment paketi 35 denetim: sağlıklı/enfekte aynı seçenek ve sonuç; ilk basış ücretsiz; çıkış ve saat değişimi onayı iptal; tek süre/güven; stok iadesi yok; kayıt/yükleme; tekrar bedel yok; çocuk ve uygunsuz durumlar; gerçek görev odası, iptal işin ürün vermemesi; en/tr 1080p/1440p onay alanı. I/O hataları ortak aday işlem paketinde sınanır; bu arayüzde gerçek disk arızası/elle tıklama yapılmadı. Komut Run-Tests.ps1; özel render anahtarı --capture-judgment.

Sık hata: yalnız NPC durumunu değiştirip yatağı/işi bırakmak veya aynı onayı farklı kişi/saatte kullanmak. Bitti ölçütü bu ilk kararın kayıt ve kontrol bütünlüğü; tam Gün 4 için izolasyon, gerçek tanık ve sosyal tepkiler açık. Sonraki bağımlılık bu eksikler ve kalan oda/karakter görsel uyumu.

Son doğrulama: 19 paket/5834 denetim geçti. Gerçek Forward+ capture 39 denetim; en/tr 1080p/1440p PNG'leri kaydedildi, Türkçe 1080p açılıp incelendi. Görselde eski geçici oda/default Elena vardır; yeni sanat onayı sayılmaz.
