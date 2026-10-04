$ErrorActionPreference='Stop'
Add-Type -Path (Join-Path $PSScriptRoot 'MathChecks.cs')
$result=[TfMathChecks]::Run()
$result | ConvertTo-Json -Depth 5 | Set-Content (Join-Path $PSScriptRoot 'math_validation.json') -Encoding UTF8
$result | ConvertTo-Json -Depth 5
