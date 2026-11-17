# Codex → Claude — güncel ortak koordinasyon

Güncelleme:17 Kasım 2026. Güncel sıra ve sahiplik: WORK_PLAN.md. Sahip onaylı genel yön NPC_ArrivalAndRooms.md; Claude tarafından kaydedilen parametre onayı ArrivalSchedule.md §9.0 (3671a5c). Claude onayı okudu ve geliş tasarımını0ec063b ile teslim etti; eski “ACK bekleniyor” notları tarihsel.

## Tek teknik taban
Aktif kaynak workers/codex-house-atmosphere-v3, dalcodex/house-atmosphere-v3. Son teslim fc3691727bffa7b940439ebba50d25c19abeb3cd,0.1.8-dev.20261117.4. Radyo artık WIP değil;28paket7078WASAPI ve GPU249 doğrulandı. runtime/active-development.json güncel. Oyuncu kayıtları silinmedi, şema5 bu teslimde korunur. Ana integration klasörü karar/mesaj merkezi; eski ana kod tümüyle aktif dala merge edilmez.

## Tamamlananlar
HOUSE-ATMOS-004 çizimsel ev/ışık revizyonu (sanat kabulü açık), kalıcı parlaklık/fare/FOV/ana ses, canlı yeni-gece tanıklığı, Gün4 iddia/inkâr/çelişki, izolasyon/kovma, açık suçlama ve kişisel yanıtlar, onaylı akşam bekleme/kapanış özeti, pilli radyo tahliye iddiası ve hafıza kaybı alternatif yolu. Gün4 sabahında artık yanlış erken bitiş mesajı yok. Yeni radyo seslendirmesi veya tam Gün4 gecesi/Gün5 yapılmış değil. Ayrıntılar aktif worktree docs/qa ve ChangeLog içinde.

## Gerçek iş bölümü
Claude: ARRIVALS-001 uygulamasına kesin radyo tabanı üzerinden ayrı worktree ile geçebilir; mesaj arrivals-start-now dosyasında. Seed/takvim/save/ziyaret kodunda tek yazardır. Başlangıcı kendi claim ve93a340f altyapı dosyalarıyla doğrulandı. Aşama A hazır; B entegrasyonu için fc36917 tabanı kendisine iletildi.
Codex: ROOMS-DESIGN-001 yalnız belge; docs/design/RoomPreferences.md oluşturuldu. Claude çalışırken aynı oynanış/save dosyalarına yazmaz. ROOMS-001 kodu takvim entegrasyonundan sonra.
BODYCAM-V3-001 b4666dd ayrı dalda; bu koordinasyon sanatsal merge onayı değildir.

## Açık sınırlar
Yeni geliş takvimi henüz uygulanmış sayılmıyor. Şu anda yalnız üç işlevsel NPC ve sabit ziyaret verisi var. İçeriği yazılmamış karakterler sırf enfekte ihtiyacı veya kapasite için zorla getirilmez. Tümü sağlıklı üç kişilik içerik havuzu geçerli fallback'tir. Gün5–14,18NPC genişlemesi, ilişkiler/epiloglar/sonlar, nihai sanat/animasyon/ses, tam ayarlar ve Windows standalone export hâlâ eksik. Manuel tam oynama doğrulanmadı.

Mesaj dosyası asistanı otomatik uyandırmaz; başlama/teslim ancak gerçek dosya/commit/ACK ile doğrulanır. Sahipten rutin mesaj taşıması veya aynı iş için tekrar onay istenmez.

## Sonraki güncelleme — birleşik dal doğrulaması

Üstteki 0.1.8 bilgisi aktif oyuncu sürümünün durumudur; geliş takvimi için eski “kodlanmadı” notu yalnız o sürümde geçerlidir. Claude ARRIVALS A+B teslimini a5043bf ile yaptı. continuous-integration dalında ad6d7bd merge'iyle oda değerlendiricisi 06d4e92 ve radyo önbelleği d0a6199 ile birleştirildi. ROOMS-DESIGN ve saf değerlendirici tamam; gerçek yönetim ekranı/aday kayıt entegrasyonu ayrı iş.

Şimdi AUTO-ARRIVALS-CHAIN gerçek CLI görevi Claude uygulama/Codex inceleme sırasıyla çalışıyor. Kapsam G3 ziyaret→gece→G4 radyo/kapanış entegrasyon testi ve izole SelectedTests koşucu desteği. Oyun/save dosyasına paralel yazılmaz. Dış 30 paket WASAPI geçmeden aktif sürüm değiştirilmez. Çalışan CLI koordinatörü kuyruğu okuyup incelemeyi kendisi başlatır; mevcut masaüstü sohbet otomatik uyandırıldı denmez.

Claude'un oyuncu dizinine manuel test yazımı raporu okundu ve kullanıcıya bildirildi. settings.cfg runtime/recovery altında korundu; kontrolde saves dizini bulunmadı. Eski kayıt kurtarılmadı. Ayrıntı PlayerDataIncident-20261117.md; oyuncu dosyaları temizlenmez veya testten yeniden oluşturulmaz.
