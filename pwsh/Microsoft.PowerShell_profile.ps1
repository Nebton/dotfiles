# Core git shortcuts (these are lightweight)
Function ga { git add . }
Function gs { git status }
Function gmc { git commit -m $args }
Function gpsh { git push }
Function nv { nvim . }

# Define color variables once
$purpleRGB = "159;135;255"  # RGB values for #9f87ff

# Setup PSReadLine only once (remove duplicates)
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Cursor
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineOption -PredictionViewStyle InlineView
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Vim navigation setup
Set-PSReadLineKeyHandler -Key 0 -Function BeginningOfLine -ViMode Command
Set-PSReadLineKeyHandler -Key '$' -Function EndOfLine -ViMode Command
Set-PSReadLineKeyHandler -Key 'h' -Function BackwardChar -ViMode Command
Set-PSReadLineKeyHandler -Key 'l' -Function ForwardChar -ViMode Command
Set-PSReadLineKeyHandler -Key 'w' -Function NextWord -ViMode Command
Set-PSReadLineKeyHandler -Key 'b' -Function BackwardWord -ViMode Command
Set-PSReadLineKeyHandler -Key 'k' -Function HistorySearchBackward -ViMode Command
Set-PSReadLineKeyHandler -Key 'j' -Function HistorySearchForward -ViMode Command
Set-PSReadLineKeyHandler -Key 'x' -Function DeleteChar -ViMode Command
Set-PSReadLineKeyHandler -Key 'u' -Function Undo -ViMode Command
Set-PSReadLineKeyHandler -Chord 'd,d' -ViMode Command -Function DeleteLine

# Configure colors
Set-PSReadLineOption -Colors @{
    Command = "$([char]0x1b)[38;2;$purpleRGB`m"
    Parameter = 'White'
    Operator = 'White'
    Variable = 'White'
    String = 'Yellow'
    Number = 'Green'
    Type = 'Green'
    Comment = 'DarkGray'
}

# Define a custom function for 'dw' (delete word)
function DeleteWordViMode {
    [Microsoft.PowerShell.PSConsoleReadLine]::DeleteWord()
}
Set-PSReadLineKeyHandler -Chord 'd,w' -ViMode Command -ScriptBlock ${function:DeleteWordViMode}

# LAZY LOADING FUNCTIONS FOR MODULES
# These functions load modules only when needed

# Function to lazy load posh-git
$global:PoshGitLoaded = $false
function LoadPoshGit {
    if (-not $global:PoshGitLoaded) {
        if (Get-Module -ListAvailable -Name posh-git) {
            Import-Module posh-git -ErrorAction SilentlyContinue
            $global:PoshGitLoaded = $true
        }
    }
}

# Function to lazy load Terminal-Icons
$global:TerminalIconsLoaded = $false
function LoadTerminalIcons {
    if (-not $global:TerminalIconsLoaded) {
        if (Get-Module -ListAvailable -Name Terminal-Icons) {
            Import-Module Terminal-Icons -ErrorAction SilentlyContinue
            $global:TerminalIconsLoaded = $true
        }
    }
}

# Function to lazy load z module
$global:ZModuleLoaded = $false
function LoadZModule {
    if (-not $global:ZModuleLoaded) {
        if (Get-Module -ListAvailable -Name z) {
            Import-Module z -ErrorAction SilentlyContinue
            $global:ZModuleLoaded = $true
        }
    }
}

# Create alias for the z function to trigger loading
function z { 
    LoadZModule
    if (Get-Command -Name z -CommandType Function -ErrorAction SilentlyContinue) {
        & (Get-Command z -CommandType Function) @args 
    } else {
        Write-Host "z module not available" -ForegroundColor Yellow
    }
}

# Improved prompt function with lazy loading of git module
function prompt {
    # Load posh-git only when in a git repository
    if (Test-Path .git -ErrorAction SilentlyContinue) {
        LoadPoshGit
    }
    
    # Get username and hostname
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME
    
    # Get current path with home folder as ~
    $fullPath = $PWD.Path.Replace($HOME, "~")
    
    # Path display logic - show last folder if path is long
    $pathDisplay = if ($fullPath.Length -gt 15) {
        Split-Path -Leaf $PWD.Path
    } else {
        $fullPath
    }
    
    # Get git information if available
    $gitInfo = ""
    if ($global:PoshGitLoaded -and (Get-Command Get-GitStatus -ErrorAction SilentlyContinue)) {
        $git = Get-GitStatus
        if ($git) {
            $branch = $git.Branch
            $gitInfo = "$([char]0x1b)[38;2;$purpleRGB`m𒌐$([char]0x1b)[0m:$branch"
            
            # Add git status indicators 
            $status = ""
            if ($git.HasIndex) { $status += "$([char]0x1b)[32m+$([char]0x1b)[0m" }
            if ($git.HasWorking) { $status += "$([char]0x1b)[33m~$([char]0x1b)[0m" }
            if ($git.HasDeleted) { $status += "$([char]0x1b)[31m×$([char]0x1b)[0m" }
            if ($git.HasUntracked) { $status += "$([char]0x1b)[37m•$([char]0x1b)[0m" }
            if ($git.HasStash) { $status += "$([char]0x1b)[36m≡$([char]0x1b)[0m" }
            if ($git.BehindBy -gt 0) { $status += "$([char]0x1b)[31;1m⇣$([char]0x1b)[0m" }
            if ($git.AheadBy -gt 0) { $status += "$([char]0x1b)[32;1m⇡$([char]0x1b)[0m" }
            if ($status) {
                $gitInfo += " [$status]"
            }
        }
    }
    
    # Format prompt components
    $usernameHost = "$([char]0x1b)[37m$username@$([char]0x1b)[38;2;$purpleRGB`m$hostname$([char]0x1b)[0m"
    $pathText = "$([char]0x1b)[37m$pathDisplay$([char]0x1b)[0m"
    $promptChar = "$([char]0x1b)[38;2;$purpleRGB`m>$([char]0x1b)[0m"
    
    # Set console title
    $Host.UI.RawUI.WindowTitle = "$fullPath - PowerShell"
    
    # Format the final prompt with git info
    if ($gitInfo -ne "") {
        $prompt = "$usernameHost $pathText "
        Write-Host $prompt -NoNewline
        
        # Only do the positioning calculation if needed
        $consoleWidth = $Host.UI.RawUI.WindowSize.Width
        $gitInfoLength = ($gitInfo -replace '\x1b\[[0-9;]*m', '').Length - 4
        $position = [Math]::Max(1, $consoleWidth - $gitInfoLength - 2)
        
        Write-Host "$([char]0x1b)[${position}G$gitInfo" -NoNewline
        Write-Host "`r" -NoNewline
        Write-Host "$prompt$promptChar " -NoNewline
        
        return " "
    } else {
        # Simple prompt without git info
        Write-Host "$usernameHost $pathText $promptChar " -NoNewline
        return " "
    }
}

# Fixed function to make ls output prettier with lazy loading
function Get-ColorizedChildItem {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $params
    )
    
    # Run Get-ChildItem with parameters
    $items = Get-ChildItem @params
    
    if ($null -eq $items) {
        return
    }
    
    # Get the longest name for formatting (more efficient)
    $maxNameLength = 0
    foreach ($item in $items) {
        if ($item.Name.Length -gt $maxNameLength) {
            $maxNameLength = $item.Name.Length
        }
    }
    
    foreach ($item in $items) {
        # Choose color based on item type
        if ($item.PSIsContainer) {
            $nameColor = "$([char]0x1b)[38;2;$purpleRGB`m"
        } elseif ($item.Extension -match '\.(exe|bat|cmd|ps1|psm1)$') {
            $nameColor = "$([char]0x1b)[32m"
        } elseif ($item.Extension -match '\.(txt|log|md)$') {
            $nameColor = "$([char]0x1b)[37m"
        } else {
            $nameColor = "$([char]0x1b)[0m"
        }
        
        # Format the output
        $mode = $item.Mode
        $lastWriteTime = $item.LastWriteTime.ToString("MM/dd/yyyy hh:mm tt")
        $length = if ($item.PSIsContainer) { "<DIR>" } else { $item.Length.ToString("#,##0") }
        $name = $item.Name
        
        # Output with colors
        "$mode  $lastWriteTime  $($length.PadLeft(10))  $nameColor$name$([char]0x1b)[0m"
    }
}

# Create alias for the colorized ls
Set-Alias -Name ls -Value Get-ColorizedChildItem -Option AllScope -Force

# LOAD PSFZF AT THE END WITH KEYBINDINGS
# This ensures the keybindings work correctly
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+e' -PSReadlineChordReverseHistory 'Ctrl+r'
}
