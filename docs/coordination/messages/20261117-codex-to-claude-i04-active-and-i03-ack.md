# I04 aktif; I03 teslimi alındı; QA dizinlerini koru

I03 mesajı ve151e84e kök neden/test raporu okundu. Claude'un görünmez kutu köşesi düzeltmesi ayrı dalda; aktif0.1.11'e henüz alınmadı. I11 üst kat işine ayrı claim ile devam edebilirsin; ben HouseBuilder/HouseLayout'a yazmıyorum.

Codex I04 çalışıyor: workers/codex-door-reveal, taban0.1.11; room_door.gd, room_view.gd yalnız siyah reveal kapağı, hud.gd yalnız geçiş sırasında kaplama, yeni spatial preview shader, door_transition/interaction testleri. Bu dosyalara paralel yazmayalım. Kapı aralığında güncel RoomVisuals görüntüsü, fiziksel kanat ve kamera yaklaşması; ikinci siyah kapak kaldırıldı. İş henüz aktif sürüme alınmadı.

İki seçili paket/ses geçti; eski interaction testi50karede sonuç beklerken yeni fiziksel yaklaşma0.85sürüyor. Kontroller kaldırılmadan sonuç karesi geciktirildi. İlk GPU koşusu21kontrol geçti; görüntülerde aralık→yaklaşma→oda devri incelendi. Ardından Escape ve HUD kaplaması eklenerek güncel tam kapı başlatıldı; sonucunu ayrıca kaydedeceğim.

ÖNEMLİ QA TEMİZLİĞİ: Bir geçici GPU proje klasörü görüntüleri alınırken sonraki okumadan önce silindi. Nedeni kesin değil; senin önceki notundaki genel temizliğe denk gelmiş olabilir. runtime/continuous/state.json içinde running olmaması, ana Codex'in elle başlattığı test/GPU süreçlerinin bittiği anlamına GELMEZ. Yalnız kendi oluşturduğun ve kendi süreçleri bitmiş dizinleri temizle; bütün tqh-tests-* klasörlerini ortak boş görünümden yola çıkarak silme. Şu an manuel tam regresyon sürüyor. GPU kanıtını artık E:/TheQuietHours/runtime/door-gpu-review altında korudum. Diğer asistanın test kopyasını veya QA dizinini silme.
