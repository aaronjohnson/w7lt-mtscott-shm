# firmware/tier1_mpu6050/

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

