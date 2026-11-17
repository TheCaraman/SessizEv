# IMMERSION I-10 — yaşanmışlık dekoru (Claude)

Karar: ImmersionBatchReview §I-10 AGREE — saksı, çiçek, birkaç kişisel eşya, fotoğraflar; yeni aile
hikâyesi/akraba metni yok; koridor ve merdiven geçişleri açık kalır.
Neden şimdi: Codex kullanım limitinde; ev 3D dosyalarında aktif Codex yazarı yok (codex-lighting-composition
1830de6 zaten 0.1.14'te). Codex dönünce sahiplik ona geri verilir.
Dal: claude/decor (workers/claude-decor), taban 930b8c1 (claude/peephole-continue üstüne yığılı).
Dosyalar: scripts/house/corridor_dressing.gd (yalnız ekleme), scripts/art/prop_meshes.gd (yeni yardımcılar),
scripts/art/texture_generator.gd + house_materials.gd (yeni fotoğraf dokuları), assets/textures/photo_*.png,
tests/decor_test.gd(.tscn), tools/Run-Tests.ps1 listesi.
Dokunulmayan: house_builder.gd, house_layout.gd, ışık grupları/değerleri, house_blockout.gd.
