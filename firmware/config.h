#ifndef BEACON_CONFIG_H
#define BEACON_CONFIG_H

// LED
#define SK6812_PIN 0

// USB
#define BEACON_USB_VID 0x1209
#define BEACON_USB_PID 0x0001 // TODO: get one at https://pid.codes/
#define BEACON_USB_DEVICE_VER 0x0010
#define BEACON_MANUFACTURER "tmsmr"
#define BEACON_PRODUCT_NAME "beacon"

#define POWER_CONSUMPTION_MA 100 // TODO: measure

#endif //BEACON_CONFIG_H
