# Intent for darrint-laptop

Distilled from live Omarchy (`~` + packages) and the old NixOS/home-manager config.

## Machine

- Hostname: `darrint-laptop` (NixOS name was `nixoslaptop`)
- User: `darrint` (uid 1000, group `wheel`)
- Hardware: Dell Precision 7520, i7-6820HQ, Intel HD 530 + NVIDIA Quadro M1200
- NVIDIA: **580xx** (`nvidia-580xx-dkms`) — Maxwell/Pascal; do not switch to current `nvidia-open`
- Theme: Lupine
- Default agent: opencode
- Shell: bash (stock Omarchy rc; no extra aliases yet)

## Live Omarchy customizations (in `overlay/`)

- Hyprland touchpad `natural_scroll = true`
- Monitor / GDK scale **1** (not Omarchy’s default 2 / auto)
- Clock format `dddd h:mm AP`
- git user `Darrin Thompson <darrint@fastmail.com>` + `gh` credential helper
- mise: `gh`, `opencode`, `codex` at latest; `node` 26.8.1

## Already provided by Omarchy (do not re-install unless missing)

Pipewire+JACK, NetworkManager, cups/avahi-ish printing stack, docker+compose, nvidia-580xx, intel media, limine, localsend, obsidian, pinta, libreoffice, lazygit, starship, zoxide, fzf, fd, ripgrep, btop, nvim (LazyVim via `omarchy-nvim`), terminals, Hyprland.

FRC Java/C++: WPILib 2026.2.1 + PathPlanner + Choreo are installed. See `frc.md`. Phoenix Tuner X has no Linux build.

Docker is installed but the service was **disabled** at last capture. Enable only if wanted:

```bash
sudo systemctl enable --now docker
sudo usermod -aG docker darrint
```

## Leftover NixOS intent (not on this Omarchy install yet)

Install with Omarchy commands where they exist; otherwise `omarchy pkg add`.

| Want | How |
| --- | --- |
| 1Password CLI + GUI | `omarchy install service 1password` |
| Steam | `omarchy install gaming steam` |
| Sunshine / Moonlight | `omarchy install service sunshine` (Moonlight client already present) |
| RetroArch | `omarchy install gaming retroarch` |
| VS Code | `omarchy install editor vscode` |
| Extra groups `uucp` (serial / FRC on Arch) | already applied; re-login to pick up |
| Node via mise | already in overlay; `mise install` |
| gh via mise | already in overlay; then `gh auth login` |

Still desired from NixOS but **no Omarchy installer** — add with `omarchy pkg add` / AUR when needed:

- NetBird peer (old module `darrint.netbird`; leftover `~/.config/netbird/` exists, do not copy state)
- grok-bot
- awscli + aws-vault + session-manager-plugin
- kubectl, helm, kubectx, argocd, telepresence
- terraform (`tf` alias)
- oci-cli (config from sops; never commit keys)
- zellij + `za` helper (old `~/.config/zellij` looks leftover; prefer the kdl in `modules/home/darrint-zellij/`)
- zoom, slack, gimp, easyeffects, reaper, musescore
- dolphin-emu, xemu, xenia, x-plane-11
- QMK udev / `uucp`
- v4l2loopback (OBS virtual cam)
- OneDrive client (abraunegg) if still used

## Abandoned with the NixOS desktop

Do not restore: niri, Dank Material Shell, GNOME/GDM autologin, home-manager/nvf Neovim, NixOS firewall hole list (8000/4000/8080/8081), podman-as-docker (Omarchy uses Docker).

## Secrets (never in git)

Restore from 1Password / backup, not this repo:

- `~/.config/sops/age/keys.txt`
- SSH keys (`~/.ssh` was empty on last capture)
- `gh auth login`
- NetBird / OCI / AWS credentials
- 1Password account
