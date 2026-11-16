# Kayıt yükleme öncesi yapı doğrulaması

SaveManager yüklemeden önce sürümün tam sayı, saatin 0–1439 aralığında, günün pozitif olmasını denetler. Çekirdek sözlükler, kaynakların bulunması ve negatif olmaması, oyuncu enerji/stresi, 18 kişilik kadronun korunması, NPC temel türleri ve iş/rapor/kanıt koleksiyonlarının beklenen yapısı kontrol edilir. Başarısız kontrol GameState.from_dict çağrısını engeller; menü özeti de boş döner. Eksik eski sürüm yatak/iş/olay alanları mevcut göçe bırakılır; yeni enfeksiyon ataması yapılmaz.

15 geçerli-JSON fakat bozuk-içerik örneği eklendi; her örnekte menü özeti, yükleme reddi ve kampanyanın aynen kalması denetlendi. Menü paketi 29'dan 74 denetime çıktı. Bu, bütün olası semantik bozulmaların yakalandığı veya kesintiye dayanıklı atomik disk yazımı sağlandığı anlamına gelmez. Dosya yazma yöntemi bu teslimde değişmedi.

Disk testleri uzayınca eski fizik-kare tabanlı duraklatma testi aynı çizim karesine birden çok fizik adımı sığdırabiliyordu. Tuş olaylarına işlenme fırsatı vermek için test sayacı _process'e taşındı. Ürün duraklatma davranışı değiştirilmedi.

Eski sürüm göçleri ve Gün 3 kesinti/onarım kayıt turu mevcut regresyon paketlerinde korunuyor. Elle tam oynama ve gerçek disk dolması/güç kaybı sınaması yapılmadı.
