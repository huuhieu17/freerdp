<#
.SYNOPSIS
  Detect AnyDesk, optionally set unattended password, retrieve AnyDesk ID and public IP, and output JSON.

.PARAMETER Password
  (Optional) Unattended access password to set. Requires administrative privileges.

.PARAMETER AnyDeskPath
  (Optional) Full path to AnyDesk executable. If omitted, script tries common install locations.

.EXAMPLE
  .\anydesk_manage.ps1 -Password 'MySecretPwd'

  Sets unattended password (requires admin), retrieves ID and public IP, prints JSON.

.EXAMPLE
  .\anydesk_manage.ps1
  Only retrieves AnyDesk ID + public IP.
#>

param(
    [string]$Password = $null,
    [string]$AnyDeskPath = $null,
    [int]$PublicIpTimeoutSec = 10
)

function Test-IsAdmin {
    $current = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($current)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Build list of candidate AnyDesk paths
$commonPaths = @()
if ($env:ProgramFiles) {
    $commonPaths += Join-Path $env:ProgramFiles "AnyDesk\AnyDesk.exe"
}
if ($env:"ProgramFiles(x86)") {
    $commonPaths += Join-Path $env:"ProgramFiles(x86)" "AnyDesk\AnyDesk.exe"
}

# If user passed AnyDeskPath, put it first
if ($AnyDeskPath) {
    $possible = @($AnyDeskPath) + ($commonPaths | Where-Object { $_ -ne $AnyDeskPath })
} else {
    $possible = $commonPaths
}

$anydeskExe = $null
foreach ($p in $possible) {
    if ($p -and (Test-Path -LiteralPath $p)) {
        $anydeskExe = (Get-Item -LiteralPath $p).FullName
        break
    }
}

$result = [ordered]@{
    anydesk_path = $null
    anydesk_id   = $null
    public_ip    = $null
    set_password = $false
    note         = $null
}

if (-not $anydeskExe) {
    $result.note = "AnyDesk not found in common locations. Provide -AnyDeskPath to specify location."
    $result | ConvertTo-Json -Depth 4
    exit 1
}

$result.anydesk_path = $anydeskExe

# --- Get AnyDesk ID via CLI ---
try {
    $out = & $anydeskExe --get-id 2>&1
    if ($out -is [array]) { $out = $out -join "`n" }
    $out = $out.Trim()
    if ($out) {
        $result.anydesk_id = $out
    } else {
        $result.anydesk_id = "unknown"
    }
} catch {
    $result.anydesk_id = "error"
}

# --- Optionally set unattended password ---
if ($PSBoundParameters.ContainsKey('Password') -and $Password) {
    if (-not (Test-IsAdmin)) {
        $result.note = "Setting password requires administrative privileges. Re-run PowerShell as Administrator."
        $result.set_password = $false
    } else {
        $tmpFile = Join-Path $env:TEMP ("anydesk_pass_{0}.txt" -f ([System.Guid]::NewGuid().ToString()))
        try {
            Set-Content -Path $tmpFile -Value $Password -Encoding ASCII -Force
            $pipeCommand = "type `"$tmpFile`" | `"$anydeskExe`" --set-password"
            Start-Process -FilePath "cmd.exe" -ArgumentList "/c", $pipeCommand -NoNewWindow -Wait -PassThru -WindowStyle Hidden | Out-Null
            $result.set_password = $true
        } catch {
            $result.set_password = $false
            $result.note = "Failed to set password: $($_.Exception.Message)"
        } finally {
            if (Test-Path $tmpFile) { Remove-Item -LiteralPath $tmpFile -Force -ErrorAction SilentlyContinue }
        }
    }
}

# --- Get public IP ---
try {
    $ip = Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing -TimeoutSec $PublicIpTimeoutSec
    $result.public_ip = $ip.Content.Trim()
} catch {
    try {
        $ip2 = Invoke-WebRequest -Uri 'https://ifconfig.me/ip' -UseBasicParsing -TimeoutSec $PublicIpTimeoutSec
        $result.public_ip = $ip2.Content.Trim()
    } catch {
        $result.public_ip = ""
    }
}

# Output JSON and also human-readable info
$json = $result | ConvertTo-Json -Depth 4
Write-Output $json
Write-Output ""
Write-Output "AnyDesk Path : $($result.anydesk_path)"
Write-Output "AnyDesk ID   : $($result.anydesk_id)"
if ($result.public_ip) {
    Write-Output "Public IP    : $($result.public_ip)"
    Write-Output "Connect string examples: vncviewer $($result.public_ip):5900   OR   mstsc /v:$($result.public_ip):3389"
}
if ($result.set_password) { Write-Output "Password    : (was set)" } elseif ($PSBoundParameters.ContainsKey('Password')) { Write-Output "Password    : (failed to set)" }

exit 0
