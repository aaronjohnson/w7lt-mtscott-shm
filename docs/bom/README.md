# docs/bom/

Bill of materials for the W7LT Mt. Scott Structural Health Monitoring system.

## Files

| File | Description |
|---|---|
| `w7lt_bom_v1.0.0.xlsx` | Source of truth — full DigiKey order with line items, part numbers, quantities, unit and extended prices |
| `w7lt_bom_v1.0.0.pdf` | Rendered export — exhibit-ready, suitable for PIIA Exhibit A and printed field reference |

## Versioning

BOM files follow semver in the filename: `w7lt_bom_vX.Y.Z.{xlsx,pdf}`.

| Change type | Version bump | Example trigger |
|---|---|---|
| New line items or supplier swap | minor (Y) | Add ADXL357 units, swap to Mouser source |
| Quantity or price update only | patch (Z) | Reorder spares, price correction |
| Major scope change | major (X) | Phase 3 → Phase 4 hardware, new site added |

Both files are committed together. Do not commit one without the other — the PDF is the archival exhibit; the xlsx is the editable source.

## Summary — v1.0.0

**Total order: ~$710 (DigiKey, March 2026)**

| Category | Items | Ext. Cost |
|---|---|---|
| Microcontrollers (ESP32-S3, ESP32-C3) | 6 units | $71 |
| Tier 1 — MPU-6050 (×3) | I2C, ±0.5°, $12 ea | $35 |
| Tier 2 — ICM-20948 (×3) | I2C, 9-DOF, $15–18 ea | $50 |
| Tier 3 — BNO055 (×2) | I2C, on-chip fusion, $30 ea | $60 |
| Tier 4 — ADXL355 (×3) | SPI, 25 µg/√Hz, $44–46 ea | $134 |
| Environmental (BME280 ×2, soil ×2, LIS3MDL ×1) | — | $55 |
| Hub: Raspberry Pi 5 4GB + PSU + cooler + storage | — | $114 |
| Power: LiPo ×3, solar ×3, charge controller ×3 | — | $84 |
| Enclosures + mounting (NEMA 4X ×3, clamps, glands) | — | $52 |
| Interconnect + prototyping (Qwiic cables, breadboards, dupont) | — | $56 |
| **Subtotal** | | **$709.77** |
| Estimated shipping + tax | | ~$15–25 |

## Sensor Tier Reference

| Tier | Sensor | Role in metrology study |
|---|---|---|
| 1 | MPU-6050 | Cost floor — how bad is cheap? |
| 2 | ICM-20948 | Manual fusion candidate |
| 3 | BNO055 | Bosch on-chip fusion benchmark |
| 4 | ADXL355 | Reference standard ("truth") |

All four tiers are deployed simultaneously on a rigid aluminum plate for
cross-calibration. See `analysis/cross_calibration.ipynb`.

## PIIA / Open Source Reference

This BOM is part of the open-source W7LT Mt. Scott SHM project released under
the MIT License. It is referenced in the project PIIA (Proprietary Information
and Inventions Agreement) Exhibit A as pre-existing work and is explicitly
excluded from assignment. The public GitHub repository at
`https://github.com/aaronjohnson/w7lt-mtscott-shm` is the canonical reference.
