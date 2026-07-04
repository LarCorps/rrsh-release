#!/bin/sh
# rrsh installer — one signed, opaque binary. SSH-shaped remote access over RRFC.
#
#   curl -fsSL https://phic.online/rrsh/install.sh | sh
#
# Downloads the prebuilt rrsh binary for this OS/arch AND its detached signature,
# verifies the signature against the MiulusTek release key PINNED BELOW (so a
# tampered download or a compromised mirror is caught before anything runs), then
# installs it as `rrsh` (+ rrshd / rrsh-cp / rrsh-keygen) into ~/.local/bin.
# The binary is self-contained: the RRFC codec is embedded.
#
# Env:
#   RRSH_BASEURL   download base   (default: https://phic.online/rrsh)
#   RRSH_BIN       install dir     (default: ~/.local/bin)
#   RRSH_NO_VERIFY 1 to skip verification (NOT recommended; only if openssl absent)
set -eu

BASEURL="${RRSH_BASEURL:-https://phic.online/rrsh}"
BINDIR="${RRSH_BIN:-$HOME/.local/bin}"

# --- pinned MiulusTek release public key (YubiKey PIV slot 9a, CN=MiulusTek-Release-CA-v2) ---
# SHA256 of this key is echoed at verify time; it is the trust root for the download.
RRSH_PUBKEY='-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA56FfQsLdqVxYFiwTu2qZ
ZLtIxPjthfHgNG8TcM1bVBg1hYC66HrMNm2YqV17UEnoD2PsCc5WGO3JRbSjgC5l
ijz0tRPcLTT9L+0WpTCGp22W/Fo0y5fR7dmD17sgb186skq2b3I/82Jn6ujJ3Z1K
9wK4pA3rMzejmHbHaZLOl+9pIKLiuLM+37+rfhiSz9akWJV/5fe7W/21cupLuHT5
5wIUNSO27WLnEuZzaOwZRfD3ZnvJUHmch+MLRfqiq2BBRnAfFfbCc74l9r9zl137
iAnSBurbYNRNeYTqvJVIg5VHIKI+MzLpYD/Ql942EyBc0l2khP5xmgNx/8W5u3qf
WwIDAQAB
-----END PUBLIC KEY-----'

log() { printf 'rrsh: %s\n' "$*"; }
die() { printf 'rrsh: %s\n' "$*" >&2; exit 1; }

os="$(uname -s | tr '[:upper:]' '[:lower:]')"
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64)  arch=x86_64 ;;
  aarch64|arm64) arch=aarch64 ;;
  *) die "unsupported arch '$arch' (need x86_64 or aarch64)" ;;
esac
case "$os" in linux|darwin) : ;; *) die "unsupported OS '$os'" ;; esac

asset="rrsh-${os}-${arch}"
url="${BASEURL%/}/bin/${asset}"

fetch() { # fetch <url> <dest>
  if command -v curl >/dev/null 2>&1; then curl -fSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then wget -qO "$2" "$1"
  else die "need curl or wget"; fi
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

log "downloading $url"
fetch "$url" "$tmp/rrsh"

# --- verify the detached signature against the pinned key ---
if [ "${RRSH_NO_VERIFY:-0}" = "1" ]; then
  log "WARNING: signature verification skipped (RRSH_NO_VERIFY=1)"
elif ! command -v openssl >/dev/null 2>&1; then
  die "openssl not found — cannot verify signature. Install openssl, or re-run with RRSH_NO_VERIFY=1 (not recommended)."
else
  log "downloading signature ${asset}.sig"
  fetch "$url.sig" "$tmp/rrsh.sig"
  printf '%s\n' "$RRSH_PUBKEY" > "$tmp/rrsh.pub"
  keyhash="$(openssl pkey -pubin -in "$tmp/rrsh.pub" -outform DER 2>/dev/null | openssl dgst -sha256 | awk '{print $NF}')"
  log "release key sha256: ${keyhash:-unknown}"
  if openssl dgst -sha256 -verify "$tmp/rrsh.pub" -signature "$tmp/rrsh.sig" "$tmp/rrsh" >/dev/null 2>&1; then
    log "signature OK (signed by MiulusTek release key)"
  else
    die "SIGNATURE VERIFICATION FAILED — refusing to install. The download may be tampered or the mirror compromised."
  fi
fi

# --- install ---
chmod +x "$tmp/rrsh"
mkdir -p "$BINDIR"
mv "$tmp/rrsh" "$BINDIR/rrsh"
for name in rrshd rrsh-cp rrsh-keygen; do ln -sf rrsh "$BINDIR/$name"; done

log "installed → $BINDIR/rrsh ($("$BINDIR/rrsh" --version 2>/dev/null || echo '?'))"
log "linked rrshd, rrsh-cp, rrsh-keygen"
case ":$PATH:" in *":$BINDIR:"*) : ;; *) log "add to PATH →  export PATH=\"$BINDIR:\$PATH\"" ;; esac
cat <<'EOF'

Next:
  rrsh-keygen mybox --host <ip> --port 8022 --allow exec --exec-allowlist uname,uptime
  # copy ~/.rrsh/grants/mybox.json to the host, out of band (the seed IS the credential)
  rrshd --grant mybox            # on the host
  rrsh  mybox -- uname -a         # from the client
EOF
