+++
title = "Get Mac Serial Number Programmatically With Cgo"
date = "2018-12-01"
slug = "2018/12/01/get-mac-serial-number-programmatically-with-cgo"
Categories = ["macOS", "Go", "Golang", "Cgo", "IOKit"]
+++

I recently had the occassion to obtain the serial number from a Mac within a Go program. Rather than shelling out to `system_profiler` or `ioreg`, I opted to use [Cgo][1] and retrieve the serial number via the `IOKit` framework. Here's how that looks:

``` go
package main

// #cgo LDFLAGS: -framework CoreFoundation -framework IOKit
// #include <CoreFoundation/CoreFoundation.h>
// #include <IOKit/IOKitLib.h>
//
// const char *
// getSerialNumber()
// {
//     CFMutableDictionaryRef matching = IOServiceMatching("IOPlatformExpertDevice");
//     io_service_t service = IOServiceGetMatchingService(kIOMasterPortDefault, matching);
//     CFStringRef serialNumber = IORegistryEntryCreateCFProperty(service,
//         CFSTR("IOPlatformSerialNumber"), kCFAllocatorDefault, 0);
//     const char *str = CFStringGetCStringPtr(serialNumber, kCFStringEncodingUTF8);
//     IOObjectRelease(service);
//
//     return str;
// }
import "C"

import (
	"fmt"
)

func main() {
	serialNumber := C.GoString(C.getSerialNumber())
	fmt.Println(serialNumber)
}
```

Make sure that the `import C` line goes directly below the C code, otherwise it will fail with something like the following:

```sh
./get_mac_serial_number.go:26:29: could not determine kind of name for C.getSerialNumber
```

Hopefully this helps the next time you need to get the serial number of a Mac in [Golang][2]!

[1]: https://blog.golang.org/c-go-cgo
[2]: https://golang.org/
