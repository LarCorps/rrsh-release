# Evidence status — 2026-11-01

This page summarizes bounded results from the private RRSH research repository
at base revision `00ff0a448a3da594cbbe51a540f269f3b10140c7`, plus the corrected
macOS release checks. It publishes results and limits, without implementation
source, specifications, private seeds or endpoint state. Different experiments
have different access models and boundaries; their numbers are kept separate.

## Shipped 2.1.0 functionality

| Check | Result and scope |
| --- | --- |
| Linux native tests | 83 pass |
| Private correspondence | All 256 octets across 16 fresh contexts; 320 events |
| Independent source checks | 44,160 coordinates, plus routing/cells/clocks |
| Full receiver audits | Two short private audits |
| Paired process API | 32 bytes across 34 receiver events; source continues alone to 64 |
| Bounded Linux RRSH | Eight exec, binary-output, denial, copy and limit cases |
| Linux complete recording | TCP capture agrees with both endpoint content captures |
| macOS release smoke | Core API, exec, command denial, download and upload refusal pass |
| macOS endpoint recordings | All four application sessions agree bidirectionally |

The [signed manifest](rfc-2.1.0/manifest.json) pins the shipped artifacts;
[validation.json](rfc-2.1.0/validation.json) records the platform results. macOS
26.6.2 was tested. The Mac build includes a clock-portability overlay after the
initial build aborted at startup. The initial build was not published. macOS
upload refuses safely on the tested filesystem; successful upload is not qualified.

64 is a hard per-direction event ceiling including framing/idles, not guaranteed
receiver capacity. The original paired 64-event API fixture failed; a separate
unchanged-binary diagnosis reached native ResourceLimit at receiver index 62.
The successful paired 34-event check does not establish a universal shorter
safe horizon. No unbounded streaming or continuation fallback was added.

## Separate private-field study

The 2026-11-01 study titled “Private fields on the shared-memo core” predates the
release integration. Corresponding private receivers recover 128/128 intended
bytes across four private cases. Two public controls bring the six-stream total
to 192 correctly released bytes, 216 actual native measurements and 24 genuine
idles. Native content occupies 864 octets, or 4.5 octets per intended byte before
TCP/IP/link overhead. The complete bidirectional loopback capture agrees with
the emitted native words. These totals are not a new throughput measurement.

The bounded primary observer receives public code and accessible recordings,
without private seeds or endpoint state. Its current fitting algorithm uses the
numeric projection and does not exploit timing. At zero disclosed input bytes,
it recovers 0/128 full bytes, but partial-bit and relationship scores must also
be retained:

| Disclosed input per private stream | Unknown bytes across four streams | Preferred correct bytes | Preferred correct bits | Correct adjacent low-bit XORs |
| --- | ---: | ---: | ---: | ---: |
| 0 bytes | 128 | 0 | 505 / 1,024 | 75 / 124 |
| 1 byte | 124 | 1 | 513 / 992 | 65 / 120 |
| 16 bytes | 64 | 1 | 270 / 512 | 35 / 60 |

The one-byte and 16-byte disclosures are separate known-input attacks. Fixed
wrong-state decoders release zero bytes across 40 attempts. Neither that refusal
nor zero full-byte recovery by one bounded observer is a confidentiality proof.
The small correlated sample supplies no calibrated advantage, entropy bound or
probability estimate. Partial-bit and relationship scores are unresolved evidence,
without a claim of statistical significance or absence of leakage.

Numeric counterfactual sources match 144 native words across four private
trajectories. None of the four alternative whole payloads satisfies the tested
necessary key-format constraints. Numeric-view matches do not establish matching
timing/full-network views, independently selectable alternative meanings for
every byte, or equal posterior probabilities. Complete-view attacks, structured
priors and identity/freshness remain open.

## Separate public-root speed and adversarial study

The 2026-10-31 study titled “Shared-memo online speed and adversarial results”
compares finite CPU VM105-to-VM104 sessions with publicly corresponding roots:

| Receiver | Correct durable bytes | Complete online time | Durable rate | Conservative setup-inclusive rate |
| --- | ---: | ---: | ---: | ---: |
| Original adaptive | 76 | 30.089264 s | 2.525818 B/s | 2.443313 B/s |
| Shared memo prefixes | 76 | 18.299403 s | 4.153141 B/s | 3.935109 B/s |

The shared candidate reduces pooled online duration by 39.18%, with six wins in
six matched pairs. “Durable” here means disk-backed file and parent-directory
fsync before receiver EOF; it does not establish restart or power-loss recovery.
The denominator includes online completion and the complete TCP capture span.
This is a finite VM-LAN public-root result, not sustained/WAN performance or a
private-field RRSH 2.1.0 rate. The private-field release has no newly qualified
durable throughput figure.

The subsequent public-root observer recovers both complete fresh 32-byte public
key payloads: 64/64 bytes. Attacker-key substitution and honest-key replay are
accepted by that fixture. A first-word least-significant-bit mutation still
releases the original complete payload. All 15 active candidate/control cases
match prior semantic results and exit/resource categories; this is regression
fidelity, not a finding that all attacks were rejected. Public-root disclosure
and missing identity/freshness binding are preserved alongside the speed result.
These outcomes do not by themselves measure private-genesis confidentiality.

## Claims that remain open

Functional recovery, a float-only application content stream and release
signatures do not establish confidentiality, remote authentication, freshness,
cryptographic full-transcript integrity or complete-wire compliance. TCP setup,
endpoints, lengths, ordering, timing and closure remain observable. Mechanism and
whole-envelope classification remain unresolved under the experimental transport
authorization. See [SECURITY.md](SECURITY.md).

The current release does not qualify physical pairing, loss/restart recovery,
WAN operation, indefinite sessions, interactive PTY/shell, forwarding or
production admission. The next research priorities are continuing-session
qualification, private complete-cost measurement, partial/relation and
complete-view observer assessment, with identity/freshness handled explicitly.
