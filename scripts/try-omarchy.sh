#!/usr/bin/env nix-shell
#! nix-shell -i bash -p qemu_kvm curl coreutils gnugrep gawk
# Try Omarchy Quattro in QEMU/KVM without touching the host install.
# Usage: ./scripts/try-omarchy.sh
# Optional env:
#   OMARCHY_ISO_URL  OMARCHY_ISO_DIR  OMARCHY_DISK_SIZE  OMARCHY_RAM_MB  OMARCHY_CPUS
set -euo pipefail

ISO_URL="${OMARCHY_ISO_URL:-https://iso.omarchy.org/omarchy-4.0.3.iso}"
ISO_SHA_URL="${OMARCHY_ISO_SHA_URL:-https://iso.omarchy.org/omarchy-4.0.3.iso.sha256}"
ISO_DIR="${OMARCHY_ISO_DIR:-$HOME/VMs/omarchy}"
ISO_PATH="$ISO_DIR/$(basename "$ISO_URL")"
DISK_PATH="$ISO_DIR/omarchy-quatro.qcow2"
DISK_SIZE="${OMARCHY_DISK_SIZE:-40G}"
RAM_MB="${OMARCHY_RAM_MB:-8192}"
CPUS="${OMARCHY_CPUS:-4}"
OVMF_CODE="${OVMF_CODE:-}"
OVMF_VARS_TEMPLATE="${OVMF_VARS_TEMPLATE:-}"

if [[ ! -r /dev/kvm ]]; then
  echo "No /dev/kvm — enable KVM or run without -enable-kvm (slow)." >&2
fi

mkdir -p "$ISO_DIR"

if [[ ! -f "$ISO_PATH" ]]; then
  echo "Downloading Omarchy ISO → $ISO_PATH"
  curl -fL --progress-bar -o "$ISO_PATH.partial" "$ISO_URL"
  mv "$ISO_PATH.partial" "$ISO_PATH"
else
  echo "Using existing ISO: $ISO_PATH"
fi

if curl -fsSL "$ISO_SHA_URL" -o "$ISO_DIR/iso.sha256" 2>/dev/null; then
  echo "Verifying SHA-256..."
  (
    cd "$ISO_DIR"
    if grep -q ' ' iso.sha256 2>/dev/null; then
      sha256sum -c <(sed "s| .*|  $(basename "$ISO_PATH")|" iso.sha256)
    else
      expected=$(tr -d ' \n\r' <iso.sha256)
      actual=$(sha256sum "$(basename "$ISO_PATH")" | awk '{print $1}')
      if [[ "$expected" != "$actual" ]]; then
        echo "SHA-256 mismatch (expected $expected got $actual)" >&2
        exit 1
      fi
      echo "OK"
    fi
  )
else
  echo "Warning: could not fetch checksum URL — skipping verify" >&2
fi

if [[ ! -f "$DISK_PATH" ]]; then
  echo "Creating disk $DISK_PATH ($DISK_SIZE)"
  qemu-img create -f qcow2 "$DISK_PATH" "$DISK_SIZE"
fi

# Prefer firmware from a throwaway nix shell if not set
if [[ -z "$OVMF_CODE" ]]; then
  OVMF_CODE="$(
    nix-build --no-out-link -E 'with import <nixpkgs> {}; OVMF.fd' 2>/dev/null \
      | head -1
  )/FV/OVMF_CODE.fd" || true
fi
if [[ -z "$OVMF_VARS_TEMPLATE" ]]; then
  OVMF_VARS_TEMPLATE="$(
    nix-build --no-out-link -E 'with import <nixpkgs> {}; OVMF.fd' 2>/dev/null \
      | head -1
  )/FV/OVMF_VARS.fd" || true
fi

VARS_PATH="$ISO_DIR/OVMF_VARS.fd"
if [[ -n "$OVMF_VARS_TEMPLATE" && -f "$OVMF_VARS_TEMPLATE" && ! -f "$VARS_PATH" ]]; then
  cp "$OVMF_VARS_TEMPLATE" "$VARS_PATH"
  chmod u+w "$VARS_PATH"
fi

QEMU_ARGS=(
  -machine q35,accel=kvm:tcg
  -cpu host
  -smp "$CPUS"
  -m "$RAM_MB"
  -drive "file=$DISK_PATH,if=virtio,format=qcow2"
  -cdrom "$ISO_PATH"
  -boot order=d
  -device virtio-vga
  -device virtio-net-pci,netdev=net0
  -netdev user,id=net0
  -usb -device usb-tablet
  -display gtk,gl=on
)

if [[ -n "$OVMF_CODE" && -f "$OVMF_CODE" && -f "$VARS_PATH" ]]; then
  QEMU_ARGS+=(
    -drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE"
    -drive "if=pflash,format=raw,file=$VARS_PATH"
  )
else
  echo "Note: OVMF not found; booting SeaBIOS. For UEFI:" >&2
  echo "  nix-shell -p OVMF --run 'echo \$OVMF/FV'" >&2
fi

echo
echo "Starting Omarchy trial VM (host NixOS untouched)."
echo "  Disk/ISO: $ISO_DIR"
echo "  Install into the virtual disk only. Ctrl+C stops the VM."
echo

exec qemu-system-x86_64 "${QEMU_ARGS[@]}"
