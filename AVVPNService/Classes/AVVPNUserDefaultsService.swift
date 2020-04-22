//
//  AVVPNUserDefaultsService.swift
//  AVVPNService
//
//  Created by Andrey Vasilev on 22.04.2020.
//

import Foundation

class AVVPNUserDefaultsService {

    private static let key = "AVVPNUserDefaultsPreferencesKey"

    static var isPreferencesSaved: Bool {
        return UserDefaults.standard.bool(forKey: key) 
    }

    static func didSavePreferences() {
        UserDefaults.standard.set(true, forKey: key)
        UserDefaults.standard.synchronize()
    }

    static func didRemovePreferences() {
        UserDefaults.standard.set(false, forKey: key)
        UserDefaults.standard.synchronize()
    }
}
