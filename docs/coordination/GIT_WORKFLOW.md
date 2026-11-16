# Yerel Git ve iki asistanla çalışma

Uzak depo henüz yok; proje sahibinin seçimi yerel depoyla ilerlemek.
Son oyun sürümü main dalında; ortak çalışma hazırlığı chore/agent-coordination dalında.

## Aynı klasörde

- Aynı Git deposunda dal değişimi iki asistanın dosyalarını da değiştirir.
- Bu nedenle aynı klasörde aynı anda tek asistan kod yazar; diğeri salt okunur
  inceleme yapar veya çakışmayan belge/varlık görevini üzerine alır.
- Gerçek paralel geliştirmede her asistan için ayrı worktree/clone kullan.
- Commit öncesi diff'i incele, yalnızca kendi yollarını `git add <dosyalar>` ile ekle.
- Görev dalını doğrulanmış sonuçla bırak. Diğer asistan HEAD'i ve devir günlüğünü okur.

## Aktarım paketi

Temiz çalışma ağacında:

```powershell
powershell -NoProfile -File tools/Export-Handoff.ps1
```

Projenin yanındaki `handoff/` klasörüne iki dosya çıkar:

- ZIP: commit edilmiş kaynaklar ve ortak çalışma belgeleri. `.godot`, motor ve kayıtlar yok.
- BUNDLE: bütün yerel dalları içeren Git geçmişi. Uzak sunucu gerekmez.

Diğer asistan ZIP içindeki AGENTS.md'yi okuyarak başlayabilir. Yerelde geçmişle
çalışmak için (paketin gerçek adını kullan):

```powershell
git clone -b chore/agent-coordination TheQuietHours-COMMIT.bundle TheQuietHours-Coop
```

Paylaşılan klasöre GitHub parolası, token veya oyun kayıt dosyası koyma.
Uzak depo kurulunca origin eklenir; o zamana kadar GitHub'a yüklenmiş sayılmaz.
Bu klasör oturum tarafından oluşturuldu; paket de aynı oturum alanındaysa oturum
silinmesine karşı kalıcı yedek sayılmaz.
