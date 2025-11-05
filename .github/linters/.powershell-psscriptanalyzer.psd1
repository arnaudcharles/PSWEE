@{
    Rules        = @{
        PSAlignAssignmentStatement         = @{
            Enable         = $true
            CheckHashtable = $true
        }
        PSAvoidLongLines                   = @{
            Enable            = $true
            MaximumLineLength = 150
        }
        PSAvoidSemicolonsAsLineTerminators = @{
            Enable = $true
        }
        PSPlaceCloseBrace                  = @{
            Enable             = $true
            NewLineAfter       = $false
            IgnoreOneLineBlock = $true
            NoEmptyLineBefore  = $false
        }
        PSPlaceOpenBrace                   = @{
            Enable             = $true
            OnSameLine         = $true
            NewLineAfter       = $true
            IgnoreOneLineBlock = $true
        }
        PSProvideCommentHelp               = @{
            Enable                  = $true
            ExportedOnly            = $false
            BlockComment            = $true
            VSCodeSnippetCorrection = $false
            Placement               = 'begin'
        }
        PSUseConsistentIndentation         = @{
            Enable              = $true
            IndentationSize     = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind                = 'space'
        }
        PSUseConsistentWhitespace          = @{
            Enable                                  = $true
            CheckInnerBrace                         = $true
            CheckOpenBrace                          = $true
            CheckOpenParen                          = $true
            CheckOperator                           = $true
            CheckPipe                               = $true
            CheckPipeForRedundantWhitespace         = $true
            CheckSeparator                          = $true
            CheckParameter                          = $true
            IgnoreAssignmentOperatorInsideHashTable = $true
        }
    }
    ExcludeRules = @(
        'PSMissingModuleManifestField',                 # This rule is not applicable until the module is built.
        'PSUseToExportFieldsInManifest',                # This rule is not applicable until the module is built.
        'PSUseOutputTypeCorrectly',                     # This rule can produce false positives in certain scenarios.
        'PSAlignAssignmentStatement',                   # False positives with hashtables in scriptblocks.
        'PSAvoidLongLines',                             # Because common we have large screen now ...
        'PSAvoidUsingWriteHost',                        # Write-Host is used for user feedback in this module.
        'PSUseSingularNouns',                           # Module uses plural nouns for some cmdlets by design.
        'PSPlaceCloseBrace',                            # False positives with one-line scriptblocks.
        'PSReviewUnusedParameter',                      # Some functions have parameters that are used in scriptblocks invoked remotely.
        'PSUseUsingScopeModifierInNewRunspaces',        # False positives in certain remote execution scenarios.
        'PSUseBOMForUnicodeEncodedFile',                # Not all files are saved with BOM.
        'PSUseConsistentIndentation',                   # False positives with here-strings.
        'PSUseShouldProcessForStateChangingFunctions',  # Some functions are not state-changing and do not require ShouldProcess.
        'PSAvoidUsingComputerNameHardcoded',            # Hardcoded computer names are used in examples and test scripts.
        'PSAvoidOverwritingBuiltInCmdlets'              # Module does not overwrite built-in cmdlets.
    )
}
