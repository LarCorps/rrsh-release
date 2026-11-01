# Security and evaluation scope

The latest distribution adds [RRSH 2.1.0](rfc-2.1.0/README.md), a bounded
experimental client/daemon and native core. It supports allowlisted exec and small
file operations; local grant authority does not authenticate a peer. The native
binary32 content stream and private preparation do not establish confidentiality,
mechanism classification or complete-wire compliance. A hard 64-event ceiling
includes framing/idles, and earlier resource refusal is possible. No reset/reseed
fallback, indefinite shell, PTY, forwarding or production admission is provided.
The signed manifest records Linux qualification and the macOS runtime-test status.
A YubiKey detached signature establishes provenance only; macOS Developer ID
notarization is not provided. Evaluate with synthetic data in isolated environments.

The following evidence and limits describe the retained historical artifacts.


The current distribution contains Relational Field Core 1.0.1 research libraries,
derived from Librarian ABI 1.14.0. It also includes `rrsh-peer 0.3.3`, a connection-only research tester with
local pairing setup and a TCP host/connect probe. It grants no remote commands,
files or forwarding. Integrating applications own additional capability boundaries.

## Current evidence

The shipped libraries passed bounded native API checks. The
[release manifest](release-manifest.json) pins their source, compiler, artifacts
and verification records. These checks establish the exercised API behavior,
not a reviewed confidentiality guarantee or production admission.

Float-valued output, successful recovery and failure of one observer do not
establish that emissions reveal nothing about content. Confidentiality,
mechanism classification and complete-wire compliance remain unestablished
for an integrating application. Do not describe this release as providing
proven "Structural Privacy," meaningless recordings, harvest resistance or a
relay whose only possible attack is denial of service. This release also does
not establish that a proposed transport is categorically not encryption.

The binding design target is no content ciphertext, no plaintext except
necessary float values, and no other referential information on the application
wire. Packing content into float bits or sending semantic identifiers,
snapshots or state hashes does not meet that target. Packaging a core library
neither implements nor certifies an application protocol meeting it.

## Paired tester scope

The tester sends native measured binary32 observations, without application
headers, peer IDs, state dumps, keyed tags or packed secret bits. Its local
pairing code contains a conventional transcription checksum; neither the code
nor checksum crosses the tested TCP connection. Direct nearby console transfer
is deliberate private provisioning, not NFC/Bluetooth integration. Console
scrollback, copied credentials, local backups and compromised accounts remain
outside the tested credential boundary. Do not transfer the code through SSH,
chat or a relay. File permissions do not establish hardware-backed storage.

The first live candidate admitted a two-session splice: independent directional
fields allowed the two proofs to belong to different sessions. The current
candidate clones only its own native first-proof state into the second phase
and binds continuation to both histories. The tested splice and public/prior
continuation substitutions refused, while genuine paired connections passed.
A legitimate challenge collision was also found; the current source chooses
only measurements unique across all 33 notebook rows. It refuses if fewer than
16 challenge choices remain or a private probe has no unique eligible event.

These bounded tests do not establish unforgeability or a secure authentication
primitive. A recording observer recovered all 64 public challenge choices;
a tested public-bootstrap response predictor matched 0/64 private responses.
Adaptive chosen-challenge/parallel oracles, secret-state inference, effective
response entropy, collisions, side channels and stronger attackers remain open.
The probe has no variable application content, so it does not test content
confidentiality. Semantic non-referentiality and mechanism classification are
unestablished; float serialization alone cannot establish either claim.
All holders of a pairing credential can construct matching native fields. The
tester does not attest individual device identity or bind host permissions.
Transparent forwarding of actual paired endpoints remains possible.

Each host accepts one connection, with a 300-second state-machine deadline and
60-second socket waits. Native calls are not preempted by that deadline.
This is not production denial-of-service resistance.
Local run records include the proposed application stream and timing but not
packet-level TCP/IP captures; an unexpected post-proof trailing byte is rejected
but not included in the persisted stream. Preserve failures when evaluating a
broader observer. Current evidence is summarized in
[verification/peer-readiness.json](verification/peer-readiness.json).

## Historical RRSH findings

The previous full RRSH distribution remains in repository history. The
2026-10-03 restoration record reports seedless recovery of six bits of every
byte in one 165-byte server message, including 128 synthetic stdout bytes,
from a recorded Linux executable's wire. Its binary SHA-256 was
`80894fc4206df111482fe1f81d8395c10632e4815fe928c4ac76fdf094f2fc09`.
This is a scoped partial-content leak, not general full-byte recovery and not
a measurement of these new core libraries.

The owning record is RRSH `docs/PRIMITIVE_RESTORATION.md`, section "Existing
release findings," at source commit
`26f389d081a42bac764b256fb0fe469eb010b98a`. Original captures reside in the
adjacent private PHIc research repository. That finding supersedes the previous
README and security document's categorical unreadability and denial-only claims.
Replacing the artifact does not erase that finding or establish that a future
complete application fixes it.

## Evaluate the complete application

Give the primary observer the public implementation and complete recording at
the claimed boundary: setup, identifiers, headers, values, ordering, timing and
lengths. Withhold private seeds and endpoint state. Use fresh private seeds,
not fixed seeds from a public harness. Allow independent recovery algorithms;
do not restrict the observer to the intended decoder.

Report full-symbol recovery, partial-bit information, repeated-symbol
relationships, state information and metadata separately. Identify additional
known-plaintext, chosen-plaintext or seed-compromise access explicitly.
Seed-holder reconstruction is a separate compromise case. A passing round trip
or absence of a plaintext marker in a capture does not establish privacy.

Snapshots and notebook rows are local diagnostic state. Do not transmit them as
a recovery shortcut or assume snapshot portability across builds. Handles are
owned by their creating library; concurrent source mutation during a notebook
call is unsupported. Applications must provide authorization, input validation,
resource bounds and secure handling of any private state.

## Verify artifact provenance

Every current library and tester has a detached RSA-2048 PKCS#1 v1.5 SHA-256 signature
made with the MiulusTek release key in YubiKey PIV slot 9a. The private key
remains on hardware. See [README.md](README.md) for verification commands.
Establish trust in the [public key](signing/miulustek-release.pub) independently.
The supplied certificate identifies that key; checking a detached signature
does not validate a certificate chain.

The installer pins the key, requires both artifact signatures and pins both artifact and header SHA-256 identities.
There is no verification bypass. Checksums and manifest metadata are not
separately hardware-signed and are not independent authenticity evidence.
The macOS artifact is not Developer ID notarized. A signature establishes
provenance and integrity of signed bytes, not their behavioral security.

## Report findings

Open an issue in this repository for public findings. For sensitive reports,
email **support@miulustek.com**. Include:

- Platform, library filename, SHA-256 and version from `rfc_version_*`.
- Integrating application identity and the exact evaluated boundary.
- Inputs, reproduction code, capture scope and observer access.
- Expected behavior, observed result, trial count and recovery advantage.
- For signature failures, artifact, signature and verification key identities.

Do not include real grants, private seeds, signing PINs or unrelated private
data. API defects, malformed-state behavior, allocation or ownership problems,
signature failures and partial-information findings are relevant. State the
tested scope without generalizing a finite result to every possible observer.
