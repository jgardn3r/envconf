function Tabexpansion2 {
    [CmdletBinding(DefaultParameterSetName = 'ScriptInputSet')]
    Param
    (
        [Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 0)]
        [string] $InputScript,

        [Parameter(ParameterSetName = 'ScriptInputSet', Mandatory = $true, Position = 1)]
        [int] $CursorColumn,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 0)]
        [Ast] $Ast,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 1)]
        [Token[]] $Tokens,

        [Parameter(ParameterSetName = 'AstInputSet', Mandatory = $true, Position = 2)]
        [IScriptPosition] $PositionOfCursor,

        [Parameter(ParameterSetName = 'ScriptInputSet', Position = 2)]
        [Parameter(ParameterSetName = 'AstInputSet', Position = 3)]
        [Hashtable] $Options = @{}
    )

    End {
        $Options.RelativeFilePaths = $false

        $CompletionData = if ($psCmdlet.ParameterSetName -eq 'ScriptInputSet') {
            [CommandCompletion]::CompleteInput($InputScript, $CursorColumn, $Options)
        } else {
            [CommandCompletion]::CompleteInput($Ast, $Tokens, $PositionOfCursor, $Options)
        }
        if (-Not $CompletionData.CompletionMatches.Count) {
            return $CompletionData
        }
        $NewCompletionMatches = [System.Collections.Generic.List[CompletionResult]]::new()
        $ForwardSlashCompletionResultTypes = @(
            [CompletionResultType]::Command,
            [CompletionResultType]::ProviderContainer,
            [CompletionResultType]::ProviderItem
         )
        foreach ($CompletionMatch in $CompletionData.CompletionMatches) {
            $CompletionResult = $CompletionMatch
            if ($ForwardSlashCompletionResultTypes -contains $CompletionMatch.ResultType) {
                $CompletionResult = [CompletionResult]::new(
                    $CompletionMatch.CompletionText.Replace('\', '/'),
                    $CompletionMatch.ListItemText,
                    $CompletionMatch.ResultType,
                    $CompletionMatch.ToolTip
                )
            }
            $NewCompletionMatches.Add($CompletionResult)
        }
        return [CommandCompletion]::new(
            $NewCompletionMatches,
            $CompletionData.CurrentMatchIndex,
            $CompletionData.ReplacementIndex,
            $CompletionData.ReplacementLength
        )
    }
}

function Update-BackslashAtCursor {
    $LineContent = ""
    $CursorPosition = 0

    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $LineContent, [ref] $CursorPosition)
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    if ($LineContent -and $LineContent[$CursorPosition - 1] -eq '\') {
        $LineContent = $LineContent.Remove($CursorPosition - 1, 1).Insert($CursorPosition - 1, '/')
    }
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($LineContent)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($CursorPosition)
}

Set-PSReadLineKeyHandler -Chord Tab -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::ViTabCompleteNext()
    Update-BackslashAtCursor
}

Set-PSReadLineKeyHandler -Chord Shift+Tab -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::ViTabCompletePrevious()
    Update-BackslashAtCursor
}