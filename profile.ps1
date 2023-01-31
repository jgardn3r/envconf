using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# helper functions
function Set-CustomAlias($Name, [scriptblock]$Script) {
    $FunctionName = "Invoke-$Name"
    New-Item -Path function: -Name script:$FunctionName -Value $Script -Force -Option AllScope | Out-Null
    New-Alias -Name $Name -Value $FunctionName -Force -Option AllScope -Scope Global
}

# import modules
Import-Module -Name PSFzf

# git aliases
Set-CustomAlias gco { git checkout @Args }
Set-CustomAlias gcb { git checkout -b @Args }
Set-CustomAlias gc { git commit @Args }
Set-CustomAlias gca { git commit -a @Args }
Set-CustomAlias gbc { git bundle create @Args }
Set-CustomAlias gb { git branch @Args }
Set-CustomAlias gs { git status @Args }
Set-CustomAlias gr { git rebase @Args }
Set-CustomAlias grm { git rebase master @Args }
Set-CustomAlias gri { git rebase -i --autosquash @Args }
Set-CustomAlias grim { git rebase -i master @Args }

Set-CustomAlias ga { git add @Args }

Set-CustomAlias gl {
    $Green = "$([char]27)[32m"
    # $Indentor = [char]0x2514 + [char]0x2500 # '└─'
    $Indentor = '|>'
    # $Separator = [char]0x2595 # '▕'
    $Separator = '|||'
    $EscapedSeparator = [regex]::Escape($Separator)
    git log --color=always --decorate --date=relative -n 100 @Args `
        --pretty=format:"%C(yellow)%h$Separator%Cred%cd$Separator%Cblue%an$Separator%Creset%s$Separator%D" |
        column --table --separator $Separator --output-separator $Separator |
        sed -E "s/$EscapedSeparator([^$Separator]+)$/\n    $Green$Indentor \1/" |
        sed -E "s/$EscapedSeparator/ /g" |
        less -R -S -# 1
}

Set-CustomAlias fixup { git commit --fixup @Args }
Set-CustomAlias amend { git commit --amend @Args }
Set-CustomAlias noedit { git commit --amend --no-edit @Args }

Set-CustomAlias gcam {
    param([Parameter(ValueFromRemainingArguments)][string]$Message)
    git commit -a -m $Message
}

Set-CustomAlias gcm {
    param([Parameter(ValueFromRemainingArguments)][string]$Message)
    git commit -m $Message
}

# custom shortcuts
Set-PSReadLineKeyHandler -Chord 'Ctrl+g,Ctrl+b' -ScriptBlock {
    $CurrentLine = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $CurrentLine, [ref] $null)
    $Branch = ((git branch -a --color=always) -replace '^..', '') -notmatch 'HEAD' |
        Invoke-Fzf -Ansi -Prompt $CurrentLine -PreviewWindow 'right:70%' -Preview 'git log -n100'
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$Branch")
}
Set-PSReadLineKeyHandler -Chord 'Ctrl+g,Ctrl+l' -ScriptBlock {
    $CurrentLine = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref] $CurrentLine, [ref] $null)
    $Separator = "|||"
    $LogLine = git log --color=always --date=relative -n 100 `
        --pretty=format:"%C(yellow)%h$Separator%Cred%cd$Separator%C(cyan)%aN$Separator%Creset%s" |
        column --table --separator $Separator --output-separator " " |
        Invoke-Fzf -Ansi -Prompt $CurrentLine -ReverseInput -NoSort `
        -Preview 'powershell -NoProfile -NonInteractive -Command git show --stat --color=always $Args[0] {}'
        # 'git show --stat --color=always ({} | head -n1)'
    $SHA = $LogLine -replace '([a-f0-9]{7,}).*', '$1'
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$SHA")
}
Set-PSReadLineKeyHandler -Chord 'Alt+g' -ScriptBlock {
    $Branch = ((git branch -a --color=never) -replace '^..', '') -notmatch 'HEAD' |
        Invoke-Fzf -Prompt 'git checkout '
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    if ($Branch) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("git checkout $Branch")
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

. $PSScriptRoot/SmartQuotesAndBrackets.ps1
. $PSScriptRoot/TabCompleteForwardSlashes.ps1