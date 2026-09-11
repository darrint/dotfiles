# darrint-laptop

Dell Precision 7520 running **Omarchy 4**. Used to be NixOS host `nixoslaptop`.

Do not manage this machine with the NixOS flake. Omarchy owns `/usr/share/omarchy` and many `~/.config` defaults. This directory is the source of truth for *this* host.

## Layout

| Path | Role |
| --- | --- |
| `intent.md` | What we want: live Omarchy customizations plus leftover NixOS intent |
| `overlay/` | Tracked copies of user-owned files to copy onto `~` |
| `inventory/` | Last captured packages / hardware / identity |
| `MANIFEST` | Overlay paths (keep capture and restore in sync) |
| `CAPTURE.md` | Agent playbook to snapshot the live machine |
| `RESTORE.md` | Agent playbook after a fresh Omarchy install |
| `frc.md` | WPILib / PathPlanner / Choreo install on this Omarchy host |

Copy files. Do not symlink `~/.config` into git. `omarchy refresh` and updates expect real files under `~/.config`.

## What belongs here

- User Hyprland / Omarchy / git / mise edits that differ from stock
- Package and hardware inventory
- Optional extras that used to live in NixOS (Steam, 1Password, NetBird, …)

## What never belongs here

Secrets, SSH private keys, sops age keys, NetBird state, browser profiles, caches, `node_modules`, nvim plugin data, large media.

Historical NixOS files stay at `systems/x86_64-linux/nixoslaptop/` and `homes/x86_64-linux/darrint@nixoslaptop/` for the other NixOS hosts’ shared modules. They are not applied to this laptop.
