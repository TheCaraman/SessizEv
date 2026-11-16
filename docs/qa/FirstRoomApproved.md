# Onaylanan çizimsel ilk oda

Sahip yanıtı: “Bu yönü koru, ilk odayı oyunda göster.” ART-REV-003 görseli assets/rooms/living_room.png yoluna bağlandı. Kaynak 1672×941; 1080p çıktı ölçeklenir, yerel 1080p kaynak iddiası yok. SHA256 manifest güncellendi. Eski kaynak docs/art/concepts/previous-living-room.png ve Git geçmişinde korundu; karşılaştırma aracı artık bu arşivle yeni üretim görselini karşılaştırır.

Gerçek HouseBlockout kampanya sahnesi, Gün 1 09:00 ve normal RoomView kullanılarak izole kayıtta 1920×1080 render edildi. First-room-approved.png görüntüsü incelendi: çizimsel arka plan, saat, oda başlığı ve mevcut TV/radyo/geçiş eylemleri görünür. İlk render çağrısı hata metni olmadan çıkış 1 verdi; aynı izole proje tekrar çalıştırıldığında çıkış 0 ve FIRST ROOM CAPTURE: 0 üretti. İlk deneme başarılı sayılmadı.

Yeni sanatla tam regresyon 12 paket/5321 denetim geçti. Fareyle kapıya yürüyerek açma henüz bu teslimde yapılmadı; gerçek kampanya sahnesinde oda açma motor içinde tetiklendi. tests/first_room_preview.tscn bu görüntüyü tekrar üretir; kullanıcı kaydı korunması için izole test kopyasında çalıştırılır.

Bilinen eksikler: TV/radyo arka planda görünür çizilmiş değil; eylemleri mevcut. Bu nesnelerin aynı üslupla ayrı katmanı gerekir. Ayrı gece resmi, karakterlerin yeni üsluba uyarlanması ve kalan odalar bu teslimde yoktur. Normal başlangıç sahnesi değiştirilmedi; yeni oda standart kampanyada kullanılır.
