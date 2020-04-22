//
//  Interactor.swift
//  AVVPNService
//
//  Created by Andrey Vasilev on 17.04.2020.
//  Copyright © 2020 Andrey Vasilev. All rights reserved.
//

import UIKit
import NetworkExtension
import AVVPNService

class Interactor {

    enum State {
        case disconnected, processing, connected
    }

    weak var viewController: ViewController?

    private let vpnService = AVVPNService.shared
    private var reloadIpLocationTask: URLSessionDataTask?

    var type: AVVPNType = .ipsec {
        didSet {
            if oldValue != type {
                vpnService.removeConfiguration()
            }
        }
    }
    var info: String? { didSet { viewController?.tableView.reloadData() } }
    lazy var state: State = .disconnected

    init() {
        vpnService.delegate = self
    }

    func connect(credentials: AVVPNCredentials) {
        guard state == .disconnected else { return }
        vpnService.connect(credentials: credentials) { [weak self] in
            if let error = $0 {
                self?.presentAlert(error.localizedDescription)
            }
        }
    }

    func disconnect() {
        vpnService.disconnect()
    }

    func reloadIpLocation() {
        guard let url = URL(string: "https://ipapi.co/json") else {
            info = "Invalid request url"
            return
        }
        reloadIpLocationTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.info = error.localizedDescription
                } else if let data = data,
                    let text = String(data: data, encoding: .utf8) {
                    self?.info = text
                } else {
                    self?.info = "Invalid response"
                }
            }
        }
        reloadIpLocationTask?.resume()
    }

    func presentAlert(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        viewController?.present(alert, animated: true, completion: nil)
    }
}

extension Interactor: AVVPNServiceDelegate {

    func vpnService(_ service: AVVPNService, didChange status: NEVPNStatus) {
        switch status {
        case .invalid:
            print("The VPN is not configured")
            state = .disconnected
        case .disconnected:
            print("The VPN is disconnected")
            state = .disconnected
        case .connecting:
            print("The VPN is connecting")
            state = .processing
        case .connected:
            print("The VPN is connected")
            state = .connected
        case .reasserting:
            print("The VPN is reconnecting following loss of underlying network connectivity")
            state = .processing
        case .disconnecting:
            print("The VPN is disconnecting")
            state = .processing
        @unknown default:
            print("The VPN status \(status) not handled")
        }
        viewController?.tableView.reloadData()
    }
}
