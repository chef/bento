#MIT License
#
#Copyright (c) 2017 Rui Lopes
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
#SOFTWARE.

Set-StrictMode -Version Latest
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'
trap {
    Write-Host
    Write-Host "ERROR: $_"
    ($_.ScriptStackTrace -split '\r?\n') -replace '^(.*)$','ERROR: $1' | Write-Host
    ($_.Exception.ToString() -split '\r?\n') -replace '^(.*)$','ERROR EXCEPTION: $1' | Write-Host
    Write-Host
    Write-Host 'Sleeping for 60m to give you time to look around the virtual machine before self-destruction...'
    Start-Sleep -Seconds (60*60)
    Exit 1
}

Write-Host 'Disabling the Microsoft Consumer Experience...'
mkdir -Force 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' | Set-ItemProperty `
    -Name DisableWindowsConsumerFeatures `
    -Value 1

# when running on pwsh and windows 10, explicitly import the appx module.
# see https://github.com/PowerShell/PowerShell/issues/13138
$currentVersionKey = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion'
$build = [int]$currentVersionKey.CurrentBuildNumber
if (($PSVersionTable.PSEdition -ne 'Desktop') -and ($build -lt 22000)) {
    Import-Module Appx -UseWindowsPowerShell
}

# remove all the provisioned appx packages.
# NB some packages fail to be removed and thats OK.
Get-AppXProvisionedPackage -Online | ForEach-Object {
    Write-Host "Removing the $($_.PackageName) provisioned appx package..."
    try {
        $_ | Remove-AppxProvisionedPackage -Online | Out-Null
    } catch {
        Write-Output "WARN Failed to remove appx: $_"
    }
}

# remove appx packages.
# NB some packages fail to be removed and thats OK.
# see https://docs.microsoft.com/en-us/windows/application-management/apps-in-windows-10
@(
    'Microsoft.BingWeather'
    'Microsoft.GetHelp'
    'Microsoft.Getstarted'
    'Microsoft.Microsoft3DViewer'
    'Microsoft.MicrosoftOfficeHub'
    'Microsoft.MicrosoftSolitaireCollection'
    'Microsoft.MicrosoftStickyNotes'
    'Microsoft.MixedReality.Portal'
    'Microsoft.MSPaint'
    'Microsoft.Office.OneNote'
    'Microsoft.People'
    'Microsoft.ScreenSketch'
    'Microsoft.Services.Store.Engagement'
    'Microsoft.SkypeApp'
    'Microsoft.StorePurchaseApp'
    'Microsoft.Wallet'
    'Microsoft.Windows.Photos'
    'Microsoft.WindowsAlarms'
    'Microsoft.WindowsCalculator'
    'Microsoft.WindowsCamera'
    'microsoft.windowscommunicationsapps'
    'Microsoft.WindowsFeedbackHub'
    'Microsoft.WindowsMaps'
    'Microsoft.WindowsSoundRecorder'
    'Microsoft.WindowsStore'
    'Microsoft.Xbox.TCUI'
    'Microsoft.XboxApp'
    'Microsoft.XboxGameOverlay'
    'Microsoft.XboxGamingOverlay'
    'Microsoft.XboxIdentityProvider'
    'Microsoft.XboxSpeechToTextOverlay'
    'Microsoft.YourPhone'
    'Microsoft.ZuneMusic'
    'Microsoft.ZuneVideo'
    #'Microsoft.BioEnrollment' # NB this fails to remove.
) | ForEach-Object {
    $appx = Get-AppxPackage -AllUsers $_
    if ($appx) {
        Write-Host "Removing the $($appx.Name) appx package..."
        try {
            $appx | Remove-AppxPackage -AllUsers
        } catch {
            Write-Output "WARN Failed to remove appx: $_"
        }
    }
}
