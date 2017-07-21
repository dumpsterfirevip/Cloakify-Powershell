# 
# Filename:  prependEmoji.ps1
#
# Version: 1.1.0
#
# Author:  Joe Gervais (TryCatchHCF)
#
# Ported to Powershell by: John Aho
#
# Summary: Inserts a random emoji in front of each line in a file. Used to 
# add noise to a cloaked file (see cloakify.ps1) in order to degrade frequency 
# analysis attacks against the cloaked payload. Works well with the emoji 
# cipher.
# 
#
# Description:  
# 
# Example:  
#
#   $ ./prependEmoji.ps1 exfiltrate.txt > exfiltrateNew.txt
# 
#   Remove prepended emoji before trying to decloak the file


param (
    [Parameter(Mandatory=$false)][string]$cloakedFile
 )

$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$currdir = Get-Location
Set-Location $directorypath
[void] (Invoke-Expression("chcp 65001"))
 $arrayCipher = Get-Content ( "..\ciphers\emoji" ) -Encoding UTF8


 if ( $cloakedFile.Length -eq 0){
	write-host("usage: prependEmoji.ps1 <exfilFilename>")
	write-host("")
	write-host("Strip leading emoji prior to decloaking the cloaked file.")
	write-host("")
    
    # FIX PENDING - Relative pathing is for cloakifyFactory.ps1
	
		 
	# Generate sample of noise generator output
		$i = 0
		while ( $i -lt 20 ){
			write-host(  Get-Random -InputObject($arrayCipher)  )
			$i = $i+1
        }
    }

if( $cloakedFile.Length -gt 0){

	if(Test-Path $cloakedFile){

	# Prepend noise generator output to file
		 
			$clFile = Get-Content $cloakedFile -Encoding UTF8
	        $i = 0

            while($i -lt $clFile.Length ){
                $randPiece =  (Get-Random -InputObject($arrayCipher))
				$clFile[$i] = ( $randPiece + "  " + $clFile[$i] )
                $i = $i+1
            }

            Out-File -FilePath $cloakedFile  -InputObject $clFile  -Encoding UTF8
    }else{
        Write-Host "File not found!"
    }
}


Set-Location $currdir