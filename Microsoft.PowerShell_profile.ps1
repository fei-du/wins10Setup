
# Import-Module 'C:\tools\poshgit\dahlbyk-posh-git-a4faccd\src\posh-git.psd1'


Set-Alias -Name zip -Value Compress-Archive
Set-Alias -Name unzip -Value Expand-Archive
Set-Alias -Name g -Value git
Set-Alias -Name v -Value vim
Set-Alias -Name j -Value jlink
#$Host.UI.RawUI.CursorSize =100

Import-Module pscx
#Import-Module PSReadLine
#import-module oh-my-posh
#set-theme paradox
Set-PSReadLineOption -PredictionSource History
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadLineKeyHandler -Key Ctrl+a -Function BeginningOfLine  
Set-PSReadLineKeyHandler -Key Ctrl+e -Function EndOfLine        
Set-PSReadLineKeyHandler -Key Ctrl+f -Function ForwardChar      
Set-PSReadLineKeyHandler -Key Alt+f -Function ForwardWord       
Set-PSReadLineKeyHandler -Key Ctrl+d -Function DeleteChar       

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

# Set-PSReadlineKeyHandler -key Ctrl+s -briefDescription "vertical slipt conemu" -ScriptBlock {
#     powershell -new_console:sV
# }

# Set-PSReadlineKeyHandler -key Ctrl+Shift+s -briefDescription "Horizontal slipt conemu" -ScriptBlock {
#     powershell -new_console:sH
# }
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


Set-PSReadlineKeyHandler -Chord Ctrl+\ `
-BriefDescription SearchForwardPipeChar `
-Description "&amp;amp;quot;Searches forward for the next pipeline character&amp;amp;quot;" `
-ScriptBlock {
param($key, $arg)
[Microsoft.PowerShell.PSConsoleReadline]::CharacterSearch($key, '|')
}
Set-PSReadlineKeyHandler -Chord Ctrl+Shift+\ `
-BriefDescription SearchBackwardPipeChar `
-Description "&amp;amp;quot;Searches backward for the next pipeline character&amp;amp;quot;" `
-ScriptBlock {
param($key, $arg)
[Microsoft.PowerShell.PSConsoleReadline]::CharacterSearchBackward($key, '|')
}

Set-PSReadlineOption -AddToHistoryHandler {
    param([string]$line)
    # Do not save any command line unless it has more than 3 characters.  Prevents storing gci, gps, etc.
    return $line.Length -gt 4
}

function save-jumps ( $file)
{
    $global:PSReadlineMarks | Export-Clixml (Join-Path -ChildPath $file -Path ~/j)
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

function cat_temp()
{
Enter-PSSession -ComputerName nxw19057
cat temp
exit
}
$temp = "C:\Users\nxa13836\Documents\temp"
$share = "\\ZCH01FPC01.fsl.freescale.net\Microcontrollers\BACES\DF"

Set-Alias -Name sj -Value save-jumps
Set-Alias -Name lj -Value load-jumps
Set-Alias -Name np -Value notepad


$h = "-new_console:sH"
$v = "-new_console:sV"

new-psdrive -Name dc -PSProvider FileSystem -Root (resolve-path ~/*documents) | out-null
new-psdrive -Name dl -PSProvider FileSystem -Root (resolve-path ~/downloads) | out-null
new-psdrive -Name T -PSProvider FileSystem -Root (resolve-path c:/TEMP) | out-null
new-psdrive -Name P -PSProvider FileSystem -Root (resolve-path "C:\Users\nxa13836\OneDrive - NXP\Project") | out-null
new-psdrive -Name L -PSProvider FileSystem -Root (resolve-path "C:\Users\nxa13836\OneDrive - NXP\Learning") | out-null

# $env:Path += ";C:\Program Files (x86)\SEGGER\JLink_V502d"
$env:Path += ";C:\Users\nxa13836\bin"
$env:Path += ";C:\Program Files (x86)\teraterm"
# $env:Path += ";C:\Users\nxa13836\transcend"
$env:Path += ";C:\Users\nxa13836\Downloads\transcend-937-windows-cygwin-64\transcend"
# $env:Path += ";C:\Program Files (x86)\SEGGER\JLink_V502d"
$env:Path += ";C:\Users\nxa13836\AppData\Local\Continuum\anaconda3\"
$env:Path += ";C:\Program Files\WinMerge"
$env:Path += ";C:\Users\nxa13836\AppData\Local\Programs\Microsoft VS Code Insiders\bin"


# $env:Path += ";C:\Program Files (x86)\IAR Systems\Embedded Workbench 8.4\arm\bin"
$env:Path += ";C:\Program Files (x86)\IAR Systems\Embedded Workbench 8.4_2\arm\bin"
$env:Path += "; C:\Program Files (x86)\IAR Systems\Embedded Workbench 8.4_2\common\bin"
# $env:Path += ";C:\Program Files (x86)\IAR Systems\Embedded Workbench 8.4_3\common\bin"
# $env:Path += ";C:\Program Files (x86)\SEGGER\JLink"
$env:Path += ";C:\Users\nxa13836\Downloads\srecord-1.63-win32"
$env:Path += ";C:\Program Files\SEGGER\Ozone"
# $env:Path += ";C:\Users\nxa13836\code\ulp\try_env\tools_windows\tool_chain\gcc-arm-none-eabi-4_8-2014q3\bin"
# set-Alias -name objcopy -value arm-none-eabi-objcopy.exe
$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
$PSDefaultParameterValues['invoke-srec:device'] = 'CORTEX-M33'
