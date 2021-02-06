# CloakifyFactory
CloakifyFactory & the Cloakify Toolset - Data Exfiltration & Infiltration In Plain Sight; Evade DLP/MLS Devices; Social Engineering of Analysts; Defeat Data Whitelisting Controls; Evade AV Detection. Text-based steganography usings lists. Convert any file type (e.g. executables, Office, Zip, images) into a list of everyday strings. Very simple tools, powerful concept, limited only by your imagination. 

# Main Menu
<img src=https://github.com/JohnAho/Cloakify-Powershell/blob/master/screenshots/MainMenu.png></img>

# Author
Joe Gervais (TryCatchHCF) - Original Python

# Ported to Powershell by
dumpsterfirevip

# Why

DLP systems, MLS devices, and SecOps analysts know what data to look for
So transform that data into something they're <b>not</b> looking for: <br/>

<img src=https://github.com/JohnAho/Cloakify-Powershell/blob/master/screenshots/CloakedWithNoise.png></img>


# Decloaking File
<img src=https://github.com/JohnAho/Cloakify-Powershell/blob/master/screenshots/Decloaking_File.png></img>

# Comparing Output
<img src=https://github.com/JohnAho/Cloakify-Powershell/blob/master/screenshots/ComparingOutput.PNG></img>

# Sample Emoji Cloak
<img src=https://github.com/JohnAho/Cloakify-Powershell/blob/master/screenshots/EmojiCloak.png></img>



For a quick start on CloakifyFactory, see the cleverly titled file "README_GETTING_STARTED.txt" in the project for a walkthrough.

# Overview
CloakifyFactory transforms any filetype (e.g. .zip, .exe, .xls, etc.) into a list of harmless-looking strings. This lets you hide the file in plain sight, and transfer the file without triggering alerts. The fancy term for this is "text-based steganography", hiding data by making it look like other data. For example, you can transform a .zip file into a list of Pokemon creatures or Top 100 Websites. You then transfer the cloaked file however you choose, and then decloak the exfiltrated file back into its original form. 

With your payload cloaked, you can transfer data across a secure network’s perimeter without triggering alerts. You can also defeat data whitelisting controls - is there a security device that only allows IP addresses to leave or enter a network? Turn your payload into IP addresses, problem solved. Additionaly, you can derail the security analyst’s review via social engineering attacks against their workflows. And as a final bonus, cloaked files defeat signature-based malware detection tools.

The pre-packaged ciphers are designed to appear like harmless / ignorable lists, though some (like MD5 password hashes) are specifically meant as distracting bait.

CloakifyFactory is also a great way to introduce people to crypto and steganography concepts. It's simple to use, guides the user through the process, and according to our kids is also fun!

# Requires
Powershell

# Run Cloakify Factory
PS .\cloakifyFactory.ps1

# Description
CloakifyFactory is a menu-driven tool that leverages Cloakify Toolset scripts. When you choose to Cloakify a file, the scripts  first Base64-encode the payload, then apply a cipher to generate a list of strings that encodes the Base64 payload. You then transfer the file however you wish to its desired destination. Once exfiltrated, choose Decloakify with the same cipher to decode the payload.

NOTE: Cloakify is not a secure encryption scheme. It's vulnerable to frequency analysis attacks. Use the 'Add Noise' option to add entropy when cloaking a payload to help degrade frequency analysis attacks. Be sure to encrypt the file prior to cloaking if secrecy is needed.

The supporting scripts (cloakify.ps1 and decloakify.ps1) can be use as standalone scripts. Very small, simple, clean, portable. For scenarios where infiltrating the full toolset is impractical, you can quickly type the standalone into a target’s local shell, generate a cipher in place, and cloakify -> exfiltrate.


Prepackaged ciphers include lists of:
- Amphibians (scientific names)
- Belgian Beers
- Desserts in English, Arabic, Thai, Russian, Hindi, Chinese, Persian, and Muppet (Swedish Chef)
- Emoji
- evadeAV (smallest cipher space, x3 payload size)
- GeoCoords World Capitals (Lat/Lon)
- GeoCaching Coordinates (w/ Site Names)
- IPv4 Addresses of Popular Websites
- MD5 Password Hashes
- PokemonGo Monsters
- Ski Resorts
- Status Codes (generic)
- Star Trek characters
- Top 100 Websites
- World Beaches
- World Cup Teams

Prepackaged scripts for adding noise / entropy to your cloaked payloads:
- prependEmoji.ps1: Adds a randomize emoji to each line
- prependID.ps1: Adds a randomized ID tag to each line 
- prependLatLonCoords.ps1: Adds randomized LatLong coordinates to each line
- prependTimestamps.ps1: Adds timestamps (log file style) to each line

See comments in each script for details on how to tailor the Noise Generators for your own needs

# Create Your Own Cipers

Cloakify Factory is at its best when you're using your own customized ciphers. The default ciphers may work for most needs, but in a unique exfiltration scenario you may need to build your own. At the very least, you can copy a prepackaged cipher and randomize the order.

Creating a Cipher:
- Generate a list of at least 66 unique words / phrases / symbols (Unicode accepted)
- Remove all duplicate entries and all blank lines
- Randomize the list order
- Place in the "ciphers/" subdirectory
- Re-run CloakifyFactory and it will automatically load your new cipher as an option
- Test cloaking / decloaking with new cipher before using operationally


# Standalone Scripts
Some of you may prefer to use the Cloakify Toolset scripts in standalone mode. The toolset is designed to support that.


# Current Limitations:
Currently you should use fully qualified file names with these scripts if the file *isn't* in the 'Cloakify-Powershell' directory. 



