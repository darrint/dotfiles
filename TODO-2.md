# NixOS Config Modularization TODOs (Round 2)

Goal: continue moving config out of `systems/` and into `modules/`.

## Pending

- [ ] `services.sunshine` → `steam` module (default `true` when steam enabled)
- [ ] `nix.settings.trusted-users` → `nix-flakes` module (hardcoded `["root" "darrint"]`)
- [ ] `networking.networkmanager.enable` → `darrint-desktop` module
- [ ] `programs.localsend` → `darrint-desktop` module
- [ ] `waypipe` → `darrint-desktop` module (systemPackages)
- [ ] Podman packages (`cachix`, `dive`, `podman-tui`, `docker-compose`, `podman-compose`) → `podman` module
- [ ] `programs.nh` (NixOS system level) → new `modules/nixos/nh` module
- [ ] Gaming emulators (`dolphin-emu`, `xenia-canary`, `xemu`, retroarch, `x-plane-11`) → new `darrint-gaming` module

## What stays in systems/nixoslaptop
- `hardware-configuration.nix`
- `system.stateVersion`
- `networking.hostName`
- `networking.wireguard.enable` (personal preference, not implied by desktop)
- `boot.*` (machine-specific bootloader)
- `nix.settings.trusted-users` (after moving to nix-flakes module)
- `darrint.user.*` (per-machine groups and keys)
- `networking.firewall.allowedTCPPorts` (machine-specific dev ports)
- `inputs.self.packages.x-plane-11` (after moving to gaming module, this stays as an extra package there)
