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

| DAY4-REACTION-001 | TAMAM | Codex (sahiplik bırakıldı) | resident_judgment.gd/json, campaign_director.gd, localization, resident_judgment_test, QA | 2026-11-16 |

| DAY4-ISOLATE-001 | TAMAM | Codex (sahiplik bırakıldı) | isolation.gd/json, GameState konum, SaveManager doğrulama, ShelterManager/View, CampaignDirector, localization ve isolation test/QA | 2026-11-16 |

| DAY4-CARE-001 | TAMAM | Codex (sahiplik bırakıldı) | isolation.gd/json, localization, isolation_test ve QA | 2026-11-16 |

| NIGHT-WITNESS-001 | TAMAM | Codex (sahiplik bırakıldı; yalnız doğrulayıcı) | scripts/narrative/night_observation.gd, resources/events/night_observation.json, tests/night_observation_test.*, tools/Run-Tests.ps1, docs/qa/NightObservation.md | 2026-11-16 |

| VISUAL-REBUILD-001 | DEVİR | Codex (mekân test sürümü hazır; sahip incelemesi) | Sahibin geri bildirimi: koridor baştan, tüm odalarda çizimsel tutarlılık; ilk dilim room_door/house_builder, RoomView, EventBus, HouseBlockout ve etkileşim testi | 2026-11-16 |

| ART-LIGHT-UTILITY-001 | TAMAM | Codex (sahiplik bırakıldı) | assets/rooms/variants/utility_*.png, room_visuals.json, room_lighting_test, provenance ve QA | 2026-11-16 |
| CORRIDOR-REFERENCE-002 | DEVİR | Claude (sahip incelemesi; sahiplik bırakıldı) | Perde/çerçeve/küçük eşya ve üst koridor tamamlandı; docs/qa/CorridorProps.md. Nihai kabul sahibinde | 2026-11-16 |
| QA-AUDIO-EXIT-001 | BEKLİYOR | — | presentation_test kapanışındaki AudioStreamWAV/PlaybackWAV ObjectDB uyarısının yaşam döngüsünü çöz; işlev testleri geçiyor | 2026-11-16 |
| DOOR-CLOSE-001 | TAMAM | Claude (sahiplik bırakıldı) | Odadan çıkışta kapının kapanarak dönmesi (CLAUDE_HANDOFF madde 2): scripts/house/room_door.gd, tests/door_transition_test.*, docs/qa/DoorOpeningTransition.md | 2026-11-16 |
| HOUSE-ATMOS-001 | DEVİR | Claude (sahip incelemesi; sahiplik bırakıldı) | Sahip koridoru tamamen reddetti (2026-11-16): evi büyüt (plan ×1,25, kat yüksekliği 3,3 m), resmî Steam görsellerinden çıkarılan atmosfer diliyle koridoru baştan kur. Dosyalar: scripts/house/{house_layout,house_builder,corridor_dressing,exterior_vista}.gd, scripts/audio/door_audio.gd, scripts/art/*, shaders/retro_post.gdshader, scripts/dev/{house_blockout,corridor_review,capture_screenshots}.gd, scenes/main/house_blockout.tscn, tests/{house_layout,interaction,door_transition,door_audio}_test.gd, assets/textures/*, docs/HousePlan.md, docs/qa/HouseAtmosphere.md | 2026-11-16 |
| HOUSE-ATMOS-002 | DEVİR | Claude (sahip incelemesi; sahiplik bırakıldı) | İki kat yüksekliğinde hol, galeri, tepe penceresi, açık ev renkleri, gece ay ışığı. docs/qa/HouseAtmosphere.md | 2026-11-16 |
| HOUSE-ATMOS-003 | DEVİR | Claude | Loş ışık, hafif yaka kamerası merceği+salınımı, spawn ve korkuluk başlığı düzeltmesi; 22 paket PASS; docs/qa/HouseAtmosphere.md üçüncü tur. Sahip incelemesi ve 004 ile hangi yönün süreceği kararı bekleniyor. Dosyalar: scripts/dev/house_blockout.gd, scripts/house/{house_builder,corridor_dressing}.gd, shaders/retro_post.gdshader, scripts/player/body_cam_sway.gd (yeni), scenes/player/player.tscn, docs/qa/* | 2026-11-16 |

| ARRIVALS-DESIGN-001 | TAMAM | Claude | Yalnız docs/design/ArrivalSchedule.md; seed/takvim, kayıt geçişi ve eksik-NPC yolları; sayılar öneri, kod yok. Başlangıç Claude kaydıyla doğrulanacak. | 2026-11-17 |
| DAY4-RADIO-001 | TAMAM | Codex ayrı worktree | Radyo final GPU/metadata/Git teslimi; campaign_director/save_manager/game_state/strings.csv koduna paralel yazılmasın. | 2026-11-17 |

| ARRIVALS-001 | AKTİF — AŞAMA A TAMAM | Claude | claude-arrivals/93a340f altyapısı mevcut; B entegrasyonu fc36917 tabanına alınacak. Takvim/save/ziyaret kodunda tek yazar. | 2026-11-17 |
| ROOMS-DESIGN-001 | TAMAM — ayrı dal | Codex / Claude incelemesi | Uygulama sözleşmesi continuous-integration/ee9ea50 içinde; yalnız belge, UI ve oyun özelliği henüz yok. | 2026-11-17 |
| ROOMS-EVALUATOR-001 | TAMAM — ayrı dal | Codex CLI / Claude incelemesi | continuous-integration/06d4e92; saf modül ve shelter 80 kontrol, dış 28 paket WASAPI geçti. UI/save entegrasyonu yok. | 2026-11-17 |

| COORDINATOR-002 | TAMAM | Codex | İki gerçek CLI worker→diğer sağlayıcı incelemesi→28 paket Godot test kapısı geçti; durdur/yeniden başlat doğrulandı. Ayrı integration dalı, aktif oyuna otomatik dağıtım yok. docs/qa/ContinuousCoordinator.md | 2026-11-17 |

| ARRIVALS-CHAIN-001 | TAMAM | Claude CLI / Codex incelemesi | ec15e36, 30 paket WASAPI/7406 raporlanmış kontrol; geliş entegrasyonu 249. 0.1.9 olarak Codex tarafından ayrıca yayımlandı; otomatik dağıtım değil. | 2026-11-17 |
