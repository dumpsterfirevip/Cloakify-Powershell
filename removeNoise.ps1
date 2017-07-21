# 
# Filename:  removeNoise.py
#
# Version: 1.1.0
#
# Author:  Joe Gervais (TryCatchHCF)
#
# Port to Powershell :  John Aho 
#
# Summary:  Removes random noise that has been prepended to a cloaked file
# (see cloakify.ps1). 
#
# Description:  
# Read in the noise-enhanced cloaked file and reprint each line without the
# prepended noise.
# 
# Example:  
#
#   $ ./removeNoise.ps1 2 noisyCloaked.txt cloaked.txt

param (
    [Parameter(Mandatory=$false)][int]$numberOfColumnsToStrip,
    [Parameter(Mandatory=$false)][string]$cloakedFile,
    [Parameter(Mandatory=$false)][string]$outputFile
 )

# Get directory path.
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
Set-Location $directorypath
[void](Invoke-Expression("chcp 65001"))




if ( $numberOfColumnsToStrip -eq 0){
	write-host("usage: removeNoise.ps1 <numberOfColumnsToStrip> <noisyFilename> <outputFile>")
	write-host("")
	return
}
 
if(($numberOfColumnsToStrip -gt 0) -and ( $cloakedFile.Length -gt 0 ) -and($outputFile.Length -gt 0) ){


    if(Test-Path $cloakedFile){


    $clFile = Get-Content $cloakedFile -Encoding UTF8
	        $i = 0

            while($i -lt $clFile.Length ){
                    
                    $j=1
                ForEach ( $match in ($clFile[$i] | select-String " " -allMatches).matches )
                    {
                       
                        $index = $match.Index
                        if ( $j -eq $numberOfColumnsToStrip )
                        {
                            $clFile[$i] = $clFile[$i].Substring($index+1)
                        }
                        $j++
                    }

				 
                $i = $i+1
            }

            Out-File -FilePath $outputFile  -InputObject $clFile  -Encoding UTF8


    }else{
        Write-Host "File not found"
    }

}