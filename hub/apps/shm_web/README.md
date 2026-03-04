# shm_web

OTP application: Phoenix LiveView kiosk dashboard and REST API.

## LiveView pages

| Route | Description |
|---|---|
| `/` | Current status: tilt magnitude, bearing, trend arrow, node health |
| `/history` | 24 h tilt time-series, N–S and E–W components |
| `/trend` | 30-day moving average with linear regression (°/month) |
| `/vibration` | RMS and spectral plot, fundamental frequency vs baseline |
| `/sensors` | Per-tier per-unit status, cross-calibration delta table |

## Kiosk mode

```bash
# Run Chromium in kiosk mode pointing at localhost
chromium-browser --kiosk --noerrdialogs http://localhost:4000
```

Add to `/etc/xdg/lxsession/LXDE-pi/autostart` for auto-start on Pi boot.

