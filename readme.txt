MyEntunnel Version 3.6.2 README
Copyright 2006-2025 Nemesis][
https://github.com/nemesis2/MyEnTunnel


MyEntunnel Description
----------------------

Note: This is a third party application and not associated with VanDyke Software or the author of PuTTY Simon Tatham.

MyEnTunnel is a simple system tray application that establishes and maintains TCP SSH tunnels. It does this by launching Plink (PuTTY Link) in the background and then monitors the process. If the Plink process dies (e.g. connection drops, server restarts or otherwise becomes unreachable) MyEnTunnel will automatically restart Plink to reestablish the tunnels in the background. It tries to use as little CPU and system resources as possible when monitoring. 

Optionally, MyEnTunnel can actively monitor the connection by creating looped tunnels (either a looped remote/local tunnel pair or a single local tunnel to the ssh servers echo service) and periodically send pings. If too many consecutive pings are lost it will restart the connection.

Since it uses Plink, you can use utilities such as Pageant (a SSH authentication agent for PuTTY, PSCP and Plink) and PuTTYgen (a RSA and DSA key generation utility), as well as named PuTTY sessions. All of the networking and encryption is done by plink.exe; not by MyEnTunnel. 

MyEnTunnel also works with portaPuTTY (Handy for USB thumbdrives).
MyEnTunnel is compatible with Wine on *IX.

For the security-conscious: The password or passphrase DOES stay in memory and the encrypted version stored in the INI file isn't fool proof. So I STRONGLY suggest you DON'T use this with root accounts for security reasons! For regular workstation (attended) usage I recommend using Pagent and passphrases.

If you like MyEnTunnel, instead of sending donations please post about it online in your blog/website or message forum. (I always prefer word of mouth advertising =) )


Unicode Support 
---------------------

Version 3.6 now has full unicode support based off of the routines developed in the 3.5 dev branch.


Profiles
---------------------

MyEntunnel version 3.4 added profiles.  Simply specify the profile to use on the command line or shortcut to MyEntunnel.exe.

The creation and switching of profiles via the right click system tray menu.
The Popup menu is populated when clicked.  
The end user must use explorer to manage (remove) unused profiles.


Command line usage:
-------------------

Example:

  "C:\Program Files\myentunnel\myentunnel.exe" work

Note: when using key files with profiles the key filename changes to: 
  <profilename>-keyfile.ppk.

Example:

  work-keyfile.ppk


Advanced Options
----------------

These options are available by hand editing the myentunnel.ini:

Executable:
  Full path and name to replacement executable; normally: plink.exe
ExecArguments:
  For customized options; normally: -N -ssh -2
FullPathKeyfile:
  Full path and name to keyfile; normally: keyfile.ppk
BackScrollLines:
  Max number of lines for status window; normally: 200
ShowOnDoubleClick:
  Toggles window visibility when system tray icon is double clicked
FullPathLogfile:
  Copies output of Status window to the define logfile.
EchoPort:
  Normally defaults to port 7 - the normal Echo Service.
PingInterval:
  Ping timer in ms.  Default is 10000 (10 seconds).

Examples:

  Executable=x:\foo\plink-testversion.exe
  ExecArguments=-2 -SSH
  FullPathKeyfile=x:\bar\mytest.key
  BackScrollLines=1000
  ShowOnDoubleClick=0
  FullPathLogfile:=c:\myentunnel.log   
  EchoPort=31337
  PingInterval=60000
  
IPv6 Support
------------

To enable IPv6 support please add "-6" to ExecArguments in the profiles INI:
ExecArguments=-N -ssh -2 -6 

HTTP/SOCKs Proxy Support
------------------------

To use a web or socks proxy for the outgoing SSH connection please use PuTTY and create a named session with those settings.  Then simply use the saved sessions name for the host to connect to.


System Tray Icons Descriptions
------------------------------

Green:
  SSH connection has been established and is stable
Yellow:
  SSH connection connecting/reconnecting/ping timeout
Red:
  Unable to connect or other error condition



GUI Options Descriptions
------------------------

Connect on Startup:
  Launch plink and establish connection when application is loaded
Enable Compression:
  Enable zlib link compression
Reconnect on Failure:
  Try up to 6 attempts to maintain tunnel every N (user defineable) seconds
Infinite Retry Attempts:
  Always attempt to maintain tunnel
Retry Delay:
  Number of seconds to wait between reconnection attempts
Use Private Keyfile:
  Enable public/private key pair authentication
Enable Dynamic SOCKS:
  Enable dynamic SOCKS support
Verbose Logging:
  Show all plink.exe messages in status window
Hide Port Connections:
  Squelch port open/close messages in status window
Disable Notifications:
  Disables notification popups (Handy when using it on a laptop)


Version History
---------------

Version 3.6.2 picks back up after several years; added in Light/Dark theme support and updated plink.exe.

Version 3.6.1 fixes a bug when the login fails. (MyEnTunnel would assume it was  logged in when it wasn't.)

Version 3.6.0 is a unicode rewrite of version 3.4.2.1.

GUI now supports dynamic languages.
Made some additional translations using Google Translate. 
(However, the phrasing may not be correct or even make sense in other languages. 
But hopefully it will convey the gist. And maybe a chuckle.)

Now including both 32 and 64 bit builds.

Switched to INNO setup to create a multilingual installer.
The INNO installer will automatically install the 32 or 64 bit version based on the OS.

Note:
If you're on a 64 bit system and want to make a portable install please use the 32 bit version. 
You'll need to manually extract it from the installer.
See: innounp available at http://innounp.sourceforge.net/ 

The plink monitoring routine has been placed in it's own thread.
The "Slow Poll" option has been removed as the application thread no longer blocks waiting on WaitForSingleObject to return.

Updated bundled plink.exe to version Beta 0.63.
Added GUI fields for to pass additional command line arguments to plink.

Removed NT service as it requires rewriting for Windows 7/Vista.

Added two methods of detecting dead SSH connections after taking a look at autossh for unix. (Thanks for the ideas!)
A remote and local tunnel pair to create a "looped back" connection.
Or a single tunnel to the servers Echo service. 
The Echo service method uses less resources and should be used if available on the ssh server.
The default ping time is 10 seconds. 
Three (3) pings must be missed to trigger a reconnect.
The round trip time (rtt) calculations are based on GetTickCount.
Both loopback and echo service pinging methods are on separate threads.
 
MyEnTunnel now has the RUNASADMIN flag in AppCompatFlags registry section.

The form will now minimize to the system tray instead of closing when clicking the Windows close button on the title bar.
Please use the right click menu option "Exit" to close the application.

Added popup menu on right click to the row of buttons on the bottom and main form body.
Local and Remote tunnels will ignore blanks and commented hash (#) lines.
GUI window can be resized at runtime.
Additional GUI changes, tweaks and internal clean ups.

The system tray icons have been slightly modified to help those who are color blind.
They will now be "unlocked" when red or yellow and "locked" when green.

Version 3.5.2 was the Unicode development branch.

Version 3.4.2.1 reduced exe file size by removing an unused library.
Small text changes only. There are no functional changes.

Version 3.4.2 fixes a few lingering issues and adds some small features.
Added INI option: logfile
Added INI option: ShowOnDoubleClick (defaults to on)
Now disconnects on standy/hibernate and reconnects on resume.
Form is once again hidden on launch.
Now allows spaces in username (quoted field).
Will now abort after 6 failed password or phrase attempts.
Updated internal buffer from 256 to 1024 bytes.
Added in License, Readme and About Tabs.
Added readme information on how to enable IPv6 and HTTP/Socks proxy usage.

Version 3.4.1 fixes a memory leak by freeing all named pipes when plink.exe 
terminates. (Thanks to Revragnarok for finding it)
The profile option on the system tray popup menu is now available even if no 
profiles exist.

Version 3.4 adds support for profile creation and switching via the right click 
system tray menu.
The MyEntunnel service now polls once every 10 (ten) seconds instead of once a 
second.
Updated bundled plink.exe to version Release 0.60.

Version 3.3 now supports MyEntunnel as a NT service.

Version 3.2 fixes a CPU usage bug when reconnecting plink (during pause).
Several small bug fixes relating to the Settings panel.
The installer now has user defineable Start menu shortcuts.
License.txt is now included in the install package.
Reordered bottom buttons and other small visual changes. 

Version 3.1.1 updated bundled plink.exe to version Release 0.59.

Version 3.1 fixes a bug with numeric only fields not accepting backspace as a 
valid key.
Status backscroll no longer keeps first line when overwriting.
Additional INI setting: BackScrollLines

Version 3.0 adds profile support (via command line)
A bug fix when sending passwords to stdin.
Installer now includes a readme.txt file.
More code cleanup and compaction.
These options are now available by hand editing the myentunnel.ini:
Executable - Full path and name to replacement executable; normally: plink.exe
ExecArguments - For customized options; normally: -N -ssh -2
FullPathKeyfile - Full path and name to keyfile; normally: keyfile.ppk

Version 2.9 now passes the password using stdin instead of the command line.
Small changes to plink command line arguments and the About Box.
Other small internal code cleanups and a system tray icon behaviour fix.

Version 2.8.1 fixes a line wrap issue with long lines in the tunnel entry 
section.

Version 2.8 adds a toggle to disable popup notifications.

Version 2.7 now allows setting the retry delay when reconnecting.
More checks on numeric fields (valid port number, non-blank).
A relayout of the settings tab to include new options as well as a few slight 
rewordings.

Version 2.6 fixes a few small glitches in the GUI. (Tab order fixes, numeric 
only input on port fields, etc.,..)
It now passes full path of the key file to plink instead of relying on the 
current working directory.
A new option to filter out port open/close spam when verbose logging is enabled.
A slight update to the About Box.

Version 2.5 has a fix when used on machines running VNC (as server).
There were small visual changes when using XP themes.
And a switch of compilers that fixes a number of issues (and adds 30k; ouch).

Version 2.4 will now prompt on server key changes.
Other slight rewording when displaying prompts.

Version 2.3 has another fix relating to pass phrases.
The phrase was forgotten on initial successful connection and was blank on all 
further reconnect attempts.
Most fatal errors now abort auto reconnect.

Version 2.2 has a major bug fix relating to pass phrases.
Phrase/password length is now 100 characters.

Version 2.1 will now allow blank pass phrases and there was a small text change.

Version 2.0 now has Public/Private Key support.
The file must be called "keyfile.ppk" in the application directory.
Visual controls now follow the current XP theme (Thanks to the use of a 
Windows.Manifest).
Other small functional changes have been added as well. (Store Key prompt, 
asking for password/pass phrase when blank...)

Version 1.9.1 contains icon updates and text changes. (Thanks to Mr. Kelcher)

Version 1.9 contains an important integer overflow bug fix that affected 
application stability.

Version 1.8 was initial public release.
