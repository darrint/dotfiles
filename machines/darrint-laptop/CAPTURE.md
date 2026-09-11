# Capture darrint-laptop into this repo

Run on the live Omarchy laptop, from a checkout of this repo. Confirm `hostname` is `darrint-laptop` and `/etc/os-release` says Omarchy.

Do not copy secrets, browser profiles, caches, SSH private keys, sops age keys, NetBird state, or `node_modules`.

## 1. Overlay files

For each path in `MANIFEST`, copy `$HOME/<path>` → `overlay/<path>`.

```bash
repo="$(git rev-parse --show-toplevel)"
dest="$repo/machines/darrint-laptop"
while IFS= read -r rel; do
  [[ -z "$rel" || "$rel" == \#* ]] && continue
  src="$HOME/$rel"
  out="$dest/overlay/$rel"
  if [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$out")"
    cp -a "$src" "$out"
    echo "copied $rel"
  else
    echo "missing $src" >&2
  fi
done < "$dest/MANIFEST"
```

Then sanitize `overlay/.config/git/config`:

- Keep `[user]` name/email
- Replace any mise-versioned `gh` path with `helper = !gh auth git-credential`
- Drop empty `helper =` lines

If a live file is **identical** to the Omarchy packaged default (`/usr/share/omarchy/config/...` or `/etc/skel/...`), remove it from `MANIFEST` and `overlay/` instead of tracking stock files.

## 2. New customizations

Diff live vs packaged defaults. If the user changed something not in `MANIFEST` (hypr, omarchy, terminals, starship, nvim lua, bashrc), add the path to `MANIFEST`, copy it, and mention it in `intent.md`.

Useful diffs:

```bash
diff -u /usr/share/omarchy/config/hypr/input.lua ~/.config/hypr/input.lua
diff -u /usr/share/omarchy/config/hypr/monitors.lua ~/.config/hypr/monitors.lua
diff -u /usr/share/omarchy/config/omarchy/shell.json ~/.config/omarchy/shell.json
diff -u /usr/share/omarchy/config/git/config ~/.config/git/config
diff -u /etc/skel/.config/nvim/lua/config/options.lua ~/.config/nvim/lua/config/options.lua
```

Skip `.sample` hook files and files that only exist because Omarchy copied them.

## 3. Inventory

```bash
dest="$(git rev-parse --show-toplevel)/machines/darrint-laptop/inventory"
{
  echo "hostname: $(hostname)"
  echo "os: $(. /etc/os-release; echo "$PRETTY_NAME $VERSION_ID")"
  echo "omarchy: $(omarchy version)"
  echo "theme: $(omarchy theme current)"
  echo "default-agent: $(cat ~/.config/omarchy/defaults/agent 2>/dev/null || echo none)"
} > "$dest/identity.txt"
pacman -Qe > "$dest/pacman-explicit.txt"
```

Update `inventory/hardware.txt` only if GPU/CPU/vendor changed.

Note extra explicit packages that are not in `/usr/share/omarchy/install/omarchy-base.packages` (ignore ISO/hardware packages like `linux`, `nvidia-580xx-*`, `pipewire*`). Put lasting extras in `intent.md`.

## 4. Finish

- Update `intent.md` if hostname, theme, agent, or desired extras changed
- Do not commit secrets
- Show `git status` / `git diff` and leave committing to the user
