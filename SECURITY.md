# Security and evaluation scope

Updated 2026-11-01 for the signed RRSH 2.1.0 evaluation release. The client/daemon
supports bounded allowlisted exec and small file operations through a native
binary32 application content stream. It does not provide established remote peer
authentication, confidentiality, freshness or production security admission.

## Authority and operating limits

The daemon checks an operator-configured exact argv allowlist, capability,
expiry and byte budgets at the host operation. `research_authority` grants local
experimental permission; it does not identify or authenticate a network peer.
Anyone who obtains matching pairing material can prepare corresponding endpoint
state. A successful exchange or wrong-state refusal is not an identity proof.

Each direction has a hard cumulative 64-event ceiling including framing and
idles. Earlier native resource refusal is possible. No reset/reseed, raw content
fallback or indefinite-stream continuation is provided. There is no interactive
shell/PTY, forwarding, resume, autonomous transport deadline or process timeout.
Use external watchdogs, unprivileged accounts, synthetic data and isolated tests.

Linux upload checks single-component names, confines operations to a supplied
root and requires unnamed atomic publication without overwrite. The macOS smoke
test confirms upload refusal with `UnnamedAtomicRequired`, leaving no published
destination. Download and allowlisted exec pass on both tested platforms.
Successful macOS upload and broader platform/filesystem combinations are not qualified.

Both endpoints receive matching 32-byte private bootstrap input through local
stdin. Ordinary pairing is on site; the application provides no remote pairing
exchange. Do not put seeds into command arguments, retained files, logs, chat or
application traffic. Controlled research used separately authorized administrative
provisioning where needed; that does not establish physical pairing or RRSH
transport authentication. Owned-buffer wiping does not establish OS/UI/backup
erasure. Surviving private field state remains sensitive. Local float captures
also belong to the observer/security assessment.

## Evidence and observer limits

The [validation record](rfc-2.1.0/validation.json) covers bounded Linux
qualification and the narrower macOS release smoke checks. Linux passes 83
native tests, 256/256 octets across 16 fresh private contexts and eight RRSH
application cases with complete TCP/endpoint capture agreement. macOS passes
five local release checks after a clock-portability correction. Passing those
checks establishes their exercised functional behavior.

[Research status](RESEARCH_STATUS.md) records the separate private-field attack
study, partial-bit/relation scores, public-root disclosure and finite VM-LAN
speed result. Zero full bytes recovered by one bounded private-state fitting
algorithm and zero bytes released by 40 wrong-state attempts do not establish
confidentiality or entropy. The earlier public-root fixture discloses both
complete key payloads and accepts full-key substitution and replay. Those
results do not become a private-field security guarantee when the preparation
changes. No private-field durable-throughput figure is claimed for this release.

For the primary confidentiality assessment, give an independent observer public
implementation knowledge and the complete accessible recording, including setup,
identifiers, content words, headers, ordering, lengths, timing and closure.
Withhold private seeds and endpoint state; use fresh private contexts rather
than a fixed seed embedded in a public harness. Public-code access is the
assessment model; implementation source/specifications are not distributed here.

Score full content, partial bits, relationships, state information and metadata
separately. Identify known/chosen-input and seed-compromise access as separate
cases. The current private-field fitting algorithm uses a numeric projection;
its unsuccessful full-byte recovery does not settle timing or stronger
complete-view attacks. Numeric ambiguity is not a calibrated advantage bound.

Float serialization alone does not show that emissions are nonreferential,
non-ciphertext or confidential. The design targets no content ciphertext, no
plaintext except necessary float values and no other referential application
wire content. The experimental transform and whole TCP-envelope classification
remain unresolved. Do not claim reviewed cryptographic security, meaningless
recordings, harvest resistance, forward secrecy or denial-of-service-only risk.

## Artifact provenance

All six 2.1.0 executables and `rfc-2.1.0/manifest.json` have detached RSA2048
PKCS#1 v1.5 SHA-256 signatures made with the pinned MiulusTek release key in
YubiKey PIV slot 9a. Verify the manifest and every executable before use using
the [main guide](README.md). Establish key trust independently; the accompanying
certificate identifies the key, but detached-signature verification alone does
not validate a certificate chain. Signing establishes provenance and integrity
of signed bytes, not their behavior or security.

The signed manifest pins the release binaries, validation record and listed
documentation. `SHA256SUMS` is an additional distribution consistency check; it
is not separately hardware-signed. macOS linker ad-hoc code-signature integrity
was checked, but Apple Developer ID notarization is not provided.

The old `install.sh` installs RFC 1.0.1 libraries and tester 0.3.3 only. It pins
that older release key and artifact/header hashes; it does not install 2.1.0 or
certify the newer binaries. See the [historical guide](LEGACY_1_0_1.md) and
[historical security record](LEGACY_SECURITY.md).

## Preserved historical findings

The 2026-10-03 restoration record found seedless recovery of six bits per byte
in a 165-byte server message, including 128 synthetic stdout bytes, from an older
Linux RRSH artifact (`80894fc4206df111482fe1f81d8395c10632e4815fe928c4ac76fdf094f2fc09`).
This is a scoped partial-content leak in that artifact, not a measurement of the
2.1.0 private-field release. Replacing a binary does not erase the failure or
establish that the successor meets confidentiality requirements.

Older paired-tester splice, challenge, continuation and observer findings remain
in [LEGACY_SECURITY.md](LEGACY_SECURITY.md). They concern that tester and do not
supply authentication claims for the 2.1.0 client/daemon.

## Report findings

Open an issue here for public findings. For sensitive reports, email
**support@miulustek.com**. Include artifact/version/platform and SHA-256, the
exact evaluated boundary, inputs/reproduction, recording scope, observer access,
expected/observed behavior, trial count and the declared recovery/advantage
measure. For signature failures include artifact, signature and key identities.
Do not include real seeds, grants, signing PINs or unrelated private data.
