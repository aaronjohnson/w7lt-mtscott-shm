# hub/

Elixir/Phoenix umbrella application running on the Raspberry Pi 5 hub in the shack.

## Architecture

```
hub/
├── apps/
│   ├── shm_ingest/      # MQTT subscriber + TimescaleDB writer
│   ├── shm_web/         # Phoenix LiveView kiosk + REST API
│   └── shm_alerts/      # Alerting GenServer (email, SMS, APRS)
├── config/
│   ├── config.exs
│   ├── dev.exs
│   └── runtime.exs      # secrets via env vars, never committed
└── priv/
    └── migrations/      # Ecto migrations for Postgres/TimescaleDB
```

## Prerequisites

- Elixir ~> 1.16, OTP ~> 26
- PostgreSQL 15+ with TimescaleDB extension
- Mosquitto MQTT broker (runs on same Pi)

```bash
sudo apt install postgresql timescaledb-postgresql-15 mosquitto mosquitto-clients
```

## Setup

```bash
cd hub
mix deps.get
mix ecto.create && mix ecto.migrate
mix phx.server
```

LiveView kiosk: http://localhost:4000

## Configuration

Copy `config/runtime.exs.example` to `config/runtime.exs` and set:

```elixir
config :shm_ingest,
  mqtt_host: "localhost",
  mqtt_port: 1883,
  db_url: "ecto://postgres:postgres@localhost/shm_dev"

config :shm_alerts,
  twilio_sid: System.get_env("TWILIO_SID"),
  twilio_token: System.get_env("TWILIO_TOKEN"),
  alert_email: "kd7vdg@example.com"
```

## MQTT Topics Consumed

```
w7lt/mtscott/pole/#     # all pole telemetry
```

Pattern: `w7lt/mtscott/pole/{tier}/{sensor}/{unit_id}/{measurement_type}/{axis}`

## Alerting Thresholds (initial values — tune after baseline)

| Condition | Threshold | Priority |
|---|---|---|
| Tilt change | > 0.5°/day | High — email + SMS |
| Tilt trend | > 0.1°/week | Medium — email |
| Vibration RMS | > 0.5g | Medium — log + email |
| Natural freq drop | > 10% from baseline | High — email + SMS |
| Sensor offline | > 2 h | Low — email |
| Node battery | < 3.3V | Low — email |

## OTP Supervision Tree

```
Shm.Application
├── Shm.Ingest.Supervisor
│   ├── Shm.Ingest.MqttClient        # tortoise311 connection
│   └── Shm.Ingest.Writer            # batched TimescaleDB inserts
├── Shm.Web.Endpoint                 # Phoenix LiveView
└── Shm.Alerts.Supervisor
    ├── Shm.Alerts.TiltMonitor       # sliding window regression
    └── Shm.Alerts.Dispatcher        # email / SMS / APRS
```

