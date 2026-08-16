#include "pico/stdlib.h"
#include <sk6812.h>
#include "tusb.h"
#include "tusb_config.h"
#include "config.h"

static volatile bool change_pending = false;
static uint8_t inbound_buffer[CFG_TUD_HID_EP_BUFSIZE] = {};

[[noreturn]] int main() {
    tusb_init();
    auto led = SK6812(1, SK6812_PIN);
    led.begin();

    while (true) {
        tud_task();

        if (change_pending && tud_hid_ready()) {
            char ret[] = {0x00};
            tud_hid_report(0, ret, 1);
            led.setPixelColor(0, inbound_buffer[2], inbound_buffer[3], inbound_buffer[4], 0);
            led.show();
            change_pending = false;
        }
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

    memcpy(inbound_buffer, buffer, bufsize);
    change_pending = true;
}

void tud_mount_cb() {
}

void tud_umount_cb() {
}
