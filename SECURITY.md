# Security — the claim, and how to break it

`rrsh` ships a specific, falsifiable claim. This document states it precisely, tells you
what a valid break looks like, and gives you a path to report one. **We want the
break.** A working distinguisher is not an attack on us — it is a research result we will
treat as a contribution and act on.

## The claim under test

The `rrsh` transport is a coupling through RRFC (Resolution-Relational Field
Communications). What crosses the wire is a stream of numeric field tuples — roughly
`{channel, mass, steps}` — governed by a shared secret (the *seed*). The claim is:

> **Without the seed, the emitted stream is statistically indistinguishable from chance
> with respect to the session content. Decoding collapses to chance; the emissions do
> not carry recoverable structure about what is being sent.**

This is a **structural** property, not a computational-hardness (cipher) claim. That
matters for how you test it — see below. It has been **demonstrated and reproduced
internally, but not independently verified.** That is exactly why this repository is
public.

## What we do NOT claim

Be precise about the target so a "break" is a real break and not a category error:

- **We do not claim traffic-analysis resistance.** That two endpoints are talking, when,
  how much, and coarse timing/volume are visible to any observer. Recovering *that a
  session happened* or *how large it was* is **not** a break. Recovering *content* — or
  any content-dependent structure the seed was supposed to erase — **is**.
- **We do not claim active-MITM resistance at first contact.** Trust bootstrap is
  out-of-band or TOFU-shaped (see README). Interposing at seed-provisioning time is a
  known limit, not a break of the transport claim.
- **We do not claim "encryption."** RRFC is not a cipher and rests on no
  computational-hardness assumption. "It's not IND-CPA" / "no security proof in model X"
  is a valid *critique of framing*, but the empirical claim above stands or falls on
  measurement, not on fitting a cipher model.

## What a valid break looks like

Anything that extracts, or statistically distinguishes, **content** from the emitted
stream **without the seed**. Concretely, any of:

- A distinguisher that separates two known plaintexts (or plaintext vs. random) from
  their emissions better than chance, at a reported advantage and sample size.
- Recoverable structure in the float stream that correlates with content — distribution
  skew, autocorrelation, spectral lines, inter-burst timing/size that tracks keystroke
  cadence or message boundaries, cross-coupling correlation for couplings sharing a seed.
- Any partial-recovery result: even leaking *bits* about content from emissions alone is
  a finding we want.

The right tools are exactly the black-box ones: capture the wire and throw the standard
batteries at it — entropy/min-entropy estimates, autocorrelation, spectral analysis,
NIST STS / dieharder / PractRand, distribution fitting, side-channel timing analysis.
You do not need the codec source to test the claim; the emissions are the public surface,
and they are testable by anyone with a capture.

## Honesty about our own evidence

Our internal check to date includes a live capture where a plaintext marker string
appeared **zero times** on the wire (only inert bursts). We are explicit that this is a
**smoke test, not proof** — a plaintext-substring grep is the weakest possible
distinguisher. It rules out the dumbest failure, nothing more. The statistical batteries
above are the real test, and running them is precisely the scrutiny this repo invites.

## How to report

- **Preferred:** open a GitHub issue with your method, sample sizes, and reproduction
  steps. Public findings are welcome — we are not trying to bury them.
- **Sensitive findings** (e.g. a recovery technique you'd rather coordinate on):
  email **security@phic.online** — replace with your real contact before publishing —
  with enough detail to reproduce. We'll acknowledge and work it with you.

When you report, tell us: OS/arch, `rrsh` binary version (`rrsh --version`), the capture
or generator, the distinguisher, and the measured advantage vs. chance. That's what turns
a claim into a result — in either direction.

## Signature verification

Every binary is signed against the MiulusTek release key (public key + certificate under
[`signing/`](signing/)). Verify before trusting a download:

```sh
openssl dgst -sha256 -verify signing/miulustek-release.pub \
  -signature bin/rrsh-linux-x86_64.sig bin/rrsh-linux-x86_64
# → Verified OK
```

A verification failure — or a signature that doesn't chain to the published key — is
itself a report-worthy finding.
