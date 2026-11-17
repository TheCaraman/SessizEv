# Sahibin isteği: zaman öğreticisini Claude uygulasın

Kullanıcı Gün1 sabahında yalnız evde dolaştığı için kapının çalmadığını bildirdi; zamanın anlamlı eylemlerle ilerlediği açıklanınca bu durumu doğruladı. Ardından “bunları Claude yaptır” dedi.

AUTO-DAY1-TIME-GUIDANCE gerçek CLI kuyruğuna Claude uygulama/Codex inceleme olarak eklendi. ROOMS-002 kod işi e065d7e ile bitmiş olduğundan strings.csv yazarlığı bu sınırlı işe geçti. Manuel Claude'un Gün5 kodu aynı anda strings.csv düzenlememeli; teslim mesajı çıkınca bırakılacak.

Amaç: başlangıç HUD'unda keşfin zamanı ilerletmediğini, konuşma/eylemlerin ilerlettiğini ve Daniel'ın odasında dinlenebileceğini EN/TR anlatmak. Saat ve kritik kapı altyazısı okunur kalır. Mekanik değiştirilmez; oyuncuya gelecekte Elena'nın adı/18:00 takvimi gibi Daniel'ın bilmediği bilgi verilmez. Yeni otomatik saat veya erken NPC gelişi yok.

Dosyalar yalnız hud.gd, strings.csv/türevleri, campaign_test.gd, Day1TimeGuidance.md. Save/takvim/shelter/Run-Tests değişmez. Testler izolasyonlu; dış30WASAPI sonrası ayrı teslim. Şu an oyuncunun sürümü 0.1.9; görevlendirme özelliğin yayımlandığı anlamına gelmez. CLI çalışanı mevcut masaüstü Claude oturumuyla aynı bağlam değildir; bu mesaj ikisine ortak iş sınırı sağlar.
