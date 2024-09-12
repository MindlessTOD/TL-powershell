# Line 14, replace XXX with the Override code from last check-in Date. 
# Line 19, Stop the service for TL
# Line 23, Download the Agent from the Link in Line 5
# Line 26, Delete the existing Service agent. 
# Line 29, Move the downloaded service from c:\temp\ to the TL directory as the proper name. 
# Line 33, restart the service

$downloadUrl = "https://updates.threatlocker.com/repository/9.1.3/amd64/threatlockerservice_exe.bin"
$downloadPath = "C:\temp\Threatlockerservice_exe.bin"
$existingFilePath = "C:\Program Files\Threatlocker\Threatlockerservice.exe"
$renamedFilePath = "C:\temp\Threatlockerservice.exe"
$overrideFilePath = "C:\ProgramData\Threatlocker\overridecode.txt"
$OverrideCode = "XXXXXXXXX"

Write-Output "Writing text to $overrideFilePath"
$OverrideCode | Set-Content -Path $overrideFilePath -Encoding UTF8 -Force
Start-Sleep -Seconds 5
Stop-Service -Name "threatlockerservice"
Start-Sleep -Seconds 5

Write-Output "Downloading file from $downloadUrl"
Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
if (Test-Path -Path $existingFilePath) {
   Write-Output "Deleting existing file: $existingFilePath"
   Remove-Item -Path $existingFilePath -Force
}
Write-Output "Renaming $downloadPath to $renamedFilepath"
Rename-Item -Path $downloadPath -NewName "Threatlockerservice.exe"
Move-Item -Path $renamedFilePath -Destination $existingFilePath
Start-Sleep -Seconds 5

Write-Output "Starting the ThreatLockerService"
Start-Service -Name "threatlockerservice"
