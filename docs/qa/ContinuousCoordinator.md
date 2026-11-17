# Sürekli görev ve bağımsız inceleme yöneticisi

## Neyi çözer
Ortak mesaj dosyası tek başına modeli uyandırmaz. Bu yönetici, mevcut hesap girişlerini kullanan Codex/Claude CLI süreçlerini çağırır. Bir çalışan görevi yapar; diğer sağlayıcı salt okunur inceleme yapar. Düzeltme geri bildirimi otomatik olarak uygulayıcıya döner. Onaydan sonra dış Godot test kapısı çalışır; ancak sonra ayrı integration dalına alınır.

Bu, masaüstündeki iki sohbetin aynı bağlamla kendiliğinden devam etmesi değildir. CLI çalışanları her görevde açık talimat ve proje/önceki inceleme kaydıyla başlar. Görevler bitince süreç boşta kalır; yeni kuyruk satırlarını30saniyede yükler, boşta modele çağrı yapmaz. Yeni görevler onaylı kapsamdan kuyrukla verilir; kendi kendine yeni yaratıcı yön veya sınırsız görev üretmez.

## Gerçek kaynaklar
- Versioned: project/tools/automation/{base_runner.py,coordinator.py,test_coordinator.py,Initialize-Continuous.ps1,Start-Continuous.ps1,Stop-Continuous.ps1,Show-Continuous.ps1}.
- Makineye özel kuyruk: TheQuietHours/queue.continuous.json. Eski queue.json ve runtime/state.json korunur.
- Durum/günlükler: runtime/continuous/state.json, events.jsonl, host.pid ve görev günlükleri. DURUM_OTOMATIK.txt okunur özettir.
- Kaynak hedefi: workers/continuous-integration, automation/continuous-development. Aktif oyuncu worktree ve Claude ARRIVALS dosyaları değiştirilmez. Her görev ayrıca kendi worktree dalını alır.
- Ortak mesajlar: project/docs/coordination/messages/auto-*.md. Worker ve inceleyici raporları oraya otomatik bırakılır; bunlar masaüstü sohbetin okuma onayı sayılmaz.

## Başlat / durdur / durum
Kök klasörde OTOMASYONU_BASLAT.cmd, OTOMASYONU_DURDUR.cmd, OTOMASYON_DURUM.cmd var. Start aynı süreç gerçekten yaşıyorsa ikinci kopya açmaz. Stop yalnız bu yöneticiye işaret yazar; görev ağacı korunur, çalışan alt süreç yönetici tarafından durdurulur. Durum komutu yalnız eski metne güvenmez, PID ve komut satırıyla gerçek süreci kontrol eder.

Bilgisayar ve bağlantı kullanılabilir olmalı; hesap oturumu/kotası geçerli olmalı. API anahtarı oluşturulmaz, API ücretlendirmesine otomatik geçilmez. Çocuk ortamından API anahtarları ve bu masaüstü sohbetine ait IPC ayarları çıkarılır. Girişler login status/auth status ile doğrulandı; gizli auth dosyaları okunmadı/paylaşılmadı.

## Güvenceler ve sınırlar
Görev başına ençok8 model çağrısı; rol/kapsam/başlangıç kontrolü. Hedef dal değişirse, HEAD ilerlerse, kapsam dışı dosya değişirse veya salt okunur inceleyici adayı değiştirirse entegrasyon engellenir ve çalışma korunur. Kayıtlı bir görevin kapsamı başladıktan sonra değiştirilemez; yeni görev kimliği gerekir. Bağımlılık döngüsü/bilinmeyen görev reddedilir. İnceleyici yoksa tamamlanan uygulama tekrar tekrar üretilmez; quota/auth beklemesi ayrı tutulur. Yeni yaratıcı karar needs_owner durumuna gider. Manuel devam eden Claude işi otomatik devralınmaz.

Test hedefi mevcut Godot4.7.2 ve WASAPI; işçilerin kendi done iddiası yeterli değildir. Aktif masaüstü oyun kısayolu otomatik değiştirilmez. Ayrı integration sonucu teslim kaydıyla incelenebilir; ana sürüme geçtiği ayrıca doğrulanmadan söylenmez. OS başlangıcında kendiliğinden açılma ve uygulama kapatılınca her durumda hayatta kalma bu teslimde test edilmedi.

## Pilot ve doğrulama
Mekanik birim testleri15 vaka: iki farklı sağlayıcı sırası, review feedback, reviewer yokken tekrar etmeme, review değişikliği engeli, test hatası, gerçek sahip kararı, çağrı sınırı, kota/kısmi dosya koruma, canlı kuyruk, başlayan görevi değiştirememe, bağımlılıklar/hedef sabitliği, STOP aktarımı, API fallback yokluğu ve kontrol dosyası kapsamı.

Gerçek pilot iki iş: AUTO-ROOMS-DESIGN(Codex→Claude) ve ardından AUTO-RADIO-CACHE(Claude→Codex). İkinci iş ilkine bağlı; aynı integration HEAD üzerinde yarışmazlar. İlk görev gerçek Claude incelemesi ve dış Godot kapısından geçti: 28 paket, WASAPI; integration commit ee9ea50f7d74550198ccc62ff395a5d442f692df. Kendi kendine geçen birim testi gerçek model veya gerçek Godot başarısı yerine sayılmaz.

İkinci görevde Claude uygulamayı tamamladı. İlk Codex incelemesi, Claude'a özgü Read/Glob/Grep ve komut yasağı talimatı nedeniyle dosya erişimi sağlayamadı. Bu teknik talimat hatası sahip kararı değildir. Yönetici durduruldu; inceleme talimatı sağlayıcıya uygun salt okunur araçlara düzeltildi; 15 birim testi tekrar geçti. Önceki inceleme state içinde review_access_retry alanında ve günlüklerde korundu. Yalnız inceleme yeniden kuyruğa alındı; uygulama ve çağrı sayacı sıfırlanmadı.

Tekrarlanan gerçek Codex incelemesi approved döndürdü; ardından dış Godot kapısında 28 paket ve DAY4 RADIO TEST 249 kontrol geçti. İkinci integration commit d0a6199fb8fb2beff6725868434fb2731902c4f2. İlk görev toplam 2, ikinci görev erişim hatası dahil toplam 3 model çağrısı kullandı. İki sonuç da ayrı integration dalında; aktif oyun sürümüne alınmadı.

Yönetici iki iş bittikten sonra Stop-Continuous ile durduruldu; süreç 25428 sona erdiği doğrulandı. Start-Continuous ile 25260 olarak yeniden başladı. Tamamlanan işler ve çağrı sayaçları korundu; yeniden uygulama başlamadı. Yeniden başlatma sonrası durum ayrı makine kanıtı coordinator-live-pilot.json içindedir. Boş kuyrukta yeni iş icat edilmez; koordinatör onaylı sonraki işleri eklemelidir.

## Kuyruk bakımı
İş kimliği harf/rakam/tire, instruction Türkçe, allowed_paths dar, required_test_markers gerçek kapıyla uyumlu olmalı. Başlamış işi değiştirme veya silme; düzeltme ayrı ID. İzolasyon, save ve takvim dosyalarını iki görev/manuel çalışan aynı anda sahiplenmemeli. Kuyruğa yeni iş eklemek/incelemek koordinatör rolündedir; çalışana supervisor veya izin ayarlarını değiştirme yetkisi verilmez.
