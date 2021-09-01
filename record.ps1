param (
    [string] $dotnet = 'dotnet',
    [string] $app = 'AndroidApp1',
    [int] $seconds = 3
)
$ErrorActionPreference = 'Stop'
$csproj = "$app/$app.csproj"

# Build & launch app with profiler
& $dotnet build $csproj -t:BuildAndStartAotProfiling -bl:logs/$app-BuildAndStartAotProfiling.binlog

# Just delay for a bit
Write-Host 'Waiting for app to launch...'
Start-Sleep -Seconds $seconds

# Pull the custom.aprof file from the device
& $dotnet build $csproj -t:FinishAotProfiling -bl:logs/$app-FinishAotProfiling.binlog

