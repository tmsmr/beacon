#include "pico/stdlib.h"
#include <sk6812.h>

#define SK6812_PIN 0

[[noreturn]] int main() {
    auto led = SK6812(1, SK6812_PIN);
    led.begin();

    led.setPixelColor(0, 255, 0, 0, 0);
    led.show();

    while (true) {
    }
}
