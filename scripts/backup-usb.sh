#!/usr/bin/env nix-shell
#! nix-shell -i bash -p zstd age gnugrep gawk coreutils findutils util-linux
# USB HDD archive backup (NTFS Seagate). Adds data only; never reformats or
# deletes existing files on the drive.
#
#   ./scripts/backup-usb.sh              # local host only
#   ./scripts/backup-usb.sh darrint-server
#   BACKUP_HOSTS="darrint-server outpost" ./scripts/backup-usb.sh
#
# Env:
#   BACKUP_MOUNT   override mountpoint (default: auto udisks mount)
#   BACKUP_ROOT    dirname under mount (default: nixos-backups)
#   BACKUP_HOSTS   space-separated remote hosts (also CLI args)
#   AGE_RECIPIENT  age public key (default: from ~/.config/sops/age/keys.txt)
#   AGE_KEY_FILE   private key file for default recipient lookup
#   DRY_RUN=1      print actions only
set -euo pipefail

DISK_ID="${BACKUP_DISK_ID:-usb-Seagate_Portable_NT3F7VT1-0:0-part2}"
DISK_PATH="/dev/disk/by-id/${DISK_ID}"
BACKUP_ROOT_NAME="${BACKUP_ROOT:-nixos-backups}"
AGE_KEY_FILE="${AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
STAMP="$(date -u +%Y-%m-%dT%H%M)"
LOCAL_HOST="$(hostname -s)"
DRY_RUN="${DRY_RUN:-0}"
TOTAL_BYTES=0

log() { printf '%s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }
run() {
  if [[ "$DRY_RUN" == 1 ]]; then
    log "DRY: $*"
  else
    "$@"
  fi
}

need() { command -v "$1" >/dev/null 2>&1 || die "missing command: $1"; }
need tar
need zstd
need age
need sha256sum

# --- age recipient ----------------------------------------------------------
if [[ -z "${AGE_RECIPIENT:-}" ]]; then
  if [[ -f "$AGE_KEY_FILE" ]]; then
    AGE_RECIPIENT="$(grep -E '^# public key: ' "$AGE_KEY_FILE" | head -1 | sed 's/^# public key: //')"
  fi
fi
[[ -n "${AGE_RECIPIENT:-}" ]] || die "set AGE_RECIPIENT or put public key comment in $AGE_KEY_FILE"

# --- mount drive ------------------------------------------------------------
[[ -e "$DISK_PATH" ]] || die "backup disk not found: $DISK_PATH (is the Seagate plugged in?)"

MOUNT="${BACKUP_MOUNT:-}"
MOUNTED_BY_US=0
if [[ -z "$MOUNT" ]]; then
  # already mounted?
  MOUNT="$(findmnt -n -o TARGET "$DISK_PATH" 2>/dev/null | head -1 || true)"
fi
if [[ -z "$MOUNT" ]]; then
  if command -v udisksctl >/dev/null 2>&1; then
    log "Mounting $DISK_PATH via udisksctl..."
    out="$(udisksctl mount -b "$DISK_PATH" 2>&1)" || die "udisksctl mount failed: $out"
    MOUNT="$(printf '%s\n' "$out" | sed -n 's/.* at \(.*\)\.$/\1/p')"
    [[ -n "$MOUNT" ]] || MOUNT="$(findmnt -n -o TARGET "$DISK_PATH" | head -1)"
    MOUNTED_BY_US=1
  else
    die "disk not mounted and udisksctl unavailable; mount manually and set BACKUP_MOUNT="
  fi
fi
[[ -d "$MOUNT" ]] || die "mountpoint not a directory: $MOUNT"
log "Using mount: $MOUNT"

cleanup() {
  if [[ "$MOUNTED_BY_US" == 1 ]]; then
    log "Unmounting $DISK_PATH..."
    udisksctl unmount -b "$DISK_PATH" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

BASE="$MOUNT/$BACKUP_ROOT_NAME"
run mkdir -p "$BASE"

# --- exclude lists ----------------------------------------------------------
EXCLUDES_FILE="$(mktemp)"
cat >"$EXCLUDES_FILE" <<'EOF'
# JS / frontend
node_modules
.npm
.next
.nuxt
.turbo
.parcel-cache
.yarn/cache
.pnpm-store
coverage
.nyc_output
# Rust
target
# Nix
result
result-*
.direnv
# Python
__pycache__
*.pyc
*.pyo
.venv
venv
.tox
.mypy_cache
.pytest_cache
.ruff_cache
*.egg-info
.eggs
htmlcov
# Generic build
dist
build
out
cmake-build-*
CMakeFiles
# Elixir / Erlang
_build
deps
.elixir_ls
.erlang.cookie
# Go / PHP
vendor
# Dart / Flutter
.dart_tool
.flutter-plugins
.flutter-plugins-dependencies
# Java / Android
.gradle
.idea
*.class
# Terraform / cloud
.terraform
.terragrunt-cache
# Caches
.cache
.cargo/registry
.cargo/git
.stack-work
.bundle
# Home bulk (only if under backed-up trees)
.local/share/Steam
.local/share/Trash
.local/share/containers
.local/share/flatpak
.local/state/nix
.thumbnails
EOF
# Strip comments/blank lines for tar/du
EXCLUDES_CLEAN="$(mktemp)"
grep -v -E '^\s*(#|$)' "$EXCLUDES_FILE" >"$EXCLUDES_CLEAN"
mv "$EXCLUDES_CLEAN" "$EXCLUDES_FILE"

# Downloads: keep personal/work-looking names; skip redistributable dumps
downloads_keep() {
  local f="$1" base
  base="$(basename "$f")"
  # skip obvious internet dumps / media images
  case "$base" in
    *.iso|*.img|*.AppImage|*.appimage) return 1 ;;
    *.img.xz|*.img.gz|*.img.bz2) return 1 ;;
    *Installer*|*Etcher*|*etcher*) return 1 ;;
    *bazzite*|*ArkOS*|*dArkOS*|*arkos*) return 1 ;;
  esac
  # ROM region tags in parentheses
  if [[ "$base" == *'(USA)'* || "$base" == *'(Europe)'* || "$base" == *'(USA,'* ]]; then
    return 1
  fi
  # UUID-looking names (browser download ids)
  if [[ "$base" =~ ^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\. ]]; then
    return 1
  fi
  # keep personal / work-ish
  case "$base" in
    *Resume*|*Wedding*|*wedding*) return 0 ;;
    Untitled\ document*|Chapter\ *|chapter\ *) return 0 ;;
    IMG_*.MOV|IMG_*.mov|IMG_*.JPG|IMG_*.jpg|IMG_*.PNG|IMG_*.png) return 0 ;;
    *.stl|*.wld|wg-*.conf) return 0 ;;
    *.pdf)
      case "$base" in
        *[Mm]anual*|*datasheet*|*Datasheet*|API-*) return 1 ;;
        *) return 0 ;;
      esac
      ;;
    GroupProject|Wedding) return 0 ;;
  esac
  return 1
}

write_manifest() {
  local dest="$1" host="$2"
  [[ "$DRY_RUN" == 1 ]] && return 0
  {
    echo "host: $host"
    echo "stamp: $STAMP"
    echo "local_runner: $LOCAL_HOST"
    echo "uname: $(uname -a)"
    echo "date_utc: $(date -u -Iseconds)"
    if [[ -d "$HOME/nixos/.git" ]]; then
      echo "flake_rev: $(git -C "$HOME/nixos" rev-parse HEAD 2>/dev/null || echo unknown)"
    fi
    echo "age_recipient: $AGE_RECIPIENT"
    echo "files:"
    find "$dest" -maxdepth 1 -type f -printf '  %f %s\n' 2>/dev/null | sort
  } >"$dest/MANIFEST.txt"
}

sha_sums() {
  local dest="$1"
  [[ "$DRY_RUN" == 1 ]] && return 0
  (
    cd "$dest"
    # shellcheck disable=SC2035
    sha256sum -- * 2>/dev/null | grep -v SHA256SUMS | grep -v MANIFEST.txt >SHA256SUMS || true
  )
}

# Human-readable bytes
fmt_bytes() {
  local b="${1:-0}"
  if command -v numfmt >/dev/null 2>&1; then
    numfmt --to=iec --suffix=B "$b"
  else
    echo "${b}B"
  fi
}

# Rough uncompressed size of paths under root, honoring excludes (matches tar).
estimate_size() {
  local root="$1"
  shift
  local bytes=0 p full
  [[ -d "$root" ]] || { echo 0; return 0; }
  for p in "$@"; do
    full="$root/$p"
    [[ -e "$full" ]] || continue
    # GNU du: --exclude-from patterns are globs against path components
    bytes=$((bytes + $(du -sb --exclude-from="$EXCLUDES_FILE" "$full" 2>/dev/null | awk '{s+=$1} END{print s+0}')))
  done
  echo "$bytes"
}

# tar helper: args after dest are paths relative to -C root
make_tar() {
  local out="$1"
  shift
  local root="$1"
  shift
  if [[ "$DRY_RUN" == 1 ]]; then
    local est
    est="$(estimate_size "$root" "$@")"
    log "DRY: tar -C $root -> $out ($*)"
    log "DRY:   estimated uncompressed: $(fmt_bytes "$est") ($est bytes)"
    TOTAL_BYTES=$((TOTAL_BYTES + est))
    return 0
  fi
  tar -C "$root" \
    --exclude-from="$EXCLUDES_FILE" \
    --exclude-caches-all \
    --warning=no-file-changed \
    --warning=no-file-removed \
    -cf - "$@" 2>/dev/null \
    | zstd -T0 -3 -o "$out"
}

encrypt_file() {
  local src="$1" dst="$2"
  if [[ "$DRY_RUN" == 1 ]]; then
    log "DRY: age -r $AGE_RECIPIENT -o $dst $src"
    return 0
  fi
  age -r "$AGE_RECIPIENT" -o "$dst" "$src"
  rm -f "$src"
}

# --- local backup -----------------------------------------------------------
backup_local() {
  local dest="$BASE/$LOCAL_HOST/$STAMP"
  run mkdir -p "$dest"
  log "=== local backup -> $dest ==="

  # home curated paths (exist only)
  local home_paths=()
  local p
  for p in dev nixos Documents Pictures Desktop; do
    [[ -e "$HOME/$p" ]] && home_paths+=("$p")
  done
  # .config without heavy caches
  if [[ -d "$HOME/.config" ]]; then
    home_paths+=(".config")
  fi

  if ((${#home_paths[@]})); then
    log "Creating home.tar.zst..."
    make_tar "$dest/home.tar.zst" "$HOME" "${home_paths[@]}"
  fi

  # filtered downloads list
  if [[ -d "$HOME/Downloads" ]]; then
    local list
    list="$(mktemp)"
    while IFS= read -r -d '' f; do
      rel="${f#"$HOME/Downloads/"}"
      if downloads_keep "$rel"; then
        printf '%s\n' "$rel" >>"$list"
      fi
    done < <(find "$HOME/Downloads" -mindepth 1 -maxdepth 2 \( -type f -o -type d \) -print0 2>/dev/null)
    if [[ -s "$list" ]]; then
      log "Creating downloads.tar.zst ($(wc -l <"$list") entries)..."
      if [[ "$DRY_RUN" == 1 ]]; then
        local dest_est=0 rel
        while IFS= read -r rel; do
          [[ -e "$HOME/Downloads/$rel" ]] || continue
          dest_est=$((dest_est + $(du -sb --exclude-from="$EXCLUDES_FILE" "$HOME/Downloads/$rel" 2>/dev/null | awk '{s+=$1} END{print s+0}')))
        done <"$list"
        log "DRY: downloads sample:"
        head -20 "$list"
        log "DRY:   estimated uncompressed: $(fmt_bytes "$dest_est") ($dest_est bytes)"
        TOTAL_BYTES=$((TOTAL_BYTES + dest_est))
      else
        tar -C "$HOME/Downloads" \
          --exclude-from="$EXCLUDES_FILE" \
          --warning=no-file-changed \
          -T "$list" -cf - 2>/dev/null \
          | zstd -T0 -3 -o "$dest/downloads.tar.zst"
      fi
    else
      log "No Downloads entries matched keep filter"
    fi
    rm -f "$list"
  fi

  # secrets (then age)
  log "Creating secrets archive..."
  local sec_paths=()
  for p in .ssh .gnupg .aws .oci; do
    [[ -e "$HOME/$p" ]] && sec_paths+=("$p")
  done
  [[ -d "$HOME/nixos/secrets" ]] && sec_paths+=("nixos/secrets")
  [[ -f "$AGE_KEY_FILE" ]] && sec_paths+=(".config/sops")

  if ((${#sec_paths[@]})); then
    local sec_raw="$dest/secrets.tar.zst"
    make_tar "$sec_raw" "$HOME" "${sec_paths[@]}"
    encrypt_file "$sec_raw" "$dest/secrets.tar.zst.age"
  fi

  write_manifest "$dest" "$LOCAL_HOST"
  sha_sums "$dest"
  log "Local backup done: $dest"
  if [[ "$DRY_RUN" == 1 ]]; then
    log "DRY: local estimated total (uncompressed, pre-zstd): $(fmt_bytes "$TOTAL_BYTES") ($TOTAL_BYTES bytes)"
    log "DRY: expect ~30–60% of that on disk after zstd (depends on data)"
  else
    ls -lh "$dest" 2>/dev/null || true
  fi
}

# --- remote backup via SSH --------------------------------------------------
# Runs tar on the remote host, streams to local file.
backup_remote() {
  local host="$1"
  local dest="$BASE/$host/$STAMP"
  run mkdir -p "$dest"
  log "=== remote backup $host -> $dest ==="

  if ! ssh -o BatchMode=yes -o ConnectTimeout=10 "$host" 'true' 2>/dev/null; then
    log "SKIP $host: SSH failed (BatchMode). Fix keys and re-run."
    return 0
  fi

  # remote home (same curated set)
  log "Streaming $host home.tar.zst..."
  if [[ "$DRY_RUN" == 1 ]]; then
    log "DRY: ssh $host tar home"
  else
    # shellcheck disable=SC2029
    ssh "$host" "bash -s" <<'REMOTE' | zstd -T0 -3 -o "$dest/home.tar.zst"
set -euo pipefail
cd "$HOME"
paths=()
for p in dev nixos Documents Pictures Desktop .config; do
  [[ -e "$p" ]] && paths+=("$p")
done
((${#paths[@]})) || exit 0
# Keep in sync with EXCLUDES_FILE at top of backup-usb.sh
ex=(
  --exclude=node_modules --exclude=target --exclude=result --exclude='result-*'
  --exclude=.direnv --exclude=__pycache__ --exclude='*.pyc' --exclude=.venv --exclude=venv
  --exclude=dist --exclude=build --exclude=out --exclude=.next --exclude=.nuxt
  --exclude=.turbo --exclude=.parcel-cache --exclude=coverage
  --exclude=.cache --exclude=.npm --exclude=.tox --exclude=.mypy_cache
  --exclude=.pytest_cache --exclude=.ruff_cache --exclude='*.egg-info'
  --exclude=_build --exclude=deps --exclude=.elixir_ls
  --exclude=vendor --exclude=.dart_tool --exclude=.gradle --exclude=.idea
  --exclude=.terraform --exclude=.cargo/registry --exclude=.cargo/git
  --exclude=.local/share/Steam --exclude=.local/share/Trash
)
tar "${ex[@]}" --warning=no-file-changed -cf - "${paths[@]}" 2>/dev/null
REMOTE
  fi

  # remote secrets
  log "Streaming $host secrets..."
  if [[ "$DRY_RUN" != 1 ]]; then
    local sec_raw="$dest/secrets.tar.zst"
    ssh "$host" "bash -s" <<'REMOTE' | zstd -T0 -3 -o "$sec_raw"
set -euo pipefail
cd "$HOME"
paths=()
for p in .ssh .gnupg .aws .oci nixos/secrets .config/sops; do
  [[ -e "$p" ]] && paths+=("$p")
done
((${#paths[@]})) || exit 0
tar --warning=no-file-changed -cf - "${paths[@]}" 2>/dev/null
REMOTE
    if [[ -s "$sec_raw" ]]; then
      encrypt_file "$sec_raw" "$dest/secrets.tar.zst.age"
    else
      rm -f "$sec_raw"
    fi
  fi

  # server /var state (sudo). Best-effort paths.
  log "Streaming $host var.tar.zst (sudo)..."
  if [[ "$DRY_RUN" != 1 ]]; then
    if ssh "$host" 'sudo -n true' 2>/dev/null; then
      ssh "$host" "sudo bash -s" <<'REMOTE' | zstd -T0 -3 -o "$dest/var.tar.zst"
set -euo pipefail
paths=()
for p in \
  /var/backup \
  /var/lib/vaultwarden \
  /var/lib/jellyfin \
  /var/lib/terraria \
  /var/lib/authentik \
  /var/lib/caddy \
  /var/lib/netbird \
  /var/lib/pocket-id \
  /var/lib/docker \
  /var/lib/containers
do
  [[ -e "$p" ]] && paths+=("$p")
done
((${#paths[@]})) || exit 0
tar --warning=no-file-changed \
  --exclude='*/cache/*' \
  --exclude='*/Cache/*' \
  --exclude='*/overlay2/*' \
  --exclude='*/image/*' \
  -cf - "${paths[@]}" 2>/dev/null
REMOTE
    else
      log "SKIP var for $host: passwordless sudo not available"
    fi
  fi

  write_manifest "$dest" "$host"
  sha_sums "$dest"
  log "Remote backup done: $dest"
  ls -lh "$dest" 2>/dev/null || true
}

# --- main -------------------------------------------------------------------
REMOTE_HOSTS=()
if [[ -n "${BACKUP_HOSTS:-}" ]]; then
  # shellcheck disable=SC2206
  REMOTE_HOSTS=($BACKUP_HOSTS)
fi
for arg in "$@"; do
  REMOTE_HOSTS+=("$arg")
done

backup_local

for h in "${REMOTE_HOSTS[@]}"; do
  [[ "$h" == "$LOCAL_HOST" ]] && continue
  backup_remote "$h"
done

rm -f "$EXCLUDES_FILE"
log "All done. Archives under $BASE"
if [[ "$DRY_RUN" == 1 ]]; then
  log "DRY: grand total estimated uncompressed: $(fmt_bytes "$TOTAL_BYTES") ($TOTAL_BYTES bytes)"
fi
log "Restore example: zstd -d -c home.tar.zst | tar -x -C /tmp/restore"
log "Secrets: age -d -i $AGE_KEY_FILE secrets.tar.zst.age | zstd -d | tar -t"
