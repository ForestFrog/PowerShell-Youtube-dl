# PowerShell-Youtube-dl
https://github.com/mpb10/PowerShell-Youtube-dl

A PowerShell script used to operate the youtube-dl command line program.


**Author: Matt Bittner**

**July 12th, 2017**

**v1.2.4**
#

 - [INSTALLATION](#installation)
 - [USAGE](#usage)
 - [CHANGE LOG](#change-log)
 - [ADDITIONAL NOTES](#additional-notes)
 
#

# INSTALLATION

**Script download link:** https://github.com/mpb10/PowerShell-Youtube-dl/archive/master.zip

Note: These scripts require Windows PowerShell to function. PowerShell comes pre-installed with Windows 10 but otherwise can be downloaded here: https://www.microsoft.com/en-us/download/details.aspx?id=50395

Make sure your ExecutionPolicy is properly set by opening a PowerShell window with administrator privileges and typing `Set-ExecutionPolicy RemoteSigned`.

**To Install:** Download the project .zip file, extract it to a folder, and run the `Youtube-dl_Installer` shortcut. The script will be installed to the folder `C:\Users\%USERNAME%\Youtube-dl`. A desktop shortcut and a Start Menu shortcut will be created. Run either of these to use the script. 

To update the script, delete the following folders, download the new version and install it:

	C:\Users\%USERNAME%\Youtube-dl\bin
	C:\Users\%USERNAME%\Youtube-dl\scripts
Make sure you don't delete any of the .txt files!

#

To uninstall this script and its files, run the `Youtube-dl_Uninstall` shortcut located in `C:\Users\%USERNAME%`. This will remove the script, the youtube-dl and ffmpeg programs, the start menu folder, and the desktop shortcut. This uninstaller will leave behind files that have a file extension of `.txt` or `.ini`. If you wish to uninstall all Youtube-dl files, including text files, copy the script `C:\Users\%USERNAME%\Youtube-dl\scripts\Youtube-dl_Installer.ps1` to the desktop and run it with the `-Uninstall` and `-Everything` parameters via a PowerShell console.


# USAGE

Run either the desktop shortcut or the Start Menu shortcut. Choose to download either video or audio, and then right click and paste the URL into the prompt. The URL you provide it can be either the URL of a video or the URL of a playlist.

Video files are downloaded to `C:\Users\%USERNAME%\Videos\Youtube-dl` and audio files are downloaded to `C:\Users\%USERNAME%\Music\Youtube-dl`. Playlists will be downloaded into their own subfolders.

Upon being ran for the first time, the script will generate the `downloadarchive.txt`, `audioplaylist.txt`, and `videoplaylist.txt` files. The `downloadarchive.txt` file keeps a record of videos that have been downloaded from playlists. Any videos that the user downloads from a playlist will be added to this file and will be skipped if the playlist is downloaded again, provided that the "UseArchive" variable is set to `True` in the settings menu.

#

**New in version 1.1.0**, users can list playlists in the `audioplaylist.txt` and `videoplaylist.txt` files located in `C:\Users\%USERNAME%\Youtube-dl`. List any playlist URL's one line at a time that you would like to download video from in the `videoplaylist.txt` file. The same goes for the `audioplaylist.txt` file. To download from these files, choose option `3` in the main menu or use the `-FromFiles` parameter switch if calling the script from the command line. When downloading from the `videoplaylist.txt` file, use the conversion options in the Settings menu to convert all of the videos to one single file type.

**New in version 1.2.0**, users can convert downloaded videos to other formats using  ffmpeg options which can be modified in option `4` of the main menu, "Settings". Only videos being downloaded will be converted, not audio downloads. This feature has not yet been implemented into the parameters that can be passed to the script.

#

For advanced users, the youtube-dl.ps1 script, which is found in the folder `C:\Users\%USERNAME%\Youtube-dl\scripts`, can be passed parameters so that this script can be used in conjunction with other scripts or forms of automation. Make sure to add the `C:\Users\%USERNAME%\Youtube-dl\bin` folder to your PATH.

**youtube-dl.ps1's parameters are as followed:**

	-Video
		Download a video.
    
	-Audio
		Download only the audio of a video.
    
	-FromFiles
		Download playlist URL's listed in the "audioplaylist.txt" and "videoplaylist.txt" files located 
		in "C:\Users\%USERNAME%\Youtube-dl". The -URL parameter will be ignored if -FromFiles is used.
    
	-URL <URL>
		The URL of the video to be downloaded from.
    
	-OutputPath <path>
		(Optional) The location to which the file will be downloaded to.


# CHANGE LOG

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

Please support the development of youtube-dl and ffmpeg. The programs youtube-dl and ffmpeg can be found at the following links:

https://youtube-dl.org/

https://www.ffmpeg.org/


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
