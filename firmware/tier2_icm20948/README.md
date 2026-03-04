# firmware/tier2_icm20948/

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

