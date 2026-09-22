# Time Tile

Minimal Garmin Connect IQ watch face for the Forerunner 55 (`fr55`).

## Current status

Initial project scaffolding only. The watch face currently draws a black
background with centered white text reading **Time Tile**. Final layout,
data fields, and styling are **not implemented**.

## Supported device

| Item | Value |
|------|-------|
| Device | Forerunner 55 (`fr55`) |
| Minimum API level | 3.4.0 |
| Connect IQ SDK | 9.2.0 (active SDK from `current-sdk.cfg`) |
| App version | 0.1.0 |

Only `fr55` is supported in this repository.

## Ubuntu 24.04

On Ubuntu 24.04, Garmin Connect IQ tools run inside an Ubuntu 22.04 Distrobox
container named `garmin-sdk` (host Cursor/Make stay on the host; the home
directory and this repository are shared). Full host/container setup,
SDK installation, developer-key creation, and troubleshooting:

→ **[docs/ubuntu-24.04-setup.md](docs/ubuntu-24.04-setup.md)**

## Distrobox requirement

Garmin SDK tools run inside a Distrobox container. Cursor and Make run on the
host; the Makefile invokes tools with:

```bash
distrobox enter garmin-sdk -- …
```

Expected container name: `garmin-sdk` (override with `CONTAINER=…`).

The project directory must be shared between the host and the container.

## Developer key

Default key path (outside the repository):

```text
$(HOME)/.config/garmin-connect-iq/developer_key.der
```

Override with `DEVELOPER_KEY=/path/to/key.der`.

**Never commit developer keys** (`.der`, `.pem`, or key material). They are
listed in `.gitignore` and must stay outside version control.

## Makefile commands

| Target | Description |
|--------|-------------|
| `make help` | List targets |
| `make check` | Verify Distrobox, SDK, device package, and developer key |
| `make assets` | Generate PNG icons from SVG sources (host ImageMagick) |
| `make build` | Generate assets, then compile and sign a debug `.prg` for `fr55` |
| `make device-build` | Compile/sign FR55 `.prg` and copy to `dist/TimeTile_fr55.prg` |
| `make device-check` | Validate `DEVICE_ROOT` for safe USB sideload (no writes) |
| `make sideload` | Build device binary, check mount, copy `TIMETILE.PRG` |
| `make clean` | Delete `build/`, `dist/TimeTile_fr55.prg`, and generated icon PNGs |
| `make simulator` | Start the Connect IQ simulator (inside the container) |
| `make run` | Build and launch the `.prg` in the simulator |

Common overrides:

```bash
make build DEVICE=fr55
make build CONTAINER=garmin-sdk
make build SDK_CFG="$HOME/.Garmin/ConnectIQ/current-sdk.cfg"
make build DEVELOPER_KEY="$HOME/.config/garmin-connect-iq/developer_key.der"
```

## Physical Forerunner 55 testing

USB sideload only. No automatic device discovery. Pass the watch mount root
explicitly as `DEVICE_ROOT`.

1. Connect the Forerunner 55 by USB.
2. Wait until the mass-storage volume mounts.
3. Identify the mount root that contains `GARMIN/APPS` (and usually
   `GARMIN/GarminDevice.xml`).
4. Validate (read-only):

```bash
make device-check DEVICE_ROOT=/media/user/GARMIN
```

5. Sideload (builds `dist/TimeTile_fr55.prg`, then copies it):

```bash
make sideload DEVICE_ROOT=/media/user/GARMIN
```

   If `GARMIN/APPS/TIMETILE.PRG` already exists, the copy stops unless you
   explicitly replace **only** that file:

```bash
make sideload DEVICE_ROOT=/media/user/GARMIN FORCE=1
```

6. Safely eject / unmount the watch, then unplug USB.
7. Restart or disconnect as needed so the watchface list refreshes.
8. Select **Time Tile** from the watchface chooser.
9. To uninstall the sideload later, remove **only**:

```text
GARMIN/APPS/TIMETILE.PRG
```

Do not delete other `.PRG` files or similarly named Garmin apps.

### Sideload filename

The destination name is `TIMETILE.PRG` (8 characters before `.PRG`), which
matches common Connect IQ USB sideload practice on FAT volumes. This project
does not invent a UUID filename.

### App settings on a physical sideload

- `build/TimeTile_fr55-settings.json` is **simulator metadata** for
  `monkeydo -a`. Do **not** copy it to the watch.
- Sideloaded apps may use a matching `.SET` under `GARMIN/APPS/SETTINGS` for
  non-default settings (same base name as the `.PRG`, including case). This
  Makefile does **not** generate or copy `.SET` files.
- Garmin Connect / Connect IQ phone settings for store apps are not assumed to
  work the same way for an unsigned-workflow sideload; treat Connect settings
  support as unverified for this first physical test.
- Without a `.SET` file, `resources/settings/properties.xml` defaults apply
  (Battery / Calendar / Steps, Blue stripe, White text/dynamic color). The first
  physical test may use defaults only.

### Physical test checklist

- Watchface launches.
- Hour/minute layout is centered.
- Stripe does not clip at the circular edge.
- Battery frame and fill are aligned.
- Calendar is readable.
- Steps icon and value are readable.
- Weather icon and temperature are readable when selected.
- Actual SVG lines are inspected for MIP dithering.
- Steps update behavior is observed in low-power mode.
- Battery updates after its five-minute interval.
- No crash or fallback to the stock watchface.
- Memory remains acceptable.
- Settings behavior on a sideloaded app is recorded.

## Icon assets

SVG files under `assets/icons-src/` are the editable source of truth. Connect IQ
does not render SVG at runtime — `make assets` converts them to transparent PNG
bitmaps under `resources/drawables/generated/`.

### Contrast model (OnLight / OnDark)

- SVG colors, white fills, black outlines, transparency, dimensions, and layer
  composition are preserved. The pipeline does **not** invert, recolor,
  threshold, trim, or resize artwork.
- Each icon has a required base SVG designed for a **light** stripe background
  (e.g. `steps.svg`, `weather/partly_cloudy.svg`).
- An optional manually authored `*_on_dark.svg` may provide artwork for a
  **dark** stripe background (e.g. `steps_on_dark.svg`). Do not create
  placeholder dark variants.
- If the dark SVG is missing, the base PNG is reused byte-for-byte for
  `*_on_dark.png`. There is no automatic color inversion.
- Full-color icons may therefore use the same artwork for both modes.
- Stripe color selects OnLight vs OnDark at runtime. The settings value
  **Text and dynamic color** (`stripeForegroundColor`) controls text and
  dynamic fills (e.g. battery bar) only — it does **not** recolor SVG bitmaps.

### Sources

- **Steps:** `steps.svg` (intrinsic size from the SVG).
- **Calendar:** `calendar_top.svg`, `calendar_bottom.svg`; weekday/day text
  stays dynamic and is overlaid at runtime.
- **Battery:** `battery_frame.svg`; percentage fill remains dynamic Monkey C
  drawing and must stay aligned with Battery-local fill geometry if the SVG
  changes.
- **Weather:** seven family SVGs under `assets/icons-src/weather/`
  (`clear`, `partly_cloudy`, `cloudy`, `rain`, `thunderstorm`, `snow`,
  `unknown`). Garmin conditions map to these visual families; `unknown.svg`
  is the fallback.

### Device notes (FR55 MIP)

- Pixel-aligned 2-pixel strokes are usually more reliable on FR55 MIP.
- Thin, diagonal, curved, or antialiased edges may dither on the device palette.
- Generated PNGs are inspected before compilation; some edge gray/AA may already
  exist in the PNG and is distinct from additional dither after Garmin packaging.

### Workflow

- Run `make assets` after editing an SVG.
- `make build` / `make run` generate assets automatically.
- Keep shapes simple and readable at icon sizes (no gradients/filters).
- Generated PNGs are gitignored; commit the SVG sources only.

Requires ImageMagick `convert` on the host (`sudo apt install imagemagick`).
Preferred longer-term converter: `rsvg-convert` from `librsvg2-bin`.

## Project structure

```text
.
├── Makefile
├── README.md
├── docs/
│   └── ubuntu-24.04-setup.md
├── assets/
│   └── icons-src/          (editable SVG sources; weather/ families)
├── manifest.xml
├── monkey.jungle
├── resources/
│   ├── drawables/
│   │   └── generated/      (PNG output; gitignored)
│   ├── settings/
│   └── strings/
├── source/
│   ├── TimeTileApp.mc
│   └── TimeTileView.mc
├── build/                  (simulator/debug build; gitignored)
└── dist/                   (device sideload .prg only; gitignored)
```

## Troubleshooting

- **`distrobox` not found** — install Distrobox on the host and ensure it is on `PATH`.
- **Container errors** — confirm `distrobox enter garmin-sdk -- true` works.
- **SDK path errors** — check `$(HOME)/.Garmin/ConnectIQ/current-sdk.cfg` points at the active SDK.
- **`monkeyc` / `monkeydo` / `connectiq` missing** — reinstall or repair the Connect IQ SDK inside the container; do not change the host Java/SDK layout from this project.
- **Device package missing** — install the `fr55` package via the Connect IQ SDK Manager into `$(HOME)/.Garmin/ConnectIQ/Devices/fr55`.
- **Developer key missing** — place a valid `.der` key at the default path or pass `DEVELOPER_KEY=…`.

## Roadmap (not implemented)

The following are planned for later steps and are **not** part of this scaffold:

- Final time layout
- Date display
- Vertical stripe
- Widgets, icons, weather
- Battery, steps, heart rate
- Settings and themes
- Custom fonts and localization
- Additional device support
- Simulator workflow validation
