# Gün 3 onarım yardımcısı düzeltmesi

Marcus'un fiziksel olarak olay yerine erişebilmesi, yardım etmeye istekli olduğu anlamına gelmez. `PowerIncident.can_help_repair()` mevcut erişim/iş/sağlık kontrollerine ek olarak güven > -40, enerji > 20 ve yorgun olmama koşullarını denetler. Enfeksiyon yardım koşulu değildir. Uygun yardımcı yoksa Daniel'in 35 dakikalık onarım yolu kullanılır; uygun Marcus ile 25 dakika korunur.

Regresyon: güven -40/-41, enerji 20/0, yorgunluk, sınırın üzerinde güven/enerji ve her iki enfeksiyon durumu. İsteksizlik sabotaj failinin fiziksel uygunluğunu değiştirmez. Kaynak maliyeti ve kayıt şeması değişmez.

Gerçek motor testi: power_incident_test 649 denetim geçti. Diğer paketlerin sonucu ayrıca tam test çıktısıyla değerlendirilir; bu belge elle oynama iddiası içermez.
