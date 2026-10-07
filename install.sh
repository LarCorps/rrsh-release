#!/bin/sh
# Install the signed RFC 1.0.1 core, connection tester and pinned C header.
# RFC_BASEURL: local checkout directory or HTTP(S) repository root.
# RFC_PREFIX: install prefix (default ~/.local/share/relational-field-core/1.0.1).
set -eu

RFC_PUBKEY='-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA56FfQsLdqVxYFiwTu2qZ
ZLtIxPjthfHgNG8TcM1bVBg1hYC66HrMNm2YqV17UEnoD2PsCc5WGO3JRbSjgC5l
ijz0tRPcLTT9L+0WpTCGp22W/Fo0y5fR7dmD17sgb186skq2b3I/82Jn6ujJ3Z1K
9wK4pA3rMzejmHbHaZLOl+9pIKLiuLM+37+rfhiSz9akWJV/5fe7W/21cupLuHT5
5wIUNSO27WLnEuZzaOwZRfD3ZnvJUHmch+MLRfqiq2BBRnAfFfbCc74l9r9zl137
iAnSBurbYNRNeYTqvJVIg5VHIKI+MzLpYD/Ql942EyBc0l2khP5xmgNx/8W5u3qf
WwIDAQAB
-----END PUBLIC KEY-----'
HEADER_SHA256=8a5331841cc2ce6f78a28625993b05a90d3eb6a5ed2730dfbbb04ddb61af4d2e
PREFIX="${RFC_PREFIX:-$HOME/.local/share/relational-field-core/1.0.1}"
BASEURL="${RFC_BASEURL:-}"
log() { printf 'rfc: %s\n' "$*"; }
die() { printf 'rfc: %s\n' "$*" >&2; exit 1; }

command -v openssl >/dev/null 2>&1 || die "OpenSSL is required for signature verification."
if [ -z "$BASEURL" ]; then
  BASEURL="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
  [ -d "$BASEURL/bin" ] || die "Set RFC_BASEURL to a checkout directory or HTTP(S) repository root."
fi
os="$(uname -s)"
arch="$(uname -m)"
case "$os/$arch" in
  Linux/x86_64|Linux/amd64) target=x86_64-linux; library=librelational_field_core_1_0_1.so; library_pin=99695573b2ad8bf915675a5a090399bab2b56de9a6c40a7bc169f0dab34f8740; tester_pin=8507dfc21b774803aabe09ad5fa9c0f82c6e276ce2a3380c4d6df03f67470a98 ;;
  Darwin/arm64|Darwin/aarch64) target=aarch64-macos; library=librelational_field_core_1_0_1.dylib; library_pin=1b7e7b6838c53d4af03fb08924ecc7e1d7d39b413832c194a536ce2f568d1f61; tester_pin=cedc5c611057422ffa2b76a78695265fe10f24302f2b8e30dd52d9bb7eee7a20 ;;
  *) die "Unsupported platform $os/$arch; available: Linux x86_64 and macOS arm64." ;;
esac

fetch() {
  relative="$1"; destination="$2"
  case "$BASEURL" in
    http://*|https://*)
      url="${BASEURL%/}/$relative"
      if command -v curl >/dev/null 2>&1; then curl -fsSL "$url" -o "$destination"
      elif command -v wget >/dev/null 2>&1; then wget -qO "$destination" "$url"
      else die "Need curl or wget for HTTP(S) downloads."; fi ;;
    *) cp "${BASEURL%/}/$relative" "$destination" ;;
  esac
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' 0
trap 'exit 1' HUP INT TERM
log "staging RFC 1.0.1 for $target"
tester="rrsh-peer-$target"
fetch "bin/$target/$library" "$tmp/$library"
fetch "bin/$target/$library.sig" "$tmp/$library.sig"
fetch "bin/$target/$tester" "$tmp/$tester"
fetch "bin/$target/$tester.sig" "$tmp/$tester.sig"
fetch "include/relational_field_core.h" "$tmp/relational_field_core.h"
fetch "LICENSE.md" "$tmp/LICENSE.md"
mkdir "$tmp/licenses"
for notice in README.md Python-macos-LICENSE.txt Python-linux-LICENSE.txt PyInstaller-COPYING.txt \
  OpenSSL-LICENSE.txt mpdecimal-COPYRIGHT.txt zstd-LICENSE.txt xz-COPYING.txt \
  xz-COPYING.0BSD.txt linux-runtime-notices.txt; do
  fetch "third-party/$notice" "$tmp/licenses/$notice"
done
printf '%s\n' "$RFC_PUBKEY" > "$tmp/miulustek-release.pub"
openssl pkey -pubin -in "$tmp/miulustek-release.pub" -outform DER > "$tmp/key.der"
keyhash="$(openssl dgst -sha256 "$tmp/key.der" | awk '{print $NF}')"
log "release public key DER sha256: $keyhash"
libraryhash="$(openssl dgst -sha256 "$tmp/$library" | awk '{print $NF}')"
testerhash="$(openssl dgst -sha256 "$tmp/$tester" | awk '{print $NF}')"
[ "$libraryhash" = "$library_pin" ] || die "Library release checksum mismatch; refusing installation."
[ "$testerhash" = "$tester_pin" ] || die "Tester release checksum mismatch; refusing installation."
openssl dgst -sha256 -verify "$tmp/miulustek-release.pub" \
  -signature "$tmp/$library.sig" "$tmp/$library" >/dev/null 2>&1 \
  || die "Signature verification failed; refusing installation."
openssl dgst -sha256 -verify "$tmp/miulustek-release.pub" \
  -signature "$tmp/$tester.sig" "$tmp/$tester" >/dev/null 2>&1 \
  || die "Tester signature verification failed; refusing installation."
headerhash="$(openssl dgst -sha256 "$tmp/relational_field_core.h" | awk '{print $NF}')"
[ "$headerhash" = "$HEADER_SHA256" ] || die "Header checksum mismatch; refusing installation."
log "library and tester signatures and header checksum verified"

mkdir -p "$PREFIX/bin" "$PREFIX/lib" "$PREFIX/include" "$PREFIX/share/rfc/licenses"
cp "$tmp/LICENSE.md" "$PREFIX/share/rfc/LICENSE.md"
cp "$tmp/licenses/"* "$PREFIX/share/rfc/licenses/"
chmod 644 "$PREFIX/share/rfc/LICENSE.md" "$PREFIX/share/rfc/licenses/"*
cp "$tmp/$tester" "$PREFIX/bin/rrsh-peer"
cp "$tmp/$tester.sig" "$PREFIX/bin/rrsh-peer.sig"
chmod 755 "$PREFIX/bin/rrsh-peer"
chmod 644 "$PREFIX/bin/rrsh-peer.sig"
cp "$tmp/$library" "$PREFIX/lib/$library"
cp "$tmp/$library.sig" "$PREFIX/lib/$library.sig"
cp "$tmp/relational_field_core.h" "$PREFIX/include/relational_field_core.h"
cp "$tmp/miulustek-release.pub" "$PREFIX/share/rfc/miulustek-release.pub"
chmod 644 "$PREFIX/lib/$library" "$PREFIX/lib/$library.sig" \
  "$PREFIX/include/relational_field_core.h" "$PREFIX/share/rfc/miulustek-release.pub"
log "installed library: $PREFIX/lib/$library"
log "installed header: $PREFIX/include/relational_field_core.h"
log "installed connection tester: $PREFIX/bin/rrsh-peer"
log "configure your application's linker and loader for this prefix"
