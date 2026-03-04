# W7LT Mt. Scott Structural Health Monitoring

**Portland Amateur Radio Club (W7LT) · Mt. Scott Repeater Site · KD7VDG**

[![Status](https://img.shields.io/badge/status-active%20development-green)](.)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE)

## About

This project brings precision measurement science to amateur radio infrastructure. The W7LT repeater site on Mt. Scott hosts a leaning antenna mast atop a wooden telephone pole at ~1,000 ft elevation overlooking Portland, OR. Rather than just fixing the lean and walking away, we turned it into a full structural health monitoring platform — continuous MEMS accelerometer sensing, real-time dashboards, and enough rigor to publish the results.

The work sits at the intersection of ham radio field engineering, embedded systems, and metrology. Four tiers of MEMS sensors (from a $5 MPU-6050 to a research-grade ADXL355) run side by side on the same mast, generating a comparative dataset that answers a practical question: how much sensor do you actually need to monitor a pole? The monitoring platform runs on Elixir/Phoenix with TimescaleDB for time-series storage, served from a Raspberry Pi in the repeater shack.

The project spans three interleaved concerns: (1) a geometric analysis and field correction of the leaning antenna pole, (2) a four-tier comparative MEMS accelerometer metrology study, and (3) a real-time monitoring platform built on Elixir/Phoenix and PostgreSQL/TimescaleDB.

This repository is also the research substrate for a series of QEX and IEEE Sensors Journal articles on applying precision measurement science to amateur radio infrastructure.

---

## Site Summary

| Parameter | Value |
|---|---|
| Site | Mt. Scott, Portland OR (~1,000 ft elevation) |
| Licensee | Portland Amateur Radio Club, W7LT |
| Property | City of Portland Water Bureau |
| Pole | Galvanized wooden telephone pole, 7.5″ diameter |
| Lean | 9.46° from vertical (measured 28 Feb 2026) |
| Lean displacement | 6.0″ over 36″ bracket span |
| Antenna mast | 3″ OD galvanized steel pipe, ~12 ft total |
| Orbit radius R | 9.75″ (pole radius + standoff gap + pipe radius) |
| Repeater | Motorola Quantar, 147.18 MHz, sector antenna |

---

## Mast Correction (Analysis Complete — Field Trip 2 Pending)

The lean is corrected by rotating the lower bracket bearing **68.7°** around the pole circumference, rather than shimming or guying. The geometry is derived from first principles: with orbit radius R = 9.75″, a chord of the orbit circle equal to the lean displacement at the new bracket span produces a plumb pipe. No standoff blocks are required.

Key results:

| Parameter | Value |
|---|---|
| Bracket span s | 66″ (5.5 ft) |
| Cantilever h | 66″ (k = 1.0) |
| Lower bracket rotation | 68.7° |
| Midspan clearance | 8.06″ (margin: 2.81″) |
| Max bracket force (60 mph) | 22.8 lb |
| All-thread safety factor | > 80× (proof load) |

Full derivation with citations: [`docs/mt_scott_mast_final.tex`](docs/mt_scott_mast_final.tex)

QEX preprint: [`docs/qex_preprint_v0.1.0.tex`](docs/qex_preprint_v0.1.0.tex)

---

## Sensor Tiers — Comparative Metrology

All four tiers are deployed simultaneously on a rigid aluminum plate to characterize absolute accuracy, noise floor, temperature sensitivity, and dynamic response.

| Tier | Sensor | Spec | Role | Units |
|---|---|---|---|---|
| 1 | MPU-6050 | ±0.5°, I2C | Cost floor | 3 |
| 2 | ICM-20948 | ±0.3°, 9-DOF, I2C | Manual fusion candidate | 3 |
| 3 | BNO055 | ±0.5° fused, I2C | On-chip Bosch fusion benchmark | 2 |
| 4 | ADXL355 | 25 µg/√Hz, SPI | Reference standard | 3 |

Experiments:

- **A** — All sensors, same rigid stimulus → cross-calibration matrix  
- **B** — 24 h no-wind baseline → Allan variance per tier  
- **C** — Thermal sweep (sunrise/sunset) → temperature coefficients  
- **D** — Known-shim controlled tilt → calibration transfer  
- **E** — Wind events → dynamic coherence across tiers  

---

## System Architecture

```
Pole (outdoor)                  Shack (indoor)
┌─────────────────────┐         ┌───────────────────────────┐
│  ESP32-S3 node      │  WiFi   │  Raspberry Pi 5           │
│  ├─ MPU-6050 (I2C)  │ ──────► │  ├─ Mosquitto (MQTT)      │
│  ├─ ICM-20948 (I2C) │  MQTT   │  ├─ Phoenix/Elixir app    │
│  ├─ BNO055 (I2C)   │         │  │  ├─ MQTT subscriber     │
│  ├─ ADXL355 (SPI)  │         │  │  ├─ LiveView kiosk      │
│  ├─ BME280 (I2C)   │         │  │  └─ Alerting GenServer  │
│  └─ Solar + LiPo   │         │  └─ PostgreSQL/TimescaleDB │
└─────────────────────┘         └───────────────────────────┘
                                          │
                                    Internet (optional)
                                    ├─ Email / SMS alerts
                                    ├─ APRS telemetry
                                    └─ Remote dashboard
```

### MQTT Topic Namespace

```
w7lt/mtscott/pole/{tier}/{sensor}/{unit_id}/{measurement_type}/{axis}
```

Examples:
```
w7lt/mtscott/pole/tier1/mpu6050/unit01/tilt/ns
w7lt/mtscott/pole/tier4/adxl355/unit01/tilt/magnitude
w7lt/mtscott/pole/tier4/adxl355/unit01/vibration/rms
w7lt/mtscott/pole/node/unit01/battery_v
```

---

## Tech Stack

| Layer | Technology | Notes |
|---|---|---|
| Sensor firmware | C++/Arduino or MicroPython | ESP32-S3 / ESP32-C3 |
| Transport | MQTT (Mosquitto) | Pub/sub, decoupled producers/consumers |
| Application | Elixir/Phoenix | BEAM VM; OTP supervision |
| MQTT client | tortoise311 | Elixir; GenServer per topic |
| Database | PostgreSQL + TimescaleDB | Time-series hypertables |
| Dashboard | Phoenix LiveView | Real-time kiosk; no JS framework |
| Alerting | Elixir GenServer | Email, SMS (Twilio), APRS |
| Geospatial | H3 res-15 | Site identifier only; not structural measurement |
| Analysis | Python (Jupyter) | Allan variance, FFT, cross-correlation |

---

## Repository Structure

```
w7lt-mtscott-shm/
│
├── README.md                        # This file
├── LICENSE
│
├── docs/                            # Technical documentation (LaTeX)
│   ├── mt_scott_mast_final.tex      # Mast correction analysis (complete)
│   ├── pole_monitoring.tex          # SHM system design document
│   ├── qex_preprint_v0.1.0.tex      # QEX article preprint: mast correction
│   └── bom/
│       └── w7lt_bom_v1.0.0.xlsx     # DigiKey BOM (~$710 total)
│
├── firmware/                        # ESP32 sensor node firmware
│   ├── tier1_mpu6050/               # MPU-6050 node (Arduino/C++)
│   ├── tier2_icm20948/              # ICM-20948 node
│   ├── tier3_bno055/                # BNO055 node
│   ├── tier4_adxl355/               # ADXL355 node (SPI)
│   └── common/                      # Shared MQTT, WiFi, deep-sleep helpers
│
├── hub/                             # Elixir/Phoenix umbrella application
│   ├── apps/
│   │   ├── shm_ingest/              # MQTT subscriber + DB writer
│   │   ├── shm_web/                 # Phoenix LiveView kiosk + API
│   │   └── shm_alerts/              # Alerting GenServer
│   ├── config/
│   └── priv/
│       └── migrations/              # PostgreSQL/TimescaleDB schemas
│
└── analysis/                        # Python notebooks
    ├── allan_variance.ipynb          # Noise floor characterization
    ├── spectral_analysis.ipynb       # Vibration FFT, natural frequency
    ├── thermal_compensation.ipynb    # Temperature coefficient extraction
    └── cross_calibration.ipynb      # Inter-tier accuracy comparison
```

---

## Implementation Phases

| Phase | Deliverable | HW Cost | Status |
|---|---|---|---|
| 0 | Mast correction analysis | $0 | ✅ Complete |
| 1 | ESP32 + MPU-6050 → MQTT → Pi → Postgres → LiveView | ~$40 | 🔧 In progress |
| 2 | Solar power, weatherproof enclosures, alerting | ~$30 | ⏳ Pending |
| 3 | Full 4-tier metrology array, kiosk display | ~$60 | ⏳ Pending |
| 4 | Multi-site, APRS telemetry, publication | $0 (software) | ⏳ Ongoing |

Field Trip 2 (mast correction with ballast): scheduled after hardware arrival.

---

## Publications

| Venue | Title | Status |
|---|---|---|
| QEX | Plumb Correction of a Leaning Antenna Mast by Rotated-Bearing Geometry | Draft — `docs/qex_preprint_v0.1.0.tex` |
| QEX | Structural Health Monitoring for a Wooden Telephone Pole Antenna Mast | Outline pending |
| QEX | Comparative MEMS Tilt Metrology for Amateur Radio Infrastructure SHM | Data pending |
| IEEE Sensors | (expanded metrology study) | Data pending |

---

## Hardware BOM Summary

Total DigiKey order: **~$710** (see [`docs/bom/w7lt_bom_v1.0.0.xlsx`](docs/bom/w7lt_bom_v1.0.0.xlsx))

Major line items: ESP32 nodes ($71), ADXL355 eval boards ($134), BNO055 ($60), ICM-20948 ($50), MPU-6050 ($35), Raspberry Pi 5 ($85), solar/LiPo power ($84), enclosures/mounting ($52), interconnect/prototyping ($56).

---

## Development Notes

- Claude Code is used for firmware and hub application code generation; experience is being documented for a blog series on AI-assisted engineering
- Measurement science philosophy traces to Intel/ASML precision metrology exposure — same uncertainty budget thinking, six orders of magnitude less stringent
- The H3 geospatial index is used as a compact, hierarchically queryable site key at resolution 15 (≈0.5 m hex edge). It is **not** used for structural measurement, which operates in a local Cartesian frame tied to the IMU gravity vector

---

## License

Apache 2.0 — see [LICENSE](LICENSE)

---

*73 de KD7VDG · Portland Amateur Radio Club · [w7lt.org](https://w7lt.org)*
