Using namespace System
Using namespace System.Text.RegularExpressions

$Regexp_Pattern = '(?:<([a-z\*]+?(?:,[a-z]+)?)>(.*?)<\/\1>)|(?:<([a-z]+)>(.*?)<\/\3>)|((?:(?!<([a-z\*]+?(?:,[a-z]+)?)>(.*?)<\/\6>).)+)'

$Regexp = [regex]::new($Regexp_Pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

<#
	.SYNOPSIS
		Writes colored text into console using xml-like tags with color names
	
	.DESCRIPTION
		Function will process text formatted with xml tags with names, supported by the System.ConsoleColor enumeration.
		Look at the example section to better understand it.
	
	.PARAMETER Message
		Message text.
	
	.PARAMETER DefaultColor
		Color which will be used on message parts, which do not have explicit color specified through color tags.
	
	.PARAMETER DefaultBColor
		BackgroundColor which will be used on message parts, which do not have explicit color specified through color tags.
	
	.PARAMETER NoNewLine
		Switch to turn on and print a NewLine between each color changes. Left omitted is set to keep message on one line.
	
	.EXAMPLE
		Hello <red>World</red>! -> 'World' will be written in red.
		wc2 ('<cyan>{0}</cyan> to the <DarkCyan,yellow>{1}</DarkCyan,yellow> <*,red>{2}</*,red>{3} <black,blue>{4}</black,blue>' -f 'hello', 'world', 'this', ' is a true ', 'test') Will be written as formated string 
	
	.NOTES
		Setting colors in the format <foreground></foreground> to change only forground.  <*,background></*,background> to only change background color.  <foreground,background></foreground,background> to change both colors.
#>
Function Write-Colorized2 {
	[CmdletBinding(HelpUri = 'https://github.com/chipgraphics/PSColorizer2#README',
				   PositionalBinding = $true)]
	Param
	(
		[Parameter(Mandatory = $true,
				   ValueFromPipeline = $true,
				   Position = 0)][string]$Message,
		[Parameter(ValueFromPipeline = $true,
				   Position = 1)][ConsoleColor]$DefaultColor,
		[Parameter(ValueFromPipeline = $true,
				   Position = 2)][ConsoleColor]$DefaultBColor,
		[Parameter(Mandatory = $false)][switch]$NoNewLine
	)
	
	Begin {
		$last_color = [System.Console]::ForegroundColor
		$last_bcolor = [System.Console]::BackgroundColor
		If (!$DefaultColor) {
			$DefaultColor = $last_color
			$DefaultBColor = $last_bcolor
		}		
		[System.Text.RegularExpressions.MatchCollection]$matches = $Regexp.Matches($Message)
	}
	
	Process {
		If ($matches.Count -gt 0) {
			$colored_messages = @()
			
			ForEach ($match In $matches) {
				If ($match.Groups[5].Length -gt 0) {
					$colored_messages += @{
						'fore' = $DefaultColor
						'back' = $DefaultBColor
						'text' = $match.Groups[5].Value
					}
				} Else {
					If ($match.Groups[1] -split "," -is [array]) {
						$fore, $back = $match.Groups[1] -split ","
						If ($fore -eq '*') {
							$colored_messages += @{
								'fore' = $DefaultColor
								'back' = $back
								'text' = $match.Groups[2].Value
							}
						} ElseIf ($back -eq $null) {
							$colored_messages += @{
								'fore' = $fore
								'back' = $DefaultBColor
								'text' = $match.Groups[2].Value
							}
						} Else {
							$colored_messages += @{
								'fore' = $fore
								'back' = $back
								'text' = $match.Groups[2].Value
							}
						}
					}
				}
			}
			
			For ($i = 0; $i -lt $colored_messages.Length - 1; $i++) {
				Set-ConsoleColor -Color $colored_messages[$i]['fore']
				Set-ConsoleBColor -Color $colored_messages[$i]['back']
				Write-Message -Text $colored_messages[$i]['text']
			}
			
			Set-ConsoleColor -Color $colored_messages[$colored_messages.Length - 1]['fore']
			Set-ConsoleBColor -Color $colored_messages[$colored_messages.Length - 1]['back']
			If (!$NoNewLine) {
				Write-Message -Text $colored_messages[$colored_messages.Length - 1]['text'] -NewLine
			} Else {
				Write-Message -Text $colored_messages[$colored_messages.Length - 1]['text']
			}
			Set-ConsoleColor -Color $last_color
			Set-ConsoleBColor -Color $last_bcolor
		} ElseIf (!$NoNewLine) {
			Write-Message -Text $Message -NewLine
		} Else {
			Write-Message -Text $Message
		}
	}
}

Function Write-Message {
	Param (
		[Parameter(Mandatory)][string]$Text,
		[switch]$NewLine
	)
	
	If ($NewLine) {
		[System.Console]::WriteLine($Text)
	} Else {
		[System.Console]::Write($Text)
	}
}

Function Set-ConsoleBColor {
	Param (
		[Parameter(Mandatory)][ConsoleColor]$Color
	)	
	[System.Console]::BackgroundColor = $Color
}

Function Set-ConsoleColor {
	Param (
		[Parameter(Mandatory)][ConsoleColor]$Color
	)	
	[System.Console]::ForegroundColor = $Color
}

Set-Alias -Name 'wc2' -Value 'Write-Colorized2'
Set-Alias -Name 'colorize2' -Value 'Write-Colorized2'

Export-ModuleMember -Function 'Write-Colorized2' -Alias 'wc2', 'colorize2'
