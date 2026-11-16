# Yerel otomatik geliştirme

Bu yürütücü mevcut kullanıcı girişleriyle Codex CLI / Claude Code çalıştırır.
API anahtarlarını alt süreç ortamından çıkarır; ayrıca API faturası başlatmaz.
Kullanım sınırları geçerlidir. Kalıcı kurulumu tamamlayan settings.local.json
ve kuyruğu proje dışındaki otomasyon klasöründe tutun.

Akış: kuyruk → görev worktree'si → asistan → kapsam kontrolü → Godot testleri →
yalnızca başarılı sonuçta ff-only birleştirme → sonraki görev.
Başarısız giriş/kota durumunda aynı yarım çalışma korunup diğer sağlayıcı denenir.
Her iki sağlayıcı da kapalıysa waiting_provider yazılır. Kota nedeniyleyse süreç
süre sınırı içinde bekleyip yeniden dener; sadece giriş eksikse beklemez.
Yeniden çalıştırma kaldığı
worktree'den devam eder. Sonuçlar runtime/state.json, events.jsonl ve DURUM.txt içindedir.

Sınırlar: her görev en fazla 4 deneme, her asistan çağrısı 25 dakika, bu kuyruk
toplam dört saat hedefi ve iki tanımlı görevle sınırlı. Yeni görevleri kendiliğinden
icat etmez. Yaratıcı karar needs_owner durumunda durur. Ana projeye dışarıdan
değişiklik gelirse sonucu ezmez; review_required olarak saklar.

STOP dosyası yürüyen asistanı birkaç saniye içinde durdurur; test fazı kendi
zaman aşımı veya tamamlanma sınırında durur.
Zaman aşımı yürütücünün kendi alt süreç ağacını sonlandırır; dosyalar korunur.
Asistanlar aynı anda aynı klasörü düzenlemez; bu ilk sürüm görevleri sırayla işler.
Worktree izolasyonu dosya çakışmasını azaltır; tam bir işletim sistemi güvenlik
sınırı değildir. Codex workspace-write/otomatik inceleme, Claude acceptEdits ve
sınırlı araç listesi kullanır. Onay engeli olursa limitsiz yetki vermek yerine raporlar.

Çalıştırma:

```
python supervisor.py --config /absolute/path/queue.json
python supervisor.py --config /absolute/path/queue.json --status
python -m unittest discover -s tools/automation -p test_supervisor.py
```

Testler sahte asistan cevaplarıyla gerçek geçici Git depoları/worktree'leri kullanır.
Hesap girişi ve canlı model erişimi ayrıca bir canlı çalıştırmada doğrulanmalıdır.
Masaüstü sohbetlerini uyandırmaz; bağımsız CLI işçileri başlatır.
