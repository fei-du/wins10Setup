Import-Module 'C:\tools\poshgit\dahlbyk-posh-git-a4faccd\src\posh-git.psd1'

function com {
    [System.IO.Ports.SerialPort]::GetPortNames()
}

function Hex($decimal, $base=16) {
    [convert]::ToString($decimal, $base)
}

Set-Alias -Name zip -Value Compress-Archive
Set-Alias -Name unzip -Value Expand-Archive
Set-Alias -Name g -Value git
Set-Alias -Name v -Value vim
Set-Alias -Name j -Value jlink
$Host.UI.RawUI.CursorSize =100

Import-Module PSReadLine
import-module oh-my-posh
set-theme paradox
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

$global:PSReadlineMarks = @{}


Set-PSReadlineKeyHandler -Key Ctrl+Shift+j `
                         -BriefDescription MarkDirectory `
                         -LongDescription "Mark the current directory" `
                         -ScriptBlock {
    param($key, $arg)

    $key = [Console]::ReadKey($true)
    $global:PSReadlineMarks[$key.KeyChar] = $pwd
}

Set-PSReadlineKeyHandler -Key Ctrl+j `
                         -BriefDescription JumpDirectory `
                         -LongDescription "Goto the marked directory" `
                         -ScriptBlock {
    param($key, $arg)

    $key = [Console]::ReadKey()
    $dir = $global:PSReadlineMarks[$key.KeyChar]
    if ($dir)
    {
        cd $dir
        [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
    }
}

Set-PSReadlineKeyHandler -Key Alt+j `
                         -BriefDescription ShowDirectoryMarks `
                         -LongDescription "Show the currently marked directories" `
                         -ScriptBlock {
    param($key, $arg)

    $global:PSReadlineMarks.GetEnumerator() | % {
        [PSCustomObject]@{Key = $_.Key; Dir = $_.Value} } |
        Format-Table -AutoSize | Out-Host

    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
}



Set-PSReadLineKeyHandler -Key '(','{','[' `
                         -BriefDescription InsertPairedBraces `
                         -LongDescription "Insert matching braces" `
                         -ScriptBlock {
    param($key, $arg)

    $closeChar = switch ($key.KeyChar)
    {
        <#case#> '(' { [char]')'; break }
        <#case#> '{' { [char]'}'; break }
        <#case#> '[' { [char]']'; break }
    }

    [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)$closeChar")
    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
    [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor - 1)
}

Set-PSReadLineKeyHandler -Key ')',']','}' `
                         -BriefDescription SmartCloseBraces `
                         -LongDescription "Insert closing brace or skip" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($line[$cursor] -eq $key.KeyChar)
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($cursor + 1)
    }
    else
    {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$($key.KeyChar)")
    }
}

Set-PSReadLineKeyHandler -Key Backspace `
                         -BriefDescription SmartBackspace `
                         -LongDescription "Delete previous character or matching quotes/parens/braces" `
                         -ScriptBlock {
    param($key, $arg)

    $line = $null
    $cursor = $null
    [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

    if ($cursor -gt 0)
    {
        $toMatch = $null
        if ($cursor -lt $line.Length)
        {
            switch ($line[$cursor])
            {
                <#case#> '"' { $toMatch = '"'; break }
                <#case#> "'" { $toMatch = "'"; break }
                <#case#> ')' { $toMatch = '('; break }
                <#case#> ']' { $toMatch = '['; break }
                <#case#> '}' { $toMatch = '{'; break }
            }
        }

        if ($toMatch -ne $null -and $line[$cursor-1] -eq $toMatch)
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::Delete($cursor - 1, 2)
        }
        else
        {
            [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar($key, $arg)
        }
    }
}

Set-PSReadlineKeyHandler -Key Ctrl+H `
			    -BriefDescription GoToParentDirectory `
			    -Description "Go To Parent Directory" -ScriptBlock {

    param($key, $arg)
    $parentDir = (Get-Item $pwd).Parent
    cd $parentDir.FullName
    [Microsoft.PowerShell.PSConsoleReadline]::InvokePrompt()
}


Set-PSReadlineKeyHandler -Chord "Ctrl+w,|" `
                         -BriefDescription ListDirectory `
                         -LongDescription "List the current directory" `
                         -ScriptBlock {
    powershell -new_console:sH
}
Set-PSReadlineKeyHandler -Chord "Ctrl+w,-" `
                         -BriefDescription ListDirectory `
                         -LongDescription "List the current directory" `
                         -ScriptBlock {
    powershell -new_console:sV
}

Set-PSReadlineKeyHandler -Key "Alt+l" `
                         -BriefDescription ListDirectory `
                         -LongDescription "List the current directory" `
                         -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadline]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadline]::Insert("ls")
    [Microsoft.PowerShell.PSConsoleReadline]::AcceptLine()
}

import-Module PSFzf -ArgumentList 'Ctrl+T','Ctrl+R'

Set-PSReadlineKeyHandler -key Ctrl+p -briefDescription "copy pwd to system clipboard" -ScriptBlock {
(pwd).providerpath | clip
}

Set-PSReadlineKeyHandler -key Ctrl+o -briefDescription "open putty" -ScriptBlock {
putty.exe  -new_console:s40H
}

Set-PSReadlineKeyHandler -key Ctrl+b -briefDescription "git bash vertical slipt conemu" -ScriptBlock {
 & 'C:\Program Files\Git\bin\sh.exe' -new_console:s10V
}

Set-PSReadlineKeyHandler -key Ctrl+Shift+b -briefDescription "git bash Horizontal slipt conemu" -ScriptBlock {
 & 'C:\Program Files\Git\bin\sh.exe' -new_console:sH
}

Set-PSReadlineKeyHandler -key Ctrl+s -briefDescription "vertical slipt conemu" -ScriptBlock {
    powershell -new_console:sV
}

Set-PSReadlineKeyHandler -key Ctrl+Shift+s -briefDescription "Horizontal slipt conemu" -ScriptBlock {
    powershell -new_console:sH
}
# ssh eighteen-street -p 22 -l b09129

Set-PSReadlineKeyHandler -key Ctrl+g -briefDescription "generate ctags file in current directory" -ScriptBlock {
    ctags -R .
    write-host "tags generated"
}

Set-PSReadlineKeyHandler -key Ctrl+k -briefDescription "fzf kill process" -ScriptBlock {
    fkill
}

Set-PSReadlineKeyHandler -key Ctrl+i -briefDescription "file explorer pwd" -ScriptBlock {
    ii .
}

Set-PSReadlineOption -AddToHistoryHandler {
    param([string]$line)
    # Do not save any command line unless it has more than 3 characters.  Prevents storing gci, gps, etc.
    return $line.Length -gt 4
}

function save-jumps ( $file)
{
    pushd $HOME\j
    $global:PSReadlineMarks | Export-Clixml $file
    popd
}

function load-jumps( $file)
{
    pushd $HOME\j
    if ($file -eq $null) {
        # if not provided, load data of last time
        $global:PSReadlineMarks = Import-Clixml (Get-ChildItem | Sort-Object lastaccesstime -Descending | Select-Object -First 1)
    } elseif (Test-Path $file){
        $global:PSReadlineMarks = Import-Clixml $file
        # make current data the lastest
        touch $file
    } else{
    "file does not exit!"
    }
    popd
}

Set-Alias -Name sj -Value save-jumps
Set-Alias -Name lj -Value load-jumps
Set-Alias -Name np -Value notepad

Import-Module Get-ChildItemColor
Set-Alias l Get-ChildItemColor -option AllScope
Set-Alias ls Get-ChildItemColorFormatWide -option AllScope

$h = "-new_console:sH"
$v = "-new_console:sV"

new-psdrive -Name dc -PSProvider FileSystem -Root (resolve-path ~/*documents) | out-null
new-psdrive -Name dl -PSProvider FileSystem -Root (resolve-path ~/downloads) | out-null
new-psdrive -Name T -PSProvider FileSystem -Root (resolve-path c:/TEMP) | out-null
new-psdrive -Name P -PSProvider FileSystem -Root (resolve-path "C:\Users\nxa13836\OneDrive - NXP\Project") | out-null
new-psdrive -Name L -PSProvider FileSystem -Root (resolve-path "C:\Users\nxa13836\OneDrive - NXP\Learning") | out-null
New-PSDrive -Name "x" -PSProvider "FileSystem" -Root '\\b18258-05\D$\project' | out-null

$env:Path += ";C:\Program Files (x86)\SEGGER\JLink_V502d"
$env:Path += ";C:\Users\nxa13836\bin"
