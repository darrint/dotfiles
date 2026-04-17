# NixOS Config Modularization TODOs

Goal: minimal configuration in `systems/` and `homes/`, maximum in `modules/`.

## High Value / Low Effort

- [ ] `modules/nixos/nix-flakes` — `nix.settings.experimental-features = ["nix-command" "flakes"]`
  - Duplicated identically across all 3 systems (darrint-server, nixos-wsl, nixoslaptop)

- [ ] `modules/nixos/locale` — timezone + i18n block
  - `time.timeZone = "America/Indiana/Indianapolis"` + full `i18n` block
  - Duplicated in darrint-server and nixoslaptop

- [ ] `modules/nixos/allowUnfree` — `nixpkgs.config.allowUnfree = true`
  - Duplicated in darrint-server and nixoslaptop

- [ ] `modules/nixos/openssh` — `services.openssh.enable = true`
  - Duplicated in darrint-server and nixoslaptop (WSL intentionally excluded)

## Medium Value

- [ ] `modules/nixos/darrint-user` — `users.users.darrint` definition
  - Common core: `isNormalUser = true`, `wheel` group
  - Options for: extra groups, SSH authorized key
  - Remove stale `packages = [zellij neovim]` from darrint-server (home-manager handles these)

- [ ] `modules/nixos/pipewire` — `security.rtkit + services.pipewire`
  - Core block identical on server + laptop
  - Server pipewire config is a copy-paste leftover (no audio hardware) — just remove it

## Larger Refactors

- [ ] `modules/nixos/darrint-desktop` — laptop GUI services
  - GNOME, GDM, auto-login, Plymouth
  - Nvidia (modesetting, closed drivers, nvidiaSettings)
  - printing + avahi
  - flatpak, fwupd
  - xdg.portal.wlr
  - services.sunshine
  - fonts (nerd-fonts: inconsolata, iosevka, monoid; inter)
  - security.polkit
  - boot extras (v4l2loopback, Plymouth, quiet kernel param, limine, systemd initrd)

- [ ] `modules/nixos/podman` — virtualisation.containers + podman with dockerCompat
  - Currently laptop-only; reusable

- [ ] `modules/nixos/steam` — `programs.steam` block
  - Currently laptop-only

- [ ] `modules/nixos/1password` — `programs._1password + programs._1password-gui`
  - Currently laptop-only

## What Stays in systems/
- `hardware-configuration.nix` (auto-generated, machine-specific)
- `system.stateVersion`
- Hostname (`networking.hostName`)
- Bootloader type and machine-specific boot config
- Machine-specific firewall ports
- `caddy.nix`, `vaultwarden.nix`, `jellyfin.nix` (server-specific services, already split out)
