using namespace System
using namespace System.Text.RegularExpressions

$Regexp_Pattern = '(?:<([a-z]+)>(.*?)<\/\1>)|((?:(?!<([a-z]+)>.*<\/\4>).)+)'

$Regexp = [regex]::new($Regexp_Pattern, [RegexOptions]::IgnoreCase)

function Write-Colorized {
    [CmdletBinding(PositionalBinding = $true, HelpUri = 'https://github.com/2chevskii/PSColorizer#README')]
    param (
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [string]$InputObject,
        [Parameter(Position = 1, ValueFromPipeline)]
        [ConsoleColor]$DefaultColor
    )

    $last_color = $Host.UI.RawUI.ForegroundColor

    if (!$DefaultColor) {
        $DefaultColor = $last_color
    }

    [MatchCollection]$matches = $Regexp.Matches($InputObject)

    if ($matches.Count -gt 0) {
        $colored_messages = @()

        foreach ($match in $matches) {
            if ($match.Groups[3].Length -gt 0) {
                $colored_messages += @{
                    'color' = $DefaultColor
                    'text'  = $match.Groups[3].Value
                }
            } else {
                $colored_messages += @{
                    'color' = $match.Groups[1].Value
                    'text'  = $match.Groups[2].Value
                }
            }
        }

        for ($i = 0; $i -lt $colored_messages.Length - 1; $i++) {
            Set-ConsoleColor -Color $colored_messages[$i]['color']
            Write-Message -Text $colored_messages[$i]['text']
        }

        Set-ConsoleColor -Color $colored_messages[$colored_messages.Length - 1]['color']
        Write-Message -Text $colored_messages[$colored_messages.Length - 1]['text'] -NewLine
        Set-ConsoleColor -Color $last_color
    } else {
        Write-Message -Text $InputObject -NewLine
    }
}

function Write-Message {
    param(
        [Parameter(Mandatory)]
        [string]$Text,
        [switch]$NewLine
    )

    if ($NewLine) {
        [Console]::WriteLine($Text)
    } else {
        [Console]::Write($Text)
    }
}

function Set-ConsoleColor {
    param(
        [Parameter(Mandatory)]
        [ConsoleColor]$Color
    )

    [Console]::ForegroundColor = $Color
}
