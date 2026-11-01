# RRSH 2.1.0 experimental binaries

Updated 2026-11-01. RRSH 2.1.0 provides a bounded client and single-use daemon
for allowlisted exec and small file operations. Linux x86_64 and macOS Apple
Silicon builds are available, with detached MiulusTek YubiKey signatures.
This is an experimental evaluation release. Authentication, confidentiality and
production readiness remain unestablished.

## Downloads and platform behavior

Download all three executables for your platform, with their `.sig` files:

| Platform | Client / daemon | Required core | Local API checker | Release validation |
| --- | --- | --- | --- | --- |
| Linux x86_64 | [rrsh-rfc21-experimental](rfc-2.1.0/linux-x86_64/rrsh-rfc21-experimental) | [librarian-rfc21-core](rfc-2.1.0/linux-x86_64/librarian-rfc21-core) | [librarian-rfc21-check](rfc-2.1.0/linux-x86_64/librarian-rfc21-check) | Full bounded Linux qualification |
| macOS Apple Silicon | [rrsh-rfc21-experimental](rfc-2.1.0/macos-aarch64/rrsh-rfc21-experimental) | [librarian-rfc21-core](rfc-2.1.0/macos-aarch64/librarian-rfc21-core) | [librarian-rfc21-check](rfc-2.1.0/macos-aarch64/librarian-rfc21-check) | Five local release smoke checks on macOS 26.6.2 |

Linux exec, upload and download pass the bounded application checks. macOS exec,
command denial and download pass; upload safely refuses with
`UnnamedAtomicRequired` on the tested filesystem. No weaker publication fallback
is provided. macOS upload success is not qualified.

Linux links to host glibc, with required symbol versions through 2.28. macOS is
arm64 with a declared minimum OS of 13.0; runtime testing covers 26.6.2 only.
Windows, Linux arm64 and Intel macOS builds are not included. The binaries do
not require Python. Apple Developer ID notarization is not provided.

## Verify the download

From a checkout, select the platform and verify the manifest and all executables:

```sh
platform=linux-x86_64  # use macos-aarch64 on Apple Silicon
openssl dgst -sha256 -verify signing/miulustek-release.pub \
  -signature rfc-2.1.0/manifest.json.sig rfc-2.1.0/manifest.json
for name in rrsh-rfc21-experimental librarian-rfc21-core librarian-rfc21-check; do
  openssl dgst -sha256 -verify signing/miulustek-release.pub \
    -signature "rfc-2.1.0/$platform/$name.sig" "rfc-2.1.0/$platform/$name" || exit 1
done
```

Every check must print `Verified OK`. Establish trust in the
[public key](signing/miulustek-release.pub) independently. Signatures use
RSA2048 PKCS#1 v1.5 with SHA-256, with the private key held in YubiKey PIV slot
9a. Signing establishes provenance and integrity of signed bytes.

The [signed manifest](rfc-2.1.0/manifest.json) pins executable and documentation
hashes. [Validation records](rfc-2.1.0/validation.json) describe the tested scopes;
[SHA256SUMS](SHA256SUMS) covers distribution files. Checksums alone are not an
authenticity check.

## Run and evaluate

Follow the [2.1.0 operating guide](rfc-2.1.0/README.md) for exact arguments,
local 32-byte pairing input, grants, captures and capacity limits. Both endpoints
must use matching 2.1.0 binaries. Set `RRSH_RFC21_CORE` to the absolute core path.

Each direction has a hard cumulative ceiling of 64 native events, including
framing and genuine idle events. The 59-byte single-frame payload ceiling is
before application-schema and session costs. Earlier native resource refusal
is possible; 64 events are not guaranteed usable capacity. There is no
reset/reseed or indefinite-stream fallback. The daemon has no autonomous
transport/process deadline; use an external watchdog for evaluation.

There is no interactive shell/PTY, forwarding, resume or authenticated peer
identity. A local research grant authorizes an operation without authenticating
the network peer. Use synthetic data, unprivileged accounts and isolated test
environments. See [security and evidence limits](SECURITY.md).

## Latest evidence

The Linux build passes 83 native tests, all 256 octets across 16 fresh private
contexts, 320 events, 44,160 independent source-coordinate checks, two short
full receiver audits and eight RRSH process cases. Complete TCP recordings
reconcile with both endpoints' native-float captures. The paired API check
covers 32 bytes over 34 receiver events, with source-only continuation to 64.

The corrected macOS build passes the local core API, exec, command denial,
download and safe upload-refusal checks. All four application sessions have
matching paired endpoint captures. A startup clock-portability defect was fixed
before publication; the manifest records that macOS overlay separately from the
unchanged qualified Linux executable identities.

[Research status](RESEARCH_STATUS.md) separates these release checks from the
private-field observer study and the earlier public-root VM-LAN speed result.
The measured 4.153141 durable B/s belongs to that earlier public-root experiment;
it is not a throughput claim for this private-field release.

## Retained older artifacts

RFC 1.0.1 libraries, their C header, and the 0.3.3 paired connection tester remain
available. Their [historical guide](LEGACY_1_0_1.md),
[tester instructions](ENDPOINT_TESTING.md) and manifests describe their own
interfaces and evidence. The existing `install.sh` installs those older artifacts;
it does not install or upgrade RRSH 2.1.0. The earlier C library API and tester
pairing commands do not apply to the new client/daemon.

See [license and distribution terms](LICENSE.md) and
[third-party notices](third-party/README.md).
