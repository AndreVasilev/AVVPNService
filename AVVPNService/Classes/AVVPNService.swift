//
//  AVVPNService.swift
//  AVVPNService
//
//  Created by Andrey Vasilev on 17.04.2020.
//  Copyright © 2020 Andrey Vasilev. All rights reserved.
//

import Foundation
import NetworkExtension

public class AVVPNService {

    public static let shared = AVVPNService()
    public weak var delegate: AVVPNServiceDelegate?
    public let vpnManager = NEVPNManager.shared()
    public var status: NEVPNStatus { return vpnManager.connection.status }

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeStatus(_:)), name: NSNotification.Name.NEVPNStatusDidChange, object: nil)
    }

    //Set credentials = nil if you don't want to re-save protocolConfiguration
    public func connect(credentials: AVVPNCredentials? = nil, _ completion: @escaping (Error?) -> Void) {
        vpnManager.loadFromPreferences(completionHandler: loadHandler(credentials: credentials, toSave: true, completion))
    }

    public func disconnect() {
        vpnManager.connection.stopVPNTunnel()
    }

    public func removeConfiguration( _ completion: ((Error?) -> Void)? = nil) {
        vpnManager.removeFromPreferences() {
            AVVPNUserDefaultsService.didRemovePreferences()
            if let error = $0 {
                print("⚠️ Could not remove VPN Configuration: \(error.localizedDescription)")
            }
            if let completion = completion {
                completion($0)
            }
        }
    }
}

// MARK: Protocol Configuration

private extension AVVPNService {
    func getProtocolConfiguration(_ credentials: AVVPNCredentials) -> NEVPNProtocol? {
        if credentials.type == .ipsec,
            let credentials = credentials as? AVVPNCredentials.IPSec {
            return getProtocolConfiguration(credentials)
        } else if credentials.type == .ike2,
            let credentials = credentials as? AVVPNCredentials.IKEv2 {
            return getProtocolConfiguration(credentials)
        } else {
            return nil
        }
    }

    func getProtocolConfiguration(_ credentials: AVVPNCredentials.IPSec) -> NEVPNProtocolIPSec {
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

    func getProtocolConfiguration(_ credentials: AVVPNCredentials.IKEv2) -> NEVPNProtocolIKEv2 {
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

    func loadHandler(credentials: AVVPNCredentials?, toSave: Bool, _ completion: @escaping (Error?) -> Void) -> (Error?) -> Void {
        return { error in
            guard error == nil else {
                print("⚠️ Could not load VPN Configuration: \(error!.localizedDescription)")
                return completion(error)
            }
            if let credentials = credentials,
                toSave {
                self.vpnManager.isEnabled = true
                self.vpnManager.localizedDescription = credentials.title
                self.vpnManager.protocolConfiguration = self.delegate?.getProtocolConfiguration(credentials) ?? self.getProtocolConfiguration(credentials)
                self.vpnManager.saveToPreferences(completionHandler: self.saveHandler(credentials: credentials, completion))
            } else {
                //Add delay if protocolConfiguration was saved. Otherwise protocolConfiguration won't be reset
                let delay = toSave ? 0 : 0.3
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                    self?.startVPNTunnel(credentials: credentials, completion)
                }
            }
        }
    }

    func saveHandler(credentials: AVVPNCredentials, _ completion: @escaping (Error?) -> Void) -> (Error?) -> Void {
        return { error in
            guard error == nil else {
                print("⚠️ Could not save VPN Configuration: \(error!.localizedDescription)")
                return completion(error)
            }
            self.vpnManager.loadFromPreferences(completionHandler: self.loadHandler(credentials: credentials, toSave: false, completion))
        }
    }

    func startVPNTunnel(credentials: AVVPNCredentials?, _ completion: @escaping (Error?) -> Void) {
        guard vpnManager.protocolConfiguration != nil else {
            return completion(NEVPNError(.configurationInvalid))
        }
        do {
            try vpnManager.connection.startVPNTunnel()
            completion(nil)
        } catch let error {
            print("⚠️ Starting VPN Tunnel failed: \(error.localizedDescription)");
            if (error as? NEVPNError)?.code == NEVPNError.Code.configurationInvalid,
                !AVVPNUserDefaultsService.isPreferencesSaved {
                //For no known reason the process of saving/loading the VPN configurations fails. On the 2nd time it works
                connect(credentials: credentials, completion)
                AVVPNUserDefaultsService.didSavePreferences()
            } else {
                completion(error)
            }
        }
    }
}
