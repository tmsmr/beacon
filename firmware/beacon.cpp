#include "pico/stdlib.h"
#include <sk6812.h>
#include "tusb.h"
#include "config.h"

static auto led = SK6812(1, SK6812_PIN);

[[noreturn]] int main() {
    led.begin();

    tusb_init();

    while (true) {
        tud_task();
    }
}

uint16_t tud_hid_get_report_cb(
    const uint8_t instance, const uint8_t report_id, const hid_report_type_t report_type,
    const uint8_t *buffer, const uint16_t reqlen
) {
    (void) instance;
    (void) report_id;
    (void) report_type;
    (void) buffer;
    (void) reqlen;
    return 0;
}

void tud_hid_set_report_cb(
    const uint8_t instance, const uint8_t report_id, const hid_report_type_t report_type,
    const uint8_t *buffer, const uint16_t bufsize
) {
    (void) instance;
    (void) report_id;
    (void) report_type;

    char ret[] = {0x00};
    if (bufsize != 5 || report_id != 0x00) {
        ret[0] = 0x01;
    } else {
        led.setPixelColor(0, buffer[2], buffer[3], buffer[4], 0);
        led.show();
    }
    tud_hid_report(0, ret, 1);
}

void tud_mount_cb() {
}

void tud_umount_cb() {
}
