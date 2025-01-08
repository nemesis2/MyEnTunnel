Note: This is a third party application and not associated with VanDyke Software or the author of PuTTY Simon Tatham.

MyEnTunnel is a simple system tray application that establishes and maintains TCP SSH tunnels. It does this by launching Plink (PuTTY Link) in the background and then monitors the process. If the Plink process dies (e.g. connection drops, server restarts or otherwise becomes unreachable) MyEnTunnel will automatically restart Plink to reestablish the tunnels in the background. It tries to use as little CPU and system resources as possible when monitoring. 

Optionally, MyEnTunnel can actively monitor the connection by creating looped tunnels (either a looped remote/local tunnel pair or a single local tunnel to the ssh servers echo service) and periodically send pings. If too many consecutive pings are lost it will restart the connection.

Since it uses Plink, you can use utilities such as Pageant (a SSH authentication agent for PuTTY, PSCP and Plink) and PuTTYgen (a RSA and DSA key generation utility), as well as named PuTTY sessions. All of the networking and encryption is done by plink.exe; not by MyEnTunnel. 

MyEnTunnel also works with portaPuTTY (Handy for USB thumbdrives).
MyEnTunnel is compatible with Wine on *IX.

For the security-conscious: The password or passphrase DOES stay in memory and the encrypted version stored in the INI file isn't fool proof. So I STRONGLY suggest you DON'T use this with root accounts for security reasons! For regular workstation (attended) usage I recommend using Pagent and passphrases.

If you like MyEnTunnel, instead of sending donations please post about it online in your blog/website or message forum. (I always prefer word of mouth advertising =) )
