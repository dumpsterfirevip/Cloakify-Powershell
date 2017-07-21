#
# Filename:  decloakify.ps1
#
# Author:  Joe Gervais (TryCatchHCF)
#
#
# Port to Powershell :  John Aho 
#
# Summary:  Exfiltration toolset (see cloakify.ps1) that transforms data into lists 
# of words / phrases / Unicode to ease exfiltration of data across monitored networks, 
# essentially hiding the data in plain sight, and facilitate social engineering attacks 
# against human analysts and their workflows. Bonus Feature: Defeats signature-based 
# malware detection tools (cloak your other tools).
#
# Used by cloakifyFactory.ps1, can be used as a standalone script as well (example below).
#
# Description:  Decodes the output of cloakify.ps1 into its underlying Base64 format, 
# then does Base64 decoding to unpack the cloaked payload file. Requires the use of the 
# same cipher that was used to cloak the file prior to exfitration, of course.
#
# Prepackaged ciphers include: lists of desserts in English, Arabic, Thai, Russian, 
# Hindi, Chinese, Persian, and Muppet (Swedish Chef); Top 100 IP Addresses; GeoCoords of 
# World Capitols; MD5 Password Hashes; An Emoji cipher; Star Trek characters; Geocaching 
# Locations; Amphibians (Scientific Names); and evadeAV cipher, a simple cipher that 
# minimizes the size of the resulting obfuscated data.
# 
# Example:  
#
#   $ ./decloakify.ps1 cloakedPayload.txt ciphers/desserts.ciph 





param (
    [Parameter(Mandatory=$false)][string]$cloakedFile,
    [Parameter(Mandatory=$false)][string]$cipher,
    [Parameter(Mandatory=$false)][string]$outputFile
 )

 
# Get directory path.
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
Set-Location $directorypath
Write-Host $directorypath

[void] (Invoke-Expression("chcp 65001")) #sets output of console to UTF-8
$OFS = "`r`n"

$array64 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/+="


if($cloakedFile -ne $null -and ($cloakedFile.Length -gt 0)){
   
    if(Test-Path $cloakedFile){	 

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
    
	$listExfiltrated = get-content $cloakedFile -Encoding UTF8
	
    $clear64SB = New-Object System.Text.StringBuilder

        foreach($line in $listExfiltrated){
        [void]$clear64SB.Append( $array64[ $cipherArray.IndexOf($line) ] )

         }
        
        $inclear64 = $clear64SB.ToString() 


	if ( $outputFile.Length -gt 0 ){
		try{
            if($outputFile.IndexOf("\") -lt 0){
                $outputFile = $directorypath +"\"+$outputFile
            }
            [IO.File]::WriteAllBytes($outputFile, [Convert]::FromBase64String($inclear64)) 

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
         #Just write out text/result to console
         $b  = [System.Convert]::FromBase64String($gah)
         write-host [System.Text.Encoding]::UTF8.GetString($b)
         
    }

    }else{
		    write-host("usage: decloakify.ps1 <cloakedFilename> <cipherFilename>")
		
    }
}else{
		write-host("usage: decloakify.ps1 <cloakedFilename> <cipherFilename>")
		
}







