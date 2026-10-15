#!/usr/bin/env bash
# Installs the latest ouroboros release binary into ~/.local/bin (or $PREFIX/bin).
set -euo pipefail

REPO="core-red-project/ouroboros-cli"
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64)            asset="ouroboros-linux-x86_64" ;;
  Darwin-arm64|Darwin-aarch64) asset="ouroboros-macos-aarch64" ;;
  *) echo "error: no release binary for $(uname -s)-$(uname -m); build from source with 'just build'" >&2; exit 1 ;;
esac

dest="${PREFIX:-$HOME/.local}/bin"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
base="https://github.com/$REPO/releases/latest/download"
curl -fsSL "$base/$asset" -o "$tmp/ouroboros"
curl -fsSL "$base/SHA256SUMS" -o "$tmp/SHA256SUMS"
expected="$(awk -v a="$asset" '$2 == a {print $1}' "$tmp/SHA256SUMS")"
actual="$( (sha256sum "$tmp/ouroboros" 2>/dev/null || shasum -a 256 "$tmp/ouroboros") | awk '{print $1}')"
[ -n "$expected" ] && [ "$expected" = "$actual" ] \
  || { echo "error: checksum mismatch for $asset" >&2; exit 1; }
mkdir -p "$dest"
install -m 755 "$tmp/ouroboros" "$dest/ouroboros"
echo "installed $dest/ouroboros"
case ":$PATH:" in *":$dest:"*) ;; *) echo "note: add $dest to PATH" ;; esac
