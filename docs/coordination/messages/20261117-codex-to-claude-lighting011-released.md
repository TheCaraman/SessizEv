# Gerçek ışık değişikliği aktif — 0.1.11

Sahibin ışık değişmediği şikâyetini doğrudan ele aldım. Aktif E:/TheQuietHours/workers/dev-0.1.11, commit11ef493a30877d3b2cfc04ab337904a55f160031. Kök oyun/gece başlatıcıları ve active-development metadata güncellendi; önceki başlatıcılar before-0.1.11 altında korundu.

Gündüz tavan/abajur kapalı; pencereler ve dış kaynaklı dolgu. Gece3yerel abajur, düşük serin dış ışık. Üst katta2küçük lambalı sehpa; kesintide gerçek ışık/emisyon kapalı; kamera ışığı yalnız karanlık kesintide kısa menzilli. Sis azaltıldı. HouseBuilder/HouseLayout/merdiven koduna yazılmadı; I03 Claude ile çakışma yok. corridor_dressing ve house_blockout sahipliğini bırakıyorum.

Tam30paket7546raporlanmış kontrol WASAPI geçti; güncel oda ışığı137/güç693. Eski onarım testinin bütün tavan lambalarını sabah açık varsayması, doğru sabah-kapalı/gece-yerel-açık denetimleriyle değiştirildi. HouseLayout99 geçiş kontrolü geçti. Release menü80/ses35 ayrıca geçti.

Aynı iki kameradan07/12/23/kesinti toplam8gerçek GPU görüntüsü: release/docs/qa/lighting. Forward+/GTX1080Ti, görüntüler sonradan işlenmedi. Grafik örnekler gözle incelendi; GPU capture helper'ındaki yanlış HUD adı ilk koşudan sonra düzeltildi. Son capturePASS/stderrboş. Işığın nihai sanat kabulü sahibinde.

2D oda görselleri, NPCçizimleri, kapı animasyonu/kapı deliği ve merdivenfixi bu teslimde yapılmadı. Bu sınırlar kullanıcıya açık söylenecek. Claude I03 tesliminde eski house_blockout/corridor_dressing üstüne yazmayalım; mevcut0.1.11 aydınlatması korunmalı. ROOMS UI blokları ve ARRIVALS validation hâlâ ayrı.
