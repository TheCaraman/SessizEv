# THE QUIET HOURS — Sanat Kitabı

Sürüm 0.1 · 2026-11-16 · K-008 ve K-009'u içerir

## 1. Temel

Tam 3D, düşük poligon, düşük çözünürlüklü doku, sınırlı palet. Oyun kasıtlı tasarlanmış görünmeli; yarım kalmış değil.

## 2. Ton revizyonu (K-008)

Proje sahibi, görünümün "temiz PS1 nostaljisi"nden çok *No, I'm Not a Human*'ın hissine yakın olmasını istedi. O oyundan alınan şey **his**tir; karakter tasarımı, sahne, arayüz veya varlık kopyalanmaz.

Hedef his: **kirli, bunaltıcı, tekinsiz.** Ev sığınak değil, içinde çok uzun kalınmış bir yer gibi görünmeli.

| Öğe | Yön |
|---|---|
| Palet | Hastalıklı sıcak tonlar: hardal, pas, kirli bej, soluk zeytin. Dışarısı soğuk ve soluk. Saf beyaz ve saf siyah yok. |
| Renk derinliği | Azaltılmış renk sayısı ve düzenli titreklik (dithering). Gölgeler pürüzsüz geçmez, kademelenir. |
| Gren | Varsayılan orta düzey; ayarlardan kapatılabilir. |
| Işık | Az sayıda sert kaynak, çıplak ampul hissi. Gündüz bile perdeler yarı kapalı. |
| Yüzeyler | Lekeli duvar kâğıdı, yağlı mutfak yüzeyleri, sararmış perde, yıpranmış halı. |
| Yüzler | Düşük çözünürlüklü, boyanmış yüz dokuları. Oranlar hafifçe "yanlış": gözler biraz fazla sabit, cilt biraz fazla solgun. Canavar değil, rahatsız edici biçimde sıradan. |
| Kamera | Diyalogda yüze normalden biraz daha yakın çerçeve. |

**Özgün spesifikasyonla fark:** bölüm 20 "aşırı gren ve agresif ekran bozulması yok" diyordu. Bu korunur: efektler güçlü ama ölçülüdür, hepsi kapatılabilir; renk sapması, ağır bulanıklık ve kamera sarsıntısı yoktur.

**Değişmeyen:** karakterler ekranda fiziksel 3D modellerdir. Sabit 2D portre kullanılmaz.

**Enfeksiyon ve görünüş:** tekinsiz yüz stili **herkese** uygulanır. Böylece görünüş enfeksiyon testi olamaz; oyuncu herkesten eşit ölçüde rahatsız olur.

## 3. Işık

- **Gündüz:** kapalı hava, soğuk dış ışık, sıcak iç yüzeyler.
- **Akşam:** sıcak lambalar, soğuk dış karanlık, uzun gölgeler.
- **Gece:** derin gölge ama gezilebilir; tam karanlığa yaslanılmaz.
- **Kriz:** elektrik kesintisi tanıdık mekânı dönüştürür. Kırmızı acil ışık yalnızca belirli sahnelerde.

## 4. Üretim yöntemi (K-009)

Blender kullanılmıyor. Buna göre:

| Varlık | Yöntem | Dürüst sınır |
|---|---|---|
| Ev mimarisi | Motor içinde, kodla ve CSG ile; sonra tek ağa dönüştürme | Düşük poligon mimari için yeterli |
| Mobilya ve eşya | İlkel parçalardan kurulan sahneler | Yeterli; organik biçimler (kumaş, bitki) basit kalır |
| Karakterler | Modüler ilkel parça kiti: gövde, baş, saç, giysi parçaları; ortak iskelet | En zayıf halka. Okunaklı ve stilize olur, ama elle modellenmiş karakter kalitesine ulaşmaz |
| Dokular | Yapay zekâ görsel araçlarıyla üretim; her doku için tam istem ve boyut verilir | Proje sahibi üretir, ben istemi ve yerleştirmeyi sağlarım |
| Animasyon | Açık konu (A-004) | Karar Faz 3 öncesi |

Karakter kalitesi Faz 6'dan önce yeniden değerlendirilir. Yetersiz kalırsa seçenekler: lisansı uygun hazır düşük poligon insan paketi ya da bir serbest çalışan sanatçı. Bu bir bütçe kararıdır ve proje sahibine sorulacaktır.

## 5. Bütçeler (geçici)

- Karakter: 1.500–4.000 üçgen, 256–512 px doku.
- Oda başına eşya dokuları: 128–256 px.
- Doku süzme: en yakın komşu.
- İç görüntüleme çözünürlüğü: varsayılan 640×360; ayarlanabilir.

## 6. Doku istem şablonu

```
Konu: [yüzey ya da yüz tanımı]
Stil: late-1990s low-resolution game texture, hand-painted, muted sickly palette
       (mustard, rust, dirty beige), flat lighting, no baked shadows, seamless tile
Boyut: 512×512 (oyunda 256'ya küçültülür)
Kaçın: fotogerçekçilik, parlak renk, yazı, logo, tanınabilir gerçek kişi ya da mevcut oyun karakteri
```
