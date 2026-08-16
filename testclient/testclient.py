#!/usr/bin/env python3

import hid

BEACON_PRODUCT_NAME = "beacon"
BEACON_REPORT_LEN = 8

found = None
for dev in hid.enumerate():
    if dev["product_string"] == BEACON_PRODUCT_NAME:
        found = dev
        break

beacon = hid.device()
beacon.open(
    vendor_id=found["vendor_id"],
    product_id=found["product_id"]
)

try:
    vals =list(range(255))
    vals.extend(reversed(range(255)))
    for v in vals:
        values = [0, 0, 0, int(v/2), int((254-v)/2), 0]
        beacon.write(bytearray(values))
        ret = beacon.read(BEACON_REPORT_LEN)
        if ret != [0]*BEACON_REPORT_LEN:
            raise IOError("unexpected report data")
finally:
    beacon.close()
