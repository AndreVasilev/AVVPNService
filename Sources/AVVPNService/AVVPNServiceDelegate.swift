//
//  AVVPNServiceDelegate.swift
//  AVVPNService
//
//  Created by Andrey Vasilev on 28.04.2020.
//

import Foundation
import NetworkExtension

public protocol AVVPNServiceDelegate: AnyObject {

    func vpnService(_ service: AVVPNService, didChange status: NEVPNStatus)

    //Configure custom NEVPNProtocol for given AVVPNCredentials
    func getProtocolConfiguration<T: AVVPNCredentials>(_ credentials: T) -> NEVPNProtocol?
}

public extension AVVPNServiceDelegate {

    func vpnService(_ service: AVVPNService, didChange status: NEVPNStatus) { /* Do nothing */}

    func getProtocolConfiguration<T: AVVPNCredentials>(_ credentials: T) -> NEVPNProtocol? { return nil }
}
