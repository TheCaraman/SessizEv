# Aktif çalışma planı — 17 Kasım 2026

Tek kaynak kod tabanı: codex/house-atmosphere-v3 @ fc3691727bffa7b940439ebba50d25c19abeb3cd (0.1.8). Ana integration klasörü ortak karar/mesaj merkezi; eski ev kodu topluca aktif dala taşınmaz.

| İş | Sorumlu | Doğrulanmış durum | Dosya sınırı / sonraki adım |
|---|---|---|---|
| DAY4-RADIO-001 | Codex | TAMAM,28paket7078+GPU249 | Checkpoint yayımlandı; Claude artık bunu beklemiyor. |
| ARRIVALS-DESIGN-001 | Claude | TAMAM,0ec063b; parametre kararı3671a5c | ArrivalSchedule.md ve §9.0 okunup incelendi. |
| ARRIVALS-001 | Claude | TESLİM a5043bf; birleşik dalda | continuous-integration/ad6d7bd içinde; bağımsız birleşik test ve yayın henüz yok. |
| ROOMS-DESIGN-001 | Codex / Claude incelemesi | TAMAM ee9ea50 | Uygulama sözleşmesi ayrı geliştirme dalında. |
| ROOMS-EVALUATOR-001 | Codex / Claude incelemesi | TAMAM 06d4e92; 28 paket WASAPI | Saf hesaplama; UI/save entegrasyonu yok. |
| ARRIVALS-CHAIN-001 | Claude CLI / Codex incelemesi | AKTİF | G3→G4 gerçek eylem zinciri, izole tek-paket çalıştırıcı; ardından dış 30 paket WASAPI. |
| ROOMS-001 | Codex | SIRADA | Takvim kodu incelenip entegre edildikten sonra. |
| BODYCAM-V3-001 | Claude | AYRI DALDA HAZIR | Görsel birleştirme onayı açık; geliş işine eklenmez. |

Tasarım onayı veya dosya mesajı, kodun çalıştığı veya diğer asistanın fiilen başladığı anlamına gelmez. Claude kendi claims/ARRIVALS-001.md ve ACK kaydıyla başlangıcını bildirir. Teslimde test kanıtı ve kalan iş listesi şart; rutin adımlar için sahibin iki asistan arasında mesaj taşıması istenmez.

CLI koordinatörü çalışıyor; runtime/continuous ve queue.continuous.json gerçek durum kaynaklarıdır. Eski manuel masaüstü sohbetle CLI çalışanı aynı bağlam değildir. İki yönlü inceleme ve dış kapı pilotları doğrulandı. Oyuncu verisine manuel test yazımı olayı docs/qa/PlayerDataIncident-20261117.md içinde açık; mevcut ayarlar korundu, eski kayıt kurtarıldı denmez. Tüm testler izole koşucu üzerinden yapılır.
