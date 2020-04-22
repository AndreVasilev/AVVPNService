# AVVPNService

[![Version](https://img.shields.io/cocoapods/v/AVVPNService.svg?style=flat)](https://cocoapods.org/pods/AVVPNService)
[![License](https://img.shields.io/cocoapods/l/AVVPNService.svg?style=flat)](https://cocoapods.org/pods/AVVPNService)
[![Platform](https://img.shields.io/cocoapods/p/AVVPNService.svg?style=flat)](https://cocoapods.org/pods/AVVPNService)

## Requirements
- iOS 9.3+
- Swift 5.0

## Installation

AVVPNService is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```swift
pod 'AVVPNService'
```
or just add AVVPNService/Classes/ to your project

## Usage

Select Signing & Capabilities pane of the project editor -> Add **Personal VPN** capability

```swift
import AVVPNService

// Initialize Credentials
let credentials = Credentials.IPSec(server: "", username: "", password: "", shared: "")
// or
let credentials = Credentials.IKEv2(server: "", username: "", password: "", remoteId: "", localId: "")

// Connect
AVVPNService.shared.connect(credentialas) { error in
// Handle error
}

//Disconnect
AVVPNService.shared.disconnect()
```
You can also observe NEVPNStatus

```swift
import AVVPNService
import NetworkExtension

// Set delegate
AVVPNService.shared.delegate = self

// and conform to AVVPNServiceDelegate
func vpnService(_ service: AVVPNService, didChange status: NEVPNStatus)
```
Or subscribe NEVPNStatusDidChange notification

```swift
import AVVPNService
import NetworkExtension

NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatus(_:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)

@objc func didChangeStatus(_ notification: Notification) {
    if let connection = notification.object as? NEVPNConnection {
        print(connection.statu)
    }
}
```

## Author

Andrey Vasilev (ao.vasilev@gmail.com)

## Credits

[Create a key chain for Apple's VPN](http://blog.moatazthenervous.com/create-a-key-chain-for-apples-vpn/), Moataz Elmasry

## License

AVVPNService is available under the MIT license. See the LICENSE file for more info.
