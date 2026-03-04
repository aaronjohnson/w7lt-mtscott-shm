# firmware/tier4_adxl355/

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

