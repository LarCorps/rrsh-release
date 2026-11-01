# RRSH 2.1.0 experimental evaluation binaries

Built from private source revision `00ff0a448a3da594cbbe51a540f269f3b10140c7`,
with the pinned Zig 0.16.0 toolchain, ReleaseSafe, on CPU VM105.
The macOS build includes a clock-portability overlay; Linux retains the exact
qualified executables. The manifest records both source identities.
Only executable artifacts, hashes, licenses and public-facing instructions are distributed.

Each platform directory contains:

- `rrsh-rfc21-experimental`: bounded client and single-use daemon for allowlisted exec and small file operations.
- `librarian-rfc21-core`: required native core process; `--version` prints `2.1.0`.
- `librarian-rfc21-check`: paired local API evaluation utility; reads exactly 32 private bootstrap bytes from stdin.

Detached `.sig` files use the existing MiulusTek YubiKey PIV 9a key,
RSA2048 PKCS#1 v1.5 with SHA-256. These establish artifact provenance.
They do not establish authentication, confidentiality, reviewed cryptographic
security, complete-wire compliance or production readiness. macOS signatures
are detached release signatures; Apple Developer ID notarization is not provided.

## Verify before running

From the repository root, verify the signed manifest, then each binary:

```sh
openssl dgst -sha256 -verify signing/miulustek-release.pub \
  -signature rfc-2.1.0/manifest.json.sig rfc-2.1.0/manifest.json
openssl dgst -sha256 -verify signing/miulustek-release.pub \
  -signature rfc-2.1.0/linux-x86_64/rrsh-rfc21-experimental.sig \
  rfc-2.1.0/linux-x86_64/rrsh-rfc21-experimental
```

Repeat for both core executables. For macOS, use `macos-aarch64` in place of
`linux-x86_64`. Check the public-key fingerprint through a trusted independent
channel. Downloading a replacement public key alongside a binary alone does not
establish trust. `SHA256SUMS` covers the complete distribution.

## Run in an isolated evaluation environment

Use matching 2.1.0 binaries on both endpoints. Make the files executable if needed.
Set `RRSH_RFC21_CORE` to the absolute path of `librarian-rfc21-core` in the
selected platform directory. No Python runtime is required by the executables. Linux links dynamically to the
host glibc (symbol requirements through 2.28); qualification is on VM105 Linux.
The prior `install.sh` installs the historical paired tester, not these binaries.

```text
rrsh-rfc21-experimental daemon ADDRESS PORT CAPTURE_PREFIX COPY_ROOT GRANT_JSON
rrsh-rfc21-experimental client ADDRESS PORT CAPTURE_PREFIX exec PROGRAM ARG...
rrsh-rfc21-experimental client ADDRESS PORT CAPTURE_PREFIX put NAME INPUT_FILE
rrsh-rfc21-experimental client ADDRESS PORT CAPTURE_PREFIX get NAME
```

Both processes read exactly 32 raw matching private bootstrap bytes from local
stdin. Pair on site through local scanning/typing or direct local provisioning;
do not send bootstrap bytes over the RRSH connection. Use fresh synthetic pairing
material for each evaluation, keep it out of argv, retained files and logs, and
close stdin after provisioning. The binary provides no remote pairing service.
Owned-buffer wiping is not a guarantee of erasing OS, UI or backup copies.

The daemon requires an operator-controlled copy directory and a local JSON grant,
for example:

```json
{"research_authority":true,"argv":["/usr/bin/printf","ok"],"max_bytes":16,"ttl_seconds":300,"copy":false}
```

The complete requested argv must match exactly. `research_authority` permits a
local research operation; it does not authenticate a network peer. Enable copy
only for a controlled directory and synthetic files. Linux upload requires unnamed
atomic publication and refuses overwrite. A platform/filesystem unable to supply
the required primitive must refuse upload; no weaker fallback is provided.

Capture prefixes must be fresh. Local `.tx.f32` and `.rx.f32` files record native
content words and should be treated as sensitive evaluation records. `get` writes
file bytes to stdout. Exec returns the remote process status. Use an external
watchdog: no autonomous process/transport deadline is provided.

macOS binaries are arm64 Mach-O files linked to system libSystem, with a declared
minimum OS of 13.0. Static code-signature integrity checks pass (linker ad-hoc
signatures); see the manifest for runtime-test status. This metadata alone does
not establish compatibility on every supported OS version.

## Capacity and evidence limits

The application content stream uses little-endian native binary32 observations,
four bytes per event. Both endpoints retain private field state. Each direction
has a hard cumulative ceiling of 64 events, including framing and genuine idle
events. A single frame can hold at most 59 payload bytes before other session
costs; exec/copy schemas consume part of that budget. Earlier resource refusal is
possible. The paired 64-event fixture failed; a separate unchanged-binary
inspection reached native ResourceLimit at receiver index 62. This is not a
universal safe horizon. There is no reset, reseed, hopping or indefinite-stream
fallback.

Linux qualification: 83 native tests; all 256 octets over 16 fresh private contexts;
320 events; 44,160 independently checked source coordinates; two short full receiver
audits; paired API checks over 32 bytes/34 events with source-only continuation to
64; eight bounded RRSH process cases and complete TCP/endpoint capture agreement.
These are finite functional results. They do not establish a private throughput
rate, remote identity/freshness, confidentiality or a semantic privacy bound.

TCP endpoints, setup, ordering, timing, lengths and closure remain observable.
Float serialization alone does not establish that application content or the
whole transport meets the intended wire rules. Mechanism classification remains
unresolved under the scoped experimental transport authorization. A wrong-state
refusal or an unsuccessful bounded observer is not proof of authentication or
privacy. Interactive shell/PTY, forwarding, resume, unbounded sessions and
production admission are absent. Use synthetic data and unprivileged accounts.

macOS release smoke checks on macOS 26.6.2 pass the paired core API, bounded
exec, command denial, copy download and safe upload refusal. The initial
unpatched build aborted at startup due to incorrect platform clock selection;
it was replaced before publication. These are local release checks, not the
complete Linux numerical/TCP qualification on another OS.

See the platform-specific validation in `manifest.json`, the repository
`SECURITY.md`, `LICENSE.md` and `third-party/README.md`.
