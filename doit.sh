#!/usr/bin/env bash
# scaffold_repo.sh
# W7LT Mt. Scott SHM — repository directory scaffold
# Run from inside your cloned repo root: bash scaffold_repo.sh
# KD7VDG — March 2026
#
# Idempotent: safe to re-run. Will not overwrite existing files.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Scaffolding repo at: ${REPO_ROOT}"

# ── helper ────────────────────────────────────────────────────────────────────
write_file() {
  local path="$1"
  local content="$2"
  if [[ -f "$path" ]]; then
    echo "  [skip]  $path"
  else
    mkdir -p "$(dirname "$path")"
    printf '%s\n' "$content" > "$path"
    echo "  [write] $path"
  fi
}

# ── move loose .tex files from root into docs/ ────────────────────────────────
mkdir -p "${REPO_ROOT}/docs"
for tex in mt_scott_mast_final.tex pole_monitoring.tex qex_preprint_v0.1.0.tex; do
  if [[ -f "${REPO_ROOT}/${tex}" ]]; then
    mv "${REPO_ROOT}/${tex}" "${REPO_ROOT}/docs/${tex}"
    echo "  [moved] ${tex} → docs/${tex}"
  fi
done

# ── docs/ ─────────────────────────────────────────────────────────────────────
write_file "${REPO_ROOT}/docs/README.md" \
'# docs/

Technical documentation for the W7LT Mt. Scott SHM project.

## LaTeX sources

| File | Status | Description |
|---|---|---|
| `mt_scott_mast_final.tex` | Complete | Mast plumb-correction analysis: rotated-bearing geometry, wind loading, field procedure |
| `pole_monitoring.tex` | Complete | SHM system design: sensors, MQTT architecture, Elixir/Phoenix stack |
| `qex_preprint_v0.1.0.tex` | Draft | QEX article preprint — mast correction (pending Trip 2 confirmation measurements) |

## BOM

| File | Description |
|---|---|
| `bom/w7lt_bom_v1.0.0.xlsx` | DigiKey order, ~$710 total, four sensor tiers + hub + power |

## Build

Requires a standard TeX Live installation (`texlive-latex-extra`, `texlive-science`).

```bash
cd docs
pdflatex mt_scott_mast_final.tex
pdflatex pole_monitoring.tex
pdflatex qex_preprint_v0.1.0.tex
```

## Notes

- `qex_preprint_v0.1.0.tex` is a working draft. The label `v0.1.0` will advance
  to `v1.0.0` after Trip 2 measurements confirm pipe OD and bracket standoff gap.
- Do not submit to QEX until checking ARRL prior-publication policy with the editor.
  The ARRL publication release requires that material has not been previously
  published; confirm whether a public GitHub draft constitutes prior publication
  before signing the release form.
'

# ── docs/bom/ ─────────────────────────────────────────────────────────────────
write_file "${REPO_ROOT}/docs/bom/.gitkeep" ''

# ── firmware/ ─────────────────────────────────────────────────────────────────
write_file "${REPO_ROOT}/firmware/README.md" \
'# firmware/

ESP32 sensor node firmware — one subdirectory per sensor tier.

## Structure

```
firmware/
├── common/              # Shared WiFi, MQTT, deep-sleep, I2C helpers
├── tier1_mpu6050/       # Tier 1: MPU-6050 (±0.5°, I2C, $12)
├── tier2_icm20948/      # Tier 2: ICM-20948 (±0.3°, 9-DOF, I2C, $17)
├── tier3_bno055/        # Tier 3: BNO055 (on-chip Bosch fusion, I2C, $30)
└── tier4_adxl355/       # Tier 4: ADXL355 (25 µg/√Hz, SPI, $44)
```

## Toolchain

- Arduino IDE 2.x or PlatformIO (VS Code extension)
- Board: `esp32:esp32:esp32s3` (primary), `esp32:esp32:esp32c3` (low-power alt)
- Required libraries (install via Arduino Library Manager or `platformio.ini`):
  - `arduino-mqtt` (Joël Gähwiler) — MQTT client
  - `MPU6050` (Electronic Cats) — Tier 1
  - `ICM_20948` (SparkFun) — Tier 2
  - `Adafruit BNO055` + `Adafruit Unified Sensor` — Tier 3
  - `ADXL355` (Analog Devices or community) — Tier 4
  - `Adafruit BME280` — environmental sensor

## MQTT Topic Pattern

```
w7lt/mtscott/pole/{tier}/{sensor}/{unit_id}/{measurement_type}/{axis}
```

Example: `w7lt/mtscott/pole/tier4/adxl355/unit01/tilt/magnitude`

## Sample Interval

- Tilt: 60 s (1,440 readings/day)
- Vibration burst: 10 min, or on-demand via `command/vibration_burst`
- Deep sleep between readings; average current draw ~0.8 mA at 60 s interval

## Power Budget

| Mode | Current |
|---|---|
| Active (read + publish) | ~80 mA |
| Deep sleep | ~10 µA |
| Average at 60 s interval | ~0.81 mA |
| 2000 mAh LiPo autonomy | ~100 days |

A 1 W solar panel sustains indefinite operation in Portland winter conditions.
'

# ── firmware/common/ ──────────────────────────────────────────────────────────
write_file "${REPO_ROOT}/firmware/common/README.md" \
'# firmware/common/

Shared utilities included by all sensor tier sketches via `#include "../common/..."`.

## Files (to be created)

| File | Purpose |
|---|---|
| `wifi_manager.h` | WiFi connect/reconnect with exponential backoff |
| `mqtt_client.h` | MQTT connect, publish, subscribe wrappers around `arduino-mqtt` |
| `deep_sleep.h` | ESP32 deep-sleep entry with configurable wake interval |
| `tilt_math.h` | `atan2`-based tilt angle computation from raw accelerometer axes |
| `topic_builder.h` | Construct MQTT topic strings from tier/sensor/unit/measurement constants |
| `config.h.example` | Template for WiFi SSID/password, MQTT broker IP, unit ID (copy to `config.h`, gitignored) |

## config.h

`config.h` is gitignored — copy `config.h.example` and fill in your credentials:

```cpp
#define WIFI_SSID     "your-ssid"
#define WIFI_PASS     "your-password"
#define MQTT_HOST     "192.168.1.x"   // Raspberry Pi hub IP
#define MQTT_PORT     1883
#define UNIT_ID       "unit01"
#define SAMPLE_INTERVAL_S  60
```
'

# ── firmware/tier1_mpu6050/ ───────────────────────────────────────────────────
write_file "${REPO_ROOT}/firmware/tier1_mpu6050/README.md" \
'# firmware/tier1_mpu6050/

Tier 1 sensor node firmware for the MPU-6050 (InvenSense, 6-DOF).

## Sensor Spec

| Parameter | Value |
|---|---|
| Static tilt accuracy | ±0.5° |
| Interface | I2C (address 0x68 / 0x69) |
| Accelerometer full scale | ±2g (default), ±4/8/16g |
| Gyroscope full scale | ±250°/s (default) |
| Sample rate (accel) | up to 1 kHz |
| Cost | ~$12 (SparkFun SEN-17697 Qwiic breakout) |

## Metrology Role

Cost floor. The question this sensor answers: *how bad is cheap, really?*
Allan variance and cross-calibration against the ADXL355 reference will
characterize where the MPU-6050 breaks down (noise floor, temperature drift,
long-term zero-g offset).

## Wiring (ESP32-S3)

| MPU-6050 pin | ESP32-S3 pin |
|---|---|
| VCC | 3.3V |
| GND | GND |
| SDA | GPIO8 (or Qwiic SDA) |
| SCL | GPIO9 (or Qwiic SCL) |
| AD0 | GND (address 0x68) |

## Files (to be created)

- `tier1_mpu6050.ino` — main sketch
'

# ── firmware/tier2_icm20948/ ──────────────────────────────────────────────────
write_file "${REPO_ROOT}/firmware/tier2_icm20948/README.md" \
'# firmware/tier2_icm20948/

Tier 2 sensor node firmware for the ICM-20948 (TDK InvenSense, 9-DOF).

## Sensor Spec

| Parameter | Value |
|---|---|
| Static tilt accuracy | ±0.3° |
| Interface | I2C (address 0x68 / 0x69) or SPI |
| DOF | 9 (accel + gyro + magnetometer AK09916) |
| On-chip DMP | Yes (Digital Motion Processor) |
| Cost | ~$15–18 (SparkFun SEN-15335 or Adafruit 4554) |

## Metrology Role

Manual fusion candidate. Two board variants ordered (SparkFun + Adafruit) to
cross-validate board-level noise between PCB layouts of the same silicon.
Experiment: compare raw + manual Madgwick/Mahony fusion vs the BNO055 Bosch
on-chip fusion (Tier 3). Quantifies "is the fusion algorithm in firmware or
in hardware worth paying for?"

## Files (to be created)

- `tier2_icm20948.ino` — main sketch
'

# ── firmware/tier3_bno055/ ────────────────────────────────────────────────────
write_file "${REPO_ROOT}/firmware/tier3_bno055/README.md" \
'# firmware/tier3_bno055/

Tier 3 sensor node firmware for the BNO055 (Bosch Sensortec, 9-DOF with on-chip fusion).

## Sensor Spec

| Parameter | Value |
|---|---|
| Static tilt accuracy | ±0.5° (fused output) |
| Interface | I2C (address 0x28 / 0x29) |
| On-chip fusion | Yes — Bosch BSX fusion; outputs Euler angles and quaternions directly |
| Operating modes | IMU, NDOF, NDOF_FMC_OFF |
| Cost | ~$30 (Adafruit 4646 STEMMA QT) |

## Metrology Role

Firmware fusion benchmark. The BNO055 outputs calibrated Euler angles and
quaternions from proprietary Bosch sensor fusion firmware running on an
embedded ARM Cortex-M0 co-processor. Experiment: is Bosch'\''s fusion better
than hand-rolled Madgwick on the ICM-20948? Is the convenience worth the cost
delta and the black-box opacity?

## Files (to be created)

- `tier3_bno055.ino` — main sketch
'

# ── firmware/tier4_adxl355/ ───────────────────────────────────────────────────
write_file "${REPO_ROOT}/firmware/tier4_adxl355/README.md" \
'# firmware/tier4_adxl355/

Tier 4 sensor node firmware for the ADXL355 (Analog Devices, research-grade
3-axis MEMS accelerometer).

## Sensor Spec

| Parameter | Value |
|---|---|
| Noise density | 25 µg/√Hz |
| Tilt resolution (with averaging) | sub-0.01° |
| Interface | SPI (up to 10 MHz) |
| Full scale | ±2g, ±4g, ±8g (selectable) |
| Self-test | Yes |
| Cost | ~$44–46 (Analog Devices EVAL-ADXL355-PMDZ or EVAL-ADXL355Z) |

## Metrology Role

Reference standard ("truth"). All other tiers are calibrated against this
sensor. The ADXL355 is used in seismology, civil engineering SHM, and
precision tilt measurement. 25 µg/√Hz noise density enables sub-0.01° tilt
resolution with 100-sample averaging (√100 noise reduction).

Two board form factors ordered:
- `EVAL-ADXL355-PMDZ` — Pmod connector, stiffer PCB
- `EVAL-ADXL355Z` — standalone breakout, smaller footprint

Compare board resonance between the two layouts under vibration.

## Wiring (ESP32-S3, SPI)

| ADXL355 pin | ESP32-S3 pin |
|---|---|
| VDD / VDDIO | 3.3V |
| GND | GND |
| SCLK | GPIO12 (SPI CLK) |
| MOSI | GPIO11 (SPI MOSI) |
| MISO | GPIO13 (SPI MISO) |
| CS | GPIO10 (or any GPIO) |
| INT1 / INT2 | GPIO14 / GPIO15 (optional) |

Note: ADXL355 eval boards may include a 3.3V regulator and level shifters.
Check board schematic before connecting directly to 3.3V logic.

## Files (to be created)

- `tier4_adxl355.ino` — main sketch
'

# ── hub/ ─────────────────────────────────────────────────────────────────────
write_file "${REPO_ROOT}/hub/README.md" \
'# hub/

Elixir/Phoenix umbrella application running on the Raspberry Pi 5 hub in the shack.

## Architecture

```
hub/
├── apps/
│   ├── shm_ingest/      # MQTT subscriber + TimescaleDB writer
│   ├── shm_web/         # Phoenix LiveView kiosk + REST API
│   └── shm_alerts/      # Alerting GenServer (email, SMS, APRS)
├── config/
│   ├── config.exs
│   ├── dev.exs
│   └── runtime.exs      # secrets via env vars, never committed
└── priv/
    └── migrations/      # Ecto migrations for Postgres/TimescaleDB
```

## Prerequisites

- Elixir ~> 1.16, OTP ~> 26
- PostgreSQL 15+ with TimescaleDB extension
- Mosquitto MQTT broker (runs on same Pi)

```bash
sudo apt install postgresql timescaledb-postgresql-15 mosquitto mosquitto-clients
```

## Setup

```bash
cd hub
mix deps.get
mix ecto.create && mix ecto.migrate
mix phx.server
```

LiveView kiosk: http://localhost:4000

## Configuration

Copy `config/runtime.exs.example` to `config/runtime.exs` and set:

```elixir
config :shm_ingest,
  mqtt_host: "localhost",
  mqtt_port: 1883,
  db_url: "ecto://postgres:postgres@localhost/shm_dev"

config :shm_alerts,
  twilio_sid: System.get_env("TWILIO_SID"),
  twilio_token: System.get_env("TWILIO_TOKEN"),
  alert_email: "kd7vdg@example.com"
```

## MQTT Topics Consumed

```
w7lt/mtscott/pole/#     # all pole telemetry
```

Pattern: `w7lt/mtscott/pole/{tier}/{sensor}/{unit_id}/{measurement_type}/{axis}`

## Alerting Thresholds (initial values — tune after baseline)

| Condition | Threshold | Priority |
|---|---|---|
| Tilt change | > 0.5°/day | High — email + SMS |
| Tilt trend | > 0.1°/week | Medium — email |
| Vibration RMS | > 0.5g | Medium — log + email |
| Natural freq drop | > 10% from baseline | High — email + SMS |
| Sensor offline | > 2 h | Low — email |
| Node battery | < 3.3V | Low — email |

## OTP Supervision Tree

```
Shm.Application
├── Shm.Ingest.Supervisor
│   ├── Shm.Ingest.MqttClient        # tortoise311 connection
│   └── Shm.Ingest.Writer            # batched TimescaleDB inserts
├── Shm.Web.Endpoint                 # Phoenix LiveView
└── Shm.Alerts.Supervisor
    ├── Shm.Alerts.TiltMonitor       # sliding window regression
    └── Shm.Alerts.Dispatcher        # email / SMS / APRS
```
'

# ── hub/apps/ subdirs ─────────────────────────────────────────────────────────
write_file "${REPO_ROOT}/hub/apps/shm_ingest/README.md" \
'# shm_ingest

OTP application: MQTT subscriber and time-series database writer.

Subscribes to `w7lt/mtscott/pole/#` via `tortoise311`, decodes JSON payloads,
and inserts rows into TimescaleDB hypertables via Ecto.

## Key modules (to be created)

- `Shm.Ingest.MqttClient` — tortoise311 handler, topic routing
- `Shm.Ingest.Writer` — Ecto changesets, batch insert to TimescaleDB
- `Shm.Ingest.TopicParser` — parse MQTT topic string into structured metadata
  `{tier, sensor, unit_id, measurement_type, axis}`
'

write_file "${REPO_ROOT}/hub/apps/shm_web/README.md" \
'# shm_web

OTP application: Phoenix LiveView kiosk dashboard and REST API.

## LiveView pages

| Route | Description |
|---|---|
| `/` | Current status: tilt magnitude, bearing, trend arrow, node health |
| `/history` | 24 h tilt time-series, N–S and E–W components |
| `/trend` | 30-day moving average with linear regression (°/month) |
| `/vibration` | RMS and spectral plot, fundamental frequency vs baseline |
| `/sensors` | Per-tier per-unit status, cross-calibration delta table |

## Kiosk mode

```bash
# Run Chromium in kiosk mode pointing at localhost
chromium-browser --kiosk --noerrdialogs http://localhost:4000
```

Add to `/etc/xdg/lxsession/LXDE-pi/autostart` for auto-start on Pi boot.
'

write_file "${REPO_ROOT}/hub/apps/shm_alerts/README.md" \
'# shm_alerts

OTP application: threshold monitoring and alert dispatch.

## GenServers

- `Shm.Alerts.TiltMonitor` — subscribes to tilt measurements via Phoenix.PubSub,
  maintains a sliding window, computes rate-of-change via linear regression,
  fires alerts when thresholds are crossed
- `Shm.Alerts.Dispatcher` — receives alert structs, dispatches via configured
  channels (Swoosh email, Twilio SMS, APRS packet)

## Alert channels

| Channel | Library | Config key |
|---|---|---|
| Email | Swoosh | `:alert_email`, `:smtp_*` |
| SMS | Req + Twilio REST API | `:twilio_sid`, `:twilio_token` |
| APRS | Custom UDP/KISS frame | `:aprs_callsign`, `:aprs_host` |
'

# ── hub/priv/migrations/ ──────────────────────────────────────────────────────
write_file "${REPO_ROOT}/hub/priv/migrations/README.md" \
'# priv/migrations/

Ecto migrations for the PostgreSQL + TimescaleDB schema.

## Schema overview (to be created via `mix ecto.gen.migration`)

### `tilt_readings` (TimescaleDB hypertable, partitioned by `time`)

| Column | Type | Notes |
|---|---|---|
| time | timestamptz | partition key |
| tier | smallint | 1–4 |
| sensor | text | mpu6050, icm20948, bno055, adxl355 |
| unit_id | text | unit01, unit02, ... |
| tilt_ns | float4 | degrees, N–S component |
| tilt_ew | float4 | degrees, E–W component |
| tilt_magnitude | float4 | degrees, total |
| tilt_bearing | float4 | degrees from N |
| site_h3 | text | H3 res-15 cell index |

### `vibration_readings` (hypertable)

| Column | Type | Notes |
|---|---|---|
| time | timestamptz | |
| unit_id | text | |
| rms_g | float4 | RMS acceleration in g |
| peak_g | float4 | |
| fundamental_hz | float4 | from FFT |

### `node_health` (hypertable)

| Column | Type | Notes |
|---|---|---|
| time | timestamptz | |
| unit_id | text | |
| battery_v | float4 | |
| solar_v | float4 | |
| rssi_dbm | smallint | |
| uptime_s | int | |

### `alert_log` (plain table)

| Column | Type | Notes |
|---|---|---|
| id | bigserial | |
| inserted_at | timestamptz | |
| level | text | high, medium, low |
| condition | text | human-readable trigger description |
| value | float4 | measured value that triggered alert |
| threshold | float4 | configured threshold |
| channels | text[] | dispatched to: email, sms, aprs |

## TimescaleDB setup

```sql
CREATE EXTENSION IF NOT EXISTS timescaledb;
SELECT create_hypertable('\''tilt_readings'\'', '\''time'\'');
SELECT create_hypertable('\''vibration_readings'\'', '\''time'\'');
SELECT create_hypertable('\''node_health'\'', '\''time'\'');
```
'

# ── analysis/ ─────────────────────────────────────────────────────────────────
write_file "${REPO_ROOT}/analysis/README.md" \
'# analysis/

Python Jupyter notebooks for post-hoc metrology analysis.
These operate on data exported from TimescaleDB; they are not part of the
real-time pipeline.

## Notebooks

| Notebook | Purpose | Status |
|---|---|---|
| `allan_variance.ipynb` | Compute Allan deviation σ(τ) per sensor tier at multiple averaging times | Pending data |
| `cross_calibration.ipynb` | Inter-tier accuracy: each tier vs ADXL355 reference under same stimulus | Pending data |
| `thermal_compensation.ipynb` | Tilt residual vs BME280 temperature; fit linear correction coefficient | Pending data |
| `spectral_analysis.ipynb` | FFT of vibration bursts; track natural frequency over time | Pending data |

## Environment

```bash
python -m venv .venv && source .venv/bin/activate
pip install jupyter numpy scipy pandas matplotlib psycopg2-binary allantools
jupyter lab
```

## Data export from TimescaleDB

```sql
COPY (
  SELECT time, tier, sensor, unit_id, tilt_magnitude
  FROM tilt_readings
  WHERE time > now() - interval '\''30 days'\''
  ORDER BY time
) TO '\''tilt_export.csv'\'' CSV HEADER;
```

## Allan Variance note

`allantools` (Python) computes overlapping Allan deviation from a uniformly
sampled time series. For tilt monitoring, use the raw accelerometer output
at the sensor'\''s native rate (500 Hz for MPU-6050, 4 kHz for ADXL355), not
the 60-second averaged MQTT publishes. Capture high-rate raw data via a
separate firmware mode and store in the `vibration_readings` table.

Reference: IEEE Std 1139-2008, *Standard Definitions of Physical Quantities
for Fundamental Frequency and Time Metrology*.
'

# ── LICENSE ───────────────────────────────────────────────────────────────────
YEAR=$(date +%Y)
write_file "${REPO_ROOT}/LICENSE" \
"MIT License

Copyright (c) ${YEAR} KD7VDG / Portland Amateur Radio Club (W7LT)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE."

# ── .gitignore ────────────────────────────────────────────────────────────────
write_file "${REPO_ROOT}/.gitignore" \
'# Elixir / Phoenix
_build/
deps/
*.ez
.elixir_ls/
hub/config/runtime.exs
hub/apps/*/config/runtime.exs

# Firmware secrets
firmware/common/config.h
firmware/**/config.h

# Python
analysis/.venv/
analysis/__pycache__/
analysis/.ipynb_checkpoints/
*.pyc

# LaTeX build artifacts
docs/*.aux
docs/*.log
docs/*.out
docs/*.toc
docs/*.fls
docs/*.fdb_latexmk
docs/*.synctex.gz

# Data exports (large, not source)
analysis/*.csv
analysis/*.parquet

# OS
.DS_Store
Thumbs.db
'

# ── summary ───────────────────────────────────────────────────────────────────
echo ""
echo "────────────────────────────────────────────────────────"
echo " Scaffold complete. Directory structure:"
echo "────────────────────────────────────────────────────────"
find "${REPO_ROOT}" \
  -not -path "*/.git/*" \
  -not -name ".git" \
  | sort \
  | sed "s|${REPO_ROOT}/||" \
  | sed 's|[^/]*/|  |g'
echo "────────────────────────────────────────────────────────"
echo ""
echo "Suggested next steps:"
echo "  1. git add -A && git commit -m 'scaffold: directory structure and README stubs'"
echo "  2. cd hub && mix new . --umbrella (when ready to start Elixir work)"
echo "  3. Rename docs/qex_preprint_v0.1.0.tex → qex_draft_v0.1.0.tex"
echo "     until QEX editor confirms preprint policy in writing."
echo ""
echo "73 de KD7VDG"
