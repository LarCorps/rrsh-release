# rrsh — Relational Shell

**SSH-shaped remote access, but the session is an RRFC coupling — not an encrypted
byte stream.**

`rrsh` gives you what SSH gives you — an authenticated, confidential interactive
session to a remote machine, plus command execution, file copy, and headless/agent
access — except the session is not a stream of ciphertext. What crosses the wire is a
sequence of structureless float tuples that do not refer to your content at all. The
difference is structural, and it changes the threat model:

> **Against the `rrsh` transport, every attack reduces to denial of service.
> None of them reduce to reading your session.**

That's the claim. It's structural, falsifiable from a traffic capture alone, and **not
yet independently verified** — which is why this repo is public. If you break it, we want
to know: [SECURITY.md](SECURITY.md) states the claim precisely, says what counts as a
break, and tells you where to send it.

```
curl -fsSL https://phic.online/rrsh/install.sh | sh
```

One self-contained, signed binary. Linux and macOS, x86_64 and arm64. Nothing else to
install — the codec is embedded in the binary. See [Install](#install) below for what
the one-liner does and how to verify it yourself.

---

## What it is

`rrsh` is a remote-access tool: shell in, run a command, copy a file, hand a scoped
credential to an agent or a CI job. If you use SSH, the shape is familiar — you mint a
credential, provision it on the host, start a daemon, and connect.

What is different is the transport underneath. A conventional secure shell wraps your
session in a cipher and sends the resulting ciphertext across the network. `rrsh`
instead couples the two endpoints through **RRFC** (Resolution-Relational Field
Communications) — a communications method in which the shared secret (the *seed*)
governs how each side resolves a stream of numeric field values back into meaning.
Without the seed, the stream on the wire is not weakly-encrypted content — it is not
content at all. There is no ciphertext to attack, harvest, or eventually break; there
is a coupling you either participate in or you do not.

If that structural claim holds — and testing it is exactly why this repo is public
([SECURITY.md](SECURITY.md)) — it yields a set of properties a cipher-based transport
does not:

- **Nothing readable on the wire.** An observer records `{channel, mass, steps}` float
  tuples that  carry no recoverable structure about your session. There is
  no ciphertext, so there is no "harvest now, decrypt later."
- **No decodable secret at rest on the server.** Steal the box and you get inert
  state, not a master key that reads captured traffic or impersonates the host to every
  client.
- **A forwarding node cannot read what it forwards.** A relay, bastion, or jump host is
  dumb substrate: it moves floats it cannot interpret. Its entire power over a session
  is denial of service — drop, delay, or flood. It cannot read, forge, or impersonate.

The first property is the load-bearing one, and it is **falsifiable from a traffic
capture alone** — the emissions are the public surface of the claim, testable by anyone
without the codec source. If it fails, the other two fail with it. We invite exactly that
test; see [SECURITY.md](SECURITY.md) for what a valid break looks like and how to report
one.

## rrsh vs SSH

`rrsh` is **not** "SSH but faster," and it is **not** strictly better than SSH. It is
better on one specific axis — the transport can only be *denied*, never *read* — and it
is weaker on another (its confidentiality is a demonstrated *structural* result, not a
decades-reviewed cipher; see [Read this first](#read-this-first-honest-limits)). Pick
per context.

| | SSH | rrsh |
|---|---|---|
| **What's on the wire** | Ciphertext — safe under today's crypto assumptions; attackable if the cipher or an implementation breaks, now or later | Structureless float tuples that don't refer to the content at all — nothing to decrypt |
| **Secret at rest on the server** | Private host key — steal the box, impersonate the host to everyone | No decodable secret at rest; a stolen box yields inert state |
| **Harvest-now, decrypt-later** | A real concern for recorded ciphertext | No ciphertext to harvest — recorded traffic is meaningless |
| **Compromised jump host / bastion** | Can MITM if it holds keys; always sees metadata | Cannot read the session it forwards — DoS only |
| **Worst case for the transport** | Key/cipher compromise → **disclosure** | Link capture / sever / flood → **denial of service, never disclosure** |
| **Trust bootstrap** | TOFU on first connect (a MITM window) | Out-of-band seed (no in-band moment to attack), or bootstrap + in-band rotation over a low-trust channel — TOFU-shaped, forward-secure |
| **Independently reviewed** | ✓ decades of cryptanalysis | Not yet — the structural confidentiality claim is demonstrated but awaits independent scrutiny |
| **Multi-factor / cert chains** | ✓ mature | The seed is the single factor today |

### Capability parity

| Capability | SSH | rrsh |
|---|---|---|
| Interactive shell (PTY) | ✓ | ✓ |
| Non-interactive exec | ✓ | ✓ |
| File copy (scp/sftp) | ✓ | ✓ |
| Jump host / bastion | ✓ (host sees metadata; can MITM if keyed) | ✓ — **and unreadable to the bastion** |
| Agent / headless access | ✓ (`ssh-agent`) | ✓ (`rrshd` holding a scoped seed) |
| Transparent reconnect | needs mosh/autossh | ✓ recoverable coupling |
| Multi-factor / cert auth | ✓ mature | not yet (seed is the single factor) |
| Independently-reviewed transport | ✓ | not yet |

**Reach for rrsh** when forwarding nodes must not be able to read the sessions they
carry, when "no secret at rest on the server" and "no harvest-now-decrypt-later" matter,
or when you want to grant automation a scoped seed instead of a key plus an
`authorized_keys` dance — fleet access, CI, agents, pre-provisioned devices.

**Reach for SSH** when your compliance regime mandates an audited cipher or MFA/cert
chains, when you need a today-independently-reviewed confidentiality layer, or for first
contact with a host where an active MITM is in your threat model and you have no
out-of-band verification. (You can also run `rrsh` *over* or *alongside* SSH to get both
properties at once.)

## Why a single opaque binary

`rrsh` ships as **one self-contained, signed executable** rather than as source or a
package. This is deliberate:

- **The method is proprietary.** RRFC is patent-pending, pre-publication work. The
  binary lets you *run* `rrsh` without shipping the method loose as readable source. The
  RRFC codec and the resolution logic are compiled and embedded inside the executable
  together with a private runtime; nothing readable ships alongside it.
- **One artifact, nothing to assemble.** The codec is embedded, so the target needs
  nothing but the binary itself — no separate library, no interpreter, no package
  install. Download, verify the signature, run.
- **Signed, so the download is verifiable.** Every binary has a detached signature
  against the MiulusTek release key (held in hardware; public key and certificate under
  [`signing/`](signing/)). The installer verifies it before anything runs, so a tampered
  download or a compromised mirror is caught up front.

Closed source and open scrutiny are not in tension here, because the confidentiality
claim is *structural*: it does not rest on the codec being secret. The claim is that the
emissions carry no recoverable content **whether or not** an adversary has the binary —
which means it is testable from a traffic capture alone, and closing the source neither
strengthens nor shields it. The binary protects the *method* (the IP); it does not, and
is not meant to, protect the *sessions* by obscurity. If the emissions leak, the binary
being opaque won't save the claim — which is exactly why we're comfortable publishing it
for people to attack ([SECURITY.md](SECURITY.md)).

## Install

```
curl -fsSL https://phic.online/rrsh/install.sh | sh
```

The installer:

1. Detects your OS/arch and downloads the matching binary (`rrsh-<os>-<arch>`) and its
   detached signature (`.sig`).
2. **Verifies the signature** against the MiulusTek release public key pinned inside the
   script, and prints that key's SHA-256 so you can confirm the trust root. A failed
   verification aborts the install.
3. Installs `rrsh` into `~/.local/bin` and links `rrshd`, `rrsh-cp`, and `rrsh-keygen`
   beside it.

Supported: Linux and macOS, `x86_64` and `aarch64`/`arm64`.

### Verify it yourself

Prefer to inspect before running? Download the binary and signature directly and check
them against the published key:

```sh
base=https://phic.online/rrsh
curl -fSLO "$base/bin/rrsh-linux-x86_64"
curl -fSLO "$base/bin/rrsh-linux-x86_64.sig"

# the release public key is in this repo under signing/
openssl dgst -sha256 -verify signing/miulustek-release.pub \
  -signature rrsh-linux-x86_64.sig rrsh-linux-x86_64
# → "Verified OK"
```

### Install from this repository

The binaries and signatures live under [`bin/`](bin/) and the installer alongside them.
To install straight from a checkout or from the raw repo, point the installer's base URL
at the repo root (the layout is `install.sh` + `bin/<asset>` + `<asset>.sig`):

```sh
# from a local checkout
RRSH_BASEURL="$PWD" sh install.sh

# or from raw GitHub
curl -fsSL https://raw.githubusercontent.com/<owner>/rrsh-release/main/install.sh \
  | RRSH_BASEURL=https://raw.githubusercontent.com/<owner>/rrsh-release/main sh
```

Installer environment variables: `RRSH_BASEURL` (download base), `RRSH_BIN` (install
dir, default `~/.local/bin`), `RRSH_NO_VERIFY=1` (skip signature verification — only if
`openssl` is unavailable; not recommended).

## Usage

The workflow mirrors SSH. You mint a *grant* (the analogue of an SSH keypair), provision
the same grant on the host out of band (the seed **is** the credential — treat grant
files exactly like SSH private keys), start the daemon on the host, and connect from the
client.

```sh
# 1. mint a grant — a seed + address + policy (the ssh-keygen step)
rrsh-keygen mybox --host 10.0.0.5 --port 8022 \
  --allow exec --exec-allowlist uname,uptime

# 2. provision the SAME grant on the host, out of band (the seed IS the credential)
scp ~/.rrsh/grants/mybox.json host:~/.rrsh/grants/mybox.json

# 3. on the host: start the daemon
rrshd --grant mybox

# 4. from the client:
rrsh    mybox -- uname -a      # run a command      (like: ssh host cmd)
rrsh    mybox                  # interactive shell  (like: ssh host)
rrsh-cp mybox ./file           # copy a file        (like: scp file host:)
```

`rrsh-keygen` policy flags scope what a grant may do: `--allow shell,exec,copy` selects
capabilities, and `--exec-allowlist cmd1,cmd2` restricts non-interactive exec to named
commands — useful for handing an agent or a CI job a tightly-scoped credential.

## Read this first (honest limits)

`rrsh` provides **Structural Privacy**, not encryption. It is not a cipher and makes no
computational-hardness claim. Know its bounds before you rely on it:

- **Not yet independently reviewed — this is a claim under test, not a settled result.**
  The confidentiality claim — that decoding collapses to chance without the seed — is a
  *structural* property that has been empirically demonstrated and reproduced internally,
  but not independently verified. Our own strongest public evidence to date is a smoke
  test (a plaintext marker absent from the wire), which we're explicit is *not* proof;
  the real test is the statistical battery an adversary can run on a capture. Because it
  is not a cipher, the bar is not cryptanalysis; it is independent scrutiny of the
  structural claim itself — and we actively invite it ([SECURITY.md](SECURITY.md) states
  the claim precisely and what a valid break looks like). Do not represent `rrsh` as
  "encryption," and do not lean on it as a *guarantee* of secrecy for high-stakes content
  until that review exists. If you need an independently-reviewed confidentiality layer
  against a well-resourced adversary today, use SSH — or run `rrsh` *and* SSH together.
- **Not traffic-hiding.** Content is unreadable, but a relay or observer still sees
  *that* two endpoints are talking, when, and how much. Metadata resistance is a
  separate mechanism, not a free property.
- **First contact is out-of-band or TOFU-shaped — not active-MITM-proof.** Provisioning
  the seed out of band (device setup, fleet tooling, QR) removes the in-band moment a
  MITM could interpose — this is the strongest posture. The low-trust onboarding path
  (share a disposable bootstrap seed, couple, then instantly rotate in-band to a true
  seed) is forward-secure and passive-safe, but like SSH's TOFU it does not defend
  against an attacker online at the rotation instant.
- **The seed is the whole security boundary.** There is no second factor in this
  version. Protect grant files exactly as you would SSH private keys.

## Provenance

`rrsh` is built on **RRFC** (Resolution-Relational Field Communications), the same
substrate behind [PHIc](https://phic.online), a messaging app for text, voice, video,
and files. The primitives that carry a PHIc message carry an `rrsh` shell.

This is early software — a research spike with real, on-device-demonstrated properties
and rough edges. Expect both.

---

*rrsh is Structural Privacy applied to remote access. It is not encryption, and it does
not claim to be.*
