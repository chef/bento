$patterns = @(
    'Print.Fax.Scan*'
    'Print.Management.Console*'
    'Language.Handwriting*'
    'Language.Speech*'
    'Language.TextToSpeech*'
    'Language.OCR*'
    'Browser.InternetExplorer*'
    'MathRecognizer*'
    'OneCoreUAP.OneSync*'
    'Microsoft.Windows.MSPaint*'
    'App.Support.QuickAssist*'
    'Microsoft.Windows.SnippingTool*'
    'App.StepsRecorder*'
    'Hello.Face*'
    'Media.WindowsMediaPlayer*'
    'Microsoft.Windows.WordPad*'
)

Write-Host "Removing unneeded Windows Capabilities..."
Get-WindowsCapability -Online | Where-Object {
    $cap = $_
    if ($cap.State -in @('NotPresent', 'Removed')) { return $false }
    foreach ($p in $patterns) {
        if ($cap.Name -like $p) { return $true }
    }
    return $false
} | ForEach-Object {
    Write-Host "Removing capability: $($_.Name)..."
    $_ | Remove-WindowsCapability -Online -ErrorAction SilentlyContinue
}
