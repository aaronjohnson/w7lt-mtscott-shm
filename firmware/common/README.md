# firmware/common/

Shared utilities included by all sensor tier sketches via `#include "../common/..."`.

## Files (to be created)

| File | Purpose |
|---|---|
| `wifi_manager.h` | WiFi connect/reconnect with exponential backoff |
| `mqtt_client.h` | MQTT connect, publish, subscribe wrappers around `arduino-mqtt` |
| `deep_sleep.h` | ESP32 deep-sleep entry with configurable wake interval |
| `tilt_math.h` | `atan2`-based tilt angle computation from raw accelerometer axes |
| `topic_builder.h` | Construct MQTT topic strings from tier/sensor/unit/measurement constants |
| `config.h.example` | Template for WiFi SSID/password, MQTT broker IP, unit ID (copy to `config.h`, gitignored) |

## config.h

`config.h` is gitignored — copy `config.h.example` and fill in your credentials:

```cpp
#define WIFI_SSID     "your-ssid"
#define WIFI_PASS     "your-password"
#define MQTT_HOST     "192.168.1.x"   // Raspberry Pi hub IP
#define MQTT_PORT     1883
#define UNIT_ID       "unit01"
#define SAMPLE_INTERVAL_S  60
```

