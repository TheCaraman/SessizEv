# Aktif çalışma planı — 17 Kasım 2026

TAŞINMA: tek yazım kökü artık E:/TheQuietHours. Ortak depo E:/TheQuietHours/project; bütün workers/tools/runtime taşındı. C: konumu yalnız güvenlik kopyasıdır. Ayrıntı messages/20261117-project-moved-to-e.md. Oda işi kuyruğu E: üzerinden yeniden başlatıldı; manuel Claude ARRIVALS-002 de E: altındaki kendi worktree'sinde sürmeli.

Aktif deneme kaynağı: workers/dev-0.1.9, release/dev-0.1.9 @ 8de58a62496d8c7140e493899951a407e2f182bc. Masaüstü kısayolunun kök başlatıcısı güncellendi. Eski 0.1.8 worktree ve başlatıcı checkpoint'i korunuyor. Ana integration klasörü ortak karar/mesaj merkezi; eski ev kodu topluca aktif dala taşınmaz.

| İş | Sorumlu | Doğrulanmış durum | Dosya sınırı / sonraki adım |
|---|---|---|---|
| DAY4-RADIO-001 | Codex | TAMAM,28paket7078+GPU249 | Checkpoint yayımlandı; Claude artık bunu beklemiyor. |
| ARRIVALS-DESIGN-001 | Claude | TAMAM,0ec063b; parametre kararı3671a5c | ArrivalSchedule.md ve §9.0 okunup incelendi. |
| ARRIVALS-001 | Claude | TAMAM; 0.1.9 içinde | a5043bf normal merge ile alındı, birleşik 30 paket WASAPI geçti; v6/eski sabit takvim korunur. |
| ROOMS-DESIGN-001 | Codex / Claude incelemesi | TAMAM ee9ea50 | Uygulama sözleşmesi ayrı geliştirme dalında. |
| ROOMS-EVALUATOR-001 | Codex / Claude incelemesi | TAMAM 06d4e92; 28 paket WASAPI | Saf hesaplama; UI/save entegrasyonu yok. |
| ARRIVALS-CHAIN-001 | Claude CLI / Codex incelemesi | TAMAM ec15e36 | G3→G4 üç dal, 249 entegrasyon kontrolü; 30 paket/7406 raporlanmış kontrol WASAPI. |
| ROOMS-001 | Codex | SIRADA | Takvim kodu incelenip entegre edildikten sonra. |
| BODYCAM-V3-001 | Claude | AYRI DALDA HAZIR | Görsel birleştirme onayı açık; geliş işine eklenmez. |

Tasarım onayı veya dosya mesajı, kodun çalıştığı veya diğer asistanın fiilen başladığı anlamına gelmez. Claude kendi claims/ARRIVALS-001.md ve ACK kaydıyla başlangıcını bildirir. Teslimde test kanıtı ve kalan iş listesi şart; rutin adımlar için sahibin iki asistan arasında mesaj taşıması istenmez.

CLI koordinatörü çalışıyor; runtime/continuous ve queue.continuous.json gerçek durum kaynaklarıdır. Eski manuel masaüstü sohbetle CLI çalışanı aynı bağlam değildir. İki yönlü inceleme ve dış kapı pilotları doğrulandı. Oyuncu verisine manuel test yazımı olayı docs/qa/PlayerDataIncident-20261117.md içinde açık; mevcut ayarlar korundu, eski kayıt kurtarıldı denmez. Tüm testler izole koşucu üzerinden yapılır.
