# Restore darrint-laptop from this repo

Start from a finished Omarchy install on this Dell Precision 7520 (or the same hardware). User `darrint`. Do not run NixOS rebuilds.

Omarchy’s NVIDIA helper should pick **580xx** for the Quadro M1200. If a newer `nvidia-open` stack is installed instead, stop and fix drivers before continuing.

## 1. Clone this repo

```bash
git clone git@github.com:<your-fork>/dotfiles.git ~/dev/dotfiles
# or https, then gh auth later
cd ~/dev/dotfiles
```

## 2. Copy overlay onto `$HOME`

```bash
repo="$(git rev-parse --show-toplevel)"
src="$repo/machines/darrint-laptop"
while IFS= read -r rel; do
  [[ -z "$rel" || "$rel" == \#* ]] && continue
  from="$src/overlay/$rel"
  to="$HOME/$rel"
  mkdir -p "$(dirname "$to")"
  cp -a "$from" "$to"
  echo "restored $rel"
done < "$src/MANIFEST"
```

Reload Hyprland config (`hyprctl reload`) and check `hyprctl configerrors`. Shell.json hot-reloads. New terminals pick up other app configs.

## 3. Theme, mise, git auth

```bash
omarchy theme set lupine
mise install
gh auth login
```

`git` credential helper expects `gh` on `PATH` (mise shims).

## 4. Optional extras (from `intent.md`)

Ask before installing. Suggested Omarchy commands:

```bash
omarchy install service 1password
omarchy install gaming steam
omarchy install service sunshine
omarchy install gaming retroarch
omarchy install editor vscode   # not for FRC robot code; use FRC VS Code 2026
```

FRC Java/C++ tools: follow `frc.md` (WPILib installer + PathPlanner + Choreo). Serial group is `uucp`, not `dialout`.

Docker is already a base package. Enable only if wanted:

```bash
sudo systemctl enable --now docker
sudo usermod -aG docker darrint
```

Everything else (NetBird, cloud CLIs, zellij, creative apps, emulators) is listed in `intent.md` — install with `omarchy pkg add` / `omarchy pkg aur add` when needed.

## 5. Secrets (manual)

Never copy these from git. Restore from 1Password or backup:

- `~/.config/sops/age/keys.txt` (mode 600)
- SSH keys if you use them
- NetBird / AWS / OCI credentials

## 6. Do not restore

niri, Dank Material Shell, GNOME autologin, home-manager, nvf, NixOS `configuration.nix`, or files under `/usr/share/omarchy/`.

## 7. Check

```bash
omarchy version
omarchy theme current
hyprctl monitors
mise ls
git config --global --get user.email
```

Compare `pacman -Qe` to `inventory/pacman-explicit.txt` only as a hint — Omarchy updates will drift versions.
