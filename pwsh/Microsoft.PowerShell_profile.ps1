# Keep your existing functions and modules
Function ga { git add . }
Function gs { git status }
Function gmc { git commit -m $args }
Function gpsh { git push }
Function nv { nvim . }


# Import posh-git module for git status information
if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
} else {
    Write-Host "Consider installing posh-git module for git integration: Install-Module posh-git -Scope CurrentUser"
}

# Import Terminal-Icons for prettier directory listings (if not installed, it will show a message)
if (Get-Module -ListAvailable -Name Terminal-Icons) {
    Import-Module Terminal-Icons
} else {
    Write-Host "Consider installing Terminal-Icons module for prettier directory listings: Install-Module Terminal-Icons -Scope CurrentUser"
}

# Define the custom theme color (similar to the purple in your ZSH theme)
$purpleRGB = "159;135;255"  # RGB values for #9f87ff

# Setup Vim mode for PSReadLine
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Cursor

# Configure Tab completion to work like in ZSH
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete


# Configure key handlers for Vim-like experience
# Basic navigation - these work with single characters
Set-PSReadLineKeyHandler -Key 0 -Function BeginningOfLine -ViMode Command
Set-PSReadLineKeyHandler -Key '$' -Function EndOfLine -ViMode Command
Set-PSReadLineKeyHandler -Key 'h' -Function BackwardChar -ViMode Command
Set-PSReadLineKeyHandler -Key 'l' -Function ForwardChar -ViMode Command
Set-PSReadLineKeyHandler -Key 'w' -Function NextWord -ViMode Command
Set-PSReadLineKeyHandler -Key 'b' -Function BackwardWord -ViMode Command

# Command history
Set-PSReadLineKeyHandler -Key 'k' -Function HistorySearchBackward -ViMode Command
Set-PSReadLineKeyHandler -Key 'j' -Function HistorySearchForward -ViMode Command
Set-PSReadLineKeyHandler -Key 'x' -Function DeleteChar -ViMode Command

# Undo/Redo
Set-PSReadLineKeyHandler -Key 'u' -Function Undo -ViMode Command

# Setup a custom chord for dd (delete line)
Set-PSReadLineKeyHandler -Chord 'd,d' -ViMode Command -Function DeleteLine

# Define a custom function for 'dw' (delete word)
function DeleteWordViMode {
    [Microsoft.PowerShell.PSConsoleReadLine]::DeleteWord()
}
# Register the custom function
Set-PSReadLineKeyHandler -Chord 'd,w' -ViMode Command -ScriptBlock ${function:DeleteWordViMode}

# Improved prompt function with specific git icons
function prompt {
    # Get username and hostname
    $username = $env:USERNAME
    $hostname = $env:COMPUTERNAME
    
    # Get current path with home folder as ~
    $fullPath = $PWD.Path.Replace($HOME, "~")
    
    # Path display logic - show last folder if path is long, otherwise show abbreviated path
    $pathDisplay = if ($fullPath.Length -gt 15) {
        # Just show the last folder name
        Split-Path -Leaf $PWD.Path
    } else {
        # Show abbreviated path
        $fullPath
    }
    
    # Get git information if available
    $gitInfo = ""
    if (Get-Command Get-GitStatus -ErrorAction SilentlyContinue) {
        $git = Get-GitStatus
        if ($git) {
            $branch = $git.Branch
            # Create a git info string with the specified icon
            $gitInfo = "$([char]0x1b)[38;2;$purpleRGB`m𒌐$([char]0x1b)[0m:$branch"
            
            # Add git status indicators matching your ZSH theme
            $status = ""
            # Minimalist symbols
            if ($git.HasIndex) { $status += "$([char]0x1b)[32m+$([char]0x1b)[0m" }            # Added
            if ($git.HasWorking) { $status += "$([char]0x1b)[33m~$([char]0x1b)[0m" }          # Modified
            if ($git.HasDeleted) { $status += "$([char]0x1b)[31m×$([char]0x1b)[0m" }          # Deleted
            if ($git.HasUntracked) { $status += "$([char]0x1b)[37m•$([char]0x1b)[0m" }        # Untracked
            if ($git.HasStash) { $status += "$([char]0x1b)[36m≡$([char]0x1b)[0m" }            # Stashed
            if ($git.BehindBy -gt 0) { $status += "$([char]0x1b)[31;1m⇣$([char]0x1b)[0m" }    # Behind
            if ($git.AheadBy -gt 0) { $status += "$([char]0x1b)[32;1m⇡$([char]0x1b)[0m" }     # Ahead            
            if ($status) {
                $gitInfo += " [$status]"
            }
        }
    }
    
    # Format prompt components
    $usernameHost = "$([char]0x1b)[37m$username@$([char]0x1b)[38;2;$purpleRGB`m$hostname$([char]0x1b)[0m"
    $pathText = "$([char]0x1b)[37m$pathDisplay$([char]0x1b)[0m"
    $promptChar = "$([char]0x1b)[38;2;$purpleRGB`m>$([char]0x1b)[0m"
    
    # Set console title to match current location (full path)
    $Host.UI.RawUI.WindowTitle = "$fullPath - PowerShell"
    
    # Clear the entire line before writing prompt to prevent overwriting
    Write-Host "`r$([char]0x1b)[K" -NoNewline
    
    # Format the final prompt with properly positioned git info
    if ($gitInfo -ne "") {
        # Get console width
        $consoleWidth = $Host.UI.RawUI.WindowSize.Width
        
        # Calculate how much space to leave between prompt and git info
        $effectivePromptLength = ($username + "@" + $hostname + " " + $pathDisplay + " > ").Length
        $gitInfoLength = ($gitInfo -replace '\x1b\[[0-9;]*m', '').Length - 4 
        
        # Write the prompt parts
        $prompt = "$usernameHost $pathText "
        Write-Host $prompt -NoNewline
        
        # Position cursor at end of line minus git info length
        $position = [Math]::Max(1, $consoleWidth - $gitInfoLength - 2)
        Write-Host "$([char]0x1b)[${position}G$gitInfo" -NoNewline
        
        # Move cursor back to where prompt should continue
        Write-Host "`r" -NoNewline
        Write-Host "$prompt$promptChar " -NoNewline
        
        return " "  # Return a space so the cursor position is correct
    } else {
        # Simple prompt without git info
        Write-Host "$usernameHost $pathText $promptChar " -NoNewline
        return " "
    }
}

# Fixed function to make ls output prettier and properly display
function Get-ColorizedChildItem {
    param(
        [Parameter(ValueFromRemainingArguments=$true)]
        $params
    )
    
    # Run the original Get-ChildItem with any parameters
    $items = Get-ChildItem @params
    
    if ($null -eq $items) {
        # Return early if directory is empty
        return
    }
    
    # Get the longest name for formatting
    $maxNameLength = ($items | ForEach-Object { $_.Name.Length } | Measure-Object -Maximum).Maximum
    
    foreach ($item in $items) {
        # Choose color based on item type
        if ($item.PSIsContainer) {
            # Directory - use hostname purple
            $nameColor = "$([char]0x1b)[38;2;$purpleRGB`m"
        } elseif ($item.Extension -match '\.(exe|bat|cmd|ps1|psm1)$') {
            # Executable - use green
            $nameColor = "$([char]0x1b)[32m"
        } elseif ($item.Extension -match '\.(txt|log|md)$') {
            # Text files - use white
            $nameColor = "$([char]0x1b)[37m"
        } else {
            # Other files - use reset color
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

# Set console color scheme
Set-PSReadLineOption -Colors @{
    Command            = "$([char]0x1b)[38;2;$purpleRGB`m"
    Parameter          = 'White'
    Operator           = 'White'
    Variable           = 'White'
    String             = 'Yellow'
    Number             = 'Green'
    Type               = 'Green'
    Comment            = 'DarkGray'
}

# Additional PSReadLine settings for history search and prediction
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -HistorySearchCursorMovesToEnd

# FIX: Configure prediction view style to be more responsive with Tab completion
Set-PSReadLineOption -PredictionViewStyle InlineView
# PSReadLine for better command editing and history
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# PSFzf for fuzzy finding
Import-Module PSFzf
Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+e' -PSReadlineChordReverseHistory 'Ctrl+r'

# z for directory jumping
Import-Module z
