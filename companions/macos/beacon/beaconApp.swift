import SwiftUI
import IOKit.hid

@main
struct beaconApp: App {
    @State private var beacon = Beacon()
    
    var body: some Scene {
        MenuBarExtra(
            "Beacon",
            systemImage: "light.beacon.max"
        ) {
            Button("Red") {
                beacon.setColor(r: 255, g: 0, b: 0)
            }.keyboardShortcut("r")
            Button("Green") {
                beacon.setColor(r: 0, g: 255, b: 0)
            }.keyboardShortcut("g")
            Button("Blue") {
                beacon.setColor(r: 0, g: 0, b: 255)
            }.keyboardShortcut("b")
        }
    }
}

@MainActor
class Beacon {
    let vendorId = 0x1209
    let productId = 0x0001
    
    var hidManager: IOHIDManager?
    var hidDevice: IOHIDDevice?
    var connected: Bool = false
    
    func connected(
        _ inResult: IOReturn,
        inSender: UnsafeMutableRawPointer,
        inIOHIDDeviceRef: IOHIDDevice
    ) {
        self.hidDevice = inIOHIDDeviceRef
        self.connected = true
        
        let openResult = IOHIDDeviceOpen(
            inIOHIDDeviceRef,
            IOOptionBits(kIOHIDOptionsTypeNone)
        )
        if openResult == kIOReturnSuccess {
            print("Beacon connected and opened successfully")
        } else {
            print("Failed to open device connection. Code: \(openResult)")
        }
    }
    
    func removed(
        _ inResult: IOReturn,
        inSender: UnsafeMutableRawPointer,
        inIOHIDDeviceRef: IOHIDDevice
    ) {
        self.connected = false
        self.hidDevice = nil
        print("Beacon removed")
    }
    
    func setColor(r: UInt8, g: UInt8, b: UInt8) {
        guard let device = self.hidDevice, connected else {
            print("Cannot send data: Beacon is not connected yet.")
            return
        }
        
        var buffer: [UInt8] = [0x00, 0x00, r, g, b]
        
        let returnCode = IOHIDDeviceSetReport(
            device,
            kIOHIDReportTypeOutput,
            CFIndex(0),
            &buffer,
            buffer.count
        )
        
        if returnCode == kIOReturnSuccess {
            print("Successfully sent \(buffer.count) bytes!")
        } else {
            print(
                "Failed to send data. Error code (Hex): 0x\(String(returnCode, radix: 16))"
            )
        }
    }
    
    init() {
        hidManager = IOHIDManagerCreate(
            kCFAllocatorDefault,
            IOOptionBits(kIOHIDOptionsTypeNone)
        )
        guard let manager = hidManager else { return }
        
        let deviceMatch = [
            kIOHIDProductIDKey: productId,
            kIOHIDVendorIDKey: vendorId
        ]
        IOHIDManagerSetDeviceMatching(manager, deviceMatch as CFDictionary?)
        
        let matchingCallback: IOHIDDeviceCallback = {
            inContext,
            inResult,
            inSender,
            inIOHIDDeviceRef in
            guard let context = inContext else { return }
            let this = Unmanaged<Beacon>.fromOpaque(context).takeUnretainedValue()
            Task { @MainActor in
                this
                    .connected(
                        inResult,
                        inSender: inSender!,
                        inIOHIDDeviceRef: inIOHIDDeviceRef
                    )
            }
        }
        
        let removalCallback: IOHIDDeviceCallback = {
            inContext,
            inResult,
            inSender,
            inIOHIDDeviceRef in
            guard let context = inContext else { return }
            let this = Unmanaged<Beacon>.fromOpaque(context).takeUnretainedValue()
            Task { @MainActor in
                this
                    .removed(
                        inResult,
                        inSender: inSender!,
                        inIOHIDDeviceRef: inIOHIDDeviceRef
                    )
            }
        }
        
        let thisPointer = Unmanaged.passRetained(self).toOpaque()
        IOHIDManagerRegisterDeviceMatchingCallback(
            manager,
            matchingCallback,
            thisPointer
        )
        IOHIDManagerRegisterDeviceRemovalCallback(
            manager,
            removalCallback,
            thisPointer
        )
        
        IOHIDManagerScheduleWithRunLoop(
            manager,
            CFRunLoopGetCurrent(),
            CFRunLoopMode.defaultMode.rawValue
        )
        IOHIDManagerOpen(manager, IOOptionBits(kIOHIDOptionsTypeNone))
    }
}
