$ErrorActionPreference='Stop'
Set-StrictMode -Version 2.0
if(Test-Path Alias:R){Remove-Item Alias:R -Force}

$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
$server='root@192.168.1.234'
$src='D:\h5\codex_workspace\dump\adb_emulator-5554_com.langla.net_20260917\decoded_client\src\url_config.txt'
$stageCfg='D:\h5\codex_workspace\dump\adb_emulator-5554_com.langla.net_20260917\hot_update_stage\update\url_config_and9999.lua'
$stageMan='D:\h5\codex_workspace\dump\adb_emulator-5554_com.langla.net_20260917\hot_update_stage\update\update_android_sszg\zip\inc_ver\70\inc_ver.lua'
$stageSrc='D:\h5\codex_workspace\dump\adb_emulator-5554_com.langla.net_20260917\hot_update_stage\update\update_android_sszg\zip\inc_ver\70\src'
$oldToken='2609177ae11eb3a2e09d2cc458a7a1b2c0c5f4'
$oldSha256='18e515fe2f89c1226fba95e3ad53de6b64975a6c0a12e3b0fa23b8e86ca3ef74'
$repo='https://github.com/gaxin488-rgb/h5test.git'

foreach($p in @($src,$stageCfg,$stageMan,$stageSrc)){if(!(Test-Path -LiteralPath $p)){throw "MISSING: $p"}}
if((Get-FileHash -Algorithm SHA256 $src).Hash.ToLower() -ne $oldSha256){throw 'SOURCE_CHANGED - ABORT'}
if((Get-FileHash -Algorithm SHA256 $stageCfg).Hash.ToLower() -ne $oldSha256){throw 'STAGE_CHANGED - ABORT'}
$oldMd5=(Get-FileHash -Algorithm MD5 $src).Hash.ToLower()
if($oldMd5 -ne $oldToken.Substring(6)){throw "TOKEN_MD5_MISMATCH md5=$oldMd5 - ABORT"}
$oldSize=(Get-Item $src).Length

$work=Join-Path $env:TEMP ('h5_rolefix_retry_'+$stamp)
New-Item -ItemType Directory -Force $work|Out-Null
$fixed=Join-Path $work 'url_config.fixed.lua'
$fixedMan=Join-Path $work 'inc_ver.fixed.lua'
$utf8=New-Object System.Text.UTF8Encoding($false)
$t=[IO.File]::ReadAllText($src,[Text.Encoding]::UTF8)

function ReplaceExactOnce([string]$s,[string]$a,[string]$b,[string]$label){
  $c=[regex]::Matches($s,[regex]::Escape($a)).Count
  if($c -ne 1){throw "$label MATCH_COUNT=$c - ABORT"}
  return $s.Replace($a,$b)
}

$t=ReplaceExactOnce $t 'REG_URL = "http://192.168.1.234:81" ' 'REG_URL = "http://192.168.1.234:806"' 'REG_URL'
$t=ReplaceExactOnce $t '    register = CDN_URL' '    register = REG_URL' 'REGISTER'
$t=ReplaceExactOnce $t 'return string.format("http://192.168.1.234:81/gonggao.php", host, os.time())' 'return string.format("http://192.168.1.234:76/gonggao.php", host, os.time())' 'NOTICE'
[IO.File]::WriteAllText($fixed,$t,$utf8)

$newSize=(Get-Item $fixed).Length
$newMd5=(Get-FileHash -Algorithm MD5 $fixed).Hash.ToLower()
$newSha256=(Get-FileHash -Algorithm SHA256 $fixed).Hash.ToLower()
$newToken=(Get-Date -Format 'yyMMdd')+$newMd5
$m=[IO.File]::ReadAllText($stageMan,[Text.Encoding]::UTF8)
$oldEntry="['src/url_config.txt']={file='$oldToken',size=$oldSize,ver=1},"
if(([regex]::Matches($m,[regex]::Escape($oldEntry))).Count -ne 1){throw 'LOCAL_MANIFEST_OLD_ENTRY_NOT_UNIQUE - ABORT'}
$newEntry="['src/url_config.txt']={file='$newToken',size=$newSize,ver=2},"
[IO.File]::WriteAllText($fixedMan,$m.Replace($oldEntry,$newEntry),$utf8)

$remoteTmp="/tmp/h5_rolefix_$stamp.lua"
& scp.exe -o StrictHostKeyChecking=no $fixed "${server}:$remoteTmp"
if($LASTEXITCODE -ne 0){throw 'SCP_FAILED - NO SERVER CHANGE'}

$remote=@'
set -u
STAMP="$1"; OLD="$2"; NEW="$3"; OLDSHA="$4"; NEWSHA="$5"; OLDSIZE="$6"; NEWSIZE="$7"; TMP="$8"
ROOT="/data/zone/sszg_symlf_6/www"
MAN="$ROOT/update/update_android_sszg/zip/inc_ver/70/inc_ver.lua"
SRC="$ROOT/update/url_config_and9999.lua"
DIR="$ROOT/update/update_android_sszg/zip/inc_ver/70/src"
OLDBLOB="$DIR/$OLD.g"; OLDGG="$DIR/$OLD.g.g"; NEWBLOB="$DIR/$NEW.g"
BK="/root/h5_rolefix_backup_$STAMP"
ROLE="/tmp/h5_role_$STAMP"; NOTICE="/tmp/h5_notice_$STAMP"; FETCH="/tmp/h5_fetch_$STAMP"
changed=0
rollback(){ if [ "$changed" = 1 ] && [ -d "$BK" ]; then cp -af "$BK/inc_ver.lua" "$MAN" 2>/dev/null || true; cp -af "$BK/url_config_and9999.lua" "$SRC" 2>/dev/null || true; rm -f "$NEWBLOB"; fi; }
fail(){ echo "ROLEFIX_ABORT: $1" >&2; rollback; rm -f "$ROLE" "$NOTICE" "$FETCH" "$TMP"; exit 1; }

echo "=== PREFLIGHT ==="
[ -f "$MAN" ] || fail "manifest missing"
[ -f "$SRC" ] || fail "server source missing"
[ -f "$OLDBLOB" ] || fail "old blob missing"
[ -f "$TMP" ] || fail "fixed config missing"
[ ! -e "$NEWBLOB" ] || fail "new blob already exists"
[ "$(sha256sum "$OLDBLOB"|awk '{print $1}')" = "$OLDSHA" ] || fail "old blob sha mismatch"
[ "$(sha256sum "$SRC"|awk '{print $1}')" = "$OLDSHA" ] || fail "server source sha mismatch"
[ "$(sha256sum "$TMP"|awk '{print $1}')" = "$NEWSHA" ] || fail "new config sha mismatch"
[ "$(wc -c < "$TMP"|tr -d ' ')" = "$NEWSIZE" ] || fail "new config size mismatch"
OLDMD5=$(printf '%s' "$OLD"|cut -c7-); NEWMD5=$(printf '%s' "$NEW"|cut -c7-)
[ "$(md5sum "$OLDBLOB"|awk '{print $1}')" = "$OLDMD5" ] || fail "old token md5 mismatch"
[ "$(md5sum "$TMP"|awk '{print $1}')" = "$NEWMD5" ] || fail "new token md5 mismatch"
OLDENTRY="['src/url_config.txt']={file='$OLD',size=$OLDSIZE,ver=1},"
CNT=$(grep -F "$OLDENTRY" "$MAN" 2>/dev/null|wc -l|tr -d ' ')
[ "$CNT" = 1 ] || fail "old manifest entry count=$CNT"
grep -aFq 'REG_URL = "http://192.168.1.234:806"' "$TMP" || fail "REG_URL fix absent"
grep -aFq 'register = REG_URL' "$TMP" || fail "register fix absent"
grep -aFq 'http://192.168.1.234:76/gonggao.php' "$TMP" || fail "notice fix absent"
if grep -aFq 'register = CDN_URL' "$TMP"; then fail "old register route remains"; fi
RC=$(curl -sS -X POST -o "$ROLE" -w "%{http_code}" "http://127.0.0.1:806/api/role.php?account=123456&platform=local&chanleId=dev&srvid=") || fail "role curl failed"
[ "$RC" = 200 ] || fail "role806 http=$RC"
if grep -aFq '<?php' "$ROLE"; then fail "806 exposes php source"; fi
grep -aEq '9001|40101' "$ROLE" || fail "role response lacks game endpoint"
NC=$(curl -sS -o "$NOTICE" -w "%{http_code}" "http://127.0.0.1:76/gonggao.php") || fail "notice curl failed"
[ "$NC" = 200 ] || fail "notice76 http=$NC"
ss -ltn 2>/dev/null|grep -Eq ':9001([[:space:]]|$)' || fail "9001 not listening"

echo "=== APPLY ==="
mkdir -p "$BK" || fail "backup mkdir failed"
cp -af "$MAN" "$BK/inc_ver.lua" || fail "manifest backup failed"
cp -af "$SRC" "$BK/url_config_and9999.lua" || fail "source backup failed"
cp -af "$OLDBLOB" "$BK/$OLD.g" || fail "blob backup failed"
if [ -e "$OLDGG" ] || [ -L "$OLDGG" ]; then cp -a "$OLDGG" "$BK/$OLD.g.g" 2>/dev/null || true; fi
changed=1
install -m 0644 "$TMP" "$SRC" || fail "source install failed"
install -m 0644 "$TMP" "$NEWBLOB" || fail "blob install failed"
sed -i "s/file='$OLD',size=$OLDSIZE,ver=1/file='$NEW',size=$NEWSIZE,ver=2/" "$MAN" || fail "manifest rewrite failed"
NEWENTRY="['src/url_config.txt']={file='$NEW',size=$NEWSIZE,ver=2},"
NCNT=$(grep -F "$NEWENTRY" "$MAN" 2>/dev/null|wc -l|tr -d ' ')
[ "$NCNT" = 1 ] || fail "new manifest entry count=$NCNT"
if grep -Fq "file='$OLD'" "$MAN"; then fail "old token remains active"; fi
HC=$(curl -sS -o "$FETCH" -w "%{http_code}" "http://127.0.0.1:86/update/update_android_sszg/zip/inc_ver/70/src/$NEW.g") || fail "new blob fetch failed"
[ "$HC" = 200 ] || fail "new blob http=$HC"
[ "$(sha256sum "$FETCH"|awk '{print $1}')" = "$NEWSHA" ] || fail "served blob sha mismatch"
MCNT=$(curl -fsS "http://127.0.0.1:86/update/update_android_sszg/zip/inc_ver/70/inc_ver.lua"|grep -F "$NEWENTRY"|wc -l|tr -d ' ')
[ "$MCNT" = 1 ] || fail "served manifest new entry count=$MCNT"
changed=0
rm -f "$ROLE" "$NOTICE" "$FETCH" "$TMP" /tmp/h5_rolefix_20260918_094500.lua
echo "ROLE_HTTP_806=200"
echo "NOTICE_HTTP_76=200"
echo "GAME_PORT_9001=LISTEN"
echo "NEW_TOKEN=$NEW"
echo "NEW_SHA256=$NEWSHA"
echo "BACKUP=$BK"
echo "OLD_BLOB_RETAINED=YES"
echo "SERVER_ROLEFIX_OK"
'@

$sshOut=$remote | & ssh.exe -o StrictHostKeyChecking=no $server "bash -s -- '$stamp' '$oldToken' '$newToken' '$oldSha256' '$newSha256' '$oldSize' '$newSize' '$remoteTmp'" 2>&1
$rc=$LASTEXITCODE
$sshOut|ForEach-Object{Write-Host $_}
if($rc -ne 0){throw 'SERVER_ROLEFIX_FAILED - rollback attempted; local sources unchanged'}

[IO.File]::WriteAllBytes($src,[IO.File]::ReadAllBytes($fixed))
[IO.File]::WriteAllBytes($stageCfg,[IO.File]::ReadAllBytes($fixed))
[IO.File]::WriteAllBytes($stageMan,[IO.File]::ReadAllBytes($fixedMan))
$newLocalBlob=Join-Path $stageSrc ($newToken+'.g')
Copy-Item $fixed $newLocalBlob -Force

if((Get-FileHash -Algorithm SHA256 $src).Hash.ToLower() -ne $newSha256){throw 'LOCAL SOURCE VERIFY FAILED'}
if((Get-FileHash -Algorithm SHA256 $stageCfg).Hash.ToLower() -ne $newSha256){throw 'LOCAL STAGE VERIFY FAILED'}
if((Get-FileHash -Algorithm SHA256 $newLocalBlob).Hash.ToLower() -ne $newSha256){throw 'LOCAL BLOB VERIFY FAILED'}

$gitTmp=Join-Path $env:TEMP ('h5_rolefix_report_'+$stamp)
git clone --depth 1 --filter=blob:none --sparse $repo $gitTmp
if($LASTEXITCODE -ne 0){throw 'REPORT CLONE FAILED; production already changed'}
git -C $gitTmp sparse-checkout set reports
$rel='reports/role_route_fix_'+$stamp
$reportDir=Join-Path $gitTmp ($rel -replace '/','\')
New-Item -ItemType Directory -Force $reportDir|Out-Null
@(
"STAMP=$stamp",
'TOKEN_RULE=YYMMDD+MD5',
'CDN_UPDATE=http://192.168.1.234:86',
'REGISTER=http://192.168.1.234:806',
'NOTICE=http://192.168.1.234:76/gonggao.php',
"OLD_TOKEN=$oldToken",
"NEW_TOKEN=$newToken",
"OLD_SIZE=$oldSize",
"NEW_SIZE=$newSize",
"NEW_SHA256=$newSha256",
"SERVER_BACKUP=/root/h5_rolefix_backup_$stamp",
'OLD_BLOB_RETAINED_PENDING_CLIENT_VERIFY=YES',
'',
'SERVER_OUTPUT:',
($sshOut -join [Environment]::NewLine)
)|Set-Content (Join-Path $reportDir 'deployment_report.txt') -Encoding UTF8
Copy-Item $fixed (Join-Path $reportDir 'url_config.fixed.published.lua') -Force
$newEntry|Set-Content (Join-Path $reportDir 'manifest_entry.txt') -Encoding UTF8
git -C $gitTmp add -- $rel
git -C $gitTmp -c user.name='h5test-deploy' -c user.email='h5test-deploy@local.invalid' commit -m ('fix role route publish '+$stamp)
if($LASTEXITCODE -ne 0){throw 'REPORT COMMIT FAILED; production already changed'}
git -C $gitTmp pull --rebase origin main
if($LASTEXITCODE -ne 0){git -C $gitTmp rebase --abort 2>$null;throw 'REPORT REBASE FAILED; production already changed'}
git -C $gitTmp push origin HEAD:main
if($LASTEXITCODE -ne 0){throw 'REPORT PUSH FAILED; production already changed'}

Remove-Item $gitTmp -Recurse -Force
Remove-Item $work -Recurse -Force
Remove-Item 'C:\Users\Admin\AppData\Local\Temp\h5_rolefix_publish_20260918_094500' -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "ROLEFIX_PUBLISHED_OK NEW_TOKEN=$newToken" -ForegroundColor Green
}
