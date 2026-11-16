# Evden çıkarma — kişisel tepki ve yerel hatıra

## Teslim

resources/events/resident_judgment.json artık üç yetişkinin ayrılık ve dinleyici yanıtı çeviri anahtarlarını içerir. Elena pratik bakım uyarısıyla, Marcus elektrik konusunda sert bir sınır koyarak, Arthur belirsizlik ve insan onuruna odaklanarak ayrılır. Metin enfeksiyona göre seçilmez. Bunlar yeni gizem açıklaması veya suç kanıtı değildir.

ResidentJudgment, kararın başında gerçekten aynı odada bulunan uygun yetişkinlere memory_<witness>_saw_expulsion_<target> bayrağını aday işlem içinde yazar. Diğer odalar, absent/izole/etkisiz kişiler ve ev dışında olanlar otomatik bilgi almaz. Hedefin memory_<id>_expelled_by_daniel hatırası da aynı işlemde saklanır. Onay tek başına hatıra üretmez. Bayraklar mevcut v5 flags alanındadır; yeni kayıt sürümü veya düğüm gerekmez.

CampaignDirector yalnız bu kayıt varsa ve dinleyici hâlâ uygun/bulunduğu odadaysa ilgili konuşma eylemini sunar. Tek yazılmış yanıt tekrar okunabilir; ek süre/güven cezası yoktur. Bu yaklaşım genel sohbet üretmez. Eski kayıtlarda geçmişe dönük hatıra veya konuşma eklenmez. Bir kişinin evde olması her olayı bildiği anlamına gelmez.

## Dosyalar ve kurulum

scripts/narrative/resident_judgment.gd, campaign_director.gd; resources/events/resident_judgment.json; localization/strings.csv; tests/resident_judgment_test.gd. Mevcut RefCounted karar denetleyicisi ve RoomView kullanılır. Godot 4.7.2 içe aktar; Gün 4'te iki uygun yetişkin aynı odadayken birini çıkar, diğerindeki ayrılık konusunu seç. Oda değişirse konu dinleyicinin yeni konumunu izler.

## Test ve sınırlar

Resident Judgment 47 denetim geçti. Yeni kapsam: her iki enfeksiyon atamasında aynı Elena ayrılık sözü, ilk onayda hatıra yokluğu, aynı oda kaydı, diğer odada bilgi yokluğu, gizli güven cezası yokluğu, kayıttan hatıra dönüşü, kişisel yanıt, ücretsiz tekrar, gerçek RoomView eylemi. Önceki 35 karar denetimi korunur. Koşucu Run-Tests.ps1; render --capture-judgment.

Genel NPC bellek/ilişki grafiği, toplu moral hesabı, sonradan haber verme konuşması, seslendirme, ayrılık animasyonu ve izolasyon henüz uygulanmadı. Bayrağın save edilmesi tek başına bu özelliklerin varlığı değildir. Kritik hata: aynı evdeki herkesi tanık saymak veya sonradan ölen kişiden yeni ifade almak. Sıradaki bağımlılık gerçek gece gözlemi ve izolasyon akışıdır.

Son regresyon: 19 paket/5867 denetim geçti. Gerçek Forward+ capture 52 denetim; Türkçe 1440p dinleyici yanıtı açılıp incelendi. Oda ve Marcus eski geçici görsellerdir; sanat kabulü değildir.
