$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$gameRoot = Split-Path $projectRoot -Parent
$configurationPath = Join-Path $gameRoot 'queue.continuous.json'
if (Test-Path -LiteralPath $configurationPath) {
    Write-Output 'Continuous queue already exists; preserving tasks and state.'
    exit 0
}
$existing = Get-Content (Join-Path $gameRoot 'queue.json') -Raw | ConvertFrom-Json
$integration = Join-Path $gameRoot 'workers\continuous-integration'
if (Test-Path -LiteralPath $integration) { throw 'Integration folder already exists; refusing to repurpose it.' }
& $existing.git -C $projectRoot worktree add -b automation/continuous-development $integration fc3691727bffa7b940439ebba50d25c19abeb3cd
if ($LASTEXITCODE -ne 0) { throw 'Could not create isolated integration worktree.' }
$roomSource = Join-Path $projectRoot 'docs\design\RoomPreferences.md'
$tasks = @(
    [ordered]@{
        id='AUTO-ROOMS-DESIGN'; provider='codex'; reviewer='claude'; max_agent_calls=8
        allowed_paths=@('docs/design/RoomPreferences.md'); required_test_markers=@('All 28 test suites passed')
        instruction="Onaylı oda tercihi tasarımını yalnız docs/design/RoomPreferences.md dosyasında üret. Mevcut taslak kaynağı $roomSource dosyasını oku. Son kararı oyuncu verir, NPC tercih/itiraz bildirir; otomatik taşıma yok. Izolasyon rezervi/kapasite/tek konum korunur. Yeni kişisel tercihler veya sayısal güven bedelleri onaylanmış gibi sunulmasın. Ayrı mevcut Claude ARRIVALS çalışmasına veya onun branch/klasörlerine yazma. Kod değiştirme. Kaynaklar ve doğrulanacak senaryolarla geliştiriciye uygulanabilir belge üret; mevcut taslağı tekrar eden gereksiz uzun metin yazma. Yeni özellik uygulanmış gibi raporlama."
    },
    [ordered]@{
        id='AUTO-RADIO-CACHE'; provider='claude'; reviewer='codex'; max_agent_calls=8
        allowed_paths=@('scripts/narrative/day4_broadcast.gd','tests/day4_broadcast_test.gd'); required_test_markers=@('All 28 test suites passed','DAY4 RADIO TEST: PASS')
        instruction='Yalnız Gün4 radyo kural JSON okumasını sınıf-yerel static önbelleğe al; her label/duration/body/validation çağrısında tekrar disk okuma olmasın. Yerel veriyi dışarıdan değiştiren yeni API ekleme. Kayıt doğrulamasındaki420 gün başlangıcı yerine mevcut GameState.DAY_START kullan. Davranış, JSON verisi, onaylı metin, ses, kayıt şeması ve diğer sistemler değişmesin. Var olan radyo testlerine aynı kayıt/ilk15dk/ücretsiznot/bozuk durum testlerini koruyarak yalnız gerekli anlamlı kontrol ekle. Mevcut Claude ARRIVALS worktree üzerinde çalışma. Kullanıcıya soru veya başka asistana başlama onayı bekleme; görevi bu ayrı worktree içinde tamamla.'
    }
)
$config = [ordered]@{
    project=$integration; expected_branch='automation/continuous-development'; git=$existing.git; godot=$existing.godot
    providers=$existing.providers; audio_driver='WASAPI'; agent_timeout_seconds=1200; test_timeout_seconds=600
    max_run_seconds=0; poll_seconds=30; tasks=$tasks
}
$config | ConvertTo-Json -Depth 15 | Set-Content -LiteralPath $configurationPath -Encoding utf8
Write-Output "Isolated queue created: $configurationPath"
