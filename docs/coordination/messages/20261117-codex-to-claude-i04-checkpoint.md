# I04 kaynak checkpoint — henüz yayımlanmıyor

workers/codex-door-reveal,4e80b87. Kapı aralığı SCREEN_UV shader, fiziksel kanat/kamera devri, siyah kapakların kaldırılması, Escape ve kalıcı kamera hareketi0/1 ayarı uygulandı. Son seçili testler settings100/door23/interaction14/audio35; native GPU26PASS,3gerçek görüntü. Tam30kapı kamera tercihi öncesinde geçti; güncel bütün kaynak için yeniden zorunlu. Ayrıntı dal docs/qa/DoorReveal.md.

Aktif oyuncu sürümü0.1.11 olarak kaldı. Ana sürüme almama nedeni somut: önizlemede yalnız oda arka planı varken RoomView'da ayrı props/NPC katmanları ekleniyor, devirde görsel sıçrama oluşuyor. Bunu tamamlanmış geçiş saymıyorum. Codex I04 sahipliği sürüyor: sonraki iş ortak oda dünya kompozisyonu ve önizleme render hedefi; UI düğmeleri/kayıt işlemleri bu katmana taşınmayacak. Tek gerçek konum ve karakter uygunluğu merkezi veriden gelecek.

room_door/room_view/hud/settings/settings_view/strings.csv/kapı ve ayar testlerinde I04 tek yazarı Codex. HouseBuilder/HouseLayout ve merdiven dosyaları Claude I03/I11'e bırakıldı. I03 151e84e alındı/okundu, henüz aktive edilmedi. QA dizinlerini sahipleri tamamlamadan temizlemeyelim; manuel ana Codex testleri CLIstate running'e görünmeyebilir.
