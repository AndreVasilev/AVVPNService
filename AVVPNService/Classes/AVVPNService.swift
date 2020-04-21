//
//  AVVPNService.swift
//  AVVPNService
//
//  Created by Andrey Vasilev on 17.04.2020.
//  Copyright © 2020 Andrey Vasilev. All rights reserved.
//

import Foundation
import NetworkExtension

public protocol AVVPNServiceDelegate: AnyObject {
    func vpnService(_ service: AVVPNService, didChange status: NEVPNStatus)
}

public class AVVPNService {

    public static let shared = AVVPNService()
    public weak var delegate: AVVPNServiceDelegate?
    public let vpnManager = NEVPNManager.shared()
    public var status: NEVPNStatus { return vpnManager.connection.status }

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatus(_:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }

    public func connect(credentials: Credentials, _ completion: @escaping (Error?) -> Void) {
        //For no known reason the process of saving/loading the VPN configurations fails. On the 2nd time it works
        guard let protocolConfiguration: NEVPNProtocol = getProtocolConfiguration(credentials) else {
            fatalError("Unhandled credentials")
        }
        vpnManager.loadFromPreferences(completionHandler: loadHandler(configuration: protocolConfiguration, description: credentials.title, completion))
    }

    public func disconnect() ->Void {
        vpnManager.connection.stopVPNTunnel()
    }
}

// MARK: Protocol Configuration

private extension AVVPNService {
    func getProtocolConfiguration(_ credentials: Credentials) -> NEVPNProtocol? {
        if credentials.type == .ipsec,
            let credentials = credentials as? Credentials.IPSec {
            return getProtocolConfiguration(credentials)
        } else if credentials.type == .ike2,
            let credentials = credentials as? Credentials.IKEv2 {
            return getProtocolConfiguration(credentials)
        } else {
            return nil
        }
    }

    func getProtocolConfiguration(_ credentials: Credentials.IPSec) -> NEVPNProtocolIPSec {
        let configuration = NEVPNProtocolIPSec()
        configuration.username = credentials.username
        configuration.serverAddress = credentials.server
        configuration.authenticationMethod = NEVPNIKEAuthenticationMethod.sharedSecret
        let keychain = AVVPNKeychainService();
        keychain.save(key: AVVPNKeychainService.sharedKey, value: credentials.shared)
        keychain.save(key: AVVPNKeychainService.passwordKey, value: credentials.password)
        configuration.sharedSecretReference = keychain.load(key: AVVPNKeychainService.sharedKey)
        configuration.passwordReference = keychain.load(key: AVVPNKeychainService.passwordKey)
        configuration.useExtendedAuthentication = true
        configuration.disconnectOnSleep = false
        return configuration
    }

    func getProtocolConfiguration(_ credentials: Credentials.IKEv2) -> NEVPNProtocolIKEv2 {
        let configuration = NEVPNProtocolIKEv2()
        configuration.username = credentials.username
        configuration.serverAddress = credentials.server
        configuration.remoteIdentifier = credentials.remoteId
        configuration.localIdentifier = credentials.localId
        configuration.authenticationMethod = NEVPNIKEAuthenticationMethod.none
        let keychain = AVVPNKeychainService();
        keychain.save(key: AVVPNKeychainService.passwordKey, value: credentials.password)
        configuration.passwordReference = keychain.load(key: AVVPNKeychainService.passwordKey)
        configuration.useExtendedAuthentication = true
        configuration.disconnectOnSleep = false
        return configuration
    }
}

// MARK: Connection lifecycle

private extension AVVPNService {

    @objc func didChangeStatus(_ notification: Notification) {
        if let connection = notification.object as? NEVPNConnection {
            delegate?.vpnService(self, didChange: connection.status)
        }
    }

    func loadHandler(configuration: NEVPNProtocol, description: String, _ completion: @escaping (Error?) -> Void) -> (Error?) -> Void {
        return { error in
            guard error == nil else {
                print("⚠️ Could not load VPN Configurations")
                return completion(error)
            }

            self.vpnManager.isEnabled = true
            self.vpnManager.localizedDescription = description
            self.vpnManager.protocolConfiguration = configuration
            self.vpnManager.saveToPreferences(completionHandler: self.saveHandler(completion))
    } }

    func saveHandler(_ completion: @escaping (Error?) -> Void) -> (Error?) -> Void {
        return { error in
            guard error == nil else {
                print("⚠️ Could not save VPN Configurations")
                return completion(error)
            }

            do {
                try self.vpnManager.connection.startVPNTunnel()
                completion(nil)
            } catch let error {
                print("⚠️ Starting VPN Tunnel failed: \(error.localizedDescription)");
                completion(error)
            }
        }
    }
}
