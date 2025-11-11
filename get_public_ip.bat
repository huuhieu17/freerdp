# Get public IP from api.ipify.org
$publicIP = Invoke-RestMethod -Uri "https://api.ipify.org"

# Wrap in JSON object
$ipObject = @{ ip = $publicIP }

# Convert to JSON
$ipJson = $ipObject | ConvertTo-Json

# Save to JSON file
$jsonFile = "$env:TEMP\public_ip.json"
$ipJson | Out-File -FilePath $jsonFile -Encoding UTF8

# Echo the JSON content
Write-Output "Saved public IP JSON to $jsonFile"
Get-Content $jsonFile
