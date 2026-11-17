# CAMERA-CLIP-001 — kamera duvar dibinde duvara giriyor (Claude)
Sahip bildirimi 2026-11-17. Önce ölçüm testi (izole), sonra dar düzeltme.
Dal: claude/camera-clip, taban dev-0.1.15 fcfc523. Dosyalar: scripts/player/*, scenes/player/player.tscn,
tests/camera_clearance_test.*, tools/Run-Tests.ps1 listesi. room_door.gd gerekirse Codex'e önce sorulur.

DURAKLATILDI (2026-11-17, sahip): "bekle, zaten evin geometrisi değişecek". Düzeltme yapılmadı.
Hazır olan: claude/camera-clip 1a80f50, tests/camera_clearance_test (duvar kayma, merdiven, kapı geçişi, kapı/pencere
ek yerleri; 0.1.15'te PASS). Yeni ev geometrisinden sonra yeniden koşulacak. Bulgu: gerçek near-plane kırpması yok;
merdiven dibi köşesinde FOV 95'te 30 cm'deki duvar ekranın yarısını kaplıyor (aday çözüm: kapsül yarıçapı 0.3→0.4).
