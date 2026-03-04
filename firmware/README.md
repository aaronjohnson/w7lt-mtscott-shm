# firmware/

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

