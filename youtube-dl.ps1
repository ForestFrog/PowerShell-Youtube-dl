<#
.SYNOPSIS 
	Download video and audio from the internet, mainly from youtube.com
	
.DESCRIPTION 
	This script downloads audio and video from the internet using the programs youtube-dl and ffmpeg. This script can be ran as a command using parameters, or it can be ran without parameters to use its GUI. Files are downloaded to the user's "Videos" and "Music" folders by default. See README.md for more information.
	
.PARAMETER Video 
	Download the video of the provided URL. Output file formats will vary.
.PARAMETER Audio 
	Download only the audio of the provided URL. Output file format will be mp3.
.PARAMETER Playlists 
	Download playlist URL's listed in videoplaylists.txt and audioplaylists.txt 
.PARAMETER Convert
	Convert the downloaded video to the default file format using the default settings.
.PARAMETER URL 
	The video URL to download from.
.PARAMETER OutputPath 
	The directory where to save the output file.
.PARAMETER DownloadOptions 
	Additional youtube-dl parameters for downloading.
.PARAMETER Install
	Install the script to "C:\Users\%USERNAME%\Scripts\Youtube-dl" and create desktop and Start Menu shortcuts.
.PARAMETER UpdateExe
	Update youtube-dl.exe and the ffmpeg files to the most recent versions.
.PARAMETER UpdateScript
	Update the youtube-dl.ps1 script file to the most recent version.

.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1
	Runs the script in GUI mode.
.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1 -Video -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0"
	Downloads the video at the specified URL.
.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1 -Audio -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0"
	Downloads only the audio of the specified video URL.
.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1 -Playlists
	Downloads video URL's listed in videoplaylists.txt and audioplaylists.txt files. These files are generated when the script is ran for the first time.
.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1 -Audio -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0" -OutputPath "C:\Users\%USERNAME%\Desktop"
	Downloads the audio of the specified video URL to the user provided location.
.EXAMPLE 
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1 -Video -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0" -DownloadOptions "-f bestvideo+bestaudio"
	Downloads the video at the specified URL and utilizes the provided youtube-dl parameters.
	
.NOTES 
	Requires Windows 7 or higher, PowerShell 5.0 or greater, and Microsoft Visual C++ 2010 Redistributable Package (x86).
	Author: mpb10
	Updated: August 13th, 2018
	Version: 2.0.4

.LINK 
	https://github.com/mpb10/PowerShell-Youtube-dl
#>


# ======================================================================================================= #
# ======================================================================================================= #

Param(
	[Switch]$Video,
	[Switch]$Audio,
	[Switch]$Playlists,
	[Switch]$Convert,
	[String]$URL,
	[String]$OutputPath,
	[String]$DownloadOptions,
	[Switch]$Install,
	[Switch]$UpdateExe,
	[Switch]$UpdateScript
)


# ======================================================================================================= #
# ======================================================================================================= #
#
# SCRIPT SETTINGS
#
# ======================================================================================================= #

$VideoSaveLocation = "$ENV:USERPROFILE\Videos\Youtube-dl"
$AudioSaveLocation = "$ENV:USERPROFILE\Music\Youtube-dl"
$PortableSaveLocation = "$PSScriptRoot"
$UseArchiveFile = $True
$EntirePlaylist = $False
$VerboseDownloading = $False
$CheckForUpdates = $True

$ConvertFile = $False
$FileExtension = "webm"
$VideoBitrate = "-b:v 800k"
$AudioBitrate = "-b:a 128k"
$Resolution = "-s 640x360"
$StartTime = ""
$StopTime = ""
$StripAudio = ""
$StripVideo = ""


# ======================================================================================================= #
# ======================================================================================================= #
#
# FUNCTIONS
#
# ======================================================================================================= #

# Function for simulating the 'pause' command of the Windows command line.
Function PauseScript {
	If ($NumOfParams -eq 0) {
		Write-Host "`nPress any key to continue ...`n" -ForegroundColor "Gray"
		$Wait = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
	}
}



# When passed a URL and a file path, downloads the file from the URL to a temporary file and then
# moves and renames the file to the specified file path.
Function DownloadFile {
	Param(
		[String]$URLToDownload,
		[String]$SaveLocation
	)
	(New-Object System.Net.WebClient).DownloadFile("$URLToDownload", "$TempFolder\download.tmp")
	Move-Item -Path "$TempFolder\download.tmp" -Destination "$SaveLocation" -Force
}



# Downloads the latest youtube-dl.exe release to the bin folder.
Function DownloadYoutube-dl {
	DownloadFile "http://yt-dl.org/downloads/latest/youtube-dl.exe" "$BinFolder\youtube-dl.exe"
}



# Downloads the latest ffmpeg release, checking whether to download a 64-bit or 32-bit version first.
# Extracts the three .exe files to the bin folder and deletes the other unnecessary files.
Function DownloadFfmpeg {
	If (([environment]::Is64BitOperatingSystem) -eq $True) {
		DownloadFile "http://ffmpeg.zeranoe.com/builds/win64/static/ffmpeg-latest-win64-static.zip" "$BinFolder\ffmpeg_latest.zip"
	}
	Else {
		DownloadFile "http://ffmpeg.zeranoe.com/builds/win32/static/ffmpeg-latest-win32-static.zip" "$BinFolder\ffmpeg_latest.zip"
	}

	Expand-Archive -Path "$BinFolder\ffmpeg_latest.zip" -DestinationPath "$BinFolder"
	
	Copy-Item -Path "$BinFolder\ffmpeg-*-win*-static\bin\*" -Destination "$BinFolder" -Recurse -Filter "*.exe" -ErrorAction Silent
	Remove-Item -Path "$BinFolder\ffmpeg_latest.zip"
	Remove-Item -Path "$BinFolder\ffmpeg-*-win*-static" -Recurse
}



# Sets the variables that define where locations such as the bin, config, temp, cache folders are.
# These all are dependent on the $RootFolder location, which is either the directory in which the
# script is running or the install location "C:\Users\%USERNAME%\Scripts\Youtube-dl".
Function ScriptInitialization {
	$Script:BinFolder = $RootFolder + "\bin"
	If ((Test-Path "$BinFolder") -eq $False) {
		New-Item -Type Directory -Path "$BinFolder" | Out-Null
	}
	$ENV:Path += ";$BinFolder"

	$Script:TempFolder = $RootFolder + "\temp"
	If ((Test-Path "$TempFolder") -eq $False) {
		New-Item -Type Directory -Path "$TempFolder" | Out-Null
	}
	Else {
		Remove-Item -Path "$TempFolder\download.tmp" -ErrorAction Silent
	}
	
	$Script:CacheFolder = $RootFolder + "\cache"
	If ((Test-Path "$CacheFolder") -eq $False) {
		New-Item -Type Directory -Path "$CacheFolder" | Out-Null
	}

	$Script:ConfigFolder = $RootFolder + "\config"
	If ((Test-Path "$ConfigFolder") -eq $False) {
		New-Item -Type Directory -Path "$ConfigFolder" | Out-Null
	}

	$Script:VideoArchiveFile = $ConfigFolder + "\DownloadVideoArchive.txt"
	If ((Test-Path "$VideoArchiveFile") -eq $False) {
		New-Item -Type file -Path "$VideoArchiveFile" | Out-Null
	}
	
	$Script:AudioArchiveFile = $ConfigFolder + "\DownloadAudioArchive.txt"
	If ((Test-Path "$AudioArchiveFile") -eq $False) {
		New-Item -Type file -Path "$AudioArchiveFile" | Out-Null
	}

	$Script:PlaylistFile = $ConfigFolder + "\PlaylistFile.txt"
	If ((Test-Path "$PlaylistFile") -eq $False) {
		DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/PlaylistFile.txt" "$PlaylistFile"
	}
}



# Installs the script to "C:\Users\%USERNAME%\Scripts\Youtube-dl". Downloads the necessary shortcuts,
# youtube-dl.exe, and ffmpeg .exe files. After changing the $RootFolder variable to the install location,
# runs the ScriptInitialization function to create the bin, config, temp, cache folders.
Function InstallScript {
	If ($PSScriptRoot -eq "$InstallLocation") {
		Write-Host "`nPowerShell-Youtube-dl files are already installed."
		PauseScript
		Return
	}
	Else {
		$MenuOption = Read-Host "`nInstall PowerShell-Youtube-dl to ""$InstallLocation""? [y/n]"
		
		If ($MenuOption -like "y" -or $MenuOption -like "yes") {
			Write-Host "`nInstalling to ""$InstallLocation"" ..."

			$Script:RootFolder = $ENV:USERPROFILE + "\Scripts\Youtube-dl"
			ScriptInitialization
			
			$DesktopFolder = $ENV:USERPROFILE + "\Desktop"
			$StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Youtube-dl"
			If ((Test-Path "$StartFolder") -eq $False) {
				New-Item -Type Directory -Path "$StartFolder" | Out-Null
			}

			DownloadYoutube-dl
			DownloadFfmpeg

			Copy-Item "$PSScriptRoot\youtube-dl.ps1" -Destination "$RootFolder"
			
			DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/Youtube-dl.lnk" "$RootFolder\Youtube-dl.lnk"
			Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$DesktopFolder\Youtube-dl.lnk"
			Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$StartFolder\Youtube-dl.lnk"
			
			DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/LICENSE" "$RootFolder\LICENSE.txt"
			DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/README.md" "$RootFolder\README.md"

			Write-Host "`nInstallation complete. Please restart the script." -ForegroundColor "Yellow"
			PauseScript
			Exit
		}
		Else {
			Return
		}
	}
}



# Updates youtube-dl and ffmpeg by re-downloading their newest released .exe files.
Function UpdateExe {
	Write-Host "`nUpdating youtube-dl.exe and ffmpeg.exe files ..."
	
	DownloadYoutube-dl
	DownloadFfmpeg
	
	Write-Host "`nUpdate .exe files complete." -ForegroundColor "Yellow"
	PauseScript
	
	If ($UpdateScript -eq $False) {
		exit
	}
}



# Checks the running version of the script and compares it to the version-file that is in the master branch.
# If running version is older, prompt the user to update the script file. If the script is installed,
# download new shortcuts, license, and readme. If running portable mode, only download the new youtube-dl.ps1
# file. Finish by downloading the update notes and displaying them to the screen.
Function UpdateScript {
	DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/version-file" "$TempFolder\version-file.txt"
	[Version]$NewestVersion = Get-Content "$TempFolder\version-file.txt" | Select -Index 0
	Remove-Item -Path "$TempFolder\version-file.txt"
	
	If ($NewestVersion -gt $RunningVersion) {
		Write-Host "`nA new version of PowerShell-Youtube-dl is available: v$NewestVersion" -ForegroundColor "Yellow"
		$MenuOption = Read-Host "`nUpdate to this version? [y/n]"
		
		If ($MenuOption -like "y" -or $MenuOption -like "yes") {
			DownloadFile "http://github.com/mpb10/PowerShell-Youtube-dl/raw/master/youtube-dl.ps1" "$RootFolder\youtube-dl.ps1"
			
			If ($PSScriptRoot -eq "$InstallLocation") {
				$DesktopFolder = $ENV:USERPROFILE + "\Desktop"
				$StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Youtube-dl"
				If ((Test-Path "$StartFolder") -eq $False) {
					New-Item -Type Directory -Path "$StartFolder" | Out-Null
				}
				DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/Youtube-dl.lnk" "$RootFolder\Youtube-dl.lnk"
				Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$DesktopFolder\Youtube-dl.lnk"
				Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$StartFolder\Youtube-dl.lnk"
				DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/LICENSE" "$RootFolder\LICENSE.txt"
				DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/README.md" "$RootFolder\README.md"
			}
			
			DownloadFile "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/UpdateNotes.txt" "$TempFolder\UpdateNotes.txt"
			Get-Content "$TempFolder\UpdateNotes.txt"
			Remove-Item "$TempFolder\UpdateNotes.txt"
			
			Write-Host "`nUpdate complete. Please restart the script." -ForegroundColor "Yellow"
			
			PauseScript
			Exit
		}
		Else {
			Return
		}
	}
	ElseIf ($NewestVersion -eq $RunningVersion) {
		Write-Host "`nThe running version of PowerShell-Youtube-dl is up-to-date." -ForegroundColor "Yellow"
	}
	Else {
		Write-Host "`n[ERROR] Script version mismatch. Re-installing the script is recommended." -ForegroundColor "Red" -BackgroundColor "Black"
		PauseScript
	}
}



# Set variables that contain youtube-dl or ffmpeg options/parameters. These are then placed in the
# youtube-dl command.
Function SettingsInitialization {
	If ($UseArchiveFile -eq $True) {
		$Script:SetVideoArchiveFile = "--download-archive ""$VideoArchiveFile"""
		$Script:SetAudioArchiveFile = "--download-archive ""$AudioArchiveFile"""
	}
	Else {
		$Script:SetUseArchiveFile = ""
	}
	
	If ($EntirePlaylist -eq $True) {
		$Script:SetEntirePlaylist = "--yes-playlist"
	}
	Else {
		$Script:SetEntirePlaylist = "--no-playlist"
	}
	
	If ($VerboseDownloading -eq $True) {
		$Script:SetVerboseDownloading = ""
	}
	Else {
		$Script:SetVerboseDownloading = "--quiet --no-warnings"
	}
	
	If ($StripVideo -eq $True) {
		$SetStripVideo = "-vn"
	}
	Else {
		$SetStripVideo = ""
	}
	
	If ($StripAudio -eq $True) {
		$SetStripAudio = "-an"
	}
	Else {
		$SetStripAudio = ""
	}
	
	If ($ConvertFile -eq $True -or $Convert -eq $True) {
		$Script:FfmpegCommand = "--recode-video $FileExtension --postprocessor-args ""$VideoBitrate $AudioBitrate $Resolution $StartTime $StopTime $SetStripVideo $SetStripAudio"" --prefer-ffmpeg"		
	}
	Else {
		$Script:FfmpegCommand = ""
	}
}



# Determines whether to download a single video or entire playlist and then runs the youtube-dl command.
Function DownloadVideo {
	Param(
		[String]$URLToDownload
	)
	$URLToDownload = $URLToDownload.Trim()
	Write-Host "`nDownloading video from: $URLToDownload`n"
	If ($URLToDownload -like "*youtube.com/playlist*" -or $EntirePlaylist -eq $True) {
		$YoutubedlCommand = "youtube-dl -o ""$VideoSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading --cache-dir ""$CacheFolder"" $DownloadOptions $FfmpegCommand --yes-playlist $SetVideoArchiveFile ""$URLToDownload"""
	}
	Else {
		$YoutubedlCommand = "youtube-dl -o ""$VideoSaveLocation\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading --cache-dir ""$CacheFolder"" $DownloadOptions $FfmpegCommand $SetEntirePlaylist ""$URLToDownload"""
	}
	Invoke-Expression "$YoutubedlCommand"
}



# Determines whether to download the audio of a single video or all of the videos in a playlist. Then runs
# the youtube-dl command with the appropriate ffmpeg conversion options to extract a mp3 of the audio.
Function DownloadAudio {
	Param(
		[String]$URLToDownload
	)
	$URLToDownload = $URLToDownload.Trim()
	Write-Host "`nDownloading audio from: $URLToDownload`n"
	If ($URLToDownload -like "*youtube.com/playlist*" -or $EntirePlaylist -eq $True) {
		$YoutubedlCommand = "youtube-dl -o ""$AudioSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading --cache-dir ""$CacheFolder"" $DownloadOptions -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg --yes-playlist $SetAudioArchiveFile ""$URLToDownload"""
	}
	Else {
		$YoutubedlCommand = "youtube-dl -o ""$AudioSaveLocation\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading --cache-dir ""$CacheFolder"" $DownloadOptions -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg $SetEntirePlaylist ""$URLToDownload"""
	}
	Invoke-Expression "$YoutubedlCommand"
}



# Gets an array of playlist URLs from the playlist config file and then loops through it, downloading
# each one using the DownloadVideo or DownloadAudio functions.
Function DownloadPlaylists {
	Write-Host "`nDownloading playlist URLs listed in: ""$PlaylistFile"""
	
	$PlaylistArray = Get-Content "$PlaylistFile" | Where-Object {$_.Trim() -ne "" -and $_.Trim() -notlike "#*"}
	
	$VideoPlaylistArray = $PlaylistArray | Select-Object -Index (($PlaylistArray.IndexOf("[Video Playlists]".Trim()))..($PlaylistArray.IndexOf("[Audio Playlists]".Trim())-1))
	$AudioPlaylistArray = $PlaylistArray | Select-Object -Index (($PlaylistArray.IndexOf("[Audio Playlists]".Trim()))..($PlaylistArray.Count - 1))
	
	If ($VideoPlaylistArray.Count -gt 1) {
		$VideoPlaylistArray | Where-Object {$_ -ne $VideoPlaylistArray[0]} | ForEach-Object {
			Write-Verbose "`nDownloading playlist: $_`n"
			DownloadVideo "$_"
		}
	}
	Else {
		Write-Verbose "The [Video Playlists] section is empty."
	}
		
	If ($AudioPlaylistArray.Count -gt 1) {
		$AudioPlaylistArray | Where-Object {$_ -ne $AudioPlaylistArray[0]} | ForEach-Object {
			Write-Verbose "`nDownloading playlist: $_`n"
			DownloadAudio "$_"
		}
	}
	Else {
		Write-Verbose "The [Audio Playlists] section is empty."
	}
}



# Runs certain functions based on the parameters that are passed to the script. Install and update functions
# take precedence over download functions.
Function CommandLineMode {
	If ($Install -eq $True) {
		InstallScript
		Exit
	}
	ElseIf ($UpdateExe -eq $True -and $UpdateScript -eq $True) {
		UpdateExe
		UpdateScript
		Exit
	}
	ElseIf ($UpdateExe -eq $True) {
		UpdateExe
		Exit
	}
	ElseIf ($UpdateScript -eq $True) {
		UpdateScript
		Exit
	}
	
	If (($OutputPath.Length -gt 0) -and ((Test-Path "$OutputPath") -eq $False)) {
		New-Item -Type directory -Path "$OutputPath" | Out-Null
		$Script:VideoSaveLocation = $OutputPath
		$Script:AudioSaveLocation = $OutputPath
	}
	ElseIf ($OutputPath.Length -gt 0) {
		$Script:VideoSaveLocation = $OutputPath
		$Script:AudioSaveLocation = $OutputPath
	}
	
	SettingsInitialization
	
	If ($Playlists -eq $True -and ($Video -eq $True -or $Audio -eq $True)) {
		Write-Host "`n[ERROR]: The parameter -Playlists can't be used with -Video or -Audio.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	ElseIf ($Playlists -eq $True) {
		DownloadPlaylists
		Write-Host "`nDownloads complete. Downloaded to:`n   $VideoSaveLocation`n   $AudioSaveLocation`n" -ForegroundColor "Yellow"
	}
	ElseIf ($Video -eq $True -and $Audio -eq $True) {
		Write-Host "`n[ERROR]: Please select either -Video or -Audio. Not Both.`n" -ForegroundColor "Red" -BackgroundColor "Black"
	}
	ElseIf ($Video -eq $True) {
		DownloadVideo "$URL"
		Write-Host "`nDownload complete.`nDownloaded to: ""$VideoSaveLocation""`n" -ForegroundColor "Yellow"
	}
	ElseIf ($Audio -eq $True) {
		DownloadAudio "$URL"
		Write-Host "`nDownload complete.`nDownloaded to: ""$AudioSaveLocation`n""" -ForegroundColor "Yellow"
	}
	Else {
		Write-Host "`n[ERROR]: Invalid parameters provided." -ForegroundColor "Red" -BackgroundColor "Black"
	}
	
	Exit
}



# Generates a CLI-based menu for downloading video and audio.
Function MainMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 4 -and $MenuOption -ne 0) {
		$URL = ""
		Clear-Host
		Write-Host "==================================================================================================="
		Write-Host "                                    PowerShell-Youtube-dl v$RunningVersion                                   " -ForegroundColor "Yellow"
		Write-Host "==================================================================================================="
		Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
		Write-Host "  1   - Download video"
		Write-Host "  2   - Download audio"
		Write-Host "  3   - Download from playlist file"
		Write-Host "  4   - Settings"
		Write-Host "`n  0   - Exit`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host "Option"
		
		Write-Host "`n==================================================================================================="
		
		Switch ($MenuOption) {
			1 {
				Write-Host "`nPlease enter the URL you would like to download from:`n" -ForegroundColor "Yellow"
				$URL = (Read-Host "URL").Trim()
				
				If ($URL.Length -gt 0) {
					Clear-Host
					SettingsInitialization
					DownloadVideo $URL
					Write-Host "`nFinished downloading video to: ""$VideoSaveLocation""" -ForegroundColor "Yellow"
					PauseScript
				}
				$MenuOption = 99
			}
			2 {
				Write-Host "`nPlease enter the URL you would like to download from:`n" -ForegroundColor "Yellow"
				$URL = (Read-Host "URL").Trim()
				
				If ($URL.Length -gt 0) {
					Clear-Host
					SettingsInitialization
					DownloadAudio $URL
					Write-Host "`nFinished downloading audio to: ""$AudioSaveLocation""" -ForegroundColor "Yellow"
					PauseScript
				}
				$MenuOption = 99
			}
			3 {
				Clear-Host
				SettingsInitialization
				DownloadPlaylists
				Write-Host "`nFinished downloading URLs from playlist files." -ForegroundColor "Yellow"
				PauseScript
				$MenuOption = 99
			}
			4 {
				Clear-Host
				SettingsMenu
				$MenuOption = 99
			}
			0 {
				Clear-Host
				Exit
			}
			Default {
				Write-Host "`nPlease enter a valid option." -ForegroundColor "Red"
				PauseScript
			}
		}
	}
}



# Generates a CLI-based menu for picking which update/install functions to run.
Function SettingsMenu {
	$MenuOption = 99
	While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 0) {
		Clear-Host
		Write-Host "==================================================================================================="
		Write-Host "                                           Settings Menu                                           " -ForegroundColor "Yellow"
		Write-Host "==================================================================================================="
		Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
		Write-Host "  1   - Update youtube-dl.exe and ffmpeg.exe"
		Write-Host "  2   - Update youtube-dl.ps1 script file"
		If ($PSScriptRoot -ne "$InstallLocation") {
			Write-Host "  3   - Install script to: ""$InstallLocation"""
		}
		Write-Host "`n  0   - Return to Main Menu`n" -ForegroundColor "Gray"
		$MenuOption = Read-Host "Option"
		
		Write-Host "`n==================================================================================================="
		
		Switch ($MenuOption) {
			1 {
				UpdateExe
				$MenuOption = 99
			}
			2 {
				UpdateScript
				PauseScript
				$MenuOption = 99
			}
			3 {
				InstallScript
				$MenuOption = 99
			}
			0 {
				Return
			}
			Default {
				Write-Host "`nPlease enter a valid option." -ForegroundColor "Red"
				PauseScript
			}
		}
	}
}



# ======================================================================================================= #
# ======================================================================================================= #
#
# MAIN
#
# ======================================================================================================= #

# PowerShell 5.0 or greater is required for some of the commands/functions in this script. It comes installed
# by default on Windows 10.
If ($PSVersionTable.PSVersion.Major -lt 5) {
	Write-Host "[ERROR]: Your PowerShell installation is not version 5.0 or greater.`n        This script requires PowerShell version 5.0 or greater to function.`n        You can download PowerShell version 5.0 at:`n            https://www.microsoft.com/en-us/download/details.aspx?id=50395" -ForegroundColor "Red" -BackgroundColor "Black"
	PauseScript
	Exit
}

# Specifies the running version of the script. Used to check if a new update is available.
[Version]$RunningVersion = '2.0.4'

# Sets the script to use any of the provided tls security protocols. Required to get the DownloadFile
# function to work with certain sites that only accept certain protocols (youtube-dl's site).
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

$NumOfParams = ($PSBoundParameters.Count)

$InstallLocation = "$ENV:USERPROFILE\Scripts\Youtube-dl"

# Determines if the script is running in portable mode or if it's installed.
If ($PSScriptRoot -eq "$InstallLocation") {
	$RootFolder = $ENV:USERPROFILE + "\Scripts\Youtube-dl"
}
Else {
	$RootFolder = "$PSScriptRoot"
	$VideoSaveLocation = $PortableSaveLocation
	$AudioSaveLocation = $PortableSaveLocation
}

# If the script is not being installed, initialize the location variables.
If ($Install -eq $False) {
	ScriptInitialization
}

# Performs and automatic update check on startup provided that the $CheckForUpdates script file setting
# is set to $True and the script isn't being installed.
If ($CheckForUpdates -eq $True -and $Install -eq $False) {
	UpdateScript
}

# Checks if the youtube-dl.exe file is present in the bin folder. If not, download it.
If ((Test-Path "$BinFolder\youtube-dl.exe") -eq $False -and $Install -eq $False) {
	Write-Host "`nyoutube-dl.exe not found. Downloading and installing to: ""$BinFolder"" ...`n" -ForegroundColor "Yellow"
	DownloadYoutube-dl
}

# Checks if the ffmpeg .exe files are present in the bin folder. If not, download them.
If (((Test-Path "$BinFolder\ffmpeg.exe") -eq $False -or (Test-Path "$BinFolder\ffplay.exe") -eq $False -or (Test-Path "$BinFolder\ffprobe.exe") -eq $False) -and $Install -eq $False) {
	Write-Host "ffmpeg files not found. Downloading and installing to: ""$BinFolder"" ...`n" -ForegroundColor "Yellow"
	DownloadFfmpeg
}

# Determine whether to run the script in command line mode or to run the CLI-based GUI menus. Does so
# by checking if any parameters have been passed to the script. No parameters means run the GUI.
If ($NumOfParams -gt 0) {
	CommandLineMode
}
Else {

	MainMenu
	
	PauseScript
	Exit
}











