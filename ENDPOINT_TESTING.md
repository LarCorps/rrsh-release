# Two-endpoint testing alongside SSH

`rrsh-peer 0.3.3` runs one paired native connection probe between a separately
started host and client. It bundles RFC 1.0.1 and its runtime, so Python and a
separate core installation are unnecessary. Keep SSH available independently
for ordinary administration. This tester runs no remote commands, shell, file
transfer or forwarding. It is a research candidate, not reviewed authentication.

## Install on both machines

Use the supported package on each endpoint: macOS Apple Silicon or Linux x86_64
with glibc 2.31 or later. From a release checkout:

```sh
sh install.sh
peer="$HOME/.local/share/relational-field-core/1.0.1/bin/rrsh-peer"
"$peer" --version
```

The installer verifies both the native library and tester against its pinned
release key before installing. If using another `RFC_PREFIX`, adjust `peer`.
The macOS tester requires macOS 26 or later and is not Developer ID notarized.
Detached YubiKey signatures establish provenance; they do not replace Apple's
platform approval. Use an appropriate locally approved execution route.

## Pair directly while the devices are nearby

On the host's physical local console:

```sh
"$peer" pair create --file "$HOME/.rrsh-peer/test.seed"
"$peer" pair show --file "$HOME/.rrsh-peer/test.seed"
```

On the client's physical local console:

```sh
"$peer" pair import --file "$HOME/.rrsh-peer/test.seed"
```

Type the displayed `RFC3-...` code into the masked client prompt. This code is
a private credential; everyone holding a copy can construct matching fields.
Transfer it directly between the nearby participating devices. Do not send it
through SSH, chat, email, a relay, or the connection being tested. The manual
console route implements direct nearby provisioning, not NFC/Bluetooth pairing.
Clear the display/scrollback after import and do not retain a screenshot.

Files are created with mode 600, must belong to the current user and must not
be symlinks. Existing files are never overwritten. Use a new filename on both
machines for a new credential. Losing/deleting either copy requires pairing
again; deleting all copies retires that credential. Other copied credentials
remain usable. Pair a separate file for each intended pair of devices.

## Start the host, then connect the client

On the host, replace `192.168.1.10` with its reachable LAN address:

```sh
"$peer" host --listen 192.168.1.10 --port 8031 \
  --pair "$HOME/.rrsh-peer/test.seed"
```

On the client:

```sh
"$peer" connect 192.168.1.10 --port 8031 \
  --pair "$HOME/.rrsh-peer/test.seed"
```

Use a directly reachable route and allow the selected TCP port through the
host's existing firewall. The default host address is loopback; it only accepts
local connections unless `--listen` is supplied. `--listen 0.0.0.0` listens on
all IPv4 interfaces. There is no rendezvous service or NAT traversal. Start the
host again for each test; it handles one connection and exits.

Success prints `Paired native connection probe completed` on both endpoints.
The exchange has two 32-round correspondence phases and one private native
probe in each direction: exactly 520 application bytes, all measured finite
binary32 floats. There are no application headers, transmitted peer IDs, hashes,
secrets or commands. TCP/IP addresses, ordering, timing and volume are visible.
Float-only serialization does not establish semantic non-referentiality or privacy.

The default state-machine deadline is 300 seconds, with individual socket waits
bounded by 60 seconds. Native calls complete before the next deadline check;
this is not a hard CPU watchdog. `--timeout` accepts 1..600 seconds.
Emulated Linux tests
can be substantially slower than native macOS. A timeout or mismatch exits
nonzero; no public-state or wider-float fallback is used.

## Results and troubleshooting

Each endpoint creates a private directory under `~/.rrsh-peer/runs/`, containing
`identity.json`, `result.json`, `sent.bin` and `received.bin`. Pairing secrets
are excluded. Use `--records /new/private/directory` to choose a fresh path.
Records include measured floats and local timing and should remain private.
Remove obsolete run directories when no longer needed. A partial TCP connection
failure can leave only an identity record; do not treat it as a passed test.

For `connection refused`, check that the host is running, the address/port match,
and the LAN/firewall allows access. For `private response mismatch`, verify that
both endpoints imported the same pairing code and run the same version. For a
file-permissions refusal, verify ownership and `chmod 600` the pairing file.
A hash/signature failure requires an authentic replacement, not bypassing checks.

## Evidence and limits

The shipped binaries passed private setup checks, three independent paired
connections per platform, wrong-pair/truncated/nonfinite refusal controls, and
a separate macOS-host/Linux-client connection in a minimal Linux container.
The embedded cores matched the signed library hashes during those actual runs.
Linux execution was tested under x86_64 emulation on the macOS host.
See [verification record](verification/peer-readiness.json).

Earlier v1 admitted a parallel-session splice. Revised private histories bind
both proof phases; the registered splice refused in all four endpoints, with
transparent forwarding controls passing. Two recorded/public continuation
substitutions also refused. Earlier challenge ambiguity and packaging hash
failures were preserved and corrected before this build.

A public-code recording observer recovered all 64 challenge sites and matched
0/64 private responses using the tested public-bootstrap baseline. This does
not bound adaptive prediction, response entropy or authentication strength.
There is no variable user payload in the fixed probe from which to evaluate
content confidentiality. The binary is admitted only for synthetic connection
evaluation. Policy/device identity binding, adaptive oracles, collisions,
side channels, credential extraction, long sessions and independent security
review remain open. See [SECURITY.md](SECURITY.md).
