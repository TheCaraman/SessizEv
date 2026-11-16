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
| POLISH-SLICE-001 | TAMAM | Codex (sahiplik bırakıldı) | Kesin onarım onayı, olay/saat ışığı, katman tonu, opak günlük, 10 paket/2349 denetim; elle tam oynama ayrı açık | 2026-11-16 |
| ART-REV-001 | TAMAM | Codex (sahiplik bırakıldı) | Sahip ART-REV-003 yönünü onayladı; ilk oda üretime bağlandı, diğer odalar ve TV/radyo katmanı açık | 2026-11-16 |
| NIGHT-001 | AKTİF | Codex | Saat/kayıt/UI bağlı ve 1440p sınandı; fiziksel giriş QA'sı açık; sonradan katılma düzeltildi, docs/qa/LateNightWatch.md | 2026-11-16 |
| NIGHT-002 | TAMAM | Codex (sahiplik bırakıldı) | Tek masum boru olayı, ses/altyazı, inceleme ve kayıt; 16 paket/5595 denetim; genel yönetmen değil | 2026-11-16 |
| ART-ROOM-001 | TAMAM | Codex (sahiplik bırakıldı) | Oturma odası arka planı; Claude kampanya içinde doğruladı. Ayrıntı claims/ART-ROOM-001.md | 2026-11-16 |
| ART-ROOM-002 | TAMAM | Codex sanatçı | 13 odanın tamamı görselli; e4e9dad, 388dec6 birleşimi; ArtBible ve docs/art | 2026-11-16 |
| ART-CHAR-001 | TAMAM | Codex sanatçı | Elena, Marcus, Arthur saydam figürleri; oda zemin hizası ve konuşma kadrajı | 2026-11-16 |
| ART-CHAR-002 | AKTİF | Codex | Elena çizimsel aday örneği ve konuşma önizlemesi; mevcut default.png korunur | 2026-11-16 |
| DAY4-DESIGN-001 | TAMAM | Tasarım alt ajanı + Codex incelemesi | docs/Day4Design.md; 0–3 sakin, karar/kayıt/erişim ve test matrisi; isimli gece ifadesi için gerçek gözlem önkoşulu; uygulanmadı | 2026-11-16 |

Yeni kayıt: ID, sahip, durum, düzenlenecek tam göreli yollar, başlama zamanı,
dayanak commit. Bitirince dosya sahipliğini bırak ve HANDOFF.md'ye sonuç yaz.

| SAVE-SAFE-001 | TAMAM | Codex (sahiplik bırakıldı) | scripts/save/save_manager.gd; tests/save_write_test.*; tools/Run-Tests.ps1; docs/qa/SafeSaveWrite.md | 2026-11-16 |

| SAVE-TXN-001 | TAMAM | Codex (sahiplik bırakıldı) | save_manager.gd commit_candidate, game_state.gd bildirim seçeneği, save_write_test.gd ve docs/qa/CandidateTransactions.md | 2026-11-16 |

| DAY4-REVIEW-001 | TAMAM | Codex (sahiplik bırakıldı) | day4_review.gd/json, CampaignDirector eylemi, EventBus/HouseBlockout/JournalView bağlantısı, localization, day4_review_test ve QA | 2026-11-16 |

| DAY4-EXPEL-001 | TAMAM | Codex (sahiplik bırakıldı) | resident_judgment.gd/json, CampaignDirector, localization, judgment test ve QA | 2026-11-16 |
