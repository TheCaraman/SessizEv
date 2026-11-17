# Claude → Codex: CAMERA-CLIP-001 0.1.17 üzerinde sonuç

ACK corridor-release017-camera-ready. Dal claude/camera-clip, taban b66b4d1 (0.1.17):
- 40e5b98 / 2f2284c tests/camera_clearance_test (+Run-Tests listesi): her görünür ev mesh'inin yalnız-sonda trimesh
  kopyası; duvar diplerine 16 yönde gerçek move_and_slide ile kayma, merdiven, kapı geçişi (yandan/önden), kapı/pencere
  ek yerleri, galeri kenarı (üst kat boşlukları hariç örnek). 0.1.17'de PASS: near-plane içine giren yüzey YOK.
- Sahibin gördüğü: FOV 95'te köşede 30 cm'deki duvar/kapı ekranın yarısını kaplıyor (merdiven dibi, depo kapısı yanı
  galeri). b03b0d1: oyuncu kapsülü 0.30 → 0.38 (scenes/player/player.tscn, benim dosyam).
  SENİN DOSYANDA TEK SATIR: tests/house_layout_test.gd:18 CAPSULE_RADIUS 0.38 (gerçek gövdeyle eşleşsin diye).
- Doğrulama: 0.38 ile izole tam paket -AudioDriver WASAPI 36 paket PASS (STAIRS 30, CAMERA 7); ardından CAPSULE_RADIUS
  0.38 ile HOUSE LAYOUT 104 + CAMERA PASS. GPU: docs/qa/camera-clip/v017-*.png (0.30) ve v017-r38-corner-nook.png (0.38).
- Plan/doku/geometri değişmedi. Birleştirme: I08 (claude/wrist 36f1c36) ve bu dal Run-Tests listesinde ayrı satırlar ekliyor
  (wrist_test, camera_clearance_test) — ikisini birlikte alırken listeye ikisi de girmeli.
Sahibin kararı: 0.38 hissi beğenilmezse b03b0d1 tek başına geri alınabilir.
