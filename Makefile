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

STEPS_SVG            := assets/icons-src/steps.svg
CALENDAR_TOP_SVG     := assets/icons-src/calendar_top.svg
CALENDAR_BOTTOM_SVG  := assets/icons-src/calendar_bottom.svg
BATTERY_FRAME_SVG    := assets/icons-src/battery_frame.svg

STEPS_BLACK          := $(ICON_GEN_DIR)/steps_black.png
STEPS_WHITE          := $(ICON_GEN_DIR)/steps_white.png
CAL_TOP_BLACK        := $(ICON_GEN_DIR)/calendar_top_black.png
CAL_TOP_WHITE        := $(ICON_GEN_DIR)/calendar_top_white.png
CAL_BOTTOM_BLACK     := $(ICON_GEN_DIR)/calendar_bottom_black.png
CAL_BOTTOM_WHITE     := $(ICON_GEN_DIR)/calendar_bottom_white.png
BATTERY_BLACK        := $(ICON_GEN_DIR)/battery_frame_black.png
BATTERY_WHITE        := $(ICON_GEN_DIR)/battery_frame_white.png

GENERATED_PNGS := \
	$(STEPS_BLACK) $(STEPS_WHITE) \
	$(CAL_TOP_BLACK) $(CAL_TOP_WHITE) \
	$(CAL_BOTTOM_BLACK) $(CAL_BOTTOM_WHITE) \
	$(BATTERY_BLACK) $(BATTERY_WHITE)

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
	@echo "OK: generated Steps, Calendar, and Battery icon PNGs"

$(ICON_GEN_DIR):
	@mkdir -p "$(ICON_GEN_DIR)"

$(STEPS_BLACK): $(STEPS_SVG) | $(ICON_GEN_DIR)
	$(call render_svg_black,$(STEPS_SVG),$(STEPS_BLACK),16,16)

$(STEPS_WHITE): $(STEPS_BLACK)
	$(call negate_to_white,$(STEPS_BLACK),$(STEPS_WHITE),16,16)

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
