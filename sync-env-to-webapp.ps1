# Script to sync .env file settings to Azure Web App
param(
    [string]$EnvFilePath = "src\.env",
    [string]$ResourceGroup = "techworkshop-l300",
    [string]$WebAppName = "mq43qjornukki-app"
)

Write-Host "Reading environment variables from $EnvFilePath..." -ForegroundColor Cyan

# Read .env file and parse key-value pairs
$envVars = @()
Get-Content $EnvFilePath | ForEach-Object {
    $line = $_.Trim()
    # Skip empty lines and comments
    if ($line -and -not $line.StartsWith("#")) {
        # Parse KEY="VALUE" or KEY=VALUE format
        if ($line -match '^([^=]+)=(.+)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            # Remove quotes if present
            $value = $value -replace '^"(.*)"$', '$1'
            $envVars += "$key=$value"
            Write-Host "  Found: $key" -ForegroundColor Gray
        }
    }
}

Write-Host "`nFound $($envVars.Count) environment variables" -ForegroundColor Green
Write-Host "`nApplying settings to Azure Web App: $WebAppName..." -ForegroundColor Cyan

# Apply all settings at once
az webapp config appsettings set `
    --name $WebAppName `
    --resource-group $ResourceGroup `
    --settings @envVars `
    --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "Environment variables configured successfully!" -ForegroundColor Green
    Write-Host "`nRestarting web app..." -ForegroundColor Cyan
    
    az webapp restart --name $WebAppName --resource-group $ResourceGroup --output none
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Web app restarted successfully!" -ForegroundColor Green
        Write-Host "`nYour application should now be accessible at:" -ForegroundColor Green
        Write-Host "  https://$WebAppName.azurewebsites.net" -ForegroundColor Cyan
    }
} else {
    Write-Host "Failed to configure environment variables" -ForegroundColor Red
}
