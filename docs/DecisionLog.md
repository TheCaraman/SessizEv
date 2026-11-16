# Karar Günlüğü — THE QUIET HOURS

Her karar numaralı, tarihli ve gerekçelidir. Bir karar değişirse eskisi silinmez; "Geçersiz → K-xxx" diye işaretlenir.

Durumlar: **Onaylı** (proje sahibi onayladı) · **Varsayım** (itiraz gelene kadar geçerli) · **Açık** (karar bekliyor)

## Onaylı kararlar

| No | Tarih | Karar | Gerekçe |
|---|---|---|---|
| K-001 | 2026-11-16 | **Lily Reed öldürülemez ve ekranda şiddet görmez.** Ona uygulanabilecek yargılar: soruşturmaya devam, Noah ile birlikte gözlem altında tutma, evden çıkarma. | Yaş derecelendirmesi ve mağaza riski; çocuğa yönelik oynanabilir şiddet yok. |
| K-002 | 2026-11-16 | **Lily her zaman sağlıklıdır** (enfeksiyon atamasına girmez). Oyuncu bunu asla kesin olarak öğrenemez; rüyaları belirsiz kalır. | K-001 ile tutarlılık; enfekte çocuk, çözümü olmayan bir ikilem üretirdi. |
| K-003 | 2026-11-16 | **Altıncı son eklendi:** sağlıklı Daniel, ayakta kalan toplulukla evde kalır. Çalışma adı: THE LONG QUIET. | "Kalma" seçiminin sonu yoktu; iyi oynayan oyuncu cezalandırılmamalı. |
| K-004 | 2026-11-16 | **Enfekte Daniel tahliyeyi seçerse son WE olur.** Epilog, ağın tahliye bölgesine taşındığını ima eder. | DAWN "sağlıklı" şartı koşuyor; boşluk kapatıldı. |
| K-005 | 2026-11-16 | **Enfekte sayısı:** 17 uygun NPC içinde 3–5. İlk altı ziyaretçi teklifinden en az biri enfektedir. | Perde II hiçbir oyunda boş kalmaz; evin temiz kalması yine mümkündür. |
| K-006 | 2026-11-16 | **NPC kademeleri:** 6 ana, 6 ikincil, 6 kısa yaylı. Hiçbiri jenerik işçi değildir. | Yazım ve üretim yükünü yaklaşık yarıya indirir. |
| K-007 | 2026-11-16 | **Motor: Godot 4.7.2 stable (standart, .NET değil), GDScript, Forward+.** | Resmi sitede doğrulanan güncel kararlı sürüm (18 Ağustos 2026). |
| K-008 | 2026-11-16 | **Görsel yön revizyonu:** PS1 düşük poligon temeli korunur, ama ton "temiz retro" değil; kirli, bunaltıcı, tekinsiz. Ayrıntı: ArtBible.md §2. | Proje sahibinin isteği. |
| K-009 | 2026-11-16 | **3D varlık üretimi:** Blender kullanılmıyor. Ev ve eşyalar motor içinde (kod ve CSG ile) üretilir; karakterler modüler ilkel parça kitinden kurulur. Dokular için yapay zekâ görsel araçları kullanılabilir; her doku için tam istem metni verilir. | Proje sahibi Blender kullanmıyor. |

| K-010 | 2026-11-16 | **Görsel hedef öne alındı.** Oturma odası, oyunun görünümünün referans odasıdır; retro görüntü geçişi, kodla üretilen dokular ve eşyalar kapı sisteminden önce yapıldı. | Proje sahibi blockout'u ruhsuz buldu; görsel yönü erken doğrulamak riski azaltır. |
| K-011 | 2026-11-16 | **Melez sunum: koridorlar 3D, odalar 2D.** Oyuncu giriş holü, hol, merdiven, sahanlık ve üst koridorda birinci şahıs yürür. Bir odanın kapısıyla etkileşince oda, çizilmiş 2D bir sahne olarak açılır; karakterler ve değişen eşyalar bu sahnenin üstüne katman olarak eklenir. Karakterler 2D çizimdir. **Özgün spesifikasyonun "tam 3D, 2D oda yok, 2D portre yok" maddelerinin (bölüm 20, 60, 75) yerini alır.** K-008, K-009'un karakter kısmı, K-010 ve V-016 geçersizdir. | Proje sahibinin kararı: hedeflenen görünüme 2D ile ulaşmak mümkün, 3D karakter ve oda üretimi tek kişi için fazla ağır. |
| K-012 | 2026-11-16 | **Renk teması:** koyu, kirli yeşil ve hafif turkuaz; vurgu olarak kirli sarı. Görüntü net ve doygun; ağır pikselleşme yok. | Proje sahibinin referans görselleri ve tarifi. |
| K-013 | 2026-11-16 | **Görüntü pürüzsüzdür; pikselli/PS1 görünümü yok.** Dokular yüksek çözünürlüklü (512–1024) ve yumuşak süzmeli; ekran pikselleştirmesi ve renk kademelenmesi kapalı; kenar yumuşatma açık. Kapı, kasa, süpürgelik gibi ayrıntılar gerçek çıkıntılı geometridir. Özgün spesifikasyonun "PS1/düşük çözünürlüklü doku" maddelerinin (bölüm 20, 26) yerini alır. | Proje sahibi iki kez pikselli görünümü reddetti; referans görselleri pürüzsüz. |

## Varsayımlar

| No | Varsayım | Kaynak sorun |
|---|---|---|
| V-001 | Gece dört nöbet bloğudur: 23–01, 01–03, 03–05, 05–07. Blok içinde serbest dolaşılır; saat blok bitince ilerler. | Hibrit zaman ile gerçek zamanlı nöbet çelişkisi |
| V-002 | Rastgelelik yalnızca "ne olacağını" belirler; seed'lidir, gün başında hesaplanıp kaydedilir. Oyuncu müdahalesinin sonucu tamamen duruma bağlıdır. | "Gizli zar yok" kuralı |
| V-003 | Mühürsüz kontamine nesneye yalnızca Daniel dokunabilir. | Kanonik enfeksiyon kuralı 4 |
| V-004 | Her enfekte NPC'nin en az üç bağımsız kanıt fırsatı, her sağlıklı NPC'nin gerçek açıklaması olan en az iki şüpheli davranışı vardır. | Adil çıkarım |
| V-005 | Enfeksiyon kampanya başında tüm kadro için bir kez atanır ve kaydedilir. | Kural 3 ile bölüm 43 uyumu |
| V-006 | Manuel kayıt yalnızca gündüz serbest dolaşımda. Otomatik kayıt: faz geçişleri ve her geri dönüşsüz karar sonrası. | Kayıt istismarı |
| V-007 | Diyalog için hazır eklenti yok; kendi veri güdümlü sistemimiz. | Bağımlılık riski, yerelleştirme |
| V-008 | Lily evden çıkarılırsa Noah onunla birlikte gider; Lily asla tek başına dışarı bırakılmaz. Noah çıkarılır, ölür veya kaybolursa Lily evde kalır ve bir bakıcıya bağlanır. | K-001'in doğal sonucu |
| V-009 | Girdi eylemleri `project.godot` içinde değil, açılışta kodla kaydedilir (`InputSetup`). | Tuş yeniden atama ve elle yazılan proje dosyasında hata riski |
| V-010 | Belgeler Türkçe, oyun içi tüm metinler İngilizce ve çeviri anahtarlıdır. | Bölüm 0 |
| V-011 | Sağlıklı Daniel, topluluğu yıkılmış hâlde tahliye olursa son EMPTY HOUSE'tur (yalnız ayrılış varyantı). | Son önceliği boşluğu |

| V-012 | Merdivenlerde basamak çıkma mantığı yok; merdiven çarpışması rampa biçimindedir. Basamaklar yalnızca görseldir. | Kontrolcü sadeliği, NPC yol bulma |
| V-013 | Yürüme hızı 2,4 m/s, hızlı yürüme 3,8 m/s, göz yüksekliği 1,6 m, görüş açısı 70°. Dengeleme değerleridir. | Faz 1.2 |

| V-014 | Retro görüntü, tam çözünürlükte çizilen kareyi kaba bir ızgarada örnekleyen tek bir ekran gölgelendiricisidir (`shaders/retro_post.gdshader`); düşük çözünürlüklü ayrı görüntü alanı kullanılmıyor. Daha basit ve fare girdisini etkilemiyor; performans gerekirse Faz 7'de değiştirilir. TechnicalDesign §2'deki şemanın yerini alır. | Faz 1.6 |
| V-015 | Dokular şimdilik kodla üretiliyor (`scripts/art/house_materials.gd`). Her biri sonradan boyanmış bir dokuyla değiştirilebilir. | K-009 |
| V-016 | Oturma odasındaki pencere gerçek bir açıklık değil, duvara asılı ışıklı bir paneldir. Gerçek pencereler kapı ve pencere geçişinde gelecek. | K-010 |
| V-017 | Koridordan kapısı olmayan odalara (yemek alanı, kiler, tesisat odası) komşu odanın 2D sahnesindeki geçiş düğmeleriyle gidilir. | K-011 |
| V-018 | Oda görselleri `assets/rooms/<oda_kimliği>.png` yolundan yüklenir. Dosya yoksa kodla üretilen bir yer tutucu gösterilir ve ekranda "yer tutucu" yazar. | K-011 |
| V-019 | Etkileşim ördek tiplemesiyle çalışır: `interact()` yöntemi olan her çarpışma gövdesi etkileşilebilirdir; `get_interaction_prompt()` varsa ipucu yazısını o verir. | Faz 1.3 |

## Açık konular
| A-008 | Gece nöbetinin yeni tasarımı | K-011 ile odaların içi gece doğrudan görülemez. Öneri: koridorda yürüyüp sesleri dinlemek ve kapıları açıp bakmak; ayrıntı Faz 4 öncesi birlikte kararlaştırılacak. |
| A-009 | 2D oda ve karakter görsellerinin üretimi | Proje sahibi yapay zekâ görsel aracıyla üretecek; tutarlılık için istem şablonu ve ölçü kuralları ArtBible'a yazılacak. |

| No | Konu | Not |
|---|---|---|
| A-001 | Su kaynağı: sayılan stok mu, "şebeke çalışıyor/arızalı" durumu mu? | Onay gelmedi; şimdilik özgün spesifikasyon geçerli (hafif sayılan stok). |
| A-002 | Altıncı sonun nihai adı | Çalışma adı THE LONG QUIET. |
| A-003 | "Maruz kalmış" (exposed) durumunun ilerleme kuralları | GDD §8'de taslak; dengeleme Faz 5'te. |
| A-006 | ~~Ev kat planı onayı~~ — **Kapandı (2026-11-16)** | Proje sahibi planı olduğu gibi onayladı (önce sadeleştirme istedi, sonra vazgeçti). Blockout kuruldu. |
| A-007 | Evin sadeleştirilmesi | Proje sahibi bir ara "biraz küçült, sadeleştir" dedi, sonra planı onayladı. İçinde yürüdükten sonra yeniden sorulacak. |
| A-004 | Animasyon kaynağı | Lisansı uygun (CC0) iskelet animasyon paketi mi, kodla üretilen basit pozlar mı? Faz 3 öncesi karar. |
| A-005 | ~~Godot ve git kurulu değil~~ — **Kapandı (2026-11-16)** | Godot 4.7.2 `tools/godot-4.7.2/` altında (proje klasörünün dışında). Git 2.56.1 kuruldu; depo başlatıldı. Uzak depo (GitHub vb.) henüz yok. |

## Değişiklik günlüğü

| Tarih | Değişiklik |
|---|---|
| 2026-11-16 | Proje iskeleti ve ilk belge seti oluşturuldu. |
| 2026-11-16 | Faz 1.1 doğrulandı: proje Godot 4.7.2'de başsız içe aktarıldı ve açılış sahnesi hatasız, uyarısız çalıştı; dokuz girdi eylemi kaydedildi. Pencereli (görsel) çalıştırma henüz yapılmadı. |
