//
//  ViewController.swift
//  AVVPNService
//
//  Created by Andrey Vasilev on 17.04.2020.
//  Copyright © 2020 Andrey Vasilev. All rights reserved.
//

import UIKit
import AVVPNService

class ViewController: UITableViewController {

    let interactor = Interactor()

    override func viewDidLoad() {
        super.viewDidLoad()
        interactor.viewController = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: "ConfigCell", bundle: nil), forCellReuseIdentifier: "ConfigCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1, 2: return 1
        case 3: return interactor.info == nil ? 1 : 2
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath)
            cell.detailTextLabel?.text = interactor.type.rawValue
            return cell
        case 1: return self.tableView(tableView, configCellForRowAt: indexPath)
        case 2:
            let identifier: String
            switch interactor.state {
            case .disconnected: identifier = "ConnectCell"
            case .connected: identifier = "DisconnectCell"
            case .processing:
                let cell = tableView.dequeueReusableCell(withIdentifier: "ProcessingCell", for: indexPath)
                (cell as? ProcessingCell)?.activityIndicator.startAnimating()
                return cell
            }
            return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        case 3:
            if indexPath.row == 0 {
                return tableView.dequeueReusableCell(withIdentifier: "ReloadCell", for: indexPath)
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)
                cell.textLabel?.text = interactor.info
                return cell
            }
        default: return UITableViewCell()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: 0, section: 0) {
            performSegue(withIdentifier: "SelectTypeSegue", sender: nil)
        } else if indexPath == IndexPath(row: 0, section: 2) {
            if interactor.state == .disconnected {
                connect()
            } else {
                interactor.disconnect()
            }
        } else if indexPath == IndexPath(row: 0, section: 3) {
            interactor.reloadIpLocation()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectTypeSegue" {
            (segue.destination as? SelectTypeController)?.interactor = interactor
        }
    }
}

private extension ViewController {

    func tableView(_ tableView: UITableView, configCellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier: String
        switch interactor.type {
        case .ipsec: identifier = "IPSecConfigurationCell"
        case .ike2: identifier = "IKEv2ConfigurationCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)

//         Set credentials for testing faster
//        if let configCell = cell as? IPSecConfigurationCell {
//            configCell.serverTextField.text = ""
//            configCell.usernameTextField.text = ""
//            configCell.passwordTextField.text = ""
//            configCell.sharedTextField.text = ""
//        } else if let configCell = cell as? IKEv2ConfigurationCell {
//            configCell.serverTextField.text = ""
//            configCell.usernameTextField.text = ""
//            configCell.passwordTextField.text = ""
//            configCell.remoteTextField.text = ""
//            configCell.localTextField.text = ""
//        }
        return cell
    }

    func connect() {
        let credentials = getCredentials()
        interactor.connect(credentials: credentials)
    }

    func getCredentials() -> AVVPNCredentials? {
        let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
        if let cell = cell as? IPSecConfigurationCell {
            let server = cell.serverTextField.text ?? ""
            let username = cell.usernameTextField.text ?? ""
            let password = cell.passwordTextField.text ?? ""
            let key = cell.sharedTextField.text ?? ""
            guard [server, username, password, key].filter({ !$0.isEmpty }).count == 4 else { return nil }
            return AVVPNCredentials.IPSec(server: server, username: username, password: password, shared: key)
        } else if let cell = cell as? IKEv2ConfigurationCell {
            let server = cell.serverTextField.text ?? ""
            let username = cell.usernameTextField.text ?? ""
            let password = cell.passwordTextField.text ?? ""
            let remote = cell.remoteTextField.text ?? ""
            let local = cell.localTextField.text ?? ""
            guard [server, username, password, remote].filter({ !$0.isEmpty }).count == 4 else { return nil }
            return AVVPNCredentials.IKEv2(server: server, username: username, password: password, remoteId: remote, localId: local)
        } else {
            return nil
        }
    }
}

