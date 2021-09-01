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

# Build aotprofile-tool if needed
$aotprofile_tool = "external/aotprofile-tool/bin/Debug/aotprofile-tool"
if (-Not (Test-Path $aotprofile_tool))
{
    & nuget restore external/aotprofile-tool
    & $dotnet build external/aotprofile-tool -bl:logs/aotprofile-tool.binlog
}

# Strip out the user's assembly
$custom_aprof = "$app/custom.aprof"
& $aotprofile_tool -sd --filter-module="^(?!$app).+" $custom_aprof -o profiles/$app.aotprofile