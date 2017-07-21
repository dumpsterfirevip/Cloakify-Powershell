# 
# Filename:  prependID.ps1
#
# Version: 1.1.1
#
# Author:  Joe Gervais (TryCatchHCF)
#
# Ported to Powershell by: John Aho
#
# Summary:  Inserts a randomized tag in front of each line of a file. Used to
# add noise to a cloaked file (see cloakify.py) in order to degrade frequency
# analysis attacks against the cloaked payload.
#
# Description:  
# Generates a random 4-character ID and prints it in front of each line of the
# file, in the form of "Tag:WXYZ". Modify the write statement below to tailor
# to your needs.
# 
# Example:  
#
#   $ ./prependID.ps1 cloaked.txt > exfiltrateMe.txt
# 
#   Remove tag before trying to decloak the file
#
#   $ cat exfiltrateMe.txt | cut -d" " -f 2- > cloaked.txt



param (
    [Parameter(Mandatory=$false)][string]$cloakedFile
 )

$arrayCode =  "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
$randomMax = $arrayCode.Length -1
[void] (Invoke-Expression("chcp 65001"))

 if ( $cloakedFile.Length -eq 0){
	write-host("usage: prepend4digitID.ps1 <exfilFilename>")
	write-host("")
	write-host("Strip tag prior to decloaking the cloaked file.")
	write-host("")
    
    # FIX PENDING - Relative pathing is for cloakifyFactory.ps1
	
		 
	# Generate sample of noise generator output
		$i = 0
		while ( $i -lt 20 ){
			Write-Host( "Tag: " +
				$arrayCode[(Get-Random -Minimum 0 -Maximum $randomMax)] + 
				$arrayCode[(Get-Random -Minimum 0 -Maximum $randomMax)] + 
				$arrayCode[(Get-Random -Minimum 0 -Maximum $randomMax)] + 
				$arrayCode[(Get-Random -Minimum 0 -Maximum $randomMax)])
			$i = $i+1
        }
    }

if( $cloakedFile.Length -gt 0){

	if(Test-Path $cloakedFile){

	# Prepend random tag output to file
		 
			$clFile = Get-Content $cloakedFile -Encoding UTF8
	        $i = 0

            while($i -lt $clFile.Length ){
                $randPiece =  ( "Tag: " +
				$arrayCode[(Get-Random -Minimum 0 -Maximum $randomMax)] + 
				$arrayCode[(Get-Random -Minimum 0 -Maximum $randomMax)] + 
				$arrayCode[(Get-Random -Minimum 0 -Maximum $randomMax)] + 
				$arrayCode[(Get-Random -Minimum 0 -Maximum $randomMax)])
				$clFile[$i] = ( $randPiece + "  " + $clFile[$i] )
                $i = $i+1
            }

            Out-File -FilePath $cloakedFile  -InputObject $clFile  -Encoding UTF8
    }else{
        Write-Host "File not found!"
    }
}