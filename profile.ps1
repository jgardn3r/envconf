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