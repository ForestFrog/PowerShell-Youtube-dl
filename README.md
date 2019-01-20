# PowerShell-Youtube-dl
https://github.com/mpb10/PowerShell-Youtube-dl

A PowerShell script used to operate the youtube-dl command line program.


**Author: mpb10**

**June 5th, 2018**

**v2.0.4**

#

 - [INSTALLATION](#installation)
 - [USAGE](#usage)
 - [ADVANCED USAGE](#advanced-usage)
 - [CHANGE LOG](#change-log)
 - [ADDITIONAL NOTES](#additional-notes)
 
#

# INSTALLATION

**Script download link:** https://github.com/mpb10/PowerShell-Youtube-dl/releases/download/v2.0.3/PowerShell-Youtube-dl-v2.0.3.zip

**Requires:** PowerShell 5.0 or greater* and Microsoft Visual C++ 2010 Redistributable Package (x86)**

	*Version 5.0 of PowerShell comes pre-installed with Windows 10 but otherwise can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=50395
	**Microsoft Visual C++ 2010 Redistributable Package (x86) can be downloaded here: https://www.microsoft.com/en-US/download/details.aspx?id=5555

#

**To Install:** 

1. Ensure that you have PowerShell Version 5.0 or greater installed.
2. Download the release .zip file and extract it to a folder.
3. Run the 'Installer' shortcut located in the `\install` folder (or run the the script with the 'Youtube-dl - Portable Version' shortcut, navigate to the settings menu, and choose the `3 -  Install script to:` option).

A desktop shortcut and a Start Menu shortcut will be created. Run either of those to use the script. The install location is `C:\Users\%USERNAME%\Scripts\Youtube-dl`.

#

To uninstall this script and its files, delete the two folders `C:\Users\%USERNAME%\Scripts\Youtube-dl` and `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Youtube-dl` and the desktop shortcut.

# USAGE

Run either the desktop shortcut or the Start Menu shortcut. Choose to download either video or audio, and then right click and paste the URL into the prompt. The URL you provide it can be either the URL of a video or the URL of a playlist.

When running the script while it's installed, video files are downloaded to `C:\Users\%USERNAME%\Videos\Youtube-dl` and audio files are downloaded to `C:\Users\%USERNAME%\Music\Youtube-dl` by default. Playlists will be downloaded into their own subfolders within these two folders. If running the portable version, video and audio files will be downloaded to the same folder as the script.

Upon being ran for the first time, the script will generate the `DownloadVideoArchive.txt`, `DownloadAudioArchive.txt`, and `PlaylistFile.txt` files in the `\config` folder. To use option `3  - Download from playlist files` of the main menu, list playlist URL's in the PlaylistFile.txt file under their respective sections, save the file, and then run option 3 of the script.

The `DownloadVideoArchive.txt` and `DownloadAudioArchive.txt` files keep a record of videos that have been downloaded from playlists. The URL of any video that is downloaded from a playlist will be added to these files and will be skipped if the playlist is downloaded again. This can be toggled by editing the `$UseArchiveFile = ` setting variable witin the script file (see the Script File Settings section of [Advanced Usage](#advanced-usage) for details)


# ADVANCED USAGE

**MAIN MENU:**

`1   - Download video`	

This option prompts the user for the URL of a video. This URL can be a single video or a playlist and doesn't necessarily have to be from Youtube.com since Youtube-dl supports a wide range of websites. If a playlist URL is provided, the entire playlist will be downloaded by default. The `1   - Download video` option can be ran from the command line using the `-Video -URL <UserProvidedURL>` parameter options.

Additonally, videos that are downloaded can be automatically converted using ffmpeg via the `$ConvertFile =` script file settings variable located within the `youtube-dl.ps1` script file.

#

`2   - Download audio`	

This option prompts the user for the URL of a video who's audio will be extracted and converted to an MP3 file. This URL can be a single video or a playlist and doesn't necessarily have to be from Youtube.com since Youtube-dl supports a wide range of websites. If a playlist URL is provided, the entire playlist will be downloaded. The script will also attempt to insert the correct artist and title metadata into the MP3 file, provided that there is a hyphen character `-` seperating the artist and song name in the video title. The `2   - Download audio` option can be ran from the command line using the `-Audio -URL <UserProvidedURL>` parameter options. 

The ffmpeg video conversion settings found in the script file settings variables of `youtube-dl.ps1` have no effect when downloading audio.

#

`3   - Download predefined playlists`	

This option downloads the video and audio of URL's listed in the `PlaylistFile.txt` file which is located in `C:\Users\%USERNAME%\Scripts\Youtube-dl\config`. List any playlist URL's or individual video URL's one line at a time in this file under their respective sections to download them as a batch job. The script will not re-download a video that has already been downloaded before, provided that the `$UseArchiveFile = ` script file setting is set to true. Videos listed in the file will download to the `C:\Users\%USERNAME%\Videos\Youtube-dl` folder and put each playlist in its own folder. The same goes for audio which downloads to the `C:\Users\%USERNAME%\Music\Youtube-dl` folder.

The ffmpeg video conversion settings found in the settings variables of `youtube-dl.ps1` will only affect the video URL's listed under the `[Video Playlists]` section of the file.

#

`4   - Settings`	

This option brings the user to the settings menu. The primary purpose of the settings menu is to update and install the script and its files. Below is a description of each option:

	'1  - Update youtube-dl.exe and ffmpeg.exe'
		Description:	This option will download the newest version youtube-dl.exe file to the bin folder.
				It should be noted that this option will also re-download the ffmpeg files as well,
				but the ffmpeg version is hardcoded. Newer versions of the script will download newer
				ffmpeg versions.

	'2  - Update youtube-dl.ps1 script file'
		Description:	This option updates the script file to the newest version by downloading it from
				Github to the scripts folder.

	'3  - Install script to: "C:\Users\%USERNAME%\Scripts\Youtube-dl"'
		Description:	This option installs the script to the user's home folder and creates a desktop
				shortcut and a start menu shortcut. The user must modify their config files again
				which are found in the config folder.
	
#

**SCRIPT FILE SETTINGS:**

In the youtube-dl.ps1 script file from lines 80 to 100, there are some settings variables that the user can modify and tweak. Their default values and descriptions are below:

	'$VideoSaveLocation = '
		Default:	"$ENV:USERPROFILE\Videos\Youtube-dl"
		Description:	This setting changes the default download location for video file downloads.
				This value can still be overridden by the -OutputPath parameter when running
				the script via the command line.
				
	'$AudioSaveLocation = '
		Default:	"$ENV:USERPROFILE\Music\Youtube-dl"
		Description:	This setting changes the default download location for audio file downloads.
				This value can still be overridden by the -OutputPath parameter when running
				the script via the command line.
				
	'$PortableSaveLocation = '
		Default:	"$PSScriptRoot"
		Description:	By default, this setting is set to download video and audio files to the same
				folder as the script when running the script in portable mode (portable mode
				is running the script anywhere but C:\Users\%USERNAME%\Scripts\Youtube-dl).
				This location will override the two previous variables.
				
	'$UseArchiveFile = '
		Default:	$True
		Description:	This setting will toggle whether or not to use the downloadarchive.txt file.
				When set to true, downloading a video from a playlist will record that video's
				URL in the downloadarchive.txt file. If the playlist is downloaded again, that
				video will then be skipped. This is useful for downloading videos from a
				playlist that continues to have new videos added to it.
				
	'$EntirePlaylist = '
		Default:	$False
		Description:	This setting toggles whether to download the entire playlist when a single
				video URL of a playlist is passed to the script. For example, when set to
				true, passing the URL of video number 3 out of a playlist of 12 will cause
				the entire playlist to be downloaded. When set to false, only video number
				3 will be downloaded. (To download entire playlists while this is set to
				false, simply pass the script the entire playlist URL. It usually looks
				something like: https://www.youtube.com/playlist?list=...)
				
	'$VerboseDownloading = '
		Default:	$True
		Description:	This setting toggles whether to display extra information when downloading
				video or audio. Setting this to $True can be used to debug issues.
				
	'$CheckForUpdates = '
		Default:	$True
		Description:	This setting toggles whether or not to automatically check for updates on
				script startup. If the script is up-to-date, no message will be displayed.
				
				
				
				
				
	'$ConvertFile = '
		Default:	$False
		Description:	This setting toggles whether or not to convert downloaded video files to
				the specified file format and quality using ffmpeg. Only video that is
				downloaded will be converted. This setting and the following settings do not
				apply when downloading only audio.
				
	'$FileExtension = '
		Default:	"webm"
		Description:	This setting determines which ffmpeg file format the video should be
				converted to.
		
	'$VideoBitrate = '
		Default:	"-b:v 800k"
		Description:	This setting determines the video bitrate at which the file will be
				converted. Increasing this value will increase the quality and file size.
				
	'$AudioBitrate = '
		Default:	"-b:a 128k"
		Description:	This setting determines the audio bitrate of the file to be converted.
				Values of 128k, 192k, and 320k are generally chosen.
				
	'$Resolution = '
		Default:	"-s 640x360"
		Description:	This setting determines the resolution to which the file will be converted.
				
	'$StartTime = '
		Default:	""
		Description:	This setting determines the starting time to which the file will be trimmed.
		
	'$StopTime = '
		Default:	""
		Description:	This setting determines the end time to which the file will be trimmed.
		
	'$StripAudio = '
		Default:	""
		Description:	This setting determines whether or not to strip the audio from the file.
				This is useful for creating videos for websites that do not support video
				files containing audio.
		
	'$StripVideo = '
		Default:	""
		Description:	This setting determines whether or not to strip the video form a file.
				The download audio functionality of the script makes this option obsolete.
	
#

For advanced users, the youtube-dl.ps1 script, can be ran via the command line and passed parameters so that this script can be used in conjunction with other scripts or forms of automation. Make sure to add the `C:\Users\%USERNAME%\Scripts\Youtube-dl\bin` folder to your PATH so that youtube-dl.exe and the ffmpeg files can be located.

**youtube-dl.ps1's parameters are as followed:**

	-Video -URL <URL>
		Download a video.
    
	-Audio -URL <URL>
		Download the audio of a video and converts it to an MP3.
    
	-Playlists
		Download playlist URL's listed in the "PlaylistFile.txt" file located 
		in "C:\Users\%USERNAME%\Scripts\Youtube-dl\config". The -URL parameter is ignored if -Playlists is used.
    
	-OutputPath <path>
		(Optional) Specify a custom download location.
		
	-Convert
		Tells the script to use the ffmpeg options located within the youtube-dl.ps1 script file.
		
	-DownloadOptions <youtube-dl parameters>
		Specify any additional parameters for Youtube-dl to use when downloading. Don't forget to surround
		the provided parameters in quotation marks (" ").
		
	-Install
		Installs the script to "C:\Users\%USERNAME%\Scripts\Youtube-dl", creates a desktop shortcut, and a
		start menu shortcut.
		
	-UpdateExe
		Updates the youtube-dl.exe file to the newest version and re-downloads the ffmpeg files to the bin folder.
		
	-UpdateScript
		Updates the youtube-dl.ps1 script file to the newest version by downloading it from Github.


# CHANGE LOG

	2.0.4	June 5th, 2018
		Added some basic comments to the script's code.

	2.0.3	May 7th, 2018
		!!! FULL RE-INSTALL IS REQUIRED FOR THIS VERSION !!! Just updating the script file won't cut it.
		\scripts folder has been removed and youtube-dl.ps1 file moved to root folder.
		DownloadArchive.txt split up into two separate files. One for video and one for audio.
		Changes and fixes to updating and installing.
		Any cache data that is downloaded is now downloaded to the new \cache folder.
		Script automatically checks for updates on startup by default. Can be toggled in script file settings.
		Video and audio are now downloaded to the same folder as the script when running in portable mode.
		Added update notes feature when updating the script file.
		Newest stable version of ffmpeg is now automatically chosen when downloaded.

	2.0.2	April 3rd, 2018
		Fixed some issues with the shortcuts.
		Added $VerboseDownloading option to the script file settings.
		Combined the videoplaylistfile.txt and audioplaylistfile.txt into one file called PlaylistFile.txt
	
	2.0.1	March 6th, 2018
		Minor bug fixes.

	2.0.0	February 28th, 2018
		Finished re-writing the script.

	1.2.6	November 16th, 2017
		Added option to download the entire playlist that a video resides in.

	1.2.5	November 15th, 2017
		Simplified and cleaned up some code.
		Updated the readme file.

	1.2.4	July 12th, 2017
		Added ability to choose whether to use the youtube-dl download archive when downloading playlists.

	1.2.3	July 11th, 2017
		Edited Youtube-dl_Installer.ps1 to uninstall the script using the -Uninstall parameter.
		Added a shortcut for uninstalling the script and its files.

	1.2.2	July 3rd, 2017
		Cleaned up code.

	1.2.1	June 22nd, 2017
		Uploaded the project to Github.
		Condensed installer to one PowerShell script.
		Edited documentation.
		
	1.2.0	March 30th, 2017
		Implemented ffmpeg video conversion.
		
	1.1.0	March 27th, 2017
		Implemented videoplaylist.txt and audioplaylist.txt downloading.


# ADDITIONAL NOTES

Please support the development of youtube-dl and ffmpeg. The programs youtube-dl and ffmpeg and their source code can be found at the following links:

https://youtube-dl.org/

https://www.ffmpeg.org/


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
