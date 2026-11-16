# Görev sahipliği

Durumlar: BEKLİYOR / AKTİF / DEVİR / TAMAM. Zaman Europe/Istanbul.
Bir görev yalnızca açıkça listelenen dosyalarda yazma hakkı bildirir; gerçek kilit sağlamaz.

| ID | Durum | Sahip | Kapsam / dosyalar | Başlangıç |
|---|---|---|---|---|
| COORD-001 | TAMAM | Codex (sahiplik bırakıldı) | AGENTS.md, CLAUDE.md, README.md, docs/coordination/*, tools/Run-Tests.ps1, tools/Export-Handoff.ps1 | 2026-11-16 |
| SAVE-002 | TAMAM | Claude (sahiplik bırakıldı) | Ana menü, duraklatma menüsü, elle kayıt ve kayıttan devam. Dal: feat/save-002-menu-continue. Ayrıntı HANDOFF.md | 2026-11-16 |
| DAY2-001 | TAMAM | Codex (sahiplik bırakıldı) | docs/Day2Design.md, docs/coordination/claims/DAY2-001.md; uygulama ayrı görev | 2026-11-16 |
| DAY2-002 | TAMAM | Claude (sahiplik bırakıldı) | Gün 2 ziyaretleri, diyalogları, yatak seçimi, kayıt v2 ve göç. Dal: feat/day2-002-arrivals. Ayrıntı HANDOFF.md ve claims/DAY2-002.md | 2026-11-16 |
| DAY2-003 | TAMAM | Codex otomatik işçi | İş/oda yönetimi, kayıt v3, 968 denetim; commit 1b3ee8f | 2026-11-16 |
| QA-DAY1-2 | TAMAM | Codex otomatik işçi | Gerçek menü geçişi/kayıt/gece tüketimi entegrasyonu; toplam 1524 denetim; b3590ae | 2026-11-16 |
| DAY3-001 | TAMAM | Codex otomatik işçi | b39c60d: koşullu kesinti, kanıt, günlük; 2250 denetim | 2026-11-16 |
| POLISH-SLICE-001 | AKTİF | Ana Codex oturumu | Yardım uygunluğu ve opak günlük tamam; zaman/güç ışığı ve taşma kontrolü açık; otomatik işçi yok | 2026-11-16 |
| ART-REV-001 | AKTİF | Codex | docs/art/AtmosphereRevision.md ve inceleme örneği; üretim PNG dosyaları korunur | 2026-11-16 |
| ART-ROOM-001 | TAMAM | Codex (sahiplik bırakıldı) | Oturma odası arka planı; Claude kampanya içinde doğruladı. Ayrıntı claims/ART-ROOM-001.md | 2026-11-16 |
| ART-ROOM-002 | TAMAM | Codex sanatçı | 13 odanın tamamı görselli; e4e9dad, 388dec6 birleşimi; ArtBible ve docs/art | 2026-11-16 |
| ART-CHAR-001 | TAMAM | Codex sanatçı | Elena, Marcus, Arthur saydam figürleri; oda zemin hizası ve konuşma kadrajı | 2026-11-16 |

Yeni kayıt: ID, sahip, durum, düzenlenecek tam göreli yollar, başlama zamanı,
dayanak commit. Bitirince dosya sahipliğini bırak ve HANDOFF.md'ye sonuç yaz.
