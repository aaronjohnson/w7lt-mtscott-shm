# shm_alerts

OTP application: threshold monitoring and alert dispatch.

## GenServers

- `Shm.Alerts.TiltMonitor` — subscribes to tilt measurements via Phoenix.PubSub,
  maintains a sliding window, computes rate-of-change via linear regression,
  fires alerts when thresholds are crossed
- `Shm.Alerts.Dispatcher` — receives alert structs, dispatches via configured
  channels (Swoosh email, Twilio SMS, APRS packet)

## Alert channels

| Channel | Library | Config key |
|---|---|---|
| Email | Swoosh | `:alert_email`, `:smtp_*` |
| SMS | Req + Twilio REST API | `:twilio_sid`, `:twilio_token` |
| APRS | Custom UDP/KISS frame | `:aprs_callsign`, `:aprs_host` |

