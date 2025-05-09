|                  | No external pull-up | External pull-up 47kΩ |
| ---------------- | ------------------- | --------------------- |
| No chip in reset | 3.30V               | 3.3V                  |
| RV1106 in reset  | 1.72V               | 2.16V                 |
| ESP32 in reset   | 3.30V               | 3.3V                  |
| Both in reset    | 0V                  | 1.32V                 |

In the setting where both are in reset, if i release the reset state of the ESP32 it shortly drops down to 0.7V until the firmware has started.

Repeated using pre compiled esp-hosted firmware. Linux host unchanged:

|                  | External pull-up 47kΩ |
| ---------------- | --------------------- |
| No chip in reset | 3.3V                  |
| RV1106 in reset  | 1.32V                 |
| ESP32 in reset   | 3.3V                  |
| Both in reset    | 1.32V                 |

Difference between those firmware: probably internal pull-up resistor

Then I cutted the PCB trace, pull up resistor is on ESP32 side:

| External pull-up 47kΩ | ESP32 Side | SoC Side |
| --------------------- | ---------- | -------- |
| IC in reset           | 3.3V       | 0V       |
| IC not in reset       | 3.3V       | 3.3V     |
| IC booting            | 1V         | N/A      |