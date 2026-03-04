# firmware/tier3_bno055/

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
embedded ARM Cortex-M0 co-processor. Experiment: is Bosch's fusion better
than hand-rolled Madgwick on the ICM-20948? Is the convenience worth the cost
delta and the black-box opacity?

## Files (to be created)

- `tier3_bno055.ino` — main sketch

