# priv/migrations/

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
SELECT create_hypertable('tilt_readings', 'time');
SELECT create_hypertable('vibration_readings', 'time');
SELECT create_hypertable('node_health', 'time');
```

