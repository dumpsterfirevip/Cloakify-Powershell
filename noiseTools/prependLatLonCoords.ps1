# Filename:  prependLatLonCoords.py
#
# Version: 1.1.1
#
# Author:  Joe Gervais (TryCatchHCF)
#
# Ported to Powershell by: John Aho
#
# Summary:  Inserts random Lat/Lon coordinates in front of each line of a file. 
# Used to add noise to a cloaked file (see cloakify.py) in order to degrade 
# frequency analysis attacks against the cloaked payload.
#
# Description:  
# Uses a bounding rectangle to generate random lat/lon coordinate pairs and
# insert them in the front of each line in a file. Defaults to Denver, with a 
# bounding rectangle roughly 10 miles / 16km per side (varies with latitude, 
# because sphere.
#
# Example:  
#
#   $ .\prependLatLonCoords.ps1 cloaked.txt > exfiltrateMe.txt
# 
#   Remove coordinate pairs before trying to decloak the file
#
#   $ cat exfiltrateMe.txt | cut -d" " -f 3- > cloaked.txt




param (
    [Parameter(Mandatory=$false)][string]$cloakedFile
 )

# Geocoords for Denver, USA. Replace with whatever is best for your needs
	$baseLat = 39.739236
	$baseLon = -104.990251

	# AT LATITUDE 40 DEGREES (NORTH OR SOUTH)
	# One minute of latitude =    1.85 km or 1.15 mi
	# One minute of longitude =   1.42 km or 0.88 mi

	$sizeLat = 0.0002
	$sizeLon = 0.0002
    [void] (Invoke-Expression("chcp 65001")) #sets output of console to UTF-8

 if ( $cloakedFile.Length -eq 0){
	write-host("usage: prependLatLonCoords.ps1 <cloakedFilename>")
	write-host("")
	write-host("Strip the coordinates prior to decloaking the cloaked file.")
	write-host("")
    
		 
	# Generate sample of noise generator output
		$i = 0
		while ( $i -lt 20 ){
            $lat = $baseLat + ($sizeLat * (Get-Random -Minimum 0 -Maximum 2000))
			$lon = $baseLon + ($sizeLon * (Get-Random -Minimum 0 -Maximum 2000))
			Write-host(  ( $lat.ToString() ) + " " +  ( $lon.ToString() ))
			$i = $i+1
        }
    }

if( $cloakedFile.Length -gt 0){

	if(Test-Path $cloakedFile){

	# Generate a random with enough range to look good, scale with vals above
		 
			$clFile = Get-Content $cloakedFile -Encoding UTF8
	        $i = 0

            while($i -lt $clFile.Length ){
                $lat = $baseLat + ($sizeLat * (Get-Random -Minimum 0 -Maximum 2000))
                $lon = $baseLon + ($sizeLon * (Get-Random -Minimum 0 -Maximum 2000))
                $clFile[$i] = (  ( $lat.ToString() ) + " " +  ( $lon.ToString() ) + " " + $clFile[$i])
                $i = $i+1
            }

            Out-File -FilePath $cloakedFile  -InputObject $clFile  -Encoding UTF8
    }else{
        Write-Host "File not found!"
    }
}