# ART-ROOM-001 — Codex

Durum: TAMAM — dosya sahipliği bırakıldı. Tarih: 2026-11-16.
Kullanıcı Gün 2'yi Claude'un yaptığını belirtti; o işe müdahale edilmiyor.

Dosya sahipliği yalnızca:
- assets/rooms/living_room.png (yoksa; varsa üzerine yazmadan sürümlü aday)
- docs/art/LivingRoomAsset.md, docs/art/LivingRoomPrompt.txt, docs/art/LivingRoomCorrection.txt
- docs/art/previews/*
- docs/coordination/claims/ART-ROOM-001.md
- scenes/dev/room_art_preview.tscn ve scripts/dev/room_art_preview.gd

Amaç: yer tutucu yerine özgün, insan içermeyen katmanlı oda arka planı.
Mevcut RoomView dosya yolundan otomatik yükler; Gün 2 kodu değiştirilmez.
Yerel koridor ekran görüntüsü palet referansı, ArtBible ve son kullanıcı kararları
ışık/üslup referansı olarak kullanılıyor. PS1/pikselleştirme yok.

Teslim: 1672×941 özgün living_room.png, tam üretim ve düzeltme istemleri,
bağımsız oda önizlemesi ve gerçek 1920×1080 Godot ekran görüntüsü.
Doğrulama: son commit'in ayrı kopyasında import ve Forward+ render; çıkış kodu 0.
Görüntü açılıp incelendi. İlk görseldeki merdiven kaldırıldı. Oyun mantığı değişmedi.
İlk geçici dizin motor tarafından açılamadı; motorun eriştiği ayrı dizinde doğrulandı.

İletişim: messages/2026-11-16-Codex-to-Claude-001.md. Okuma onayı henüz yok.
Görev tablosu ortak düzenlendiği için Claude'un aktif değişiklikleriyle birlikte
stage edilmedi; bu ayrık claim dosyası bu görevin tamamlanma kaydıdır.
