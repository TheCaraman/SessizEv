# Claude → Codex / NPC-ACTOR-3D-001 teslim

Sahip, senin haftalık limitin dolduğu için "yazılımsal kısımları sen yap" dedi. Elena V7 çalışma modelini (senin `codex/elena-volume-v8` dalından `assets/models/elena_v7` aynen kopyalandı, dokunulmadı) oyun mantığına bağlayan teknik katmanı yaptım. Dal `claude/npc-actor-3d` (taban release/dev-0.1.22 cbbad17). Claim: claims/NPC-ACTOR-3D-001.md. Kampanya, HouseLayout/Builder, sanat, shader'lara dokunulmadı.

**Eklenenler:** `NpcRoutes` (HouseLayout'tan oda arası zemin rotası; kapı boşlukları + bitişik gezilebilir odalar), `NpcWalker` (rota izleme, köşede dönüş/yavaşlama), `NpcActor3D` (modeli yükler, Idle/Walk, yüz yönü, oynatma hızı gerçek hızdan, `arrived`). Test `npc_actor_3d_test` (1193 denetim; gerçek evde tüm 182 oda çifti: zemin var, duvar yok; gerçek bir rotayı fizik karelerinde yürüyor). Demo: `DENE_NPC_YURUYUS.cmd` (ayrı proje kopyası + kullanıcı dizini). Görüntüler docs/qa/npc-actor-3d. Ayrıntı docs/qa/NpcActor3D.md.

**Sana (sanat) bulgu:** Walk_8fps klibi 1,042 sn, ayak yalnız 0,28 m geri kayıyor ⇒ klip ≈0,42 m/s için yazılmış (çok kısa adım). Evde 0,9 m/s yürütüp klibi 2,25x oynatıyorum (ayak kaymıyor, adımlar sık). Doğal görünüm için klip ~1,0–1,2 m/s (adım ~0,6 m) için yeniden yazılmalı; kodda yalnız `NpcActor3D.CLIP_SPEED` sabiti değişir, test klibin ayak hızını ölçüp sabitle karşılaştırır. Oturma/yatma/iş klibi yok (NpcRoutine poz tablosuna hazır). Idle iki anahtarlı tek poz.

**Karar bekleyen (sahip/sen):** Elena kampanyada 3D görünsün mü, hangi sakin/ne zaman, kapı geçişinde ne olsun. Bunu yapmadım; aktör yalnız dev demosu.

Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>
