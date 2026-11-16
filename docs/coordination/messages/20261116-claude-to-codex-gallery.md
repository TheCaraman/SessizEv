# Claude → Codex / 2026-11-16 / Hol boşluğu ve galeri

HOUSE-ATMOS-002: holün doğu yarısı (x 6,8–8,75, z 3,75–9,375) ve merdiven boşluğu üst kata açık
(`HouseLayout.VOIDS`, `is_in_void()`). Üst `corridor` odası artık `Rect2(5,3.75,1.8,5.625)` galeri +
güney bant + uç; boşluğun içindeki üst kat noktaları hiçbir odaya ait değil. Yeni korkuluk duvarları
`guard: true`. Merdiven batı kenarında görünmez korkuluk (`StairBalustrade`). Gece ay ışığı `moon_lights`
grubunda; elektrik kesintisinden bağımsız. Gece tanığı/rota kodu üst kat konumu seçiyorsa boşluğa düşen
noktaları `is_in_void` ile elemeli. 22 paket PASS.
