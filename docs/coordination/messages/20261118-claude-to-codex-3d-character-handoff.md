# Claude → Codex / 3B karakter: sahip gerçekçi karakteri sana bıraktı

Sahip, onayladığı karakter resmini verip "bunu baz alarak 3D bir karakter oluştur, çok düşük poly olmasın" dedi. Claude kodla bir maket denedi; renk/ışık referansa yaklaştı ama **yüz gerçekçi değil** (küre/silindirle insan yüzü çıkmıyor). Sahip bu işi sana bırakmamı istedi ("ChatGPT'ye bırak"). Ayrıca bkz. ROOM-3D-TRIAL-001: oradaki Elena henüz düz çizim; bu iş onun 3B karşılığı.

## Elindekiler
- `docs/art/character-3d-block-model.html`: Claude'un kodla yaptığı oran/boyut maketi (three.js, ~54 bin üçgen, 1.70 m boy). Tarayıcıda açılır; Ön/Yan/Arka/Yüz + tel kafes. **Görsel kalite referans değil**, yalnız şu ölçüler için: omuz x=±0.20, kalça y=0.84, ayak bileği y≈0.06, baş merkezi y≈1.60; hırka açık V önlü, gömlek içeride, pantolon düz paça; düşük at kuyruğu.
- Referans resim sahibin sohbetinde (koyu yeşil zemin, pembe-kahve hırka, krem gömlek, zeytin pantolon, düşük at kuyruğu, yorgun/ciddi yüz). Dosyaya Claude erişemedi; gerekirse sahipten tekrar iste.

## Sende kalan (tasarım/sanat)
1. Gerçekçi yüz ve vücut modeli (resimden 3B üretim veya elle heykel), orta/yüksek poligon, GLB/glTF.
2. Hareket: en az yürüme ve bekleme animasyonu (iskelet), sonra NpcRoutine pozları (stand/sit/lie/work).
3. Sahibin onayladığı posterize ışık/vinyet görünümüne oturması (bedroom_3d_trial'daki lens gölgelendiricisi).

## Claude'un bağlayacağı kısım
Model hazır olunca (`assets/characters/<id>/model.glb` gibi bir yol söyle) RoomWorld/NpcRoutine tarafına pozları bağlamak, yürüme sesi/animasyon zamanlamasını ve testleri Claude yapar.
