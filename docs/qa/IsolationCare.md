# İzolasyon — temel ihtiyaç kontrolü ve kişisel yanıt

Isolation akışında yerleştirme ilk temel kontrolü de içerir. isolation_care_day_<day>_<npc> mevcut flags alanına aynı aday işlemde yazılır. Küçük odada “Check on” seçeneği bu kaydı okuyarak aynı gün ücretsiz kişisel yanıt gösterir. Daha eski, geçerli izolasyon kaydında kontrol işareti yoksa ilk kontrol 15 dakika ve iki basışlı onay ister. Kaynak tüketmez, tedavi etmez, teşhis koymaz, izolasyondan çıkarmaz ve güven puanı üretmez. Başka eylem/oda çıkışı onayı iptal eder. SaveManager işlemi başarısızsa bakım yapılmış sayılmaz.

resources/events/isolation.json içinde üç kişinin care_keys alanı vardır; Elena başkalarının ihtiyaçlarını hatırlatır, Marcus belirsiz bekleyişe tepki verir, Arthur korkunun teşhis sayılmamasını ister. Enfeksiyon bu metin seçiminde okunmaz. Bu yazılmış kısa yanıttır; seslendirme veya tıbbi muayene animasyonu yoktur.

Değişen dosyalar: scripts/shelter/isolation.gd, resources/events/isolation.json, localization/strings.csv, tests/isolation_test.gd. Hiyerarşi/kurulum değişmez; Godot 4.7.2 içe aktarması yeterli. Gün 4'te küçük odayı hazırla, yetişkini yerleştir, küçük odada bakım eylemini seç. Aynı gün tekrar okumak ücretsizdir; salıverip yeniden yerleştirmek aynı gün bakım bedeli üretmez.

ISOLATION TEST 65 denetim geçti. Yeni kontroller yerleştirmede bakım işareti, aynı gün ücretsiz tekrar, en/tr iki çözünürlükte metin, üç yetişkinin eski işaretsiz kaydında ücretsiz onay ardından yalnız 15 dakika, sabit NPC/kaynaklar, save/load ve tekrar bedelsizliğini kapsar. Tıbbi sonuç veya oyuncunun gerçekten muayene yaptığı iddia edilmez. Genel uzun vadeli bakım/ihmal uyarısı ve Gün 4 sonrası gece henüz yoktur. Sıradaki bağımlılık bu bakım kaydını ilerleyen günlere ve kapanışa bağlamak; gerçek gece tanığı ve nihai sanat da açık.

Son regresyon: 20 paket/5986 denetim geçti. GPU capture 73; en/tr iki çözünürlük, TR1080p açılıp incelendi. Üretim sanatı değişmedi.
