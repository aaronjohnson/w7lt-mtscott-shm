# shm_ingest

OTP application: MQTT subscriber and time-series database writer.

Subscribes to `w7lt/mtscott/pole/#` via `tortoise311`, decodes JSON payloads,
and inserts rows into TimescaleDB hypertables via Ecto.

## Key modules (to be created)

- `Shm.Ingest.MqttClient` — tortoise311 handler, topic routing
- `Shm.Ingest.Writer` — Ecto changesets, batch insert to TimescaleDB
- `Shm.Ingest.TopicParser` — parse MQTT topic string into structured metadata
  `{tier, sensor, unit_id, measurement_type, axis}`

