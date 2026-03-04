# analysis/

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
  WHERE time > now() - interval '30 days'
  ORDER BY time
) TO 'tilt_export.csv' CSV HEADER;
```

## Allan Variance note

`allantools` (Python) computes overlapping Allan deviation from a uniformly
sampled time series. For tilt monitoring, use the raw accelerometer output
at the sensor's native rate (500 Hz for MPU-6050, 4 kHz for ADXL355), not
the 60-second averaged MQTT publishes. Capture high-rate raw data via a
separate firmware mode and store in the `vibration_readings` table.

Reference: IEEE Std 1139-2008, *Standard Definitions of Physical Quantities
for Fundamental Frequency and Time Metrology*.

