# THE QUIET HOURS — Ev Kat Planı

Sürüm 0.3 · 2026-11-16 · **Durum: sahibin genişletme isteğiyle yeni geometri uygulandı; görsel inceleme sürüyor**

Planın kod karşılığı `scripts/house/house_layout.gd` dosyasıdır; ikisi çelişirse önce bu belge güncellenir. Sahibin son isteğiyle ana dolaşım şeridi 3m oldu; fizik/kapsül/merdiven testleri ve gerçek render kontrolü yapıldı. Baştan sona elle yürüyüş ayrıca açık; karar DecisionLog ve docs/qa/CorridorRebuild.md içinde kayıtlıdır.

Uygulamada netleşenler: merdiven iki duvar arasında kapalıdır (korkuluk yok). Zemin kat banyosuna, merdivenin dibindeki holün uzantısından girilir. Dış kapılar şimdilik kapalı panellerdir.

## Genel ölçüler

- Dış ölçü: 12 m (doğu–batı) × 10 m (kuzey–güney), iki kat.
- Koordinat: `x` batıdan doğuya 0–12, `z` kuzeyden (arka) güneye (ön) 0–10.
- Tavan yüksekliği 2,6 m; kat döşemesi 0,2 m; katlar arası yükseklik 2,8 m.
- Kapı genişliği 0,9 m (oyuncu kapsülü 0,6 m çapında; test odasında doğrulandı).
- Duvar kalınlığı: dış 0,2 m, iç 0,1 m.

## Zemin kat

| Oda | x | z | Ölçü (m) | Bağlantılar | Oynanış işlevi |
|---|---|---|---|---|---|
| Yemek alanı | 0–4 | 0–4,5 | 4 × 4,5 | Oturma odasına ve mutfağa açık | Toplu yemek, grup sahneleri |
| Oturma odası | 0–4 | 4,5–10 | 4 × 5,5 | Hole kapı; ön pencere | TV, radyo, toplanma |
| Mutfak | 4–9,5 | 0–3 | 5,5 × 3 | Hole kapı; kiler; tesisat odası; arka kapı | Yemek işi; arka çıkış (normalde kilitli) |
| Kiler | 9,5–12 | 0–3 | 2,5 × 3 | Yalnızca mutfaktan | Yiyecek ve malzeme stoğu |
| Hol | 4–7 | 3–8,5 | 3 × 5,5 | Giriş, mutfak, oturma odası, merdiven | Evin omurgası; gece seslerinin kesiştiği yer |
| Giriş holü | 4–8,2 | 8,5–10 | 4,2 × 1,5 | Ön kapı; hol; banyo | Kapıya gelenlerle konuşma |
| Merdiven | 7–8,2 | 3–7,5 | 1,2 × 4,5 | Alt ucu güneyde (z = 7,5), kuzeye doğru yükselir | Eğim yaklaşık 32°; çarpışma rampa biçiminde |
| Tesisat odası | 8,2–12 | 3–7,5 | 3,8 × 4,5 | Yalnızca mutfaktan | Jeneratör, sigorta kutusu, onarım malzemesi |
| Küçük banyo | 8,2–12 | 7,5–10 | 3,8 × 2,5 | Giriş holünden | Gece "masum" hareketlerin gerekçesi |

## Üst kat

| Oda | x | z | Ölçü (m) | Bağlantılar | Oynanış işlevi |
|---|---|---|---|---|---|
| Misafir odası B | 0–4 | 0–3 | 4 × 3 | Sahanlığın batı ucundan | 2 yatak |
| Misafir odası A | 0–4 | 3–6 | 4 × 3 | Koridordan | 2 yatak |
| Daniel'ın odası | 0–4 | 6–10 | 4 × 4 | Koridordan | Uyku, manuel kayıt |
| İzolasyon odası | 4–8,2 | 0–1,8 | 4,2 × 1,8 | Sahanlıktan; dışarıdan kilitlenir | 1 kişi; penceresiz |
| Sahanlık ve koridor | 4–8,2 / 4–7 | 1,8–3 / 3–8,5 | L biçimli | Merdivenin üst ucu z = 3'te | Gece nöbetinin ana noktası |
| Merdiven boşluğu | 7–8,2 | 3–7,5 | 1,2 × 4,5 | Korkuluklu | Alt kattaki sesler buradan duyulur |
| Çok amaçlı oda | 8,2–12 | 0–6,5 | 3,8 × 6,5 | Sahanlıktan | 2 yatak; yükseltmeyle 4 |
| Banyo | 8,2–12 | 6,5–10 | 3,8 × 3,5 | Koridorun güney ucundan | — |
| Depo dolabı | 4–8,2 | 8,5–10 | 4,2 × 1,5 | Koridordan | Yedek malzeme, saklanan eşyalar |

## Kapasite

Başlangıç: Misafir A (2) + Misafir B (2) + Çok amaçlı (2) = **6**. Yükseltme: çok amaçlı odaya iki yatak daha = **8**. Lily, Noah'ın yatağının yanındaki ek yatakta kalır ve kapasiteden bir kişi sayılır.

## Tasarım gerekçeleri

- **Tesisat odasına yalnızca mutfaktan girilir.** Jeneratöre giden herkes mutfaktan geçmek zorundadır; elektrik sabotajı için tanıklık ve erişim kanıtı üretir.
- **İzolasyon odası merdivenin tam karşısında.** Sahanlıkta nöbet tutan biri hem merdiveni hem izolasyon kapısını görür; ama doğu ve batı odalarının kapılarını aynı anda göremez.
- **Daniel'ın odası merdivenden en uzak köşede.** Uyuyan oyuncu alt kattaki olayı kaçırır; nöbet tutmak gerçek bir tercih olur.
- **Zemin katta yatak yok.** Gece zemin katta olan herkesin bir gerekçesi olmalıdır.

## Açık noktalar

- Pencere yerleri blockout sırasında belirlenecek (her yatak odasında en az bir, izolasyon odasında yok).
- Merdiven altı boşluk şimdilik kapalı hacim.
- Mobilya yerleşimi Faz 2'de.
