//
//  SelectTypeController.swift
//  AVVPNService
//
//  Created by Andrey Vasilev on 17.04.2020.
//  Copyright © 2020 Andrey Vasilev. All rights reserved.
//

import UIKit
import AVVPNService

class SelectTypeController: UITableViewController {

    var interactor: Interactor?

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AVVPNType.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath)
        let type = AVVPNType.allCases[indexPath.row]
        cell.textLabel?.text = type.rawValue
        cell.accessoryType = interactor?.type == type ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactor?.type = AVVPNType.allCases[indexPath.row]
        tableView.reloadData()
    }
}
