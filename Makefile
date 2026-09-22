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
# Colors are preserved. Optional *_on_dark.svg selects dark-stripe artwork.
ICON_GEN_DIR   := resources/drawables/generated
CONVERT        := $(shell command -v convert 2>/dev/null)
SVG_SIZE       := scripts/svg-declared-size.sh
RENDER_PAIR    := scripts/render-svg-contrast-pair.sh

STEPS_SVG            := assets/icons-src/steps.svg
CALENDAR_TOP_SVG     := assets/icons-src/calendar_top.svg
CALENDAR_BOTTOM_SVG  := assets/icons-src/calendar_bottom.svg
BATTERY_FRAME_SVG    := assets/icons-src/battery_frame.svg

WEATHER_ICON_DIR     := assets/icons-src/weather
WEATHER_FAMILIES     := clear partly_cloudy cloudy rain thunderstorm snow unknown

STEPS_ON_LIGHT           := $(ICON_GEN_DIR)/steps_on_light.png
STEPS_ON_DARK            := $(ICON_GEN_DIR)/steps_on_dark.png
CAL_TOP_ON_LIGHT         := $(ICON_GEN_DIR)/calendar_top_on_light.png
CAL_TOP_ON_DARK          := $(ICON_GEN_DIR)/calendar_top_on_dark.png
CAL_BOTTOM_ON_LIGHT      := $(ICON_GEN_DIR)/calendar_bottom_on_light.png
CAL_BOTTOM_ON_DARK       := $(ICON_GEN_DIR)/calendar_bottom_on_dark.png
BATTERY_ON_LIGHT         := $(ICON_GEN_DIR)/battery_frame_on_light.png
BATTERY_ON_DARK          := $(ICON_GEN_DIR)/battery_frame_on_dark.png

WEATHER_ON_LIGHT_PNGS := $(foreach f,$(WEATHER_FAMILIES),$(ICON_GEN_DIR)/weather_$(f)_on_light.png)
WEATHER_ON_DARK_PNGS  := $(foreach f,$(WEATHER_FAMILIES),$(ICON_GEN_DIR)/weather_$(f)_on_dark.png)

GENERATED_PNGS := \
	$(STEPS_ON_LIGHT) $(STEPS_ON_DARK) \
	$(CAL_TOP_ON_LIGHT) $(CAL_TOP_ON_DARK) \
	$(CAL_BOTTOM_ON_LIGHT) $(CAL_BOTTOM_ON_DARK) \
	$(BATTERY_ON_LIGHT) $(BATTERY_ON_DARK) \
	$(WEATHER_ON_LIGHT_PNGS) $(WEATHER_ON_DARK_PNGS)

# Legacy Black/White names from earlier pipelines (removed on clean).
LEGACY_PNGS := \
	$(ICON_GEN_DIR)/steps_black.png $(ICON_GEN_DIR)/steps_white.png \
	$(ICON_GEN_DIR)/calendar_top_black.png $(ICON_GEN_DIR)/calendar_top_white.png \
	$(ICON_GEN_DIR)/calendar_bottom_black.png $(ICON_GEN_DIR)/calendar_bottom_white.png \
	$(ICON_GEN_DIR)/battery_frame_black.png $(ICON_GEN_DIR)/battery_frame_white.png \
	$(foreach f,$(WEATHER_FAMILIES),$(ICON_GEN_DIR)/weather_$(f)_black.png $(ICON_GEN_DIR)/weather_$(f)_white.png)

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

# Preserve SVG colors; optional *_on_dark.svg; else reuse base PNG bytes.
assets: $(GENERATED_PNGS)
	@echo "OK: generated OnLight/OnDark icon PNGs"

$(ICON_GEN_DIR):
	@mkdir -p "$(ICON_GEN_DIR)"

define render_contrast_pair
	@if [ ! -x "$(RENDER_PAIR)" ]; then chmod +x "$(RENDER_PAIR)"; fi
	@SVG_SIZE="$(SVG_SIZE)" "$(RENDER_PAIR)" "$(1)" "$(2)" "$(3)"
endef

$(STEPS_ON_LIGHT): $(STEPS_SVG) $(RENDER_PAIR) $(SVG_SIZE) | $(ICON_GEN_DIR)
	$(call render_contrast_pair,$(STEPS_SVG),$(STEPS_ON_LIGHT),$(STEPS_ON_DARK))

$(STEPS_ON_DARK): $(STEPS_ON_LIGHT)

$(CAL_TOP_ON_LIGHT): $(CALENDAR_TOP_SVG) $(RENDER_PAIR) $(SVG_SIZE) | $(ICON_GEN_DIR)
	$(call render_contrast_pair,$(CALENDAR_TOP_SVG),$(CAL_TOP_ON_LIGHT),$(CAL_TOP_ON_DARK))

$(CAL_TOP_ON_DARK): $(CAL_TOP_ON_LIGHT)

$(CAL_BOTTOM_ON_LIGHT): $(CALENDAR_BOTTOM_SVG) $(RENDER_PAIR) $(SVG_SIZE) | $(ICON_GEN_DIR)
	$(call render_contrast_pair,$(CALENDAR_BOTTOM_SVG),$(CAL_BOTTOM_ON_LIGHT),$(CAL_BOTTOM_ON_DARK))

$(CAL_BOTTOM_ON_DARK): $(CAL_BOTTOM_ON_LIGHT)

$(BATTERY_ON_LIGHT): $(BATTERY_FRAME_SVG) $(RENDER_PAIR) $(SVG_SIZE) | $(ICON_GEN_DIR)
	$(call render_contrast_pair,$(BATTERY_FRAME_SVG),$(BATTERY_ON_LIGHT),$(BATTERY_ON_DARK))

$(BATTERY_ON_DARK): $(BATTERY_ON_LIGHT)

define weather_icon_rules
$(ICON_GEN_DIR)/weather_$(1)_on_light.png: $(WEATHER_ICON_DIR)/$(1).svg $(RENDER_PAIR) $(SVG_SIZE) | $(ICON_GEN_DIR)
	$$(call render_contrast_pair,$(WEATHER_ICON_DIR)/$(1).svg,$(ICON_GEN_DIR)/weather_$(1)_on_light.png,$(ICON_GEN_DIR)/weather_$(1)_on_dark.png)

$(ICON_GEN_DIR)/weather_$(1)_on_dark.png: $(ICON_GEN_DIR)/weather_$(1)_on_light.png
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
	@rm -f $(GENERATED_PNGS) $(LEGACY_PNGS)
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
