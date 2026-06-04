# MyEnTunnel

> **After a few years hiatus MyEnTunnel is now back with an updated release and I'm releasing the Delphi source code.**

**MyEnTunnel** is a Windows system tray application that establishes and maintains persistent TCP SSH tunnels. It runs silently in the background, automatically reconnecting when a connection drops — so your tunnels stay up without any manual intervention.

![Screenshot](/images/myentunnel-screenshot.png "MyEnTunnel Screenshot")

> **Note:** This is a third-party application and is not associated with VanDyke Software or Simon Tatham (the author of PuTTY).

---

## What It Does

MyEnTunnel works by launching **Plink** (`plink.exe`, the command-line SSH client from PuTTY) as a background child process and watching over it. If Plink dies for any reason — network interruption, server restart, timeout — MyEnTunnel restarts it automatically.

**Supported tunnel types:**
- **Local port forwarding** — forward a local port through the SSH server to a remote host
- **Remote port forwarding** — expose a local port on the remote SSH server
- **SOCKS proxy** — dynamic SOCKS5 proxy through the SSH connection

**Active connection monitoring (optional):**
- Looped TCP tunnel pairs (local + remote) to detect dead connections via echo
- Single tunnel to the server's echo service (port 7) — lighter on resources
- Triggers a reconnect after 3 consecutive missed pings (configurable)

All cryptography and networking is handled by `plink.exe`. MyEnTunnel only manages the process lifecycle and connection health.

---

## Features

- System tray icon with color-coded status (green / yellow / red)
- Multiple profiles — manage several SSH connections independently
- Multi-language UI: English, German, French, Dutch, Polish, Simplified Chinese, Traditional Chinese
- Light / Dark theme with automatic detection of Windows system theme
- Pageant and PuTTYgen compatible (SSH key authentication)
- Works with portaPuTTY (portable/USB drive usage)
- Compatible with Wine on Linux/macOS

---

## Security Notice

The password or passphrase **remains in memory** while MyEnTunnel is running. The obfuscated version stored in the INI file is **not strongly encrypted**. For this reason:

- **Do not use MyEnTunnel with root or administrator accounts.**
- For attended workstation use, prefer **Pageant with passphrases** over stored passwords.

---

## Requirements (End Users)

- Windows 10 or Windows 11 (32-bit or 64-bit)
- `plink.exe` from the [PuTTY download page](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) — place it in the same folder as `myentunnel.exe`, or configure its path in the INI file

---

## Installation

Download the installer from the [Releases page](https://github.com/nemesis2/MyEnTunnel/releases). The INNO Setup installer automatically selects the correct 32-bit or 64-bit build for your OS.

For a **portable install** on a 64-bit system, use the 32-bit build. You can extract it manually from the installer using [innounp](http://innounp.sourceforge.net/).

---

## Quick Start

1. Launch `myentunnel.exe`. It minimizes to the system tray immediately.
2. Right-click the tray icon and choose **Settings** (or double-click to open the main window).
3. Fill in your SSH server, username, password or key file, and tunnel definitions.
4. Click **Connect**. The tray icon turns green when the tunnel is established.

To exit, right-click the tray icon and choose **Exit**. Closing the window only minimizes it back to the tray.

---

## Profiles

Profiles let you run multiple independent SSH tunnel configurations simultaneously. Each profile stores its own INI settings and key file.

**Creating/switching profiles:** right-click the system tray icon and use the Profiles submenu.

**Launching a specific profile from the command line or a shortcut:**

```
"C:\Program Files\myentunnel\myentunnel.exe" work
```

When using key files with profiles, the key file is named `<profilename>-keyfile.ppk` (e.g., `work-keyfile.ppk`).

---

## System Tray Icon States

| Icon | Meaning |
|------|---------|
| Green lock | SSH connection established and stable |
| Yellow lock (open) | Connecting, reconnecting, or ping timeout |
| Red lock (open) | Unable to connect or error condition |

---

## GUI Options

| Option | Description |
|--------|-------------|
| Connect on Startup | Establish the connection as soon as the app launches |
| Enable Compression | Enable zlib compression on the SSH link |
| Reconnect on Failure | Retry up to 6 times, with a configurable delay between attempts |
| Infinite Retry Attempts | Keep retrying forever (overrides the 6-attempt limit) |
| Retry Delay | Seconds to wait between reconnection attempts |
| Use Private Keyfile | Use public/private key pair authentication (requires `keyfile.ppk`) |
| Enable Dynamic SOCKS | Enable SOCKS5 dynamic proxy forwarding |
| Verbose Logging | Show all Plink output in the status window |
| Hide Port Connections | Suppress port open/close messages from verbose output |
| Disable Notifications | Suppress system tray balloon notifications |

---

## Advanced INI Options

Edit `myentunnel.ini` directly to access these settings:

| Key | Default | Description |
|-----|---------|-------------|
| `Executable` | `plink.exe` | Full path to a replacement Plink executable |
| `ExecArguments` | `-N -ssh -2` | Extra command-line arguments passed to Plink |
| `FullPathKeyfile` | `keyfile.ppk` | Full path to the key file |
| `BackScrollLines` | `200` | Maximum lines kept in the status window |
| `ShowOnDoubleClick` | `1` | Toggle window visibility on tray icon double-click |
| `FullPathLogfile` | *(none)* | Path to a log file that mirrors the status window |
| `EchoPort` | `7` | Port used for the echo service ping |
| `PingInterval` | `10000` | Ping interval in milliseconds |

**Examples:**

```ini
Executable=X:\tools\plink-dev.exe
ExecArguments=-N -ssh -2 -6
FullPathKeyfile=X:\keys\mykey.ppk
BackScrollLines=1000
ShowOnDoubleClick=0
FullPathLogfile=C:\logs\myentunnel.log
EchoPort=31337
PingInterval=60000
```

### IPv6

Add `-6` to `ExecArguments`:

```ini
ExecArguments=-N -ssh -2 -6
```

### HTTP / SOCKS Proxy

Create a named PuTTY session with the proxy settings configured, then use that session name as the **Host** field in MyEnTunnel instead of a bare hostname.

---

## Building from Source

### Requirements

- **Delphi 12 Athens** (or compatible version — the project targets Delphi 12.3)
- **Indy Components** — bundled with Delphi; used for TCP socket handling
- Windows SDK (included with Delphi)

### Steps

1. Clone the repository:

   ```
   git clone https://github.com/nemesis2/MyEnTunnel.git
   ```

2. Open `myentunnel.dproj` in the Delphi IDE.

3. Select your target platform (**Win32** or **Win64**) from the toolbar.

4. Choose a build configuration:
   - **Release** — optimized, no debug symbols
   - **Debug** — unoptimized, with debug information

5. Build with **Project > Build** (or `Shift+F9`).

   The compiled executable is placed in:
   - `Win32\Release\myentunnel.exe` (32-bit release)
   - `Win64\Release\myentunnel.exe` (64-bit release)

### Command-line Build (MSBuild)

```
msbuild myentunnel.dproj /p:Config=Release /p:Platform=Win32
msbuild myentunnel.dproj /p:Config=Release /p:Platform=Win64
```

### Installer

The installer is built with [INNO Setup](https://jrsoftware.org/isinfo.php). Open the INNO script (`.iss` file) in the INNO Setup IDE and compile it. The installer bundles both 32-bit and 64-bit builds and selects the correct one at install time.

---

## Version History

| Version | Highlights |
|---------|-----------|
| 3.6.2 | Light/Dark theme support, updated plink.exe |
| 3.6.1 | Fix: login failure no longer incorrectly reports success |
| 3.6.0 | Full Unicode rewrite, dynamic language switching, 32+64-bit builds, INNO installer, active ping monitoring on separate threads |
| 3.4.2 | Logfile INI option, suspend/resume disconnect, spaces in username, 6-attempt abort |
| 3.4 | Profile creation and switching via tray menu |
| 3.3 | NT service support (removed in 3.6 pending rewrite for Vista/7+) |
| 3.0 | Command-line profile support |
| 2.9 | Password sent via stdin instead of command line |
| 2.0 | Public/private key support |
| 1.8 | Initial public release |

---

## License

MyEnTunnel is **freeware**. Free for personal and commercial use. You may distribute it freely but you may not sell it or include it in a paid product. See [license.txt](license.txt) for full terms.

---

## Links

- [PuTTY / Plink downloads](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)
- [Pageant (SSH key agent)](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)
- [INNO Setup](https://jrsoftware.org/isinfo.php)
- [innounp (INNO unpacker)](http://innounp.sourceforge.net/)
