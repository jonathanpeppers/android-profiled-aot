param (
    [string] $dotnet = 'dotnet',
    [string] $app = 'AndroidApp1',
    [int] $seconds = 3,
    [int] $iterations = 10
)
$ErrorActionPreference = 'Stop'
$csproj = "$app/$app.csproj"
$package = "com.androidaot.$app"

# Uninstall the app if it was there already
& adb uninstall $package

# Build the app in Release+AOT mode
& $dotnet build $csproj -t:Install -c Release -p:RunAOTCompilation=true -bl:logs/$app-RunAOTCompilation.binlog

# Setup adb logcat settings
& adb logcat -G 15M
& adb logcat -c
& adb shell setprop debug.mono.profile '""'

# Launch the app N times
& adb shell am force-stop $package
for ($i = 1; $i -le $iterations; $i++) {
    & $dotnet build $project -t:Run -c Release -p:RunAOTCompilation=true -bl:logs/$app-Run.binlog -v:quiet -nologo
    Start-Sleep -Seconds $seconds
    & adb shell am force-stop $package
}

# Pull the adb logcat output
$adb_log = "logs/$app-adb.txt"
& adb logcat -d > $adb_log

# Log message of the form:
# 09-01 11:37:38.826  1878  1900 I ActivityManager: Displayed com.androidaot.AndroidApp1/AndroidApp1.MainActivity: +1s336ms

$log = Get-Content $adb_log | Select-String -Pattern 'Activity.*Manager.+Displayed'
if ($log.Count -eq 0)
{
    Write-Error "No ActivityManager messages found"
}

$sum = 0;
[System.Collections.ArrayList] $times = @()
foreach ($line in $log)
{
    if ($line -match "((?<seconds>\d+)s)?(?<milliseconds>\d+)ms(\s+\(total.+\))?$")
    {
        $seconds = [int]$Matches.seconds
        $milliseconds = [int]$Matches.milliseconds
        $time = $seconds * 1000 + $milliseconds
        $times.Add($time) > $null
        $sum += $time
        Write-Host $line
    }
    else
    {
        Write-Error "No timing found for line: $line"
    }
}
$mean = $sum / $log.Count
$variance = 0
if ($log.Count -ne 1)
{
    foreach ($time in $times)
    {
        $variance += ($time - $mean) * ($time - $mean) / ($log.Count - 1)
    }
}
$stdev = [math]::Sqrt($variance)
$stderr = $stdev / [math]::Sqrt($log.Count)

Write-Host "Average(ms): $mean"
Write-Host "Std Err(ms): $stderr"
Write-Host "Std Dev(ms): $stdev"
