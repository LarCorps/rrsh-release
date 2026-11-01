# Historical RFC 1.0.1 libraries and paired tester 0.3.3

These retained artifacts were released on 2026-10-07. For the current RRSH
client/daemon, use [the main guide](README.md). All results below concern the
older artifacts; they do not describe RRSH 2.1.0.

This repository distributes signed native **Relational Field Core (RFC)
1.0.1** libraries, derived from **Librarian ABI 1.14.0**, for evaluation and
integration. The core owns field creation, profile input, reaction measurement,
candidate notebooks and local binary snapshots.

These libraries replace the previous RRSH command-line binaries here. They are
loaded through a C API; they are not shell clients or daemons. The previous
`rrsh`, `rrshd`, `rrsh-cp` and `rrsh-keygen` commands are not included.
The accompanying `rrsh-peer` executable bundles this core for a synthetic
paired connection test. It provides local pairing setup and host/connect
commands; it grants no remote execution, file or forwarding capability.

This is a research profile. Signing establishes artifact provenance, not
confidentiality, complete-wire compliance or production readiness. See
[SECURITY.md](SECURITY.md) for evidence limits and reporting, and
[LICENSE.md](LICENSE.md) for distribution terms and
[third-party notices](third-party/README.md) for bundled runtime licenses.

For an actual two-device connection alongside SSH, follow the
[pairing and host/connect instructions](ENDPOINT_TESTING.md). The tester checks
native private-field correspondence. Authentication security and semantic
non-referentiality remain unestablished.

## Artifacts

| Platform | Native library | Signature | Requirement |
| --- | --- | --- | --- |
| Linux x86_64 | [librelational_field_core_1_0_1.so](bin/x86_64-linux/librelational_field_core_1_0_1.so) | [.sig](bin/x86_64-linux/librelational_field_core_1_0_1.so.sig) | glibc 2.28 or later |
| macOS Apple Silicon | [librelational_field_core_1_0_1.dylib](bin/aarch64-macos/librelational_field_core_1_0_1.dylib) | [.sig](bin/aarch64-macos/librelational_field_core_1_0_1.dylib.sig) | arm64 / aarch64 |

The standalone tester is available for [Linux x86_64](bin/x86_64-linux/rrsh-peer-x86_64-linux)
([signature](bin/x86_64-linux/rrsh-peer-x86_64-linux.sig)) and
[macOS Apple Silicon](bin/aarch64-macos/rrsh-peer-aarch64-macos)
([signature](bin/aarch64-macos/rrsh-peer-aarch64-macos.sig)). It includes the
unchanged hash-pinned RFC core and a bundled Python runtime: no system Python
is required. The Linux tester requires glibc 2.31 or later; the standalone core
requires 2.28. The macOS tester requires macOS 26 or later.
[Tester manifest](peer-release-manifest.json) records build/source identities.

Linux arm64, Intel macOS and Windows binaries are not included in this update.
The macOS library has a detached release signature; Apple Developer ID signing
and notarization are not provided.

The [C header](include/relational_field_core.h),
[release manifest](release-manifest.json), [checksums](SHA256SUMS),
[public key](signing/miulustek-release.pub) and
[certificate](signing/miulustek-release-9a.crt) accompany the libraries.
Checksums and the manifest describe the artifacts; the detached signatures
provide the authenticity check.

## Verify before loading

From a checkout, verify the library for your platform:

```sh
# Linux
openssl dgst -sha256 -verify signing/miulustek-release.pub \
  -signature bin/x86_64-linux/librelational_field_core_1_0_1.so.sig \
  bin/x86_64-linux/librelational_field_core_1_0_1.so

# macOS
openssl dgst -sha256 -verify signing/miulustek-release.pub \
  -signature bin/aarch64-macos/librelational_field_core_1_0_1.dylib.sig \
  bin/aarch64-macos/librelational_field_core_1_0_1.dylib
```

Verify the tester before executing it as well:

```sh
# Linux; on macOS use aarch64-macos/rrsh-peer-aarch64-macos instead.
openssl dgst -sha256 -verify signing/miulustek-release.pub \
  -signature bin/x86_64-linux/rrsh-peer-x86_64-linux.sig \
  bin/x86_64-linux/rrsh-peer-x86_64-linux
```

Each successful check prints `Verified OK`. The signatures use RSA-2048,
PKCS#1 v1.5 and SHA-256 with the existing MiulusTek release key in YubiKey PIV
slot 9a. Establish trust in the public key independently: an attacker who can
replace both a download and your trust key can substitute a different signed
artifact. The installer pins this key and prints its DER SHA-256 fingerprint.

## Install the library, header and connection tester

From this checkout:

```sh
sh install.sh
```

The installer stages the supported platform's library, tester, signatures and
header, verifies against its pinned release key, and checks both artifacts and
the header against their pinned SHA-256 identities before installing anything.
It requires OpenSSL and does not execute downloaded artifacts during installation.

Default layout:

```text
~/.local/share/relational-field-core/1.0.1/
  bin/rrsh-peer
  bin/rrsh-peer.sig
  lib/librelational_field_core_1_0_1.so     # Linux; .dylib on macOS
  lib/librelational_field_core_1_0_1.so.sig
  include/relational_field_core.h
  share/rfc/miulustek-release.pub
  share/rfc/LICENSE.md
  share/rfc/licenses/                       # bundled runtime notices
```

To select another checkout, host or prefix:

```sh
RFC_BASEURL=/path/to/rrsh-release RFC_PREFIX=/path/to/rfc sh install.sh

# Save and inspect the installer before running it.
base=https://raw.githubusercontent.com/LarCorps/rrsh-release/main
curl -fsSL "$base/install.sh" -o install-rfc.sh
RFC_BASEURL="$base" sh install-rfc.sh
```

The remote example targets the historical artifacts in this repository. It does not update `phic.online` or any other hosted download.

`RFC_BASEURL` selects a local directory or HTTP(S) repository root.
`RFC_PREFIX` selects the installation prefix. The old `RRSH_BIN` and
`RRSH_NO_VERIFY` behavior is retired. The tester is installed as `bin/rrsh-peer`;
no services are installed.
Remove the selected RFC prefix to uninstall after checking that applications
no longer use it. Existing RRSH installations are separate and are not
upgraded by this installer.

## Integrate through the C API

Include `relational_field_core.h` and link or dynamically load the matching
library. The linker name is `relational_field_core_1_0_1`. Configure your
application's loader search path for the installed library. The macOS install
name is `@rpath/librelational_field_core_1_0_1.dylib`.
No Python interpreter is required by the native core.

```c
#include "relational_field_core.h"

int main(void) {
    RfcCore *core = rfc_field_create(16);
    if (!core) return 1;
    RfcNotebookRow rows[17];
    int32_t count = rfc_notebook(core, 16, rows, 17);
    librarian_destroy(core);
    return count == 17 ? 0 : 1;
}
```

Supported field sizes are 16 and 32. A notebook contains the no-input candidate
(`-1`), then every site candidate, giving 17 or 33 rows. Each row has a 40-byte
C layout. Reaction bits represent a binary32 value; post-state hashes are local
diagnostics. The header documents buffer queries, refusal results and sizing.

Handles belong to their creating library and must be destroyed through that
same library. Do not mutate a source core concurrently with a notebook call.
The inherited ownership/step APIs are `librarian_destroy` and `librarian_step`.
`rfc_version_*` reports 1.0.1; `librarian_version_*` reports upstream ABI 1.14.0.
This profile is not full legacy Librarian compatibility.

Active snapshots use typed local binary state with an `RFCB` schema-1 header.
They are build-bound validation data, not a cross-platform persistence or peer
state interchange format. There is no binary snapshot import API. Legacy JSON
serialization, deserialization and metabolic output refuse in this profile.
Identity text remains available locally. Snapshots, notebook rows and hashes
do not define an application wire protocol.

## Build and verification record

Built on 2026-10-07 from RRSH `main` at
`26f389d081a42bac764b256fb0fe469eb010b98a`, using unchanged RFC 1.0.1 sources
and Zig 0.15.2, `ReleaseFast`, with debug symbols stripped. Binary-state,
instrumentation and passive-event omission options are enabled. The macOS SDK
was 15.4; Linux targets glibc 2.28.

These are new platform builds, not replicas of the earlier Windows artifact
recorded with Zig `0.16.0-dev.2349+204fa8959`. The
[manifest](release-manifest.json) records source, compiler, header, library,
signature and certificate identities.

The native smoke check passed on the macOS arm64 host and in an emulated
Linux x86_64 Debian bookworm container: product and upstream versions, the
40-byte row layout, JSON refusal, snapshot schema, candidate ordering,
selected reaction agreement, 16 notebooks across both profile sizes and
native ownership cleanup. Logs: [macOS](verification/macos-smoke.log),
[Linux](verification/linux-smoke.log). Both copied signatures were verified
independently with OpenSSL.

These native API checks do not test a complete RRSH transport, authentication,
PTY, file copy, long-session behavior or confidentiality. The previous full
RRSH artifacts remain historical evidence in Git history; their behavior
must not be attributed to the current distribution.

Tester 0.3.3 was frozen separately with PyInstaller 6.22.3, using Python 3.14
on macOS and Python 3.12 on Debian bullseye for Linux. The unchanged core is
bundled as a local compressed asset, restored and hash-verified before load
to preserve its signed byte identity. Actual frozen setup and
connection checks, capture comparisons and failed-gate limits are documented
in [ENDPOINT_TESTING.md](ENDPOINT_TESTING.md) and the
[readiness record](verification/peer-readiness.json).

The final installer passed local-checkout and HTTP staging checks on macOS,
including refusal of modified tester bytes, tester/core signatures and the C
header before any prefix was created. See
[installer verification](verification/peer-installer.json).

The Linux installer also passed in an emulated Debian bookworm container,
including the installed tester's version and detached-signature verification:
[Linux installer log](verification/peer-linux-install.log). A bullseye package
mirror failure occurred before the initial installer attempt could run; paired
binary runtime checks on bullseye are separate from this setup failure.
