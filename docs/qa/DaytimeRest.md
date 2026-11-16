# Nöbet sonrası gündüz dinlenme

Önceki dinlenme yalnızca zamanı ilerletiyordu; gece enerji kaybı uygulandıktan sonra gündüz geri kazanım eksikti. resources/events/player_actions.json ilk dengeleme olarak 60 dakika/15 enerji tanımlar. Bu bir fizyoloji iddiası değil oyun dengeleme varsayımıdır. CampaignDirector gerçek geçen dakikayı ölçer, saatlik kazanımı aşağı yuvarlayarak uygular ve 100 üst sınırını korur. İşlem kaynak veya enfeksiyon değiştirmez.

Kapı veya elektrik olayı dinlenmeyi keserse metin artık yanlış biçimde bir saatin geçtiğini söylemez; gerçek dakika ve gerçek kazanımı gösterir. Kesinti sırasında PowerIncident'in erken aldığı otomatik kayıt, dinlenme sonucu eklendikten sonra yenilenir. Aynı kayıt yüklendiğinde enerji kazanımı tekrar uygulanmaz.

7 yeni kontrol: 60→75 tam saat; kaynak değişmezliği; 98→100 üst sınır; 10 dakikada 60→62 ziyaret kesmesi ve metni; elektrik kesmesi ve son enerji değerini içeren otomatik kayıt. NightState 32, tüm 16 paket toplam 5602 denetim geçti. Yeni bağımsız sahne veya autoload yok; çeviri anahtarları en/tr güncellendi.

Godot importundan sonra Daniel odasında gündüz Rest eylemini kullan. Uyanık geçen geceden sonra enerji artmalı, saat ilerlemeli; gelen kişi süreci keserse gerçek süre görünmeli. Fiziksel giriş denemesi bu teslimde yapılmadı; tam otomatik paket ve gerçek motor durumları doğrulandı. Oyuncuya sürekli bakım gerektiren ek açlık/uyku göstergesi eklenmedi.
