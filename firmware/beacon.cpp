#include "pico/stdlib.h"
#include <sk6812.h>
#include "tusb.h"

#define SK6812_PIN 0

[[noreturn]] int main() {
    auto led = SK6812(1, SK6812_PIN);
    led.begin();

    led.setPixelColor(0, 255, 0, 0, 0);
    led.show();

    tusb_init();

    while (true) {
        tud_task();
    }
}

uint16_t tud_hid_get_report_cb(
    uint8_t instance, uint8_t report_id, hid_report_type_t report_type, uint8_t *buffer, uint16_t reqlen
) {
    return 0;
}

void tud_hid_set_report_cb(
    uint8_t instance, uint8_t report_id, hid_report_type_t report_type, uint8_t const *buffer, uint16_t bufsize
) {
}
