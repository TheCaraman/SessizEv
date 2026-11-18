# NPC-ACTOR-3D-001 — Elena 3D'yi evde yürüten teknik katman

Sahip: Claude (Codex/GPT haftalık limiti doldu; sahip "yazılımsal kısımları sen yap" dedi, 2026-11-18).
Dal: `claude/npc-actor-3d`, taban `release/dev-0.1.22` (cbbad17). Kampanyaya, HouseLayout/Builder'a ve sanata dokunulmadı.
Model: Codex'in `assets/models/elena_v7` dosyaları `codex/elena-volume-v8` dalından aynen kopyalandı (değiştirilmedi). Model sahip tarafından henüz kabul edilmedi; bu iş yalnız teknik bağlamadır.

## Ne eklendi

| Dosya | Ne yapar |
|---|---|
| `scripts/npc/npc_routes.gd` (`NpcRoutes`) | Yalnız `HouseLayout`'tan (sahne/fizik yok) iki oda arası zemin rotası. Kapı boşluklarından (duvar açıklığı) ve bitişik gezilebilir odalardan (giriş, hol, sahanlık, koridor) bir oda grafiği çıkarır; BFS ile en kısa oda zinciri; her kapıdan önce-kapı-sonra üç nokta. |
| `scripts/npc/npc_walker.gd` (`NpcWalker`) | Rota boyunca yürüme matematiği: sabit hız, köşede dönüş (5 rad/s) ve dönüş büyükse 0,3x yavaşlama, büyük kare süresinde birden fazla bacağı geçme. Düğümsüz, test edilebilir. |
| `scripts/npc/npc_actor_3d.gd` (`NpcActor3D`) | Rigli modeli yükler (`Idle_8fps`/`Walk_8fps` bekler), `walk_route()` ile yürütür, yüz yönünü yürüyüş yönüne çevirir, yürüme klibinin oynatma hızını gerçek hızdan ayarlar, varınca `arrived` yayar. Model yoksa/animasyonu eksikse `load_model` false döner. |
| `tests/npc_actor_3d_test.*` | 1193 denetim (aşağıda). `Run-Tests.ps1` listesine eklendi. |
| `scripts/dev/npc_walk_demo.gd`, `scenes/dev/npc_walk_demo.tscn` | Gerçek evde Elena odadan odaya yürür; sen de dolaşabilirsin. N: sıradaki odaya hemen git. |
| `scripts/dev/npc_walk_review.gd`, `scenes/dev/npc_walk_review.tscn` | Yalıtılmış proje kopyasında GPU'lu görüntü alır (`docs/qa/npc-actor-3d/*.png`). |
| `tools/Start-Game.ps1` | `-WalkDemo` anahtarı (NightDemo gibi: ayrı proje kopyası, ayrı kullanıcı dizini; gerçek kayıtlara dokunmaz). |
| `E:\TheQuietHours\DENE_NPC_YURUYUS.cmd` | Sahip denemesi için başlatıcı. |

## Önemli bulgu: yürüme klibi çok yavaş/kısa adımlı

Ölçüm (testte): `Walk_8fps` 1,042 sn; sol ayak 0,28 m geriye 0,673 sn'de kayıyor ⇒ klibin yazıldığı zemin hızı yaklaşık **0,42 m/s** (adım başına 0,28 m). `NpcActor3D.CLIP_SPEED = 0,4`.
- Evde sakinlerin makul hızı yaklaşık 0,9 m/s (`WALK_PACE`) ⇒ klip 2,25x oynuyor, ayaklar kaymıyor ama adımlar sık görünür (8 fps'lik STEP örnekleme 18 fps'e çıkar).
- Daha doğal olması için sanat tarafında klibin yaklaşık 1,0–1,2 m/s için yeniden yazılması gerekir (adım uzunluğu ~0,6 m). Kod buna hazır: yalnız `CLIP_SPEED` sabiti ve test ölçümü değişir; test klibin ayak hızını ölçüp sabitle karşılaştırır (±%20), yani yeni klip eski sabitle gelirse test bunu yakalar.

## Doğrulananlar (`npc_actor_3d_test`, 1193 denetim)

- **Rotalar (gerçek plan):** 14 odanın tüm çiftleri erişilebilir (182 rota); başlangıç/bitiş oda merkezi; iki yönde aynı uzunluk; her örnek nokta (0,1 m) bir odanın içinde; en uzun rota < 35 m; depo yalnız banyodan, servis yalnız mutfaktan, misafir odası kendi kapısından geçiyor.
- **Walker:** 6 m, 1,2 m/s ⇒ 5 sn; hiçbir karede set hızı aşılmıyor; köşede yavaşlıyor ama rota çizgisinden hiç sapmıyor (<1 mm); dev kare tüm bacakları geçip tam son noktaya iniyor; stop / tek nokta / sıfır ve negatif delta güvenli.
- **Actor:** eksik model reddediliyor ve boş kalıyor; modelsiz aktör yine de rotayı bitiriyor; 17 kemikli tek iskelet; yürüyüşte yürüme klibi, varışta bekleme klibi, `gait_changed` (walk, idle) ve `arrived` birer kez; yüz yönü +X yürüyüşünde +90°; yarı hızda klip yarı hızda, çok düşük hızda klip donmuyor; stop → idle.
- **Gerçek evde (fizik):** tüm rotaların her noktasının altında zemin var; ardışık noktalar arasında 0,35/0,9/1,6 m yükseklikte duvar yok (kapılar ve oyuncu hariç); aktör servis odasından Daniel'ın yatak odasına 15,9 m'lik rotayı fizik karelerinde yürüyüp varıyor, hep bir oda içinde, odaları sırayla geçiyor, süre ≈ uzunluk / hız.
- **Demo:** tur geçerli, sahne kuruluyor, aktör yürümeye başlıyor.
- Hem normal hem WASAPI (sızıntı kapısı) geçti.

## Görüntü

`docs/qa/npc-actor-3d/`: `front.png` (koridorda kameraya doğru yürüyor, yüzü kameraya dönük), `side.png`, `corner.png`. Gerçek GPU (Forward+, GTX 1080 Ti), yalıtılmış proje kopyası. Yüz yönü doğru; ölçek kapılarla uyumlu. Modelin kendisi (yüz/doku/saç) Codex'in çalışma modeli, değerlendirmesi sahibe ait.

## Yapılmayanlar / sınırlar

- Elena kampanyada 3D olarak görünmüyor; oda ekranı (2D) ve kapı deliği aynen. Kampanyaya bağlamak için sahibin kararı ve yeni model kabulü gerekir (hangi sakin, ne zaman 3D görünsün, kapı geçişinde ne olsun).
- Aktör fiziksel bir engel değil (çarpışma gövdesi yok), oyuncu içinden geçebilir; oyuncuyla karşılaşma/yol verme yok.
- Merdiven yok (tek kat plan); kapılar açık/kapalı oynamıyor (rota kapı boşluğundan geçiyor, kapı yaprağı oynamıyor).
- Idle yalnız tek poz (Idle_8fps iki anahtarlı); oturma/yatma/iş pozları yok (NpcRoutine'in poz tablosuna hazır ama klip yok).
