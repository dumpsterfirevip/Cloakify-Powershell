# 
# Filename:  cloakify.ps1 
#
# Version: 1.1.1
#
# Author:  Joe Gervais (TryCatchHCF)
#
# Port to Powershell :  John Aho 
#
# Summary:  Exfiltration toolset (see decloakify.ps1) that transforms any filetype (binaries,
# archives, images, etc.) into lists of words / phrases / Unicode to ease exfiltration of 
# data across monitored networks, hiding the data in plain sight. Also facilitates social 
# engineering attacks against human analysts and their workflows. Bonus Feature: Defeats 
# signature-based malware detection tools (cloak your other tools during an engagement).
#
# Used by cloakifyFactory.ps1, can be used as a standalone script as well (example below).
#
# Description:  Base64-encodes the given payload and translates the output using a list 
# of words/phrases/Unicode provided in the cipher. This is NOT a secure encryption tool, 
# the output is vulnerable to frequency analysis attacks. Use the Noise Generator scripts
# to add entropy to your cloaked file. You should encrypt the file before cloaking if
# secrecy is needed.
#
# Prepackaged ciphers include: lists of desserts in English, Arabic, Thai, Russian, 
# Hindi, Chinese, Persian, and Muppet (Swedish Chef); PokemonGo creatures; Top 100 IP 
# Addresses; Top Websites; GeoCoords of World Capitols; MD5 Password Hashes; An Emoji 
# cipher; Star Trek characters; Geocaching Locations; Amphibians (Scientific Names); 
# evadeAV cipher (simple cipher that minimizes size of the resulting obfuscated data).
#
# To create your own cipher:
#
#	- Generate a list of at least 66 unique words (Unicode-16 accepted)
#	- Remove all duplicate entries and blank lines
# 	- Randomize the list (see 'randomizeCipherExample.txt' in Cloakify directory)
#	- Provide the file as the cipher argument to the script.
#	- ProTip: Place your cipher in the "ciphers/" directory and cloakifyFactory 
#	  will pick it up automatically as a new cipher
# 
# Example:  
#
#   $ ./cloakify.ps1 payload.txt ciphers\desserts > exfiltrate.txt
# 

param (
    [Parameter(Mandatory=$false)][string]$payloadFile,
    [Parameter(Mandatory=$false)][string]$cipher,
    [Parameter(Mandatory=$false)][string]$outputFile
 )

# Get directory path.
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$currdir = Get-Location
Set-Location $directorypath
[void] (Invoke-Expression("chcp 65001")) #sets output of console to UTF-8
$OFS = "`n"

$array64 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/+="


if($payloadFile -ne $null -and ($payloadFile.Length -gt 0)){
    if(Test-Path $payloadFile){	 
    
    if($payloadFile.IndexOf("\") -lt 0){
        $payloadFile = $directorypath +"\"+$payloadFile
    }

    $payloadB64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($payloadFile))
	 
	try{
    		$cipherArray = Get-Content ( $cipher ) -Encoding UTF8
	}catch{
		write-host("")
		write-host("!!! Oh noes! Problem reading cipher '" + $cipher + "'")
		write-host("!!! Verify the location of the cipher file" )
		write-host("")
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host(" $ErrorMessage : $FailedItem ")
        write-host("")
    }

	if ( $outputFile.Length -gt 0 ){
		try{
			$sb = New-Object -TypeName "System.Text.StringBuilder"; 
            $inprocess = $payloadB64.ToCharArray()
            foreach( $char in $inprocess ){
				[void]$sb.append( $cipherArray[ $array64.IndexOf($char) ] + $OFS)
            }

            $sb = $sb.Remove($sb.Length-1 ,1) # remove the trailing newline.

            Out-File -FilePath $outputFile  -InputObject $sb.ToString()  -Encoding UTF8

		}catch{
			write-host("")
			write-host("!!! Oh noes! Problem opening or writing to file "+ $outputFile)
			write-host("")
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Host(" $ErrorMessage : $FailedItem ")
            write-host("")
        }
	}else{
        $inprocess = $payloadB64.ToCharArray()
		foreach( $char in $inprocess ){
				write-host( $cipherArray[ $array64.IndexOf($char) ])
            }
    }

    }else{
		    write-host("usage: cloakify.ps1 <payloadFilename> <cipherFilename>")
		
    }
}else{
		write-host("usage: cloakify.ps1 <payloadFilename> <cipherFilename>")
		
}

Set-Location $currdir