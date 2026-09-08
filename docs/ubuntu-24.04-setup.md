# Ubuntu 24.04 development environment

This guide documents the **verified** setup used to build and run **Time Tile** on Ubuntu 24.04 with the Garmin Connect IQ SDK.

| Item | Verified value |
|------|----------------|
| Host OS | Ubuntu 24.04 |
| Distrobox container | `garmin-sdk` |
| Container OS | Ubuntu 22.04.5 LTS |
| Connect IQ SDK | 9.2.0 |
| Target device | `fr55` (Forerunner 55) |
| Simulator device API profile | 3.4.2 |
| Project minimum API level | 3.4.0 |
| Java (container) | OpenJDK 17 |

Verified Make targets: `check`, `build`, `simulator`, `run`, `clean`.

---

## 1. Problem summary

Garmin’s native Linux **Connect IQ SDK Manager** depends on:

```text
libwebkit2gtk-4.0.so.37
```

Ubuntu 24.04 ships a newer WebKitGTK stack that is incompatible with that requirement. Running the official SDK Manager directly on the host therefore fails (or cannot satisfy the expected WebKit 4.0 libraries).

---

## 2. AppImage attempt (not recommended)

A community AppImage that packages the SDK Manager was tested from:

[https://github.com/pcolby/connectiq-sdk-manager](https://github.com/pcolby/connectiq-sdk-manager)

This is a **community project**, not an official Garmin tool.

Installation command tested:

```bash
curl -Ls https://raw.githubusercontent.com/pcolby/connectiq-sdk-manager/main/install.sh | bash -r
```

Observed results:

- The main SDK Manager window opened.
- The Garmin login window remained **blank**.
- The terminal showed a GLib/GVFS compatibility error involving `g_task_set_static_name`.
- Environment-variable workarounds aimed at WebKit rendering did **not** fix the blank login.

**Conclusion:** the AppImage route is **not** the recommended setup for this project.

---

## 3. Working architecture

The working approach isolates Garmin tooling in an older Ubuntu userspace:

1. **Host (Ubuntu 24.04)** — Cursor, Git, and the project source stay on the host.
2. **Container (Ubuntu 22.04 via Distrobox)** — SDK Manager, `monkeyc`, `monkeydo`, `connectiq`, and the simulator run inside `garmin-sdk`.
3. **Shared home and project tree** — Distrobox shares the home directory (and thus this repository) with the container, so builds write to the same `build/` path the host sees.
4. **Makefile** — Host-side `make` targets invoke Distrobox so day-to-day commands stay simple (`make check`, `make build`, `make run`, …).

```text
Ubuntu 24.04 host                  Ubuntu 22.04 Distrobox (garmin-sdk)
─────────────────                  ───────────────────────────────────
Cursor / editor                    Connect IQ SDK Manager
make (this repo)    ──enter──►     monkeyc / monkeydo / connectiq
shared ~/.Garmin/…                 simulator (Forerunner 55 / fr55)
shared project dir                 OpenJDK 17
```

---

## 4. Distrobox installation

On the **host**:

```bash
sudo apt update
sudo apt install distrobox podman
```

Create the container:

```bash
distrobox create \
  --name garmin-sdk \
  --image docker.io/library/ubuntu:22.04
```

Enter the container:

```bash
distrobox enter garmin-sdk
```

Verify the container OS:

```bash
cat /etc/os-release
```

Expect Ubuntu 22.04.x LTS.

---

## 5. Required container packages

Inside `garmin-sdk`:

```bash
sudo apt update

sudo apt install -y \
  libwebkit2gtk-4.0-37 \
  libjavascriptcoregtk-4.0-18 \
  libsoup2.4-1 \
  libsecret-1-0 \
  libxkbcommon0 \
  libsm6 \
  libgtk-3-0 \
  libcanberra-gtk-module \
  libcanberra-gtk3-module \
  openjdk-17-jre
```

These packages supply WebKitGTK 4.0 for the official SDK Manager, GTK/X11 support for GUI tools, and OpenJDK 17 for the Monkey C compiler.

If the simulator fails with `libusb-1.0.so.0: cannot open shared object file`, install:

```bash
sudo apt install -y libusb-1.0-0
```

---

## 6. Garmin SDK installation

Still inside `garmin-sdk`, run the **official** Garmin Connect IQ SDK Manager (downloaded from Garmin’s developer site). Do not rely on the community AppImage for this project.

In the SDK Manager UI:

1. Sign in with your Garmin developer account.
2. Install **Connect IQ SDK 9.2.0**.
3. Set **9.2.0** as the **active** SDK (so `~/.Garmin/ConnectIQ/current-sdk.cfg` points at that SDK root).
4. Install the **Forerunner 55** device package.
5. Confirm the device identifier is **`fr55`** (device package under `~/.Garmin/ConnectIQ/Devices/fr55`).

Because the home directory is shared, SDK files under `~/.Garmin/ConnectIQ/` are visible from both host and container.

---

## 7. SDK verification

Inside the container (or via Distrobox from the host):

```bash
ciq_sdk_path="$(cat ~/.Garmin/ConnectIQ/current-sdk.cfg)"
"$ciq_sdk_path/bin/monkeyc" --version
```

`current-sdk.cfg` should contain the active SDK directory. Tools live under `$ciq_sdk_path/bin/`.

Check that these exist:

```bash
ciq_sdk_path="$(cat ~/.Garmin/ConnectIQ/current-sdk.cfg)"
test -x "$ciq_sdk_path/bin/monkeyc" && echo "OK monkeyc"
test -x "$ciq_sdk_path/bin/monkeydo" && echo "OK monkeydo"
test -x "$ciq_sdk_path/bin/connectiq" && echo "OK connectiq"
test -d ~/.Garmin/ConnectIQ/Devices/fr55 && echo "OK fr55 device package"
```

From the project directory on the host, `make check` performs the same class of verification through Distrobox.

---

## 8. Developer key

Create the signing key **outside** the repository:

```bash
mkdir -p ~/.config/garmin-connect-iq
chmod 700 ~/.config/garmin-connect-iq

openssl genrsa \
  -out ~/.config/garmin-connect-iq/developer_key.pem \
  4096

openssl pkcs8 \
  -topk8 \
  -inform PEM \
  -outform DER \
  -in ~/.config/garmin-connect-iq/developer_key.pem \
  -out ~/.config/garmin-connect-iq/developer_key.der \
  -nocrypt

chmod 600 \
  ~/.config/garmin-connect-iq/developer_key.pem \
  ~/.config/garmin-connect-iq/developer_key.der
```

The Makefile defaults to:

```text
$(HOME)/.config/garmin-connect-iq/developer_key.der
```

**Warnings:**

- **Never commit** `developer_key.pem` or `developer_key.der`.
- **Never share** key contents in chat, screenshots, or tickets.
- **Back up** the key securely; losing it prevents signing updates with the same identity.
- **Future application updates must use the same signing identity** so Connect IQ Store / sideload updates remain consistent.

---

## 9. Project commands

Run these from the **host** project directory (`garmin-timetile`). The Makefile enters `garmin-sdk` as needed.

| Command | Purpose |
|---------|---------|
| `make check` | Verify Distrobox, container, SDK path/tools, `fr55` device package, and developer key |
| `make build` | Run `check`, then compile and sign a debug `build/TimeTile_fr55.prg` |
| `make simulator` | Start the Connect IQ simulator inside the container |
| `make run` | Build (including `check`), then load the `.prg` into the running simulator for `fr55` |
| `make clean` | Delete project-generated `build/` artifacts only |

Typical workflow:

```bash
make simulator   # leave the simulator window open
make run         # builds if needed, then monkeydo → Forerunner 55
```

Overrides (optional): `CONTAINER`, `DEVICE`, `SDK_CFG`, `DEVELOPER_KEY`, `DEVICES_DIR`.

---

## 10. Troubleshooting

| Symptom | What to check |
|---------|----------------|
| **Missing Java** | Inside the container: `java -version` should report OpenJDK 17. Reinstall `openjdk-17-jre` if needed. |
| **Missing `current-sdk.cfg`** | Install SDK 9.2.0 and set it active in the SDK Manager. Path: `~/.Garmin/ConnectIQ/current-sdk.cfg`. |
| **Missing `fr55` device package** | In the SDK Manager, install Forerunner 55. Expect `~/.Garmin/ConnectIQ/Devices/fr55`. |
| **Missing developer key** | Create the `.der` key under `~/.config/garmin-connect-iq/` (see §8) or pass `DEVELOPER_KEY=…`. |
| **Distrobox container not running** | `distrobox enter garmin-sdk -- true`. Recreate with the `distrobox create` command in §4 if the container was removed. |
| **Simulator window not opening** | Confirm display forwarding (`DISPLAY` inside the container). Install `libusb-1.0-0` if the binary complains about `libusb-1.0.so.0`. Ensure GTK/WebKit packages from §5 are present. |
| **Duplicate simulator process** | Close extra simulator windows or stop leftover `simulator` processes before `make simulator` / `make run`. |
| **Blank SDK Manager login (AppImage)** | Expected with the community AppImage on this host stack. Use the Distrobox + official SDK Manager path instead (§3–§6). |

---

## Related project docs

- Project overview and Makefile reference: [README.md](../README.md)
