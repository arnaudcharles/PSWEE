<#
.SYNOPSIS
    Automates the generation of Charmbracelet VHS .tape scripts and media artifacts (GIF, MP4)
    from module examples and public function comment-based help (.EXAMPLE).

.DESCRIPTION
    Build-VhsMedia scans both:
      1. Public functions in src/functions/public/*.ps1 for .EXAMPLE blocks
      2. Standalone example scripts in examples/*.ps1
    It deduplicates commands between both sources, generates .tape script files ready for VHS,
    and optionally executes VHS to render media assets into the media/ folder.
    Designed for local development and CI/CD pipelines (GitHub Actions, GitLab CI).

.PARAMETER ModuleRoot
    The root directory of the PowerShell module. Defaults to repository root.

.PARAMETER ExamplesFolder
    Subfolder containing example .ps1 files. Defaults to 'examples'.

.PARAMETER PublicFunctionsFolder
    Subfolder containing public function definitions. Defaults to 'src/functions/public'.

.PARAMETER TapesFolder
    Folder where generated .tape files will be stored. Defaults to 'tapes'.

.PARAMETER MediaFolder
    Folder where rendered media (GIF/MP4) will be saved. Defaults to 'media'.

.PARAMETER Format
    Output format for the rendered media: 'gif', 'mp4', 'webm', or 'png'. Defaults to 'gif'.

.PARAMETER Theme
    Terminal theme for VHS (e.g., 'Catppuccin Mocha', 'TokyoNight', 'Dracula'). Defaults to 'Catppuccin Mocha'.

.PARAMETER FontSize
    Font size in points for the terminal recording. Defaults to 14.

.PARAMETER Width
    Width in pixels for the terminal window. Defaults to 1200.

.PARAMETER Height
    Height in pixels for the terminal window. Defaults to 700.

.PARAMETER TypingSpeed
    Typing delay per character (e.g. '50ms', '75ms'). Defaults to '60ms'.

.PARAMETER Render
    Switch to invoke the VHS CLI on all generated or existing tapes.

.PARAMETER Priority
    Source to prioritize when deduplicating identical or equivalent command signatures:
    'ExamplesFolder' (default) or 'PublicFunctions'.
    'ExamplesFolder' is ideal for using real server names / endpoints to generate realistic media.
    'PublicFunctions' prioritizes generic/dummy names from Comment-Based Help.

.PARAMETER Source
    Filter which source to scan: 'All' (default), 'ExamplesFolderOnly', or 'PublicFunctionsOnly'.

.PARAMETER Showcase
    Switch to generate a multi-step showcase .tape (<FunctionName>-showcase.tape).
    By default, it looks for dedicated showcase files following the convention 'Ex_<FunctionName>-showcase.ps1'
    in the examples/ folder. Can also be overridden with -ShowcasePath.

.PARAMETER ShowcasePath
    Optional path to a custom showcase script (.ps1) to use instead of the default convention 'Ex_<FunctionName>-showcase.ps1'.

.PARAMETER FunctionName
    Optional filter to target only a specific public function name.

.PARAMETER Force
    Overwrite existing .tape files if they already exist.

.EXAMPLE
    # Generate .tape files prioritizing examples/ folder
    .\tools\Build-VhsMedia.ps1

.EXAMPLE
    # Prioritize .EXAMPLE blocks from public functions instead
    .\tools\Build-VhsMedia.ps1 -Priority PublicFunctions -Force

.EXAMPLE
    # Only scan the examples/ folder and render
    .\tools\Build-VhsMedia.ps1 -Source ExamplesFolderOnly -Render

.EXAMPLE
    # Generate showcase tape using Ex_Start-PSWEE-showcase.ps1 convention
    .\tools\Build-VhsMedia.ps1 -Showcase -Render

.EXAMPLE
    # Generate showcase tape from a specific custom script
    .\tools\Build-VhsMedia.ps1 -Showcase -ShowcasePath 'examples/Ex_Start-PSWEE-showcase.ps1' -Render
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$ModuleRoot = (Resolve-Path "$PSScriptRoot\..").Path,

    [Parameter()]
    [string]$ExamplesFolder = "examples",

    [Parameter()]
    [string]$PublicFunctionsFolder = "src\functions\public",

    [Parameter()]
    [string]$TapesFolder = "tapes",

    [Parameter()]
    [string]$MediaFolder = "media",

    [Parameter()]
    [ValidateSet('gif', 'mp4', 'webm', 'png')]
    [string]$Format = 'gif',

    [Parameter()]
    [string]$Theme = 'Catppuccin Mocha',

    [Parameter()]
    [int]$FontSize = 14,

    [Parameter()]
    [int]$Width = 1200,

    [Parameter()]
    [int]$Height = 700,

    [Parameter()]
    [string]$TypingSpeed = '60ms',

    [Parameter()]
    [switch]$Render,

    [Parameter()]
    [switch]$Showcase,

    [Parameter()]
    [string]$ShowcasePath,

    [Parameter()]
    [ValidateSet('ExamplesFolder', 'PublicFunctions')]
    [string]$Priority = 'ExamplesFolder',

    [Parameter()]
    [ValidateSet('All', 'ExamplesFolderOnly', 'PublicFunctionsOnly')]
    [string]$Source = 'All',

    [Parameter()]
    [string]$FunctionName,

    [Parameter()]
    [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-CommandSignature {
    param([string]$Text)
    if ([string]::IsNullOrWhiteSpace($Text)) { return '' }
    # Normalize command to compare signature even if server names / literal values differ
    $clean = $Text.Trim()
    # Replace quoted strings with placeholder <STR> so server names differ without preventing deduplication
    $clean = $clean -replace '("[^"]*"|''[^'']*'')', '<STR>'
    # Normalize common aliases e.g. -cn -> -computername
    $clean = $clean -replace '(?i)\s+-cn\b', ' -ComputerName'
    # Collapse multiple whitespaces and convert to lowercase
    return ($clean -replace '\s+', ' ').ToLowerInvariant()
}

$moduleRootPath = (Resolve-Path -Path $ModuleRoot).Path
$examplesPath = Join-Path $moduleRootPath $ExamplesFolder
$publicPath = Join-Path $moduleRootPath $PublicFunctionsFolder
$tapesPath = Join-Path $moduleRootPath $TapesFolder
$mediaPath = Join-Path $moduleRootPath $MediaFolder

if (-not (Test-Path $tapesPath)) {
    $null = New-Item -ItemType Directory -Path $tapesPath -Force
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " VHS Media Builder - PowerShell Module" -ForegroundColor Cyan
Write-Host " Root: $moduleRootPath" -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Discover Public Functions and extract .EXAMPLE blocks
$publicExamples = [System.Collections.Generic.List[PSCustomObject]]::new()

if (Test-Path $publicPath) {
    $publicFiles = Get-ChildItem -Path $publicPath -Filter "*.ps1"
    if ($FunctionName) {
        $publicFiles = $publicFiles | Where-Object { $_.BaseName -like "*$FunctionName*" }
    }

    foreach ($file in $publicFiles) {
        $raw = Get-Content -Path $file.FullName -Raw
        $regex = '(?ms)\.EXAMPLE\s*\r?\n(.*?)(?=\r?\n\s*\.(?:EXAMPLE|SYNOPSIS|DESCRIPTION|PARAMETER|OUTPUTS|INPUTS|NOTES|LINK|COMPONENT|ROLE|FUNCTIONALITY)|#>)'
        $matches = [regex]::Matches($raw, $regex)

        $exampleIndex = 1
        foreach ($m in $matches) {
            $lines = $m.Groups[1].Value.Trim() -split "\r?\n"
            $cmdLines = @()
            $descLines = @()
            $isDesc = $false

            foreach ($line in $lines) {
                $trimmed = $line.Trim()
                if (-not $trimmed) { continue }
                if ($trimmed.StartsWith("#")) {
                    $descLines += $trimmed.TrimStart('#').Trim()
                    continue
                }

                if (-not $isDesc -and ($trimmed -match '^[A-Za-z0-9]+-[A-Za-z0-9]+' -or $trimmed.StartsWith('$') -or $trimmed.StartsWith('&'))) {
                    $cmdLines += $trimmed
                } else {
                    $isDesc = $true
                    $descLines += $trimmed
                }
            }

            if ($cmdLines.Count -gt 0) {
                $cmdJoined = $cmdLines -join "`n"
                $publicExamples.Add([PSCustomObject]@{
                    Source         = "PublicFunction"
                    FunctionName   = $file.BaseName
                    Index          = $exampleIndex
                    Command        = $cmdJoined
                    Signature      = (Get-CommandSignature -Text $cmdJoined)
                    Description    = ($descLines -join ' ')
                    OriginFile     = $file.Name
                })
                $exampleIndex++
            }
        }
    }
}

Write-Host "[+] Found $($publicExamples.Count) example(s) in public functions." -ForegroundColor Green

# 2. Discover Examples from examples/*.ps1
$scriptExamples = [System.Collections.Generic.List[PSCustomObject]]::new()

if (Test-Path $examplesPath) {
    # Exclude showcase scripts from standard individual example discovery
    $exampleFiles = Get-ChildItem -Path $examplesPath -Filter "*.ps1" | Where-Object {
        $_.BaseName -notlike "*showcase*"
    }
    foreach ($file in $exampleFiles) {
        $raw = Get-Content -Path $file.FullName -Raw
        $tokens = $null
        $errors = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($raw, [ref]$tokens, [ref]$errors)

        $stmtIndex = 1
        foreach ($stmt in $ast.EndBlock.Statements) {
            $text = $stmt.Extent.Text.Trim()
            # Ignore Import-Module and pure variable setups if they're standard preamble
            if ($text -match '^Import-Module\b') { continue }

            # Find comments immediately preceding this statement
            $stmtStartLine = $stmt.Extent.StartLineNumber
            $commentLines = $tokens | Where-Object {
                $_.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment -and
                $_.Extent.EndLineNumber -eq ($stmtStartLine - 1)
            }
            $desc = if ($commentLines) { ($commentLines.Text -replace '^[#\s]+', '') -join ' ' } else { '' }

            # Extract target function name from command statement if possible
            $cmdAst = $stmt.Find({ $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true)
            $targetFn = if ($cmdAst) {
                $cmdAst.GetCommandName()
            } else {
                $file.BaseName -replace '^Ex_', ''
            }
            if (-not $targetFn) {
                $targetFn = $file.BaseName -replace '^Ex_', ''
            }

            $scriptExamples.Add([PSCustomObject]@{
                Source         = "ExampleScript"
                FunctionName   = $targetFn
                Index          = $stmtIndex
                Command        = $text
                Signature      = (Get-CommandSignature -Text $text)
                Description    = $desc
                OriginFile     = $file.Name
            })
            $stmtIndex++
        }
    }
}

Write-Host "[+] Found $($scriptExamples.Count) example(s) in $ExamplesFolder folder." -ForegroundColor Green

# 3. Deduplicate and merge examples based on Priority and Source
$mergedList = [System.Collections.Generic.List[PSCustomObject]]::new()
$seenSignatures = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)

$primaryList = [System.Collections.Generic.List[PSCustomObject]]::new()
$secondaryList = [System.Collections.Generic.List[PSCustomObject]]::new()

if ($Source -eq 'ExamplesFolderOnly') {
    $primaryList.AddRange($scriptExamples)
} elseif ($Source -eq 'PublicFunctionsOnly') {
    $primaryList.AddRange($publicExamples)
} else {
    # Source is 'All' - resolve according to Priority
    if ($Priority -eq 'ExamplesFolder') {
        $primaryList.AddRange($scriptExamples)
        $secondaryList.AddRange($publicExamples)
    } else {
        $primaryList.AddRange($publicExamples)
        $secondaryList.AddRange($scriptExamples)
    }
}

# Add primary items first (they win if signatures conflict)
foreach ($ex in $primaryList) {
    if (-not $seenSignatures.Contains($ex.Signature)) {
        $null = $seenSignatures.Add($ex.Signature)
        # Inherit description from secondary list if primary has none
        if ([string]::IsNullOrWhiteSpace($ex.Description)) {
            $matchingSecondary = $secondaryList | Where-Object {
                $_.Signature -eq $ex.Signature -and -not [string]::IsNullOrWhiteSpace($_.Description)
            } | Select-Object -First 1
            if ($matchingSecondary) {
                $ex.Description = $matchingSecondary.Description
            }
        }
        $mergedList.Add($ex)
    }
}

# Add secondary items only if not already covered by primary
$duplicatesCount = 0
foreach ($ex in $secondaryList) {
    if (-not $seenSignatures.Contains($ex.Signature)) {
        $null = $seenSignatures.Add($ex.Signature)
        $mergedList.Add($ex)
    } else {
        $duplicatesCount++
    }
}

# Re-index items per function to guarantee sequential ex1, ex2... numbering
$byFunction = $mergedList | Group-Object -Property FunctionName
foreach ($group in $byFunction) {
    $idx = 1
    foreach ($item in $group.Group) {
        $item.Index = $idx
        $idx++
    }
}

Write-Host "[+] Deduplication completed (Priority: $Priority, Source: $Source): $duplicatesCount duplicate(s) merged/skipped." -ForegroundColor Yellow
Write-Host "[+] Total distinct scenarios to generate: $($mergedList.Count)" -ForegroundColor Green

# 4. Generate .tape files
$generatedTapes = [System.Collections.Generic.List[string]]::new()

foreach ($item in $mergedList) {
    $fnSafe = ($item.FunctionName -replace '[^\w\-]', '_')
    $targetDirName = "$fnSafe-Examples"
    $tapeFileName = "$fnSafe-ex$($item.Index).tape"
    $tapeFilePath = Join-Path $tapesPath $tapeFileName

    $outputFolderRel = "media/$targetDirName"
    $outputFullPath = Join-Path $mediaPath $targetDirName
    if (-not (Test-Path $outputFullPath)) {
        $null = New-Item -ItemType Directory -Path $outputFullPath -Force
    }

    $outputFile = "../media/$targetDirName/$fnSafe-ex$($item.Index).$Format"

    # Format Type command safely for VHS (VHS does not support \" backslash escapes)
    $typeStatement = if ($item.Command.Contains('"') -and -not $item.Command.Contains("'")) {
        "Type '$($item.Command)'"
    } elseif ($item.Command.Contains("'") -and -not $item.Command.Contains('"')) {
        "Type `"$($item.Command)`""
    } elseif ($item.Command.Contains('"')) {
        "Type `"$($item.Command -replace '"', "'")`""
    } else {
        "Type `"$($item.Command)`""
    }

    # Tape file template
    $tapeContent = @"
# ==============================================================================
# VHS Tape: $($item.FunctionName) - Example $($item.Index)
# Source: $($item.Source) ($($item.OriginFile))
# Description: $($item.Description)
# ==============================================================================

# Output configuration
Output $outputFile

# Terminal settings
Set Shell "pwsh"
Set FontSize $FontSize
Set Width $Width
Set Height $Height
Set Padding 20
Set Theme "$Theme"
Set TypingSpeed $TypingSpeed

# Environment setup
Hide
Type "Get-ChildItem -Path ./src/functions -Recurse -Filter *.ps1 | ForEach-Object { . `$_.FullName }; Clear-Host"
Enter
Sleep 1s
Show

# Command demonstration
$typeStatement
Sleep 500ms
Enter

# Display result
Sleep 3s
"@

    # Content-based change detection (auto-update if source code changed or if -Force)
    $needsUpdate = $Force
    if (-not $needsUpdate -and (Test-Path $tapeFilePath)) {
        $existingContent = (Get-Content -Path $tapeFilePath -Raw).Trim()
        if ($existingContent -ne $tapeContent.Trim()) {
            $needsUpdate = $true
            Write-Host "    [!] Source changed for: $tapeFileName -> Updating" -ForegroundColor Yellow
        }
    } else {
        $needsUpdate = $true
    }

    if ($needsUpdate) {
        Set-Content -Path $tapeFilePath -Value $tapeContent -Encoding utf8
        Write-Host "    -> Generated: $tapeFileName" -ForegroundColor Gray
    } else {
        Write-Verbose "Skipping unchanged tape: $tapeFileName"
    }
    $generatedTapes.Add($tapeFilePath)
}

# 4b. Optional Showcase Tape generation
if ($Showcase) {
    Write-Host "`n[*] Processing Showcase mode..." -ForegroundColor Cyan

    # Determine which functions to process for showcase
    $functionsToTarget = if ($FunctionName) {
        @($FunctionName)
    } else {
        @($byFunction.Name)
    }

    foreach ($fn in $functionsToTarget) {
        $fnSafe = ($fn -replace '[^\w\-]', '_')
        $targetDirName = "$fnSafe-Examples"
        $showcaseFileName = "$fnSafe-showcase.tape"
        $showcaseFilePath = Join-Path $tapesPath $showcaseFileName
        $outputFile = "../media/$targetDirName/$fnSafe-showcase.$Format"

        # Determine showcase script path
        $scriptPathToUse = $null
        if ($ShowcasePath) {
            # User explicitly specified a showcase file
            $resolvedCustom = Join-Path $moduleRootPath $ShowcasePath
            if (Test-Path $resolvedCustom) {
                $scriptPathToUse = $resolvedCustom
            } elseif (Test-Path $ShowcasePath) {
                $scriptPathToUse = (Resolve-Path $ShowcasePath).Path
            } else {
                Write-Warning "Specified -ShowcasePath not found: $ShowcasePath"
            }
        } else {
            # Convention: Ex_<FunctionName>-showcase.ps1 in examples folder
            $cand1 = Join-Path $examplesPath "Ex_$fn-showcase.ps1"
            $cand2 = Join-Path $examplesPath "Ex_$fn-Showcase.ps1"
            $cand3 = Join-Path $examplesPath "$fn-showcase.ps1"
            $candidates = @($cand1, $cand2, $cand3)
            foreach ($cand in $candidates) {
                if (Test-Path $cand) {
                    $scriptPathToUse = $cand
                    break
                }
            }
        }

        if (-not $scriptPathToUse) {
            Write-Warning "No showcase script found for function '$fn' (expected convention: examples/Ex_$fn-showcase.ps1). Skipping showcase for this function."
            continue
        }

        Write-Host "    [+] Showcase source for ${fn}: $(Split-Path -Leaf $scriptPathToUse)" -ForegroundColor Green

        # Parse commands and steps from the designated showcase script
        $showcaseRaw = Get-Content -Path $scriptPathToUse -Raw
        $scTokens = $null
        $scErrors = $null
        $scAst = [System.Management.Automation.Language.Parser]::ParseInput($showcaseRaw, [ref]$scTokens, [ref]$scErrors)

        $preambleSb = [System.Text.StringBuilder]::new()
        $stepsSb = [System.Text.StringBuilder]::new()
        $stepIndex = 1

        foreach ($stmt in $scAst.EndBlock.Statements) {
            $stmtText = $stmt.Extent.Text.Trim()
            if ($stmtText -match '^Import-Module\b') { continue }

            # Variable assignments ($UserTemp = ..., $Cred = ...) belong to preamble/environment setup
            if ($stmt -is [System.Management.Automation.Language.AssignmentStatementAst] -or $stmtText.StartsWith('$')) {
                [void]$preambleSb.AppendLine("Type `"$($stmtText -replace '"', "'")`"`nEnter`nSleep 300ms")
                continue
            }

            # Retrieve comment immediately before the statement
            $stmtStartLine = $stmt.Extent.StartLineNumber
            $commentLines = $scTokens | Where-Object {
                $_.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment -and
                $_.Extent.EndLineNumber -eq ($stmtStartLine - 1)
            }
            $stepDesc = if ($commentLines) {
                ($commentLines.Text -replace '^[#\s]+', '') -join ' '
            } else {
                "Step $stepIndex"
            }

            $stepTypeCmd = if ($stmtText.Contains('"') -and -not $stmtText.Contains("'")) {
                "Type '$stmtText'"
            } elseif ($stmtText.Contains("'") -and -not $stmtText.Contains('"')) {
                "Type `"$stmtText`""
            } else {
                "Type `"$($stmtText -replace '"', "'")`""
            }

            $exitInteractivity = if ($stmtText -match 'Start-PSWEE|Start-PSBite') {
                "`nDown 1`nSleep 800ms`nType `"q`"`nSleep 1s"
            } else {
                "Sleep 2s"
            }

            [void]$stepsSb.AppendLine(@"
# ------------------------------------------------------------------------------
# Step ${stepIndex}: $stepDesc
# ------------------------------------------------------------------------------
Type "# Step ${stepIndex}: $stepDesc"
Enter
Sleep 500ms
$stepTypeCmd
Sleep 500ms
Enter
Sleep 2s$exitInteractivity
Type "Clear-Host"
Enter
Sleep 500ms
"@)
            $stepIndex++
        }

        $showcaseContent = @"
# ==============================================================================
# VHS Showcase: $fnSafe - Full Walkthrough
# Source: $(Split-Path -Leaf $scriptPathToUse)
# Total Steps: $($stepIndex - 1)
# ==============================================================================

# Output configuration
Output $outputFile

# Terminal settings
Set Shell "pwsh"
Set FontSize $FontSize
Set Width $Width
Set Height $Height
Set Padding 20
Set Theme "$Theme"
Set TypingSpeed $TypingSpeed

# Environment setup
Hide
Type "Get-ChildItem -Path ./src/functions -Recurse -Filter *.ps1 | ForEach-Object { . `$_.FullName }"
Enter
Sleep 500ms
$($preambleSb.ToString())Type "Clear-Host"
Enter
Sleep 1s
Show

$($stepsSb.ToString())
"@

        $needsUpdateSc = $Force
        if (-not $needsUpdateSc -and (Test-Path $showcaseFilePath)) {
            $existingSc = (Get-Content -Path $showcaseFilePath -Raw).Trim()
            if ($existingSc -ne $showcaseContent.Trim()) {
                $needsUpdateSc = $true
            }
        } else {
            $needsUpdateSc = $true
        }

        if ($needsUpdateSc) {
            Set-Content -Path $showcaseFilePath -Value $showcaseContent -Encoding utf8
            Write-Host "    -> Generated Showcase: $showcaseFileName" -ForegroundColor Magenta
        } else {
            Write-Verbose "Skipping unchanged showcase tape: $showcaseFileName"
        }
        $generatedTapes.Add($showcaseFilePath)
    }
}

# 5. Render using VHS if requested
if ($Render) {
    $vhsCmd = Get-Command -Name 'vhs' -ErrorAction SilentlyContinue
    if (-not $vhsCmd) {
        Write-Error @"
VHS CLI was not found in PATH!
To install VHS on Windows:
  winget install charmbracelet.vhs
  winget install Gyan.FFmpeg
Or with Scoop:
  scoop install vhs ffmpeg
"@
        return
    }

    Write-Host "`n==========================================================" -ForegroundColor Cyan
    Write-Host " Rendering tapes with VHS..." -ForegroundColor Cyan
    Write-Host "==========================================================" -ForegroundColor Cyan

    Push-Location $tapesPath
    try {
        # Discover all tapes in folder (generated + custom)
        $allTapes = Get-ChildItem -Path $tapesPath -Filter "*.tape"
        foreach ($tapeFile in $allTapes) {
            $name = $tapeFile.Name
            Write-Host "[*] Rendering $name ..." -ForegroundColor Yellow
            & vhs $name
            if ($LASTEXITCODE -eq 0) {
                Write-Host "    [✓] Done: $name" -ForegroundColor Green
            } else {
                Write-Host "    [✗] Failed to render $name" -ForegroundColor Red
            }
        }
    } finally {
        Pop-Location
    }
}

Write-Host "`nProcess finished successfully!" -ForegroundColor Green
