# Bundled runtime notices

The paired tester includes CPython and the PyInstaller bootloader. These and
bundled runtime dependencies retain their respective licenses; RRSH proprietary
terms apply to RRSH/RRFC components, not to separately licensed third-party code.
Python licenses include notices for its bundled components. PyInstaller's
bootloader exception permits generated application distribution under its own
license. Build tools that are not included in the binary remain separate.

macOS includes Python 3.14, OpenSSL 3, mpdecimal 4, zstd and liblzma (XZ's 0BSD
library). Linux includes Python 3.12 and runtime libraries from Debian bullseye;
its collected system-library notices are included in linux-runtime-notices.txt.
These files preserve the upstream notices without modifying their text.
