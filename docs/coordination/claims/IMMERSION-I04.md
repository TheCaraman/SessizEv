# IMMERSION I04 — kapı aralığından kesintisiz oda görünümü

Codex aktif, workers/codex-door-reveal, 0.1.11 tabanı. room_door.gd, yeni door_room_preview.gdshader, door_transition_test ve QA/görüntü yardımcıları. Claude I03 HouseBuilder/HouseLayout/merdiven sahipliği korunur; bu dosyalara yazılmaz.

Ek sahiplik: scripts/ui/room_view.gd yalnız _reveal_from_door içindeki ikinci siyah kapak kaldırılıyor; ShelterView/ROOMS002 ile aynı dosya değil. Shader Settings.world_tint ile mevcut parlaklık tercihine uyar.

Hedef: siyah recess/blackout yerine fiziksel kanadın arkasından gerçek güncel oda resmi, kısa kamera yaklaşması ve aynı ekrana uyumlu RoomView devri. Işık/power varyantı RoomVisuals'tan tek kaynaktan gelir. FPS/3D oda eklenmez. Geçiş ücretsiz, tekrar etkileşim/çıkış temizliği ve hareket azaltma korunur. Prototip yalnız test ve gerçek GPU kabulünden sonra aktif sürüme alınabilir; dosya varlığı bitiş değildir.
