# CLAUDE.md

## Project Overview

W7LT Mt. Scott Structural Health Monitoring (SHM) — a precision MEMS accelerometer monitoring platform for the Portland Amateur Radio Club's (W7LT) repeater antenna mast on Mt. Scott, Portland, OR. The project combines embedded sensor firmware, an Elixir/Phoenix data hub, and Python analysis notebooks.

The repository spans three concerns:
1. **Geometric mast correction** — rotated-bearing geometry to plumb a leaning antenna pole (analysis complete, field trip 2 pending)
2. **Four-tier comparative MEMS metrology** — MPU-6050, ICM-20948, BNO055, ADXL355 running side-by-side
3. **Real-time monitoring platform** — Elixir/Phoenix + PostgreSQL/TimescaleDB on Raspberry Pi 5

**License:** Apache 2.0

## Repository Structure

```
w7lt-mtscott-shm/
├── CLAUDE.md                    # This file
├── README.md                    # Project overview and site parameters
├── LICENSE                      # Apache 2.0
├── doit.sh                     # Idempotent repo scaffold script (bash)
├── .gitignore
├── docs/                       # LaTeX technical documents
│   ├── qex_preprint_v0.1.0.tex # QEX article preprint (mast correction)
│   └── bom/                    # Bill of materials
├── firmware/                   # ESP32 sensor node firmware (C++/Arduino)
│   ├── common/                 # Shared WiFi, MQTT, deep-sleep helpers
│   ├── tier1_mpu6050/          # MPU-6050 node (±0.5°, I2C, cost floor)
│   ├── tier2_icm20948/         # ICM-20948 node (±0.3°, 9-DOF, I2C)
│   ├── tier3_bno055/           # BNO055 node (Bosch on-chip fusion, I2C)
│   └── tier4_adxl355/          # ADXL355 node (25 µg/√Hz, SPI, reference)
├── hub/                        # Elixir/Phoenix umbrella app (Raspberry Pi)
│   ├── apps/
│   │   ├── shm_ingest/         # MQTT subscriber + TimescaleDB writer
│   │   ├── shm_web/            # Phoenix LiveView kiosk + REST API
│   │   └── shm_alerts/         # Alerting GenServer (email, SMS, APRS)
│   └── priv/migrations/        # Ecto migrations for TimescaleDB
└── analysis/                   # Python Jupyter notebooks (post-hoc)
```

## Current State

The project is in early development. The repository currently contains:
- Scaffold structure with README stubs in each directory
- Completed LaTeX mast correction analysis (`docs/qex_preprint_v0.1.0.tex`)
- No firmware source code yet (`.ino` files are planned)
- No Elixir/Phoenix application code yet (umbrella app not yet initialized)
- No Jupyter notebooks yet (pending sensor data)

## Tech Stack

| Layer | Technology | Notes |
|---|---|---|
| Sensor firmware | C++/Arduino or MicroPython | ESP32-S3 / ESP32-C3, PlatformIO or Arduino IDE 2.x |
| Transport | MQTT (Mosquitto) | Topic: `w7lt/mtscott/pole/{tier}/{sensor}/{unit_id}/{measurement_type}/{axis}` |
| Application | Elixir/Phoenix | BEAM VM, OTP supervision, umbrella app |
| MQTT client | tortoise311 | Elixir GenServer per topic |
| Database | PostgreSQL 15+ with TimescaleDB | Time-series hypertables |
| Dashboard | Phoenix LiveView | Real-time kiosk, no JS framework |
| Analysis | Python (Jupyter) | numpy, scipy, pandas, matplotlib, allantools |
| Documents | LaTeX | pdflatex, texlive-latex-extra, texlive-science |

## Development Commands

### Elixir/Phoenix Hub (when initialized)

```bash
cd hub
mix deps.get              # Install dependencies
mix ecto.create           # Create database
mix ecto.migrate          # Run migrations
mix phx.server            # Start Phoenix server (localhost:4000)
mix test                  # Run tests
mix format                # Format Elixir code
mix credo                 # Static analysis (if configured)
```

### Firmware (Arduino/PlatformIO)

```bash
# Arduino CLI
arduino-cli compile --fqbn esp32:esp32:esp32s3 firmware/tier1_mpu6050/
arduino-cli upload --fqbn esp32:esp32:esp32s3 --port /dev/ttyUSB0 firmware/tier1_mpu6050/

# PlatformIO alternative
cd firmware/tier1_mpu6050 && pio run && pio run -t upload
```

### Python Analysis

```bash
cd analysis
python -m venv .venv && source .venv/bin/activate
pip install jupyter numpy scipy pandas matplotlib psycopg2-binary allantools
jupyter lab
```

### LaTeX Documents

```bash
cd docs
pdflatex qex_preprint_v0.1.0.tex
```

## Key Conventions

### MQTT Topic Namespace

All sensor data follows a strict topic hierarchy:
```
w7lt/mtscott/pole/{tier}/{sensor}/{unit_id}/{measurement_type}/{axis}
```
- Tiers: `tier1` through `tier4`
- Sensors: `mpu6050`, `icm20948`, `bno055`, `adxl355`
- Measurement types: `tilt`, `vibration`, `battery_v`, `solar_v`, etc.
- Axes: `ns`, `ew`, `magnitude`, `bearing`, `rms`

### Sensor Tier Numbering

| Tier | Sensor | Role |
|---|---|---|
| 1 | MPU-6050 | Cost floor baseline |
| 2 | ICM-20948 | Manual fusion candidate |
| 3 | BNO055 | On-chip fusion benchmark |
| 4 | ADXL355 | Reference standard ("truth") |

Tier 4 (ADXL355) is the calibration reference. All other tiers are compared against it.

### Firmware Conventions

- Each tier has its own directory under `firmware/`
- Shared code lives in `firmware/common/` and is included via `#include "../common/..."`
- `config.h` is gitignored — copy `config.h.example` and fill in credentials
- Default sample interval: 60 seconds for tilt, 10-minute bursts for vibration
- ESP32 deep sleep between readings (~10 µA sleep current)

### Elixir/Phoenix Conventions

- Umbrella application with three OTP apps: `shm_ingest`, `shm_web`, `shm_alerts`
- `runtime.exs` is gitignored — secrets via environment variables
- OTP supervision tree with dedicated GenServers per concern
- TimescaleDB hypertables for time-series data (`tilt_readings`, `vibration_readings`, `node_health`)
- Phoenix.PubSub for internal event distribution between apps

### Database Schema

Key tables (all TimescaleDB hypertables partitioned by `time`):
- `tilt_readings` — per-sensor tilt data (ns, ew, magnitude, bearing)
- `vibration_readings` — RMS acceleration, peak, fundamental frequency
- `node_health` — battery voltage, solar voltage, RSSI, uptime
- `alert_log` — plain table for alert history

### Units and Measurement

- Tilt angles: degrees
- Acceleration: g (gravity units)
- Vibration: RMS g
- Frequency: Hz
- Voltage: V
- Temperature: from BME280 environmental sensor
- Geospatial: H3 resolution 15 (site identifier only, not for structural measurement)

## Files to Never Commit

- `firmware/common/config.h` and `firmware/**/config.h` — WiFi/MQTT credentials
- `hub/config/runtime.exs` — database URLs, API keys
- `analysis/*.csv` and `analysis/*.parquet` — exported data files
- Any `.env` files or credential files

## Important Context

- The ADXL355 uses SPI (not I2C like the other sensors) — firmware for tier4 requires different bus handling
- The H3 geospatial index is only a site key; structural measurement uses a local Cartesian frame tied to the IMU gravity vector
- The project follows metrology/uncertainty-budget thinking from semiconductor precision measurement
- LaTeX document `qex_preprint_v0.1.0.tex` is a working draft; version will advance to v1.0.0 after Trip 2 confirmation measurements
- Check ARRL prior-publication policy before submitting to QEX (public GitHub may affect eligibility)
