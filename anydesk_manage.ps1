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

# Common AnyDesk paths to try if not provided
$commonPaths = @(
    "$env:ProgramFiles(x86)\AnyDesk\AnyDesk.exe",
    "$env:ProgramFiles\AnyDesk\AnyDesk.exe",
    "$env:ProgramFiles(x86)\AnyDesk\AnyDesk.exe" -replace '\\\\','\\',
    "$env:ProgramFiles\AnyDesk\AnyDesk.exe" -replace '\\\\','\\'
)

# If user provided AnyDeskPath, test it first
if ($AnyDeskPath) {
    $possible = ,$AnyDeskPath + ($commonPaths | Where-Object { $_ -ne $AnyDeskPath })
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
    $proc = Start-Process -FilePath $anydeskExe -ArgumentList '--get-id' -NoNewWindow -RedirectStandardOutput -Wait -PassThru -ErrorAction Stop
    $out = $proc.StandardOutput.ReadToEnd().Trim()
    if (-not $out) {
        # sometimes Start-Process redirect yields empty; try simpler invocation
        $out = & $anydeskExe --get-id 2>$null
        if ($out -is [array]) { $out = $out -join "`n" }
        $out = $out.Trim()
    }
    if ($out) {
        $result.anydesk_id = $out
    } else {
        $result.anydesk_id = "unknown"
    }
} catch {
    # Fallback: try executing directly and capture stdout
    try {
        $out2 = & $anydeskExe --get-id 2>&1
        if ($out2) { $result.anydesk_id = ($out2 -join "`n").Trim() } else { $result.anydesk_id = "error" }
    } catch {
        $result.anydesk_id = "error"
    }
}

# --- Optionally set unattended password ---
if ($PSBoundParameters.ContainsKey('Password') -and $Password) {
    if (-not (Test-IsAdmin)) {
        $result.note = "Setting password requires administrative privileges. Re-run PowerShell as Administrator."
        $result.set_password = $false
    } else {
        $tmpFile = Join-Path $env:TEMP ("anydesk_pass_{0}.txt" -f ([System.Guid]::NewGuid().ToString()))
        try {
            # write password to temp file (ASCII) then pipe via cmd to AnyDesk CLI
            Set-Content -Path $tmpFile -Value $Password -Encoding ASCII

            # Use cmd piping to ensure compatibility across environments
            $cmd = "cmd /c type `"$tmpFile`" | `"$anydeskExe`" --set-password"
            $p = Start-Process -FilePath "cmd.exe" -ArgumentList "/c", "type `"$tmpFile`" | `"$anydeskExe`" --set-password" -NoNewWindow -Wait -PassThru -WindowStyle Hidden -RedirectStandardOutput $null -RedirectStandardError $null
            # The AnyDesk CLI may not return nonzero even if unsupported; we set flag true if no exception
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
    # try alternate service
    try {
        $ip2 = Invoke-WebRequest -Uri 'https://ifconfig.me/ip' -UseBasicParsing -TimeoutSec $PublicIpTimeoutSec
        $result.public_ip = $ip2.Content.Trim()
    } catch {
        $result.public_ip = ""
    }
}

# Output JSON and also write a human-friendly echo
$json = $result | ConvertTo-Json -Depth 4
Write-Output $json
Write-Output ""
Write-Output "AnyDesk Path : $($result.anydesk_path)"
Write-Output "AnyDesk ID   : $($result.anydesk_id)"
if ($result.public_ip) {
    Write-Output "Public IP    : $($result.public_ip)"
    Write-Output "VNC/RDP style connect string (example): vncviewer $($result.public_ip):5900   OR   mstsc /v:$($result.public_ip):3389"
}
if ($result.set_password) { Write-Output "Password    : (was set)" } elseif ($PSBoundParameters.ContainsKey('Password')) { Write-Output "Password    : (failed to set)" }

# Exit code 0 successful
exit 0
