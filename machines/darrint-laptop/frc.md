# FRC tools on darrint-laptop (Omarchy)

Java/C++ only. Runs **natively** (no Distrobox/chroot). Do not use AUR WPILib packages, `frc-nix`, or `omarchy install editor vscode` for robot code.

## Installed (2026 season)

| What | Where |
| --- | --- |
| WPILib 2026.2.1 Everything | `~/wpilib/2026` |
| WPILib VS Code | `frc-vscode` or menu **FRC VS Code 2026** |
| PathPlanner v2026.1.2 | `~/.local/opt/pathplanner` → `pathplanner` |
| Choreo v2026.0.3 | `~/.local/opt/choreo` → `choreo` |
| Phoenix Tuner X | **not on Linux** (Windows 11 / macOS / Android / iOS only) |

WPILib tree includes JDK 17, GradleRIO maven cache, roboRIO toolchain, AdvantageScope, Elastic, Glass, SysId, DataLogTool, Shuffleboard, SmartDashboard, OutlineViewer, PathWeaver, RobotBuilder, Team Number Setter, WPIcal.

Installers cache (not in git): `~/.cache/frc-installers/`

## Host prep (already applied)

Arch serial group is **`uucp`**, not `dialout`:

```bash
sudo usermod -aG uucp darrint   # then log out/in
```

ufw allows robot networks:

```bash
sudo ufw allow from 10.0.0.0/8 comment 'FRC robot LAN'
sudo ufw allow from 172.22.11.0/24 comment 'roboRIO USB tether'
```

Do not export `JAVA_HOME` globally. WPILib VS Code uses `~/wpilib/2026/frccode/frcvars2026.sh`.

## Reinstall WPILib

```bash
tar -xf ~/.cache/frc-installers/WPILib_Linux-2026.2.1.tar.gz -C /tmp
/tmp/WPILib_Linux-2026.2.1/WPILibInstaller --install-mode all --force
```

2026.2.1’s `WPILibInstaller` treats extra args as “start install”. GUI is optional. SHA-256:

`c36591be0b5d1b753356543e0e672af9d91335fb26b5ffcba31cf05af829c656`

https://packages.wpilib.workers.dev/installer/v2026.2.1/Linux/WPILib_Linux-2026.2.1.tar.gz

## Reinstall PathPlanner / Choreo

```bash
unzip -q ~/.cache/frc-installers/PathPlanner-Linux-v2026.1.2.zip -d ~/.local/opt/pathplanner
unzip -q ~/.cache/frc-installers/Choreo-v2026.0.3-Linux-x86_64-standalone.zip -d ~/.local/opt/choreo
chmod +x ~/.local/opt/pathplanner/pathplanner ~/.local/opt/choreo/choreo ~/.local/opt/choreo/choreo-cli
```

## Windows-only (need another machine)

FRC Game Tools (roboRIO imaging, Driver Station), LabVIEW, Phoenix Tuner X, typically REV Hardware Client.

Team number on Linux: **roboRIO Team Number Setter**. Imaging still needs Windows.

## Check

```bash
~/wpilib/2026/jdk/bin/java -version
ls ~/wpilib/2026/tools/glass ~/wpilib/2026/vscode/VSCode-linux-x64/bin/code
pathplanner --help >/dev/null; echo pathplanner:$?
choreo --help >/dev/null; echo choreo:$?
id | grep uucp
```
