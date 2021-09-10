#requires -modules PSScriptAnalyzer

Import-Module -FullyQualifiedName './PSColorizer.psd1'
Import-Module -Name 'PSScriptAnalyzer'

$manifest = Test-ModuleManifest './PSColorizer.psd1'

$module_version = $manifest.Version

Write-Colorized -Message ('Publishing PSColorizer v<yellow>' + $module_version + '</yellow>...')

$api_key_path = Join-Path $PSScriptRoot '.api-key'

$api_key = ''

if($env:PS_API_KEY) {
    $api_key = $env:PS_API_KEY
} elseif(Test-Path $api_key_path) {
    $api_key = Get-Content $api_key_path -Raw
} else {
    Write-Error 'Could not find API key for PowerShellGallery publishing! It must be specified either in PS_API_KEY environment variable or in the .api-key file.'
    exit 1
}

Write-Colorized "API key found! ($($api_key.Substring(0, 6)))"

Write-Colorized "Running PSScriptAnalyzer on module..."
$analysis = Invoke-ScriptAnalyzer -Path 'PSColorizer.psm1' -IncludeDefaultRules -CustomRulePath './' -Verbose

if($null -ne $analysis) {
    Write-Colorized 'Found rule violations in module file. Fix them before publishing module!' -DefaultColor Red
    exit 1
}

Write-Colorized 'Publishing module...'
Publish-Module -Path '../PSColorizer' -NuGetApiKey $api_key -Verbose
