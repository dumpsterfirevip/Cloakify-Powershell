# 
# Filename:  cloakifyFactory.ps1 
#
# Version: 1.1.0
#
# Author:  Joe Gervais (TryCatchHCF) -Original Python program
#
# Port to Powershell :  John Aho 
#
# Summary:  Cloakify Factory is part of the Cloakify Exfiltration toolset that transforms 
# any fileype into lists of words / phrases / Unicode to ease exfiltration of data across 
# monitored networks, defeat data whitelisting restrictions, hiding the data in plain 
# sight, and facilitates social engineering attacks against human analysts and their 
# workflows. Bonus Feature: Defeats signature-based malware detection tools (cloak your 
# other tools). Leverages other scripts of the Cloakify Exfiltration Toolset, including
# cloakify.ps1, decloakify.ps1, and the noise generator scripts.
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
# 	- Randomize the list
#	- Place in the 'ciphers/' subdirectory
#	- Relaunch cloakifyFactory and it will automatically detect the new cipher
# 
# Example:  
#
#   $ ./cloakifyFactory.ps1 
# 

# Get directory path.
$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
Set-Location $directorypath

# Load list of ciphers
$gCipherFiles = Get-ChildItem ($directorypath + "\ciphers\")



# Load list of noise generators
$gNoiseScripts =  Get-ChildItem ($directorypath + "\noiseTools\*") -include *.ps1  | Foreach-Object {$_.Name}


[void](Invoke-Expression("chcp 65001"))


function CloakifyFile(){

    write-host("")
	write-host("====  Cloakify a File  ====")
	write-host("")
	$sourceFile = Read-Host("Enter filename to cloak (e.g. ImADolphin.exe or /foo/bar.zip): ")
	write-host("")
	$cloakedFile = Read-Host("Save cloaked data to filename (default: 'tempList.txt'): ")

	if($cloakedFile -eq ""){
		$cloakedFile = "tempList.txt"
        }

	$cipherNum = SelectCipher

	$noiseNum = -1
	$choice = Read-Host("Add noise to cloaked file? (y/n): ")
	if( $choice -eq "y"){
		$noiseNum = SelectNoise
    }

	write-host("")
	write-host("Creating cloaked file using cipher:", $gCipherFiles[ $cipherNum ])

	try{
		Invoke-Expression ($directorypath +"\cloakify.ps1 "+ $sourceFile +" "+$directorypath + "\ciphers\" + $gCipherFiles[ $cipherNum ] +" " + $cloakedFile )
	}catch{
		write-host("")
		write-host("!!! Well that didn't go well. Verify that your cipher is in the 'ciphers\' subdirectory.")
		write-host("")
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host(" $ErrorMessage : $FailedItem ")
        write-host("")
        }

	if( $noiseNum -ge 0 ){
		write-host("Adding noise to cloaked file using noise generator:", $gNoiseScripts[ $noiseNum ])
		try{
            $prependFile
            if($cloakedFile.IndexOf("\") -ge 0){
                $prependFile = $cloakedFile
             }else{
                $prependFile = $directorypath +"\"+ $cloakedFile
             }

		    Invoke-Expression ($directorypath + "\noiseTools\" + $gNoiseScripts[ $noiseNum ] + " "+  $prependFile )
		}catch{
			write-host("")
			write-host("!!! Well that didn't go well. Verify that '"+ $cloakedFile + "'")
			write-host("!!! is in the current working directory or try again giving full filepath." )
			write-host("")
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Host(" $ErrorMessage : $FailedItem ")
            write-host("")
            }
        }

	write-host("")
	write-host("Cloaked file saved to:"+ $cloakedFile)
	write-host("")

	$choice = read-host( "Preview cloaked file? (y/n): " )
	if( $choice -eq "y"){
		write-host("")
		$cloakedPreview = Get-Content $cloakedFile -Encoding UTF8  
			$i = 0;
			while ( $i -lt 20 ){
				write-host( $cloakedPreview[ $i ])
				$i = $i+1
            }
		write-host("")
     }

	$choice =  Read-Host  "Press return to continue... " 


}

function DecloakifyFile(){
	$decloakTempFile = "decloakTempFile.txt"

	write-host("")
	write-host("====  Decloakify a Cloaked File  ====")
	write-host("")
	$sourceFile = Read-Host( "Enter filename to decloakify (e.g. /foo/bar/MyBoringList.txt): " )
	write-host("")
	$decloakedFile = Read-Host( "Save decloaked data to filename (default: 'decloaked.file'): " )
	write-host("")
	
	try{
		Copy-Item $sourceFile $decloakTempFile
    
	}catch{
		write-host("Can't create temp file")
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host(" $ErrorMessage : $FailedItem ")
        write-host("")
	}

	if( $decloakedFile -eq ""){
		$decloakedFile = "decloaked.file"
    }
	# Reviewing the cloaked file within cloakifyFactory will save a little time for those who
	# forgot the format of the cloaked file and don't want to hop into a new window just to look

	$choice = Read-Host( "Preview cloaked file? (y/n default=n): " )
    
    if( $choice -eq "y"){
		write-host("")
        try{
		$cloakedPreview = Get-Content $sourceFile -Encoding UTF8  
			$i = 0;
			while ( $i -lt 20 ){
				write-host( $cloakedPreview[ $i ])
				$i = $i+1
            }
        }catch{
			write-host("")
			write-host("!!! Well that didn't go well. Verify that '", $sourceFile, "'")
			write-host("!!! is in the current working directory or the filepath you gave.")
			write-host("")
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Host(" $ErrorMessage : $FailedItem ")
            write-host("")
            }
		write-host("")
     }

	

	$choice = Read-Host("Was noise added to the cloaked file? (y/n default=n): ")

	if($choice -eq "y"){
		$noiseNum = SelectNoise

		$stripColumns = 2

		# No upper bound checking, relies on SelectNoise() returning valid value, fix in next release
		if( $noiseNum -ge 0){
			try{
				# Remove Noise, overwrite the source file with the stripped contents
				write-host("Removing noise from noise generator:", $gNoiseScripts[ $noiseNum ])
				Invoke-Expression( $directorypath +"\removeNoise.ps1 " + $stripColumns +" "+ $sourceFile +" "+ $decloakTempFile )
			}catch{
				write-host("!!! Error while removing noise from file. Was calling 'removeNoise.py'.\n")
                $ErrorMessage = $_.Exception.Message
                $FailedItem = $_.Exception.ItemName
                Write-Host(" $ErrorMessage : $FailedItem ")
                write-host("")
            }
            }
        }
	$cipherNum = SelectCipher

	write-host("Decloaking file using cipher: ", $gCipherFiles[ $cipherNum ])

	# Call Decloakify()
	try{
		Invoke-Expression ($directorypath+ "\decloakify.ps1 "+ $decloakTempFile +" '"+$directorypath+ "\ciphers\" + $gCipherFiles[ $cipherNum ]+ "' "+ $decloakedFile )

		write-host("")
		write-host("Decloaked file", $sourceFile, ", saved to", $decloakedFile)
	}catch{
		write-host("")
		write-host("!!! Oh noes! Error decloaking file (did you select the same cipher it was cloaked with?) ")
		write-host("")
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host(" $ErrorMessage : $FailedItem ")
        write-host("")
    }

	try{
		
			#Remove-Item -Force ( $decloakTempFile )

	}catch{
		write-host("")
		write-host("!!! Oh noes! Error while deleting temporary file $decloakTempFile")
		write-host("")
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host(" $ErrorMessage : $FailedItem ")
        write-host("")
    }

	$choice =  Read-Host  "Press return to continue... " 

}

function SelectCipher(){
	write-host("")
	write-host("Noise Generators:")
	write-host("")

	$cipherCount = 1
	ForEach( $cipherName in $gCipherFiles){
		write-host( ($cipherCount.ToString() + "-") + $cipherName)
		$cipherCount = $cipherCount + 1
    }
	write-host("")

	$selection = -1
	$cipherTotal = $cipherCount - 2

	while ( $selection -lt 0 -or $selection -gt $cipherTotal ){
		try{
			$cipherNum =   Read-Host( "Enter the Cipher #: " )

			$selection =  ( $cipherNum ) - 1

			if ( $selection.Length -eq 0 -or $selection -lt 0 -or $selection -gt $cipherTotal){  #l 
				write-host("Invalid cipher number, try again...")
				selection = -1
                }
        }catch{
			write-host("Invalid cipher number, try again...")
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Host(" $ErrorMessage : $FailedItem ")
            write-host("")
	    }
     }
     #Write-Host $selection + " selection is "
	return $selection
}

function BrowseCipher(){

    write-host("")
	write-host("========  Preview Ciphers  ========")
	$cipherNum = SelectCipher

	write-host("=====  Cipher:" + $gCipherFiles[ $cipherNum ] + " =====")
	write-host("")

	try{
		$arrayCipher = Get-Content ($directorypath +"\ciphers\"+$gCipherFiles[$cipherNum]  ) -Encoding UTF8
		write-host($arrayCipher)
	}catch{
		write-host('!!! Error opening cipher file.')
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host(" $ErrorMessage : $FailedItem ")
        write-host("")
    }

	$choice = Read-Host( "Press return to continue... " )



}

function SelectNoise(){
	write-host("")
	write-host("Noise Generators:")
	write-host("")

	$noiseCount = 1
	ForEach( $noiseName in $gNoiseScripts){
		write-host( ($noiseCount.ToString() + "-") + $noiseName)
		$noiseCount = $noiseCount + 1
    }
	write-host("")

	$selection = -1
	$noiseTotal = $noiseCount - 2

	while ( $selection -lt 0 -or $selection -gt $noiseTotal ){
		try{
			$noiseNum =   Read-Host( "Enter noise generator #: " )

			$selection =  ( $noiseNum ) - 1

			if ( $selection.Length -eq 0 -or $selection -lt 0 -or $selection -gt $noiseTotal){  #l 
				write-host("Invalid generator number, try again...")
				selection = -1
                }
        }catch{
		
			write-host("Invalid generator number, try again...")
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Host(" $ErrorMessage : $FailedItem ")
            write-host("")
	    }
     }
     #Write-Host $selection + " selection is "
	return $selection
}

function BrowseNoise(){
    write-host("")
	write-host("========  Preview Noise Generators  ========")

	$noiseNum = SelectNoise
    
    #debug
    write-host($noiseNum.ToString() +" selected item")

	write-host("")

	# No upper bounds checking, relies on SelectNoise() to return a valid value, fix in next update
	if($noiseNum -gt -1){

		try{
			write-host("Sample output of prepended strings, using noise generator:"+ $gNoiseScripts[ $noiseNum ] )
            $noisePath  =  ($directorypath + "\noiseTools\") 
            $noisePath  = $noisePath  + $gNoiseScripts[ $noiseNum ].ToString() 
            &($noisePath)
        }catch{
			write-host("!!! Error while generating noise preview.\n")
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Host(" $ErrorMessage : $FailedItem ")
            write-host("")
        }
    }
	write-host("")
	$choice = Read-Host( "Press return to continue... " )

}

function Help(){
	write-output("")
	write-output("=====================  Using Cloakify Factory  =====================")
	write-output("")
	write-output("For background and full tutorial, see the presentation slides at")
	write-output("https://github.com/TryCatchHCF/Cloakify")
	write-output("")
	write-output("WHAT IT DOES:")
	write-output("")
	write-output("Cloakify Factory transforms any filetype (e.g. .zip, .exe, .xls, etc.) into")
	write-output("a list of harmless-looking strings. This lets you hide the file in plain sight,")
	write-output("and transfer the file without triggering alerts. The fancy term for this is")
	write-output("'text-based steganography', hiding data by making it look like other data.")
	write-output("")
	write-output("For example, you can transform a .zip file into a list made of Pokemon creatures")
	write-output("or Top 100 Websites. You then transfer the cloaked file however you choose,")
	write-output("and then decloak the exfiltrated file back into its original form. The ciphers")
	write-output("are designed to appear like harmless / ignorable lists, though some (like MD5")
	write-output("password hashes) are specifically meant as distracting bait.")
	write-output("")
	write-output("BASIC USE:")
	write-output("")
	write-output("Cloakify Factory will guide you through each step. Follow the prompts and")
	write-output("it will show you the way.")
	write-output("")
	write-output("Cloakify a Payload:")
	write-output("- Select 'Cloakify a File' (any filetype will work - zip, binaries, etc.)")
	write-output("- Enter filename that you want to Cloakify (can be filename or filepath)")
	write-output("- Enter filename that you want to save the cloaked file as")
	write-output("- Select the cipher you want to use")
	write-output("- Select a Noise Generator if desired")
	write-output("- Preview cloaked file if you want to check the results")
	write-output("- Transfer cloaked file via whatever method you prefer")
	write-output("")
	write-output("Decloakify a Payload:")
	write-output("- Receive cloaked file via whatever method you prefer")
	write-output("- Select 'Decloakify a File'")
	write-output("- Enter filename of cloaked file (can be filename or filepath)")
	write-output("- Enter filename to save decloaked file to")
	write-output("- Preview cloaked file to review which Noise Generator and Cipher you used")
	write-output("- If Noise Generator was used, select matching Generator to remove noise")
	write-output("- Select the cipher used to cloak the file")
	write-output("- Your decloaked file is ready to go!")
	write-output("")
	write-output("You can browse the ciphers and outputs of the Noise Generators to get")
	write-output("an idea of how to cloak files for your own needs.")
	write-output("")
	write-output("Anyone using the same cipher can decloak your cloaked file, but you can")
	write-output("randomize (scramble) the preinstalled ciphers. See 'randomizeCipherExample.txt'")
	write-output("in the Cloakify directory for an example.")
	write-output("")
	write-output("NOTE: Cloakify is not a secure encryption scheme. It's vulnerable to")
	write-output("frequency analysis attacks. Use the 'Add Noise' option to add entropy when")
	write-output("cloaking a payload to help degrade frequency analysis attacks. Be sure to")
	write-output("encrypt the file prior to cloaking if secrecy is needed.")

}

function About(){

 
	write-output("")
	write-output("=====================  About Cloakify Factory  =====================")
	write-output("")
	write-output('            "Hide & Exfiltrate Any Filetype in Plain Sight"')
	write-output("")
	write-output("                        Written by TryCatchHCF")
	write-output("                https://github.com/TryCatchHCF/Cloakify")
    write-output(" ")
    write-output("                         Ported to Powershell by John Aho")
    write-output("                     https://github.com/JohnAho")
	write-output("")
	write-output("Data Exfiltration In Plain Sight; Evade DLP/MLS Devices; Social Engineering")
	write-output("of Analysts; Defeat Data Whitelisting Controls; Evade AV Detection. Text-based")
	write-output("steganography usings lists. Convert any file type (e.g. executables, Office,")
	write-output("Zip, images) into a list of everyday strings. Very simple tools, powerful")
	write-output("concept, limited only by your imagination.")
	write-output("")
	write-output("Cloakify Factory uses Python scripts to cloak / uncloak any file type using")
	write-output("list-based ciphers (text-based steganography). Allows you to transfer data")
	write-output("across a secure network's perimeter without triggering alerts, defeating data")
	write-output("whitelisting controls, and derailing analyst's review via social engineering")
	write-output("attacks against their workflows. As a bonus, cloaked files defeat signature-")
	write-output("based malware detection tools.")
	write-output("")
	write-output("NOTE: Cloakify is not a secure encryption scheme. It's vulnerable to")
	write-output("frequency analysis attacks. Use the 'Add Noise' option to add entropy when")
	write-output("cloaking a payload to help degrade frequency analysis attacks. Be sure to")
	write-output("encrypt the file prior to cloaking if secrecy is needed.")
	write-output("")
	write-output("DETAILS:")
	write-output("")
	write-output("Cloakify first Base64-encodes the payload, then applies a cipher to generate")
	write-output("a list of strings that encodes the Base64 payload. Once exfiltrated, use")
	write-output("Decloakify with the same cipher to decode the payload. The ciphers are")
	write-output("designed to appear like harmless / ingorable lists, though some (like MD5")
	write-output("password hashes) are specifically meant as distracting bait.")
	write-output("")
	write-output("Prepackaged ciphers include lists of:")
	write-output("")
	write-output("- Amphibians (scientific names)")
	write-output("- Belgian Beers")
	write-output("- Desserts in English, Arabic, Thai, Russian, Hindi, Chinese, Persian, and")
	write-output("  Muppet (Swedish Chef)")
	write-output("- Emoji")
	write-output("- evadeAV (smallest cipher space, x3 payload size)")
	write-output("- GeoCoords World Capitals (Lat/Lon)")
	write-output("- GeoCaching Coordinates (w/ Site Names)")
	write-output("- IPv4 Addresses of Popular Websites")
	write-output("- MD5 Password Hashes")
	write-output("- PokemonGo Monsters")
	write-output("- Top 100 Websites")
	write-output("- Ski Resorts")
	write-output("- Status Codes (generic)")
	write-output("- Star Trek characters")
	write-output("- World Beaches")
	write-output("- World Cup Teams")
	write-output("")
	write-output("Prepackaged scripts for adding noise / entropy to your cloaked payloads:")
	write-output("")
	write-output("- prependEmoji.ps1: Adds a randomized emoji to each line")
	write-output("- prependID.ps1: Adds a randomized ID tag to each line")
	write-output("- prependLatLonCoords.ps1: Adds random LatLong coordinates to each line")
	write-output("- prependTimestamps.ps1: Adds timestamps (log file style) to each line")
	write-output("")
	write-output("CREATE YOUR OWN CIPHERS:")
	write-output("")
	write-output("Cloakify Factory is at its best when you're using your own customized")
	write-output("ciphers. The default ciphers may work for most needs, but in a unique")
	write-output("exfiltration scenario you may need to build your own.")
	write-output("")
	write-output("Creating a Cipher:")
	write-output("")
	write-output("- Create a list of at least 66 unique words/phrases/symbols (Unicode accepted)")
	write-output("- Randomize the list order")
	write-output("- Remove all duplicate entries and all blank lines")
	write-output("- Place cipher file in the 'ciphers/' subdirectory")
	write-output("- Re-run Cloakify Factory to automatically load the new cipher")
	write-output("- Test cloaking / decloaking with new cipher before using operationally")
	write-output("")

}

function Menu(){
	write-output("  ____ _             _    _  __        ______         _                   ")
	write-output(" / __ \ |           | |  |_|/ _|       |  ___|       | |                  ")
	write-output("| /  \/ | ___   __ _| | ___| |_ _   _  | |_ __ _  ___| |_ ___  _ __ _   _ ")
	write-output("| |   | |/ _ \ / _` | |/ / |  _| | | | |  _/ _` |/ __| __/ _ \| '__| | | |")
	write-output("| \__/\ | |_| | |_| |   <| | | | |_| | | || |_| | |__| || |_| | |  | |_| |")
	write-output(" \____/_|\___/ \__,_|_|\_\_|_|  \__, | \_| \__,_|\___|\__\___/|_|   \__, |")
	write-output("                                 __/ |                               __/ |")
	write-output("                                |___/                               |___/ ")
	write-output("")
	write-output('             "Hide & Exfiltrate Any Filetype in Plain Sight"')
	write-output("")
	write-output("                         Written by TryCatchHCF")
	write-output("                     https://github.com/TryCatchHCF")
    write-output(" ")
    write-output("                         Ported to Powershell by John Aho")
    write-output("                     https://github.com/JohnAho")
	write-output("  (\~---.")
	write-output("  /   (\-`-/)")
	write-output(" (      ' '  )         data.xls image.jpg  \\     List of emoji, IP addresses,")
	write-output("  \ (  \_Y_/\\    ImADolphin.exe backup.zip  -->  sports teams, desserts,")
	write-output('   \"\"\ \___//         LoadMe.war file.doc  /     beers, anything you imagine')
	write-output("      `w   \"   )

		write-output("")
		write-output("====  Cloakify Factory Main Menu  ====")
		write-output("")
		write-output('1) Cloakify a File')
		write-output('2) Decloakify a File')
		write-output('3) Browse Ciphers')
		write-output('4) Browse Noise Generators')
		write-output('5) Help / Basic Usage')
		write-output('6) About Cloakify Factory')
		write-output('7) Exit')
        write-output('m) This Menu')
		write-output("")
}

function MainMenu(){

    Menu

	$selectionErrorMsg = '1-7 are your options. Try again.'
	$notDone = 1

 


	
		$invalidSelection = 1

do
{
    
     $input = Read-Host "Please make a selection (m for menu)"
     switch ($input)
     {
           '1' {
                CloakifyFile
           } '2' {
                DecloakifyFile
           } '3' {
                BrowseCipher
           } '4' {
                BrowseNoise
           } '5' {
                Help
           } '6' {
               About 

           } '7' {
                
           } 'm' {
                menu
           } 'M' {
                menu
           }
           
     }
     
}
until ($input -eq '7')
	
	$byeArray = "Bye!", "Ciao!", "Adios!", "Aloha!", "Hei hei!", "Bless bless!", "Hej da!", "Tschuss!", "Adieu!", "Cheers!", "Genki de!"
    
	write-output("")
	write-output( Get-Random -InputObject $byeArray )
	write-output("")

}

# ==============================  Main Loop  ================================
#
MainMenu 