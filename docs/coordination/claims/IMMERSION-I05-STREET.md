# IMMERSION I-05 (Claude kısmı) — veranda ve sınırlı sokak kadrajı

Sahip: Claude. Worktree workers/claude-porch-street, dal claude/porch-street, taban 433d97c (0.1.14).
Dosyalar: scripts/house/exterior_vista.gd, yeni scripts/house/porch_set.gd, yeni scenes/dev/porch_review.tscn +
scripts/dev/porch_review.gd (yalnız GPU görüntü aracı), yeni tests/porch_test.*, tools/Run-Tests.ps1 (yalnız liste).
Kapsam: ön kapı önü veranda/basamak, saçak, kapı lambası, saksı çiçekler, paspas, yol, bahçe kapısı, posta kutusu,
karşı kaldırımda sokak lambası. Gezilebilir dış dünya, zincirli kapı, peephole bileşeni, RoomDoor, UI, input, strings YOK
(Codex). house_blockout ışık mantığına yazılmaz; mevcut window_lights / moon_lights / electric_lights gruplarına bağlanır.
Ziyaretçinin duracağı veranda alanı (x 6.7–8.3, z 12.9–14.0) boş bırakılır.
