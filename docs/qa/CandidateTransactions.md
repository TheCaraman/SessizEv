# Aday durumdan kalıcı karar uygulama

## Hedef ve kullanım

SaveManager.commit_candidate(expected, candidate, transaction_id, slot) eşzamanlı teknik temeldir. Çağıran önce GameState.to_dict() anlık görüntüsünü alır; adayını duplicate(true) ile ayırıp kararın etkilerini yalnız bu sözlükte hazırlar. Uygulama eski görüntü hâlâ canlı durumla eşitse, aday şeması geçerliyse ve işlem kimliği kullanılmamışsa adayı güvenli kayıt yazıcısından geçirir. Ancak başarılı yayından sonra GameState.from_dict(committed, false) çalışır. Hata Error döndürür; maliyet/sinyal yok. Kullanıcı Retry/Cancel arayüzü ilgili karar uygulamasının sorumluluğudur.

Dosyalar: scripts/save/save_manager.gd, scripts/core/game_state.gd, tests/save_write_test.gd. Hiyerarşi ve bağımlılıklar değişmedi: mevcut SaveManager/GameState/EventBus autoload'ları. Yeni sahne, editör ayarı veya kaynak gerekmez; Godot 4.7.2 içe aktarması yeterli. Kayıt sürümü 5; flags içinde transaction/<id> boolean işareti kullanılır. Day4 kararları henüz bu API'ye bağlanmadı.

## Kurallar

- Beklenen görüntü eskiyse ERR_BUSY; yeni teklif/onay hazırlanır.
- Başarılı işlem kimliği tekrar gelirse ERR_ALREADY_EXISTS; maliyet tekrar uygulanmaz.
- Adayda tam üst düzey alanlar gerekir. Aynı kampanya/gün korunur, saat geri alınamaz; NPC enfeksiyon atamaları ve Daniel'ın enfeksiyonu değiştirilemez. Bulaşma ayrı yazılmış sistemin sorumluluğudur.
- İşaret ve aday, çağıranın sözlüğü değiştirilmeden kopyalanır. Dosyaya yazılan bütün durum canlıya bildirimlerden önce uygulanır.
- from_dict varsayılan yükleme davranışını korur. Karar uygulamasında announce_day=false sahte day_started sinyalini engeller; saat/faz, sakin, kaynak bildirimleri güncellenir.
- Karar başına yatak, erişim, kaynak, süre, tanık ve hedef uygunluğu bu genel API'nin yerine geçmez; Day4 saf karar doğrulayıcısında ayrıca kontrol edilecek. Var olan oyun eylemleri topluca dönüştürülmedi.

## Test ve bitti ölçütü

İzole Run-Tests.ps1 koşusunda SAVE WRITE TEST 58 denetim geçti. Yeni 21 denetim: yazma/kısa dosya/yayın/rollback hatalarında aday maliyeti ve bildirim yokluğu; başarılı işlemde tek maliyet; kaynak bildirimi içinde diskte işlem işaretinin zaten varlığı; sahte gün sinyali yokluğu; çift tık, eski teklif, yükleme sonrası tekrar ve enfeksiyon değiştirme reddi. Gerçek arayüz tıklaması veya disk arızası testi değildir.

Sık hata: canlı GameState'i değiştirip sonra commit_candidate çağırmak; bu durumda beklenen görüntü eski kalır ve işlem reddedilir. Bu API'de await yoktur; aday hazırlamak da canlı durum sinyali üretmemelidir. Donanım düzeyinde atomiklik garantisi verilmez; SafeSaveWrite.md sınırları geçerlidir. Sonraki bağımlılık: Day3 gerçek tanık kaydı ve Day4 nonlethal karar arayüzü/semantik doğrulaması.
