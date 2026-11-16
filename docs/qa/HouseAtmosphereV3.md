# HOUSE-ATMOS-004 — Kaynak temelli ev atmosferi

## Amaç ve dayanak
Sahip son sürümü renk, tasarım, ışık ve atmosfer açısından referanstan uzak ve basık buldu; evi baştan düzenlemeye izin verdi. 3f5fb32 dayanaklı ayrı codex/house-atmosphere-v3 worktree'sinde çalışıldı; kanonik klasörde Claude003'ün yarım dosyalarına yazılmadı. Galeri ve geniş açı/filtreden medet ummak yerine tam geniş dolaşım, sıradan kapalı kat hacmi, onaylı oturma odasıyla ortak çizimsel yüzey ve fiziksel ışık kaynakları kullanılır. Yeni oyun mekaniği yok.

## Gerçek değişiklikler
- Üst koridor1,8m galeri yerine3,75m ve tam döşemeli. Yalnız merdiven boşluğu açık. Atrium ve tepe penceresi kaldırıldı. 15×12,5m ayak izi ve3,3m kat yüksekliği korunur.
- Kaybolan başlangıç zemini geri geldi; başlangıçtan önce teleport yapan testlerin kaçırdığı düşme için doğrudan spawn/zemin testleri eklendi.
- x yönündeki korkuluk üst başlıkları artık doğru eksende. Tavan çıtası kapı üstlerinde kopuk parçalar yerine süreklidir.
- Üç özgün image_gen diffuse doku: assets/textures/painted_v3/{plaster,floorboards,door}.png. Promptlar/source_hint docs/art/prompts/house_atmosphere_v3.json. Mevcut ev görseli sadece sıva ve zemin üslup referansı; bir başka oyunun varlığı kopyalanmadı. Eski dokular ayrı yollarda korunur. Pikselleştirme ve dither yok.
- Duvar solmuş sıcak sıva, kapılar mat teal, nötr açık tavan, kahverengi ahşap, bordo yolluk. Yeşil renk tüm ekrana bastırılmaz. Ağır gölge ezme/sinema şeritleri kaldırıldı; hafif kontur ve çok az gren kalır.
- Ortam dolgusu gündüz.27/gece.13; lamba.32 ve sıcak renk. Gerçek pencere spotu3.8; yerel düşük güçlü yansıma dolgusu. Gece ışığı teal renkli3.8, saatle artar ve şebekeden bağımsızdır. Sis.008; göz kamaştıran bloom azaltıldı.
- Pencereler üst bölümde kısmen jaluzili, iki yanda açık krem kumaş perdeler; dış manzara görünür. Alt ve üst kaynaklar, ay ışığı ve elektrik kesintisi mevcut saat/kesinti durumundan güncellenir.
- Claude'un kapı kapanışı ve küçük eşyaları korunur. Aynı Gün1–3, oda kimlikleri, kayıt şeması ve enfeksiyon atamaları korunur. Yeni görüntü mevcut2D odaları filtrelemez.

## Dosyalar ve hiyerarşi
HouseLayout veri → HouseBuilder: Slabs, Walls/doors/windows, Stairs, Ceilings, Lamps, Runners, ExteriorVista, CorridorDressing. Window: collision pane/frame, top blinds, Curtain(mesh), Daylight(Spot), WindowBounce(Omni), Moonlight(Spot). HouseBlockout: saate bağlı Environment ve ışık önbelleği. Yeni autoload veya harici model/eklenti yok.

project.godot sürümü0.1.2-dev.20261116.3. Godot4.7.2 Forward+ ile import et. tools/Start-Game.ps1 -GodotPath <kurulu console.exe> kullan. Ayrı worktree nedeniyle bu parametre gerekir. Ana menüde version etiketi görünür. Tam Windows standalone export değildir.

## Test ve bitti ölçütü
Tam regresyon tools/Run-Tests.ps1 -GodotPath <console.exe>; spawn döşeme varlığı, merdiven iki yön, kapı açılış/kapanış ve odalara erişim, Gün1–3 ve kayıt devamı korunmalı. Gerçek GPU alt/üst gündüz-gece ve giriş görüntüleri incelenmeli. Sadece test yeşilliği estetik onay sayılmaz. Kameranın elle oynanış hissi ve sahibin sanat kabulü ayrıca açık. Yeni gece görseli sahte olay/tanık üretmez.

## Sınırlar
Bu özgün bir revizyondur, referans oyunun aynısı veya nihai ticari sanat değildir. Eşya ve çerçeve çizimleri hâlâ koddan basit geometridir. Claude003'ün commit edilmemiş lens/headbob adayları bu çalışma kopyasında yer almaz; silinmedi, kanonik klasörde korunur. Görsel hedef netleşince kapatılabilir erişilebilirlik ayarıyla entegre edilmelidir. Ses çıkışındaki daha önce raporlanan ObjectDB uyarısı bu görsel teslimin çözülmüş bir parçası değildir. Genel kampanya tamamlanmadı.

Doğrulama: son tam koşu22paket/6072denetim PASS (tqh-tests-a40c16e3ad104e98bbfd3e48b8b3a97e). HouseLayout99, yeni ilk spawn/zemin denetimleri dahil. Gerçek GPU alt/üst/giriş gündüz/gece görüntüleri docs/qa/house-v3 altında saklanır. Önceki galeri renderları eski QA belgelerinde tarihsel görüntülerdir; yeni plana ait sayılmamalı. Kaynak dokuların manifest boyut/hash bilgisi güncellendi.

Deneme hedefi: kökteki OYUNU_AC.cmd ve NOBETI_DENE.cmd bu dalın worktree'sindeki Start-Game.ps1'e kurulu motor yolunu açıkça vererek yönlendirilir. Önceki başlatıcılar runtime/checkpoints/before-house-v3 altında yedeklenir. Masaüstü THE QUIET HOURS.lnk aynı kök OYUNU_AC.cmd'ye bağlı kalır. runtime/active-development.json hangi kaynak dalının oynatıldığını bildirir. Ana project klasörüne entegrasyon yapılmış gibi anlatma; çalışan deneme kaynağı ayrı worktree'dir. Önceki oyun kapanıp yeniden açılmalıdır. Normal kampanya kaydı aynı user:// konumunu kullanır; başlatıcı kayıt silmez. Başlatma ön kontrolü sürüm0.1.2-dev.20261116.3 ve motor4.7.2 yolunu doğruladı.
