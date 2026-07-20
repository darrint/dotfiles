# Deprecation Warnings TODO

Collected from `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel` across all hosts.

---

## All Hosts (darrint-server, nixoslaptop, nixos-wsl)

### `flake.nix`
- [ ] `'system'` has been renamed to `stdenv.hostPlatform.system`

### `modules/home/darrint-neovim/default.nix`
- [x] `vim.languages.ts` → rename to `vim.languages.typescript`
- [x] `vim.languages.tailwind.enable` → rename to `vim.lsp.presets.tailwindcss-language-server.enable`
- [x] `vim.languages.rust.crates.enable` → rename to `vim.languages.rust.extensions.crates-nvim.enable`

### `modules/home/darrint-base/default.nix`
- [x] `programs.ssh.addKeysToAgent` → rename to `programs.ssh.matchBlocks.*.addKeysToAgent`
- [x] `programs.ssh` default values will be removed in the future — review and set explicitly

### `modules/home/darrint-git/default.nix`
- [x] `programs.git.userEmail` → rename to `programs.git.settings.user.email`
- [x] `programs.git.userName` → rename to `programs.git.settings.user.name`

### Nix internals (likely upstream, low priority)
- [ ] `builtins.derivation` used to create `options.json` references a store path without proper context — may break in future Nix versions (likely from nvf/neovim module, not our code)

---

## nixoslaptop only

### `modules/home/darrint-frc/default.nix`
- [ ] `programs.vscode.extensions` → rename to `programs.vscode.profiles.default.extensions`

### `modules/nixos/darrint-desktop/default.nix`
- [ ] `services.xserver.desktopManager.gnome.enable` → rename to `services.desktopManager.gnome.enable`
- [ ] `services.xserver.displayManager.gdm.enable` → rename to `services.displayManager.gdm.enable`

### `modules/nixos/pipewire/default.nix`
- [ ] `hardware.pulseaudio` → rename to `services.pulseaudio`
