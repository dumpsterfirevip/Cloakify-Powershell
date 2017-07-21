#
# Filename:  prependTimestamps.py
#
# Version: 1.0.1
#
# Author:  Joe Gervais (TryCatchHCF)
#
# Ported to Powershell by: John Aho
#
# Summary:  Inserts datetimestamps in front of each line of a file. Used to 
# add noise to a cloaked file (see cloakify.py) in order to degrade frequency 
# analysis attacks against the cloaked payload.
#
# Description:  
# Takes current date and randomly subtracts 1011-1104 days to generate a 
# starting date. Then starts randomly incrementing the datetimestamp (between 
# 0-664 seconds) for each entry in the cloaked file. If the datetimestamp 
# reaches the current date, repeats the above steps to avoid generating 
# timestamps into the future.
#
# Example:  
#
#   $ ./prependTimestamps.ps1 cloaked.txt > exfiltrateMe.txt
# 
#   Remove timestamps before trying to decloak the file
#
#   $ cat exfiltrateMe.txt | cut -d" " -f 3- > cloaked.txt



param (
    [Parameter(Mandatory=$false)][string]$cloakedFile
 )

[void] (Invoke-Expression("chcp 65001")) #sets output of console to UTF-8
$minDaysBack = -1104
$maxDaysBack = -1011

$minSecondsStep = 0
$maxSecondsStep = 664

$minMilliseconds = 11
$maxMilliseconds = 9999

$minTick = 3
$maxTick = 9999

    # Set the start date back around 2 years from today (give or take) for entropy range
	# Randomize a little for each run to avoid a pattern in the first line of each file
    $today = Get-Date
	$startDate = $today.AddDays( (Get-Random -Minimum $minDaysBack -Maximum $maxDaysBack))
	$step = (Get-Random -Minimum $minSecondsStep -Maximum $maxSecondsStep)

    $startDate = [System.DateTime]::Parse(($startDate).ToString("yyyy.MM.dd"))
    $toparse = ((Get-Random -Minimum 0 -Maximum 23).ToString()+":"+(Get-Random -Minimum 0 -Maximum 59).ToString()+":"+ (Get-Random -Minimum 0 -Maximum 59).ToString())
    $t = [System.Timespan]::Parse($toparse)
	$fakeDate = $startDate.Add($t)
    $fakeDate = $fakeDate.AddMilliseconds((Get-Random -Minimum $minMilliseconds -Maximum $maxMilliseconds))
    $fakeDate = $fakeDate.AddTicks((Get-Random -Minimum $minTick -Maximum $maxTick))



 if ( $cloakedFile.Length -eq 0){
	write-host("usage: prependTimestamps.ps1 <cloakedFilename>")
	write-host("")
	write-host("Strip the timestamps prior to decloaking the cloaked file.")
	write-host("")
    
	
		 
	# Generate sample of noise generator output
		$i = 0
		while ( $i -lt 20 ){
                Write-Host( Get-date $fakeDate -Format o)
                $fakeDate = $fakeDate.AddSeconds( (Get-Random -Minimum $minSecondsStep -Maximum $maxSecondsStep))
                $fakeDate = $fakeDate.AddMilliseconds((Get-Random -Minimum $minMilliseconds -Maximum $maxMilliseconds))
                $fakeDate = $fakeDate.AddTicks((Get-Random -Minimum $minTick -Maximum $maxTick))

                if($fakeDate -gt $today){
                    $startDate = $today.AddDays( (Get-Random -Minimum $minDaysBack -Maximum $maxDaysBack))
	                $step = (Get-Random -Minimum $minSecondsStep -Maximum $maxSecondsStep)
                    $startDate = [System.DateTime]::Parse(($startDate).ToString("yyyy.MM.dd"))
                    $toparse = ((Get-Random -Minimum 0 -Maximum 23).ToString()+":"+(Get-Random -Minimum 0 -Maximum 59).ToString()+":"+ (Get-Random -Minimum 0 -Maximum 59).ToString())
                    $t = [System.Timespan]::Parse($toparse)
	                $fakeDate = $startDate.Add($t)
                    $fakeDate = $fakeDate.AddMilliseconds((Get-Random -Minimum $minMilliseconds -Maximum $maxMilliseconds))
                    $fakeDate = $fakeDate.AddTicks((Get-Random -Minimum $minTick -Maximum $maxTick))

                }


			$i = $i+1
        }
    }

if( $cloakedFile.Length -gt 0){

	if(Test-Path $cloakedFile){

	# Generate a random with enough range to look good, scale with vals above
		 
			$clFile = Get-Content $cloakedFile -Encoding UTF8
	        $i = 0

            while($i -lt $clFile.Length ){
                
                $clFile[$i] = ((get-date $fakeDate -Format o ) + "  " + $clFile[$i])
                $fakeDate = $fakeDate.AddSeconds( (Get-Random -Minimum $minSecondsStep -Maximum $maxSecondsStep))
                $fakeDate = $fakeDate.AddMilliseconds((Get-Random -Minimum 12 -Maximum 9999))
                $fakeDate = $fakeDate.AddTicks((Get-Random -Minimum 12 -Maximum 9999))




                $i = $i+1
            }

            Out-File -FilePath $cloakedFile  -InputObject $clFile  -Encoding UTF8
    }else{
        Write-Host "File not found!"
    }
}