# Time Tile — Connect IQ watch face
# Invoke from the host project directory. Garmin tools run inside Distrobox.

CONTAINER      ?= garmin-sdk
DEVICE         ?= fr55
SDK_CFG        ?= $(HOME)/.Garmin/ConnectIQ/current-sdk.cfg
DEVELOPER_KEY  ?= $(HOME)/.config/garmin-connect-iq/developer_key.der
DEVICES_DIR    ?= $(HOME)/.Garmin/ConnectIQ/Devices

BUILD_DIR      := build
APP_NAME       := TimeTile
PRG            := $(BUILD_DIR)/$(APP_NAME)_$(DEVICE).prg
# monkeyc writes this next to the .prg when resources/settings/settings.xml is present.
SETTINGS_JSON  := $(BUILD_DIR)/$(APP_NAME)_$(DEVICE)-settings.json
SETTINGS_SRC   := resources/settings/settings.xml
# Simulator virtual path required by App Settings Editor (monkeydo -a source:dest).
SETTINGS_DEST  := GARMIN/Settings/$(APP_NAME)_$(DEVICE)-settings.json
JUNGLE         := monkey.jungle

# SVG → PNG icon pipeline (host ImageMagick; generated PNGs are not committed).
ICON_GEN_DIR   := resources/drawables/generated
CONVERT        := $(shell command -v convert 2>/dev/null)
SVG_SIZE       := scripts/svg-declared-size.sh

STEPS_SVG            := assets/icons-src/steps.svg
CALENDAR_TOP_SVG     := assets/icons-src/calendar_top.svg
CALENDAR_BOTTOM_SVG  := assets/icons-src/calendar_bottom.svg
BATTERY_FRAME_SVG    := assets/icons-src/battery_frame.svg

WEATHER_ICON_DIR     := assets/icons-src/weather
WEATHER_FAMILIES     := clear partly_cloudy cloudy rain thunderstorm snow unknown

STEPS_BLACK          := $(ICON_GEN_DIR)/steps_black.png
STEPS_WHITE          := $(ICON_GEN_DIR)/steps_white.png
CAL_TOP_BLACK        := $(ICON_GEN_DIR)/calendar_top_black.png
CAL_TOP_WHITE        := $(ICON_GEN_DIR)/calendar_top_white.png
CAL_BOTTOM_BLACK     := $(ICON_GEN_DIR)/calendar_bottom_black.png
CAL_BOTTOM_WHITE     := $(ICON_GEN_DIR)/calendar_bottom_white.png
BATTERY_BLACK        := $(ICON_GEN_DIR)/battery_frame_black.png
BATTERY_WHITE        := $(ICON_GEN_DIR)/battery_frame_white.png

WEATHER_BLACK_PNGS := $(foreach f,$(WEATHER_FAMILIES),$(ICON_GEN_DIR)/weather_$(f)_black.png)
WEATHER_WHITE_PNGS := $(foreach f,$(WEATHER_FAMILIES),$(ICON_GEN_DIR)/weather_$(f)_white.png)

GENERATED_PNGS := \
	$(STEPS_BLACK) $(STEPS_WHITE) \
	$(CAL_TOP_BLACK) $(CAL_TOP_WHITE) \
	$(CAL_BOTTOM_BLACK) $(CAL_BOTTOM_WHITE) \
	$(BATTERY_BLACK) $(BATTERY_WHITE) \
	$(WEATHER_BLACK_PNGS) $(WEATHER_WHITE_PNGS)

# Fixed-size render (Calendar / Battery only in this step).
# $1 = svg, $2 = black png out, $3 = width, $4 = height
define render_svg_black
	@if [ -z "$(CONVERT)" ]; then \
		echo "ERROR: ImageMagick 'convert' not found on PATH."; \
		echo "Install on Ubuntu: sudo apt install imagemagick"; \
		echo "Preferred alternative: sudo apt install librsvg2-bin  (rsvg-convert)"; \
		exit 1; \
	fi
	@echo "Generating $(2) ($(3)x$(4)) from $(1)..."
	@"$(CONVERT)" -background none -size $(3)x$(4) "$(1)" PNG32:"$(2)"
	@identify -format '%wx%h' "$(2)" | grep -qx '$(3)x$(4)' \
		|| (echo "ERROR: $(2) is not $(3)x$(4)"; exit 1)
endef

# $1 = black png, $2 = white png out, $3 = width, $4 = height
define negate_to_white
	@echo "Generating $(2) from $(1)..."
	@"$(CONVERT)" "$(1)" -channel RGB -negate +channel PNG32:"$(2)"
	@identify -format '%wx%h' "$(2)" | grep -qx '$(3)x$(4)' \
		|| (echo "ERROR: $(2) is not $(3)x$(4)"; exit 1)
endef

# Intrinsic-size render for Steps / Weather: preserve Black, White, and alpha.
# $1 = svg, $2 = black png out
define render_svg_black_intrinsic
	@if [ -z "$(CONVERT)" ]; then \
		echo "ERROR: ImageMagick 'convert' not found on PATH."; \
		echo "Install on Ubuntu: sudo apt install imagemagick"; \
		exit 1; \
	fi
	@if [ ! -x "$(SVG_SIZE)" ]; then chmod +x "$(SVG_SIZE)"; fi
	@declared="$$($(SVG_SIZE) "$(1)")"; \
	echo "Generating $(2) (intrinsic $$declared) from $(1)..."; \
	"$(CONVERT)" -background none "$(1)" PNG32:"$(2)"; \
	got="$$(identify -format '%wx%h' "$(2)")"; \
	if [ "$$got" != "$$declared" ]; then \
		echo "ERROR: $(1) declares $$declared"; \
		echo "but generated $(2) is $$got"; \
		exit 1; \
	fi; \
	opaque="$$("$(CONVERT)" "$(2)" -alpha extract -format '%[fx:maxima]' info:)"; \
	opaque_int="$$(echo "$$opaque" | awk '{printf "%d", ($$1>0)?1:0}')"; \
	if [ "$$opaque_int" -le 0 ]; then \
		echo "ERROR: $(2) is completely transparent (from $(1))"; \
		exit 1; \
	fi
endef

# $1 = black png, $2 = white png out, $3 = source svg (for error text)
define negate_to_white_intrinsic
	@echo "Generating $(2) from $(1) (RGB invert, alpha unchanged)..."
	@"$(CONVERT)" "$(1)" -channel RGB -negate +channel PNG32:"$(2)"
	@black_wh="$$(identify -format '%wx%h' "$(1)")"; \
	white_wh="$$(identify -format '%wx%h' "$(2)")"; \
	if [ "$$black_wh" != "$$white_wh" ]; then \
		echo "ERROR: $(3): Black $$black_wh and White $$white_wh dimensions differ"; \
		exit 1; \
	fi
endef

# Resolve active SDK path from current-sdk.cfg (supports SDK root or .../bin).
SDK_PATH_RAW := $(shell tr -d '\r\n' < "$(SDK_CFG)" 2>/dev/null | sed 's:/*$$::')
ifeq ($(notdir $(SDK_PATH_RAW)),bin)
  SDK_HOME := $(patsubst %/,%,$(dir $(SDK_PATH_RAW)))
  SDK_BIN  := $(SDK_PATH_RAW)
else
  SDK_HOME := $(SDK_PATH_RAW)
  SDK_BIN  := $(SDK_HOME)/bin
endif

MONKEYC   := $(SDK_BIN)/monkeyc
MONKEYDO  := $(SDK_BIN)/monkeydo
CONNECTIQ := $(SDK_BIN)/connectiq
DEVICE_PKG := $(DEVICES_DIR)/$(DEVICE)

# Run a command inside the Distrobox container, preserving project cwd.
# Usage: $(call in_container,command with "quoted" args)
define in_container
distrobox enter "$(CONTAINER)" -- bash --noprofile --norc -c $(1)
endef

.PHONY: help check assets build clean simulator run

help:
	@echo "Time Tile — Connect IQ watch face"
	@echo ""
	@echo "Targets:"
	@echo "  help       List available targets"
	@echo "  check      Verify Distrobox, SDK tools, device package, and developer key"
	@echo "  assets     Generate PNG icons from SVG sources (host ImageMagick)"
	@echo "  build      Generate assets, then compile and sign a debug .prg for $(DEVICE)"
	@echo "  clean      Remove build/ and generated icon PNGs"
	@echo "  simulator  Start the Connect IQ simulator inside the container"
	@echo "  run        Build and launch the .prg on the simulator for $(DEVICE)"
	@echo ""
	@echo "Overrides: CONTAINER DEVICE SDK_CFG DEVELOPER_KEY DEVICES_DIR"

check:
	@status=0; \
	if ! command -v distrobox >/dev/null 2>&1; then \
		echo "ERROR: distrobox is not available on the host PATH."; status=1; \
	else \
		echo "OK: distrobox is available"; \
	fi; \
	if ! distrobox enter "$(CONTAINER)" -- bash --noprofile --norc -c 'true' >/dev/null 2>&1; then \
		echo "ERROR: cannot execute commands in Distrobox container '$(CONTAINER)'."; status=1; \
	else \
		echo "OK: container '$(CONTAINER)' accepts commands"; \
	fi; \
	if [ ! -f "$(SDK_CFG)" ]; then \
		echo "ERROR: SDK configuration file not found: $(SDK_CFG)"; status=1; \
	else \
		echo "OK: SDK configuration exists: $(SDK_CFG)"; \
	fi; \
	if [ -z "$(SDK_HOME)" ] || [ ! -d "$(SDK_HOME)" ]; then \
		echo "ERROR: SDK directory does not exist: '$(SDK_HOME)' (from $(SDK_CFG))"; status=1; \
	else \
		echo "OK: SDK directory exists: $(SDK_HOME)"; \
	fi; \
	if [ ! -x "$(MONKEYC)" ] && [ ! -f "$(MONKEYC)" ]; then \
		echo "ERROR: monkeyc not found at: $(MONKEYC)"; status=1; \
	else \
		echo "OK: monkeyc found: $(MONKEYC)"; \
	fi; \
	if [ ! -x "$(MONKEYDO)" ] && [ ! -f "$(MONKEYDO)" ]; then \
		echo "ERROR: monkeydo not found at: $(MONKEYDO)"; status=1; \
	else \
		echo "OK: monkeydo found: $(MONKEYDO)"; \
	fi; \
	if [ ! -x "$(CONNECTIQ)" ] && [ ! -f "$(CONNECTIQ)" ]; then \
		echo "ERROR: connectiq not found at: $(CONNECTIQ)"; status=1; \
	else \
		echo "OK: connectiq found: $(CONNECTIQ)"; \
	fi; \
	if [ ! -d "$(DEVICE_PKG)" ]; then \
		echo "ERROR: device package for '$(DEVICE)' not found at: $(DEVICE_PKG)"; status=1; \
	else \
		echo "OK: device package exists: $(DEVICE_PKG)"; \
	fi; \
	if [ ! -f "$(DEVELOPER_KEY)" ]; then \
		echo "ERROR: developer key not found at: $(DEVELOPER_KEY)"; status=1; \
	else \
		echo "OK: developer key exists: $(DEVELOPER_KEY)"; \
	fi; \
	exit $$status

# Generate white/black PNG variants from SVG sources (host-side).
assets: $(GENERATED_PNGS)
	@echo "OK: generated Steps, Calendar, Battery, and Weather icon PNGs"

$(ICON_GEN_DIR):
	@mkdir -p "$(ICON_GEN_DIR)"

$(STEPS_BLACK): $(STEPS_SVG) $(SVG_SIZE) | $(ICON_GEN_DIR)
	$(call render_svg_black_intrinsic,$(STEPS_SVG),$(STEPS_BLACK))

$(STEPS_WHITE): $(STEPS_BLACK)
	$(call negate_to_white_intrinsic,$(STEPS_BLACK),$(STEPS_WHITE),$(STEPS_SVG))

$(CAL_TOP_BLACK): $(CALENDAR_TOP_SVG) | $(ICON_GEN_DIR)
	$(call render_svg_black,$(CALENDAR_TOP_SVG),$(CAL_TOP_BLACK),30,18)

$(CAL_TOP_WHITE): $(CAL_TOP_BLACK)
	$(call negate_to_white,$(CAL_TOP_BLACK),$(CAL_TOP_WHITE),30,18)

$(CAL_BOTTOM_BLACK): $(CALENDAR_BOTTOM_SVG) | $(ICON_GEN_DIR)
	$(call render_svg_black,$(CALENDAR_BOTTOM_SVG),$(CAL_BOTTOM_BLACK),30,18)

$(CAL_BOTTOM_WHITE): $(CAL_BOTTOM_BLACK)
	$(call negate_to_white,$(CAL_BOTTOM_BLACK),$(CAL_BOTTOM_WHITE),30,18)

$(BATTERY_BLACK): $(BATTERY_FRAME_SVG) | $(ICON_GEN_DIR)
	$(call render_svg_black,$(BATTERY_FRAME_SVG),$(BATTERY_BLACK),30,16)

$(BATTERY_WHITE): $(BATTERY_BLACK)
	$(call negate_to_white,$(BATTERY_BLACK),$(BATTERY_WHITE),30,16)

# Weather families: intrinsic size per SVG (no forced 18×18).
define weather_icon_rules
$(ICON_GEN_DIR)/weather_$(1)_black.png: $(WEATHER_ICON_DIR)/$(1).svg $(SVG_SIZE) | $(ICON_GEN_DIR)
	$$(call render_svg_black_intrinsic,$(WEATHER_ICON_DIR)/$(1).svg,$(ICON_GEN_DIR)/weather_$(1)_black.png)

$(ICON_GEN_DIR)/weather_$(1)_white.png: $(ICON_GEN_DIR)/weather_$(1)_black.png
	$$(call negate_to_white_intrinsic,$(ICON_GEN_DIR)/weather_$(1)_black.png,$(ICON_GEN_DIR)/weather_$(1)_white.png,$(WEATHER_ICON_DIR)/$(1).svg)
endef

$(foreach family,$(WEATHER_FAMILIES),$(eval $(call weather_icon_rules,$(family))))

build: check assets
	@mkdir -p "$(BUILD_DIR)"
	@echo "Compiling $(APP_NAME) for $(DEVICE)..."
	@echo "Compiler command:"
	@echo "  $(MONKEYC) -f $(JUNGLE) -o $(PRG) -d $(DEVICE) -y $(DEVELOPER_KEY) -w"
	@$(call in_container,"set -e; \
		'$(MONKEYC)' \
			-f '$(CURDIR)/$(JUNGLE)' \
			-o '$(CURDIR)/$(PRG)' \
			-d '$(DEVICE)' \
			-y '$(DEVELOPER_KEY)' \
			-w")
	@echo "OK: built $(PRG)"

clean:
	@rm -rf "$(BUILD_DIR)"
	@rm -f $(GENERATED_PNGS)
	@echo "OK: removed $(BUILD_DIR)/ and generated icon PNGs"

simulator:
	@echo "Starting Connect IQ simulator in container '$(CONTAINER)'..."
	@$(call in_container,"'$(CONNECTIQ)'")

run: build
	@if [ -f "$(SETTINGS_SRC)" ] && [ ! -f "$(SETTINGS_JSON)" ]; then \
		echo "ERROR: Settings JSON not found. Run make build and verify $(SETTINGS_SRC)."; \
		echo "Expected: $(SETTINGS_JSON)"; \
		exit 1; \
	fi
	@echo "Launching $(PRG) on $(DEVICE)..."
	@if [ -f "$(SETTINGS_JSON)" ]; then \
		echo "  $(MONKEYDO) $(PRG) $(DEVICE) -a \"$(SETTINGS_JSON):$(SETTINGS_DEST)\""; \
		$(call in_container,"'$(MONKEYDO)' '$(CURDIR)/$(PRG)' '$(DEVICE)' -a '$(CURDIR)/$(SETTINGS_JSON):$(SETTINGS_DEST)'"); \
	else \
		echo "  $(MONKEYDO) $(PRG) $(DEVICE)"; \
		$(call in_container,"'$(MONKEYDO)' '$(CURDIR)/$(PRG)' '$(DEVICE)'"); \
	fi
